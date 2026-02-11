const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('drawBridge', {
  startQ: () => ipcRenderer.invoke('q:start'),
  runQ: (code) => ipcRenderer.invoke('q:run', code),
  tickCanvasFrame: () => ipcRenderer.invoke('q:tick-canvas-frame'),
  stopQ: () => ipcRenderer.invoke('q:stop'),
  copyOutput: (text) => ipcRenderer.invoke('q:copy-output', text),
  saveOutput: (text, suggestedName) => ipcRenderer.invoke('q:save-output', text, suggestedName),
  pushInputEvent: (event) => ipcRenderer.send('input:event', event),
  onQDrawCommand: (handler) => {
    const wrapped = (_, cmd) => handler(cmd);
    ipcRenderer.on('q:draw-cmd', wrapped);
    return () => ipcRenderer.removeListener('q:draw-cmd', wrapped);
  },
  onQOutput: (handler) => {
    const wrapped = (_, text) => handler(text);
    ipcRenderer.on('q:output', wrapped);
    return () => ipcRenderer.removeListener('q:output', wrapped);
  }
});
