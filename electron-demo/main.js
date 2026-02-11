const { app, BrowserWindow, clipboard, dialog, ipcMain } = require('electron');
const { spawn, execFileSync } = require('child_process');
const fsSync = require('fs');
const fs = require('fs/promises');
const os = require('os');
const path = require('path');

let mainWindow = null;
let qProcess = null;
let stdoutBuffer = '';
let currentCommand = null;
let commandChain = Promise.resolve();
const Q_DRAW_CMD_PREFIX = 'RAYLIB_Q_CMD ';
const Q_CANVAS_FRAME_TICK = [
  'target:.[value;enlist `.draw.target.current;{`raylib}];',
  'if[target~`canvas;tick:.[value;enlist `.raylib.interactive.tick;{`missing}];if[not `missing~tick;.[tick;enlist(::);{0}]]];'
].join('\n');

const INPUT_QUEUE_CAP = 8192;
let inputQueue = [];
let inputDropped = 0;
let inputSeq = 1;

const gotSingleInstanceLock = app.requestSingleInstanceLock();
if (!gotSingleInstanceLock) {
  app.quit();
  process.exit(0);
}

function isExecutable(filePath) {
  if (!filePath) {
    return false;
  }
  try {
    fsSync.accessSync(filePath, fsSync.constants.X_OK);
    return true;
  } catch (_) {
    return false;
  }
}

function uniquePaths(paths) {
  const out = [];
  const seen = new Set();
  for (const p of paths) {
    if (!p || seen.has(p)) {
      continue;
    }
    seen.add(p);
    out.push(p);
  }
  return out;
}

function buildLaunchPath(basePath) {
  const home = os.homedir();
  return uniquePaths([
    path.join(home, '.kx/bin'),
    '/opt/homebrew/bin',
    '/opt/homebrew/sbin',
    '/usr/local/bin',
    '/usr/bin',
    '/bin',
    ...(basePath ? basePath.split(path.delimiter) : [])
  ]).join(path.delimiter);
}

function resolveQBinary() {
  const home = os.homedir();
  const envPath = buildLaunchPath(process.env.PATH || '');
  const envCandidates = [process.env.RAYLIB_Q_BIN, process.env.Q_BIN];
  const pathCandidates = envPath
    .split(path.delimiter)
    .filter(Boolean)
    .map((dir) => path.join(dir, 'q'));
  const fixedCandidates = [
    path.join(home, '.kx/bin/q'),
    '/opt/homebrew/bin/q',
    '/usr/local/bin/q',
    '/usr/bin/q'
  ];

  const candidates = uniquePaths([...envCandidates, ...pathCandidates, ...fixedCandidates]);
  for (const candidate of candidates) {
    if (isExecutable(candidate)) {
      return candidate;
    }
  }

  for (const shell of ['/bin/zsh', '/bin/bash']) {
    if (!isExecutable(shell)) {
      continue;
    }
    try {
      const discovered = execFileSync(shell, ['-lc', 'command -v q'], {
        encoding: 'utf8',
        stdio: ['ignore', 'pipe', 'ignore']
      }).trim();
      if (isExecutable(discovered)) {
        return discovered;
      }
    } catch (_) {
      // Keep trying fallbacks.
    }
  }

  return null;
}

function emitOutput(text) {
  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.webContents.send('q:output', text);
  }
}

function resetQState() {
  stdoutBuffer = '';
  currentCommand = null;
  commandChain = Promise.resolve();
}

function handleStdout(chunk) {
  stdoutBuffer += chunk.toString();
  const lines = stdoutBuffer.split('\n');
  stdoutBuffer = lines.pop() ?? '';

  for (const line of lines) {
    if (currentCommand && line === currentCommand.marker) {
      const done = currentCommand;
      currentCommand = null;
      done.resolve(done.output);
      continue;
    }

    if (line.startsWith(Q_DRAW_CMD_PREFIX)) {
      if (mainWindow && !mainWindow.isDestroyed()) {
        mainWindow.webContents.send('q:draw-cmd', line.slice(Q_DRAW_CMD_PREFIX.length));
      }
      continue;
    }

    if (currentCommand) {
      currentCommand.output += `${line}\n`;
    }
    emitOutput(`${line}\n`);
  }
}

function ensureQProcess() {
  if (qProcess && !qProcess.killed) {
    return;
  }

  const qBinary = resolveQBinary();
  if (!qBinary) {
    emitOutput('\n[q launcher error: could not find `q`. Set `RAYLIB_Q_BIN` or install q at ~/.kx/bin/q]\n');
    return;
  }

  qProcess = spawn(qBinary, ['-q'], {
    stdio: ['pipe', 'pipe', 'pipe'],
    env: {
      ...process.env,
      PATH: buildLaunchPath(process.env.PATH || ''),
      RAYLIB_Q_AUTO_PUMP: '0'
    }
  });

  qProcess.stdout.on('data', handleStdout);
  qProcess.stderr.on('data', (chunk) => emitOutput(chunk.toString()));

  qProcess.on('exit', (code, signal) => {
    if (currentCommand) {
      currentCommand.reject(new Error('q exited while command was running'));
      currentCommand = null;
    }
    emitOutput(`\n[q process exited: code=${code ?? 'null'} signal=${signal ?? 'null'}]\n`);
    qProcess = null;
    resetQState();
  });

  qProcess.on('error', (err) => {
    emitOutput(`\n[q process error: ${err.message}]\n`);
  });
}

function stopQProcess(force = false) {
  if (!qProcess || qProcess.killed) {
    qProcess = null;
    return;
  }
  try {
    qProcess.kill(force ? 'SIGKILL' : 'SIGTERM');
  } catch (_) {
    // Best-effort shutdown.
  }
  if (!force) {
    setTimeout(() => {
      if (qProcess && !qProcess.killed) {
        try {
          qProcess.kill('SIGKILL');
        } catch (_) {
          // Best-effort shutdown.
        }
      }
    }, 1200).unref();
  }
}

function toQEscapedString(text) {
  return text
    .replace(/\\/g, '\\\\')
    .replace(/\"/g, '\\\"')
    .replace(/\n/g, '\\n')
    .replace(/\r/g, '');
}

function enqueueInputEvent(payload) {
  if (!payload || typeof payload !== 'object') {
    return;
  }

  const event = {
    type: String(payload.type || ''),
    a: Number.isFinite(payload.a) ? Math.trunc(payload.a) : 0,
    b: Number.isFinite(payload.b) ? Math.trunc(payload.b) : 0,
    c: Number.isFinite(payload.c) ? Math.trunc(payload.c) : 0,
    d: Number.isFinite(payload.d) ? Math.trunc(payload.d) : 0,
    timeMs: Number.isFinite(payload.timeMs) ? Math.trunc(payload.timeMs) : Date.now()
  };

  if (!event.type) {
    return;
  }

  if (inputQueue.length >= INPUT_QUEUE_CAP) {
    inputQueue.shift();
    inputDropped += 1;
  }
  inputQueue.push(event);
}

function drainInputEventText() {
  if (inputQueue.length === 0 && inputDropped === 0) {
    return '';
  }

  const lines = [];
  if (inputDropped > 0) {
    lines.push(`${inputSeq++}|${Date.now()}|dropped|${inputDropped}|0|0|0`);
    inputDropped = 0;
  }

  for (const ev of inputQueue) {
    lines.push(`${inputSeq++}|${ev.timeMs}|${ev.type}|${ev.a}|${ev.b}|${ev.c}|${ev.d}`);
  }
  inputQueue = [];

  if (!lines.length) {
    return '';
  }
  return `${lines.join('\n')}\n`;
}

function buildEventBridgePreamble() {
  const blob = drainInputEventText();
  if (!blob.length) {
    return '';
  }

  const escapedBlob = toQEscapedString(blob);
  return [
    'if[10h<>type .[value;enlist `.electron.eventBlob;{::}]; .electron.eventBlob:""];',
    'if[10h<>type .[value;enlist `.electron.events.installed;{::}]; .electron.events.installed:0b];',
    'if[not .electron.events.installed; .electron.events.poll:{[] b:.electron.eventBlob; .electron.eventBlob:""; :b}; if[10h<>type .[value;enlist `.raylib.transport.events.poll;{::}]; .raylib.transport.events.poll:{[] b:.electron.events.poll[]; if[count b; :b]; n:.[value;enlist `.raylib.native.pollEvents;{::}]; :.[n;enlist(::);{""}]}; .raylib.transport.events.clear:{[] .electron.eventBlob:""; n:.[value;enlist `.raylib.native.clearEvents;{::}]; :.[n;enlist(::);{0}]}]; .electron.events.installed:1b];',
    `.electron.eventBlob,:"${escapedBlob}";`
  ].join('\n');
}

function runQueuedCommand(code) {
  commandChain = commandChain.then(
    () =>
      new Promise((resolve, reject) => {
        if (!qProcess || qProcess.killed || !qProcess.stdin.writable) {
          reject(new Error('q process is not writable'));
          return;
        }

        const marker = `__DRAW_DONE_${Date.now()}_${Math.random().toString(36).slice(2)}__`;
        currentCommand = { marker, output: '', resolve, reject };

        const preamble = buildEventBridgePreamble();
        if (preamble.length) {
          qProcess.stdin.write(`${preamble}\n`);
        }
        qProcess.stdin.write(`${code}\n`);
        qProcess.stdin.write(`-1 "${marker}";\n`);
      })
  );
  return commandChain;
}

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1360,
    height: 920,
    minWidth: 1080,
    minHeight: 720,
    backgroundColor: '#0f1419',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false
    }
  });

  mainWindow.loadFile(path.join(__dirname, 'renderer/index.html'));
}

app.whenReady().then(() => {
  createWindow();
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('second-instance', () => {
  if (!mainWindow || mainWindow.isDestroyed()) {
    return;
  }
  if (mainWindow.isMinimized()) {
    mainWindow.restore();
  }
  mainWindow.focus();
});

app.on('window-all-closed', () => {
  stopQProcess(true);
  app.quit();
});

app.on('before-quit', () => {
  stopQProcess(true);
});

app.on('will-quit', () => {
  stopQProcess(true);
});

process.on('SIGINT', () => {
  stopQProcess(true);
  app.quit();
});

process.on('SIGTERM', () => {
  stopQProcess(true);
  app.quit();
});

ipcMain.handle('q:start', async () => {
  ensureQProcess();
  return { ok: !!qProcess };
});

ipcMain.handle('q:run', async (_, code) => {
  try {
    ensureQProcess();
    const output = await runQueuedCommand(code);
    return { ok: true, output };
  } catch (err) {
    return { ok: false, message: err.message };
  }
});

ipcMain.handle('q:tick-canvas-frame', async () => {
  try {
    if (!qProcess || qProcess.killed) {
      return { ok: false, message: 'q process is not running' };
    }
    await runQueuedCommand(Q_CANVAS_FRAME_TICK);
    return { ok: true };
  } catch (err) {
    return { ok: false, message: err.message };
  }
});

ipcMain.handle('q:stop', async () => {
  stopQProcess();
  qProcess = null;
  resetQState();
  return { ok: true };
});

ipcMain.on('input:event', (_, payload) => {
  enqueueInputEvent(payload);
});

ipcMain.handle('q:copy-output', async (_, text) => {
  clipboard.writeText(String(text ?? ''));
  return { ok: true };
});

ipcMain.handle('q:save-output', async (_, text, suggestedName) => {
  const defaultPath = path.join(app.getPath('documents'), suggestedName || `q-output-${Date.now()}.log`);
  const result = await dialog.showSaveDialog({
    title: 'Save q output',
    defaultPath,
    filters: [
      { name: 'Log files', extensions: ['log', 'txt'] },
      { name: 'All files', extensions: ['*'] }
    ]
  });

  if (result.canceled || !result.filePath) {
    return { ok: false, canceled: true };
  }

  await fs.writeFile(result.filePath, String(text ?? ''), 'utf8');
  return { ok: true, path: result.filePath };
});
