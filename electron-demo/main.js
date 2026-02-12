const { app, BrowserWindow, clipboard, dialog, ipcMain } = require('electron');
const { spawn, execFileSync } = require('child_process');
const fsSync = require('fs');
const fs = require('fs/promises');
const os = require('os');
const path = require('path');

const Q_DRAW_CMD_PREFIX = 'RAYLIB_Q_CMD ';
const Q_CANVAS_FRAME_TICK = [
  'target:.[value;enlist `.draw.target.current;{`raylib}];',
  'if[target~`canvas;tick:.[value;enlist `.raylib.interactive.tick;{`missing}];if[not `missing~tick;.[tick;enlist(::);{0}]]];'
].join('\n');

const INPUT_QUEUE_CAP = 8192;
const FORCE_KILL_DELAY_MS = 1200;
const COMMAND_TIMEOUT_MS = 8000;

let mainWindow = null;
let qProcess = null;
let stdoutBuffer = '';
let currentCommand = null;
let commandChain = Promise.resolve();

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

function emitDrawCommand(command) {
  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.webContents.send('q:draw-cmd', command);
  }
}

function toErrorMessage(err, fallback = 'unknown error') {
  if (err instanceof Error && err.message) {
    return err.message;
  }
  if (typeof err === 'string' && err.length) {
    return err;
  }
  if (err && typeof err === 'object') {
    try {
      const msg = String(err.message || '').trim();
      if (msg.length) {
        return msg;
      }
      const serialized = JSON.stringify(err);
      if (serialized && serialized !== '{}') {
        return serialized;
      }
    } catch (_) {
      // Best-effort fallback below.
    }
  }
  return fallback;
}

function settleCurrentCommand(resolveOk, value) {
  if (!currentCommand) {
    return;
  }
  const done = currentCommand;
  currentCommand = null;
  if (done.timeoutId) {
    clearTimeout(done.timeoutId);
  }
  if (done.settled) {
    return;
  }
  done.settled = true;
  if (resolveOk) {
    done.resolve(value);
    return;
  }
  const err = value instanceof Error ? value : new Error(toErrorMessage(value, 'q command failed'));
  done.reject(err);
}

function resetQState() {
  settleCurrentCommand(false, new Error('q state reset while command was running'));
  stdoutBuffer = '';
  commandChain = Promise.resolve();
}

function handleStdout(chunk) {
  stdoutBuffer += chunk.toString();
  const lines = stdoutBuffer.split('\n');
  stdoutBuffer = lines.pop() ?? '';

  for (const line of lines) {
    if (currentCommand && line === currentCommand.marker) {
      settleCurrentCommand(true, currentCommand.output);
      continue;
    }

    if (line.startsWith(Q_DRAW_CMD_PREFIX)) {
      emitDrawCommand(line.slice(Q_DRAW_CMD_PREFIX.length));
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
      // Renderer drives pumping manually via q:tick-canvas-frame.
      RAYLIB_Q_AUTO_PUMP: '0'
    }
  });

  qProcess.stdout.on('data', handleStdout);
  qProcess.stderr.on('data', (chunk) => emitOutput(chunk.toString()));
  qProcess.stdin.on('error', (err) => settleCurrentCommand(false, err));

  qProcess.on('exit', (code, signal) => {
    settleCurrentCommand(false, new Error('q exited while command was running'));
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
    }, FORCE_KILL_DELAY_MS).unref();
  }
}

function toQEscapedString(text) {
  return text.replace(/\\/g, '\\\\').replace(/\"/g, '\\"').replace(/\n/g, '\\n').replace(/\r/g, '');
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

  return lines.length ? `${lines.join('\n')}\n` : '';
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
  commandChain = commandChain.catch(() => undefined).then(
    () =>
      new Promise((resolve, reject) => {
        if (!qProcess || qProcess.killed || !qProcess.stdin.writable) {
          reject(new Error('q process is not writable'));
          return;
        }

        // Marker handshake lets us capture only command-local output even while
        // the shared q process is receiving async renderer events.
        const marker = `__DRAW_DONE_${Date.now()}_${Math.random().toString(36).slice(2)}__`;
        if (currentCommand) {
          settleCurrentCommand(false, new Error('previous q command was interrupted'));
        }
        currentCommand = { marker, output: '', resolve, reject, settled: false, timeoutId: null };
        currentCommand.timeoutId = setTimeout(() => {
          if (!currentCommand || currentCommand.marker !== marker) {
            return;
          }
          settleCurrentCommand(false, new Error(`q command timed out after ${COMMAND_TIMEOUT_MS}ms`));
        }, COMMAND_TIMEOUT_MS);
        currentCommand.timeoutId.unref?.();

        const preamble = buildEventBridgePreamble();
        try {
          if (preamble.length) {
            qProcess.stdin.write(`${preamble}\n`);
          }
          qProcess.stdin.write(`${code}\n`);
          qProcess.stdin.write(`-1 "${marker}";\n`);
        } catch (err) {
          settleCurrentCommand(false, err);
        }
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

function focusMainWindow() {
  if (!mainWindow || mainWindow.isDestroyed()) {
    return;
  }
  if (mainWindow.isMinimized()) {
    mainWindow.restore();
  }
  mainWindow.focus();
}

function shutdownAndQuit() {
  stopQProcess(true);
  app.quit();
}

function runIpcTask(task) {
  return async (...args) => {
    try {
      return await task(...args);
    } catch (err) {
      return { ok: false, message: toErrorMessage(err) };
    }
  };
}

process.on('uncaughtException', (err) => {
  emitOutput(`\n[main uncaught exception: ${toErrorMessage(err)}]\n`);
});

process.on('unhandledRejection', (reason) => {
  emitOutput(`\n[main unhandled rejection: ${toErrorMessage(reason)}]\n`);
});

app.whenReady().then(() => {
  createWindow();
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('second-instance', focusMainWindow);

app.on('window-all-closed', shutdownAndQuit);
app.on('before-quit', () => stopQProcess(true));
app.on('will-quit', () => stopQProcess(true));

process.on('SIGINT', shutdownAndQuit);
process.on('SIGTERM', shutdownAndQuit);

ipcMain.handle(
  'q:start',
  runIpcTask(async () => {
    ensureQProcess();
    return { ok: !!qProcess };
  })
);

ipcMain.handle(
  'q:run',
  runIpcTask(async (_, code) => {
    ensureQProcess();
    const output = await runQueuedCommand(code);
    return { ok: true, output };
  })
);

ipcMain.handle(
  'q:tick-canvas-frame',
  runIpcTask(async () => {
    if (!qProcess || qProcess.killed) {
      return { ok: false, message: 'q process is not running' };
    }
    await runQueuedCommand(Q_CANVAS_FRAME_TICK);
    return { ok: true };
  })
);

ipcMain.handle(
  'q:stop',
  runIpcTask(async () => {
    stopQProcess();
    qProcess = null;
    resetQState();
    return { ok: true };
  })
);

ipcMain.on('input:event', (_, payload) => {
  enqueueInputEvent(payload);
});

ipcMain.handle(
  'q:copy-output',
  runIpcTask(async (_, text) => {
    clipboard.writeText(String(text ?? ''));
    return { ok: true };
  })
);

ipcMain.handle(
  'q:save-output',
  runIpcTask(async (_, text, suggestedName) => {
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
  })
);
