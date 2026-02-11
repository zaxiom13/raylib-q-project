(function () {
  function createCanvasRuntime(opts) {
    const canvas = opts.canvas;
    const sceneStatus = opts.sceneStatus;
    const ctx = canvas.getContext('2d');
    const pushInputEvent = opts.pushInputEvent;

    const raylibMouseButtons = window.RAYLIB_MOUSE_BUTTONS || { 0: 0, 1: 2, 2: 1, 3: 3, 4: 4 };
    const raylibKeyByCode = window.RAYLIB_KEY_BY_CODE || {};

    let currentTarget = 'canvas';
    let lastPointer = { x: 0, y: 0 };
    let dirty = true;
    const state = window.CanvasRuntimeState.createSceneState();

    function clearCanvas() {
      window.CanvasRuntimeRender.drawBackground(ctx, canvas);
    }

    function renderIfNeeded(nowMs) {
      const moved = window.CanvasRuntimeState.advanceAnimations(state, nowMs);
      const active = window.CanvasRuntimeState.hasActiveAnimations(state);
      if (!dirty && !moved && !active) {
        return;
      }
      window.CanvasRuntimeRender.renderScene(ctx, canvas, state, nowMs);
      dirty = false;
    }

    function applyQDrawCommand(line) {
      const cmd = window.CanvasRuntimeCore.parseQDrawCommand(line);
      if (!cmd) {
        return;
      }

      const changed = window.CanvasRuntimeState.applyCommand(state, cmd, Date.now());
      if (!changed) {
        return;
      }

      dirty = true;
      if (currentTarget !== 'raylib') {
        renderIfNeeded(Date.now());
        sceneStatus.textContent = `Scene: rendered from q commands to ${currentTarget} target`;
      }
    }

    function getCanvasPosition(ev) {
      const rect = canvas.getBoundingClientRect();
      if (rect.width === 0 || rect.height === 0) {
        return null;
      }

      const sx = canvas.width / rect.width;
      const sy = canvas.height / rect.height;
      const x = Math.round((ev.clientX - rect.left) * sx);
      const y = Math.round((ev.clientY - rect.top) * sy);
      return {
        x: Math.max(0, Math.min(canvas.width, x)),
        y: Math.max(0, Math.min(canvas.height, y))
      };
    }

    function keyToRaylibCode(ev) {
      if (Object.prototype.hasOwnProperty.call(raylibKeyByCode, ev.code)) {
        return raylibKeyByCode[ev.code];
      }

      if (/^Digit[0-9]$/.test(ev.code)) {
        return ev.code.charCodeAt(ev.code.length - 1);
      }

      if (/^Key[A-Z]$/.test(ev.code)) {
        return ev.code.charCodeAt(ev.code.length - 1);
      }

      return Number.isFinite(ev.keyCode) ? ev.keyCode : 0;
    }

    function installInputBridge() {
      canvas.tabIndex = 0;

      canvas.addEventListener('pointermove', (ev) => {
        const pos = getCanvasPosition(ev);
        if (!pos) {
          return;
        }

        const dx = pos.x - lastPointer.x;
        const dy = pos.y - lastPointer.y;
        lastPointer = pos;
        pushInputEvent('mouse_move', pos.x, pos.y, dx, dy);
        pushInputEvent('mouse_state', pos.x, pos.y, dx, dy);
      });

      canvas.addEventListener('pointerdown', (ev) => {
        const pos = getCanvasPosition(ev);
        if (!pos) {
          return;
        }

        canvas.focus();
        lastPointer = pos;
        const button = raylibMouseButtons[ev.button] ?? 0;
        pushInputEvent('mouse_down', button, pos.x, pos.y, 0);
        pushInputEvent('mouse_state', pos.x, pos.y, 0, 0);
      });

      canvas.addEventListener('pointerup', (ev) => {
        const pos = getCanvasPosition(ev);
        if (!pos) {
          return;
        }

        lastPointer = pos;
        const button = raylibMouseButtons[ev.button] ?? 0;
        pushInputEvent('mouse_up', button, pos.x, pos.y, 0);
        pushInputEvent('mouse_state', pos.x, pos.y, 0, 0);
      });

      canvas.addEventListener(
        'wheel',
        (ev) => {
          const pos = getCanvasPosition(ev);
          if (!pos) {
            return;
          }

          ev.preventDefault();
          lastPointer = pos;
          const scaled = Math.round((-ev.deltaY / 120) * 1000);
          pushInputEvent('mouse_wheel', scaled, pos.x, pos.y, 0);
        },
        { passive: false }
      );

      canvas.addEventListener('keydown', (ev) => {
        const key = keyToRaylibCode(ev);
        if (key > 0) {
          pushInputEvent('key_down', key, 0, 0, 0);
        }
        if (ev.key && ev.key.length === 1) {
          pushInputEvent('char_input', ev.key.codePointAt(0), 0, 0, 0);
        }
      });

      canvas.addEventListener('keyup', (ev) => {
        const key = keyToRaylibCode(ev);
        if (key > 0) {
          pushInputEvent('key_up', key, 0, 0, 0);
        }
      });

      window.addEventListener('focus', () => pushInputEvent('window_focus', 1, 0, 0, 0));
      window.addEventListener('blur', () => pushInputEvent('window_focus', 0, 0, 0, 0));
      window.addEventListener('resize', () => {
        pushInputEvent('window_resize', window.innerWidth, window.innerHeight, 0, 0);
      });
    }

    function setTarget(target) {
      currentTarget = target;
      canvas.classList.toggle('hidden', target !== 'canvas');
      sceneStatus.textContent = `Scene: target ${target}`;
      if (target !== 'raylib') {
        dirty = true;
        renderIfNeeded(Date.now());
      }
    }

    function renderLoop() {
      if (currentTarget === 'canvas') {
        renderIfNeeded(Date.now());
      }
      window.requestAnimationFrame(renderLoop);
    }
    window.requestAnimationFrame(renderLoop);

    return {
      applyQDrawCommand,
      clearCanvas,
      installInputBridge,
      setTarget
    };
  }

  window.createCanvasRuntime = createCanvasRuntime;
})();
