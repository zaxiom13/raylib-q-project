const canvas = document.getElementById('canvasStage');
const qInput = document.getElementById('qInput');
const qOutput = document.getElementById('qOutput');
const sceneStatus = document.getElementById('sceneStatus');
const qStatus = document.getElementById('qStatus');
const targetSelect = document.getElementById('targetSelect');

const MAX_OUTPUT_CHARS = 300000;
const MAX_HISTORY_ITEMS = 200;

let currentTarget = 'canvas';
let outputText = '';
let commandHistory = [];
let historyIndex = 0;
let historyDraft = '';
let qRunning = false;
let frameTickInFlight = false;
let lastFrameTickError = '';
let lastFrameTickErrorMs = 0;

const canvasRuntime = window.createCanvasRuntime({
  canvas,
  sceneStatus,
  pushInputEvent: (type, a = 0, b = 0, c = 0, d = 0) => {
    window.drawBridge.pushInputEvent({
      type,
      a: Math.trunc(a),
      b: Math.trunc(b),
      c: Math.trunc(c),
      d: Math.trunc(d),
      timeMs: Date.now()
    });
  }
});

function scrollOutputToBottom() {
  qOutput.scrollTop = qOutput.scrollHeight;
}

function setOutput(text) {
  outputText = text;
  qOutput.textContent = outputText;
  scrollOutputToBottom();
}

function appendOutput(text) {
  if (!text) {
    return;
  }

  outputText += text;
  if (outputText.length > MAX_OUTPUT_CHARS) {
    outputText = outputText.slice(-MAX_OUTPUT_CHARS);
  }

  qOutput.textContent = outputText;
  scrollOutputToBottom();
}

function clearOutput() {
  setOutput('');
}

function nowTag() {
  return new Date().toLocaleTimeString();
}

function appendSystem(text) {
  appendOutput(`[console ${nowTag()}] ${text}\n`);
}

function appendError(text) {
  appendOutput(`[error] ${text}\n`);
}

function appendPrompt(code) {
  appendOutput(`\nq> ${code}\n`);
}

function pushHistory(code) {
  if (!code) {
    return;
  }
  const previous = commandHistory[commandHistory.length - 1];
  if (previous !== code) {
    commandHistory.push(code);
    if (commandHistory.length > MAX_HISTORY_ITEMS) {
      commandHistory = commandHistory.slice(commandHistory.length - MAX_HISTORY_ITEMS);
    }
  }
  historyIndex = commandHistory.length;
  historyDraft = '';
}

function isCursorOnFirstLine(el) {
  return el.value.slice(0, el.selectionStart).indexOf('\n') === -1;
}

function isCursorOnLastLine(el) {
  return el.value.slice(el.selectionEnd).indexOf('\n') === -1;
}

function loadHistory(direction) {
  if (!commandHistory.length) {
    return;
  }

  if (historyIndex === commandHistory.length) {
    historyDraft = qInput.value;
  }

  historyIndex = Math.max(0, Math.min(commandHistory.length, historyIndex + direction));
  qInput.value = historyIndex === commandHistory.length ? historyDraft : commandHistory[historyIndex];
  qInput.selectionStart = qInput.value.length;
  qInput.selectionEnd = qInput.value.length;
}

function qTargetLiteral(target) {
  return target === 'raylib' ? '`raylib' : '`canvas';
}

async function startQ() {
  const res = await window.drawBridge.startQ();
  qRunning = !!res.ok;
  qStatus.textContent = res.ok ? 'q: running' : 'q: failed';
  if (!res.ok && res.message) {
    appendError(res.message);
  }
  return res.ok;
}

async function runQ(code) {
  const result = await window.drawBridge.runQ(code);
  if (!result.ok) {
    appendError(result.message);
  }
  return result.ok;
}

async function syncDrawTarget(target) {
  const ok = await startQ();
  if (!ok) {
    return false;
  }
  return runQ(`.draw.target.set[${qTargetLiteral(target)}]`);
}

function appendFrameTickError(message) {
  const msg = String(message || 'canvas frame tick failed');
  const now = Date.now();
  if (msg === lastFrameTickError && now - lastFrameTickErrorMs < 2000) {
    return;
  }
  lastFrameTickError = msg;
  lastFrameTickErrorMs = now;
  appendError(`[frame] ${msg}`);
}

async function tickCanvasFrame() {
  if (currentTarget !== 'canvas' || !qRunning || frameTickInFlight) {
    return;
  }

  frameTickInFlight = true;
  try {
    const result = await window.drawBridge.tickCanvasFrame();
    if (!result.ok) {
      qRunning = false;
      qStatus.textContent = 'q: stopped';
      appendFrameTickError(result.message);
    }
  } finally {
    frameTickInFlight = false;
  }
}

function installCanvasFrameTicker() {
  const loop = () => {
    tickCanvasFrame().catch((err) => appendFrameTickError(err.message));
    window.requestAnimationFrame(loop);
  };
  window.requestAnimationFrame(loop);
}

async function copyOutput() {
  const result = await window.drawBridge.copyOutput(outputText);
  if (result.ok) {
    appendSystem('Copied output to clipboard.');
  }
}

async function saveOutput() {
  const date = new Date().toISOString().slice(0, 19).replace(/[:T]/g, '-');
  const result = await window.drawBridge.saveOutput(outputText, `q-output-${date}.log`);
  if (result.ok) {
    appendSystem(`Saved output to ${result.path}`);
  } else if (!result.canceled) {
    appendError('Could not save output.');
  }
}

function showTarget(target) {
  currentTarget = target;
  canvasRuntime.setTarget(target);
  syncDrawTarget(target).catch((err) => appendError(`[target] ${err.message}`));
}

function printConsoleHelp() {
  appendOutput('\n');
  appendOutput(':help                 show console commands\n');
  appendOutput(':clear or :cls        clear output pane\n');
  appendOutput(':copy                 copy output to clipboard\n');
  appendOutput(':save                 save output to a file\n');
  appendOutput(':history              show command history\n');
  appendOutput(':target canvas|raylib switch render target\n\n');
}

async function runConsoleCommand(code) {
  if (!code.startsWith(':')) {
    return false;
  }

  const parts = code.split(/\s+/);
  const cmd = parts[0].toLowerCase();

  if (cmd === ':help') {
    printConsoleHelp();
    return true;
  }

  if (cmd === ':clear' || cmd === ':cls') {
    clearOutput();
    appendSystem('Output cleared.');
    return true;
  }

  if (cmd === ':copy') {
    await copyOutput();
    return true;
  }

  if (cmd === ':save') {
    await saveOutput();
    return true;
  }

  if (cmd === ':history') {
    if (!commandHistory.length) {
      appendSystem('History is empty.');
      return true;
    }
    appendOutput(`\n${commandHistory.map((line, i) => `${i + 1}. ${line}`).join('\n')}\n\n`);
    return true;
  }

  if (cmd === ':target') {
    const target = (parts[1] || '').toLowerCase();
    if (target !== 'canvas' && target !== 'raylib') {
      appendError('usage: :target canvas|raylib');
      return true;
    }
    targetSelect.value = target;
    showTarget(target);
    appendSystem(`Render target set to ${target}.`);
    return true;
  }

  appendError(`unknown console command: ${code} (use :help)`);
  return true;
}

async function sendCommand() {
  const code = qInput.value.trim();
  if (!code) {
    return;
  }

  pushHistory(code);
  qInput.value = '';

  if (await runConsoleCommand(code)) {
    return;
  }

  appendPrompt(code);
  await syncDrawTarget(currentTarget);
  await startQ();
  await runQ(code);
}

async function stopQ() {
  await window.drawBridge.stopQ();
  qRunning = false;
  qStatus.textContent = 'q: stopped';
  appendSystem('q process stopped.');
}

function installReplInputHandlers() {
  qInput.addEventListener('keydown', (ev) => {
    if (ev.key === 'Enter' && !ev.shiftKey) {
      ev.preventDefault();
      sendCommand().catch((err) => appendError(`[q] ${err.message}`));
      return;
    }

    if (ev.key === 'ArrowUp' && isCursorOnFirstLine(qInput)) {
      ev.preventDefault();
      loadHistory(-1);
      return;
    }

    if (ev.key === 'ArrowDown' && isCursorOnLastLine(qInput)) {
      ev.preventDefault();
      loadHistory(1);
    }
  });

  document.addEventListener('keydown', (ev) => {
    if (!ev.ctrlKey && !ev.metaKey) {
      return;
    }

    const key = ev.key.toLowerCase();
    if (key === 'l') {
      ev.preventDefault();
      clearOutput();
      appendSystem('Output cleared.');
      return;
    }

    if (key === 's') {
      ev.preventDefault();
      saveOutput().catch((err) => appendError(err.message));
      return;
    }

    if (key === 'k') {
      ev.preventDefault();
      qInput.value = '';
      return;
    }

    if (key === 'c' && ev.shiftKey) {
      ev.preventDefault();
      copyOutput().catch((err) => appendError(err.message));
    }
  });
}

document.getElementById('startQ').addEventListener('click', startQ);
document.getElementById('stopQ').addEventListener('click', stopQ);
document.getElementById('sendCmd').addEventListener('click', () => {
  sendCommand().catch((err) => appendError(`[q] ${err.message}`));
});
document.getElementById('clearOutput').addEventListener('click', () => {
  clearOutput();
  appendSystem('Output cleared.');
});
document.getElementById('copyOutput').addEventListener('click', () => {
  copyOutput().catch((err) => appendError(err.message));
});
document.getElementById('saveOutput').addEventListener('click', () => {
  saveOutput().catch((err) => appendError(err.message));
});
document.getElementById('clearInput').addEventListener('click', () => {
  qInput.value = '';
  qInput.focus();
});
targetSelect.addEventListener('change', (ev) => showTarget(ev.target.value));

window.drawBridge.onQOutput((text) => appendOutput(text));
window.drawBridge.onQDrawCommand((cmd) => canvasRuntime.applyQDrawCommand(cmd));
canvasRuntime.installInputBridge();
installReplInputHandlers();
installCanvasFrameTicker();

showTarget('canvas');
canvasRuntime.clearCanvas();
sceneStatus.textContent = 'Scene: waiting for q draw commands';
appendSystem('REPL ready. Use :help for console commands.');
