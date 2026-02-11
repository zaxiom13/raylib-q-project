const canvas = document.getElementById('canvasStage');
const qInput = document.getElementById('qInput');
const qOutput = document.getElementById('qOutput');
const sceneStatus = document.getElementById('sceneStatus');
const qStatus = document.getElementById('qStatus');
const targetSelect = document.getElementById('targetSelect');
const consoleTabBtn = document.getElementById('consoleTabBtn');
const examplesTabBtn = document.getElementById('examplesTabBtn');
const consoleTabPanel = document.getElementById('consoleTabPanel');
const examplesTabPanel = document.getElementById('examplesTabPanel');
const examplesList = document.getElementById('examplesList');

const MAX_OUTPUT_CHARS = 300000;
const MAX_HISTORY_ITEMS = 200;
const FRAME_ERROR_DEDUPE_MS = 2000;
const TUTORIAL_EXAMPLES = Array.isArray(window.TUTORIAL_EXAMPLES) ? window.TUTORIAL_EXAMPLES : [];

const state = {
  currentTarget: 'canvas',
  outputText: '',
  commandHistory: [],
  historyIndex: 0,
  historyDraft: '',
  qRunning: false,
  frameTickInFlight: false,
  lastFrameTickError: '',
  lastFrameTickErrorMs: 0
};

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
  state.outputText = String(text ?? '');
  qOutput.textContent = state.outputText;
  scrollOutputToBottom();
}

function appendOutput(text) {
  if (!text) {
    return;
  }

  state.outputText += text;
  if (state.outputText.length > MAX_OUTPUT_CHARS) {
    state.outputText = state.outputText.slice(-MAX_OUTPUT_CHARS);
  }

  qOutput.textContent = state.outputText;
  scrollOutputToBottom();
}

function clearOutput() {
  setOutput('');
}

function appendSystem(text) {
  appendOutput(`[console ${new Date().toLocaleTimeString()}] ${text}\n`);
}

function appendError(text) {
  appendOutput(`[error] ${text}\n`);
}

function appendPrompt(code) {
  appendOutput(`\nq> ${code}\n`);
}

function clearOutputAndNotify() {
  clearOutput();
  appendSystem('Output cleared.');
}

function pushHistory(code) {
  if (!code) {
    return;
  }

  const previous = state.commandHistory[state.commandHistory.length - 1];
  if (previous !== code) {
    state.commandHistory.push(code);
    if (state.commandHistory.length > MAX_HISTORY_ITEMS) {
      state.commandHistory = state.commandHistory.slice(state.commandHistory.length - MAX_HISTORY_ITEMS);
    }
  }
  state.historyIndex = state.commandHistory.length;
  state.historyDraft = '';
}

function isCursorOnFirstLine(el) {
  return el.value.slice(0, el.selectionStart).indexOf('\n') === -1;
}

function isCursorOnLastLine(el) {
  return el.value.slice(el.selectionEnd).indexOf('\n') === -1;
}

function loadHistory(direction) {
  if (!state.commandHistory.length) {
    return;
  }

  if (state.historyIndex === state.commandHistory.length) {
    state.historyDraft = qInput.value;
  }

  state.historyIndex = Math.max(0, Math.min(state.commandHistory.length, state.historyIndex + direction));
  qInput.value = state.historyIndex === state.commandHistory.length ? state.historyDraft : state.commandHistory[state.historyIndex];
  qInput.selectionStart = qInput.value.length;
  qInput.selectionEnd = qInput.value.length;
}

function qTargetLiteral(target) {
  return target === 'raylib' ? '`raylib' : '`canvas';
}

function switchConsoleTab(tabName) {
  const showExamples = tabName === 'examples';
  if (!consoleTabBtn || !examplesTabBtn || !consoleTabPanel || !examplesTabPanel) {
    return;
  }

  consoleTabBtn.classList.toggle('active', !showExamples);
  examplesTabBtn.classList.toggle('active', showExamples);
  consoleTabBtn.setAttribute('aria-selected', showExamples ? 'false' : 'true');
  examplesTabBtn.setAttribute('aria-selected', showExamples ? 'true' : 'false');
  consoleTabPanel.classList.toggle('active', !showExamples);
  examplesTabPanel.classList.toggle('active', showExamples);

  if (!showExamples) {
    qInput.focus();
  }
}

function appendSnippetToInput(snippet) {
  const code = String(snippet || '').trim();
  if (!code) {
    return;
  }

  const existing = qInput.value;
  const hasExisting = existing.trim().length > 0;
  const separator = hasExisting ? (existing.endsWith('\n') ? '\n' : '\n\n') : '';
  qInput.value = `${existing}${separator}${code}`;
  qInput.selectionStart = qInput.value.length;
  qInput.selectionEnd = qInput.value.length;
}

function renderExamples() {
  if (!examplesList) {
    return;
  }
  if (!TUTORIAL_EXAMPLES.length) {
    examplesList.textContent = 'No tutorial examples available.';
    return;
  }

  const frag = document.createDocumentFragment();
  for (const sample of TUTORIAL_EXAMPLES) {
    const card = document.createElement('article');
    card.className = 'example-card';

    const head = document.createElement('div');
    head.className = 'example-head';

    const title = document.createElement('h3');
    title.className = 'example-title';
    title.textContent = sample.title || 'Untitled example';

    const badge = document.createElement('span');
    badge.className = 'example-category';
    badge.textContent = sample.category || 'Example';

    const description = document.createElement('p');
    description.className = 'example-description';
    description.textContent = sample.description || '';

    const code = document.createElement('pre');
    code.className = 'example-code';
    code.textContent = sample.code || '';

    const insertBtn = document.createElement('button');
    insertBtn.type = 'button';
    insertBtn.className = 'insert-example';
    insertBtn.textContent = 'Insert into command';
    insertBtn.addEventListener('click', () => {
      appendSnippetToInput(sample.code || '');
      appendSystem(`Added example: ${sample.title || 'snippet'} (not run yet).`);
      switchConsoleTab('console');
    });

    head.append(title, badge);
    card.append(head, description, code, insertBtn);
    frag.append(card);
  }
  examplesList.innerHTML = '';
  examplesList.append(frag);
}

function setQStatusText(statusText) {
  qStatus.textContent = statusText;
}

async function startQ() {
  const res = await window.drawBridge.startQ();
  state.qRunning = !!res.ok;
  setQStatusText(res.ok ? 'q: running' : 'q: failed');
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

  // Frame tick errors can repeat every animation frame while q is down.
  if (msg === state.lastFrameTickError && now - state.lastFrameTickErrorMs < FRAME_ERROR_DEDUPE_MS) {
    return;
  }

  state.lastFrameTickError = msg;
  state.lastFrameTickErrorMs = now;
  appendError(`[frame] ${msg}`);
}

async function tickCanvasFrame() {
  if (state.currentTarget !== 'canvas' || !state.qRunning || state.frameTickInFlight) {
    return;
  }

  state.frameTickInFlight = true;
  try {
    const result = await window.drawBridge.tickCanvasFrame();
    if (!result.ok) {
      state.qRunning = false;
      setQStatusText('q: stopped');
      appendFrameTickError(result.message);
    }
  } finally {
    state.frameTickInFlight = false;
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
  const result = await window.drawBridge.copyOutput(state.outputText);
  if (result.ok) {
    appendSystem('Copied output to clipboard.');
  }
}

async function saveOutput() {
  const date = new Date().toISOString().slice(0, 19).replace(/[:T]/g, '-');
  const result = await window.drawBridge.saveOutput(state.outputText, `q-output-${date}.log`);
  if (result.ok) {
    appendSystem(`Saved output to ${result.path}`);
  } else if (!result.canceled) {
    appendError('Could not save output.');
  }
}

function setTarget(target) {
  state.currentTarget = target;
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

const CONSOLE_COMMAND_ALIASES = {
  ':cls': ':clear'
};

const CONSOLE_COMMAND_HANDLERS = {
  ':help': async () => {
    printConsoleHelp();
    return true;
  },
  ':clear': async () => {
    clearOutputAndNotify();
    return true;
  },
  ':copy': async () => {
    await copyOutput();
    return true;
  },
  ':save': async () => {
    await saveOutput();
    return true;
  },
  ':history': async () => {
    if (!state.commandHistory.length) {
      appendSystem('History is empty.');
      return true;
    }
    appendOutput(`\n${state.commandHistory.map((line, i) => `${i + 1}. ${line}`).join('\n')}\n\n`);
    return true;
  },
  ':target': async (parts) => {
    const target = (parts[1] || '').toLowerCase();
    if (target !== 'canvas' && target !== 'raylib') {
      appendError('usage: :target canvas|raylib');
      return true;
    }
    targetSelect.value = target;
    setTarget(target);
    appendSystem(`Render target set to ${target}.`);
    return true;
  }
};

async function runConsoleCommand(code) {
  if (!code.startsWith(':')) {
    return false;
  }

  const parts = code.split(/\s+/);
  const rawCommand = (parts[0] || '').toLowerCase();
  const command = CONSOLE_COMMAND_ALIASES[rawCommand] || rawCommand;
  const handler = CONSOLE_COMMAND_HANDLERS[command];
  if (!handler) {
    appendError(`unknown console command: ${code} (use :help)`);
    return true;
  }

  return handler(parts, code);
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
  const started = await startQ();
  if (!started) {
    return;
  }
  await runQ(`.draw.target.set[${qTargetLiteral(state.currentTarget)}]`);
  await runQ(code);
}

async function stopQ() {
  await window.drawBridge.stopQ();
  state.qRunning = false;
  setQStatusText('q: stopped');
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
      clearOutputAndNotify();
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

function bindClick(id, handler, errorPrefix = '') {
  const el = document.getElementById(id);
  if (!el) {
    return;
  }
  el.addEventListener('click', () => {
    Promise.resolve(handler()).catch((err) => appendError(`${errorPrefix}${err.message}`));
  });
}

bindClick('startQ', () => startQ());
bindClick('stopQ', () => stopQ());
bindClick('sendCmd', () => sendCommand(), '[q] ');
bindClick('clearOutput', () => clearOutputAndNotify());
bindClick('copyOutput', () => copyOutput());
bindClick('saveOutput', () => saveOutput());
bindClick('clearInput', () => {
  qInput.value = '';
  qInput.focus();
});

targetSelect.addEventListener('change', (ev) => setTarget(ev.target.value));
if (consoleTabBtn) {
  consoleTabBtn.addEventListener('click', () => switchConsoleTab('console'));
}
if (examplesTabBtn) {
  examplesTabBtn.addEventListener('click', () => switchConsoleTab('examples'));
}

window.drawBridge.onQOutput((text) => appendOutput(text));
window.drawBridge.onQDrawCommand((cmd) => canvasRuntime.applyQDrawCommand(cmd));
canvasRuntime.installInputBridge();
installReplInputHandlers();
installCanvasFrameTicker();
renderExamples();
switchConsoleTab('console');

setTarget('canvas');
canvasRuntime.clearCanvas();
sceneStatus.textContent = 'Scene: waiting for q draw commands';
appendSystem('REPL ready. Use :help for console commands.');
