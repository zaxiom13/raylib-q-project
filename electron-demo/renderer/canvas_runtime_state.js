(function () {
  function createAnimTrack() {
    return {
      frames: [],
      playing: false,
      frame: 0,
      frameStartedAtMs: 0
    };
  }

  function createAnimPixelsTrack() {
    return {
      rects: [],
      frameCount: 0,
      rateMs: 100,
      playing: false,
      frame: 0,
      frameStartedAtMs: 0
    };
  }

  function createSceneState() {
    return {
      drawOrder: [],
      anim: {
        circle: createAnimTrack(),
        triangle: createAnimTrack(),
        rect: createAnimTrack(),
        line: createAnimTrack(),
        point: createAnimTrack(),
        text: createAnimTrack(),
        pixels: createAnimPixelsTrack()
      }
    };
  }

  function clearAnimTrack(track) {
    track.frames = [];
    track.playing = false;
    track.frame = 0;
    track.frameStartedAtMs = 0;
  }

  function playAnimTrack(track, nowMs) {
    track.playing = track.frames.length > 0;
    track.frameStartedAtMs = nowMs;
  }

  function stopAnimTrack(track) {
    track.playing = false;
  }

  function clearAnimPixelsTrack(track) {
    track.rects = [];
    track.frameCount = 0;
    track.rateMs = 100;
    track.playing = false;
    track.frame = 0;
    track.frameStartedAtMs = 0;
  }

  function playAnimPixelsTrack(track, nowMs) {
    track.playing = track.frameCount > 0 && track.rects.length > 0;
    track.frameStartedAtMs = nowMs;
  }

  function stopAnimPixelsTrack(track) {
    track.playing = false;
  }

  function resetScene(state) {
    state.drawOrder = [];
    clearAnimTrack(state.anim.circle);
    clearAnimTrack(state.anim.triangle);
    clearAnimTrack(state.anim.rect);
    clearAnimTrack(state.anim.line);
    clearAnimTrack(state.anim.point);
    clearAnimTrack(state.anim.text);
    clearAnimPixelsTrack(state.anim.pixels);
  }

  function applyCommand(state, cmd, nowMs) {
    if (cmd.op === 'PING' || cmd.op === 'EVENT_DRAIN' || cmd.op === 'EVENT_CLEAR') {
      return false;
    }

    if (cmd.op === 'CLEAR' || cmd.op === 'CLOSE') {
      resetScene(state);
      return true;
    }

    if (cmd.op === 'ADD_TRIANGLE') {
      state.drawOrder.push({ kind: 'triangle', x: cmd.x, y: cmd.y, r: cmd.r, color: cmd.color });
      return true;
    }
    if (cmd.op === 'ADD_CIRCLE') {
      state.drawOrder.push({ kind: 'circle', x: cmd.x, y: cmd.y, r: cmd.r, color: cmd.color });
      return true;
    }
    if (cmd.op === 'ADD_SQUARE') {
      state.drawOrder.push({ kind: 'rect', x: cmd.x - cmd.r, y: cmd.y - cmd.r, w: 2 * cmd.r, h: 2 * cmd.r, color: cmd.color });
      return true;
    }
    if (cmd.op === 'ADD_RECT') {
      state.drawOrder.push({ kind: 'rect', x: cmd.x, y: cmd.y, w: cmd.w, h: cmd.h, color: cmd.color });
      return true;
    }
    if (cmd.op === 'ADD_LINE') {
      state.drawOrder.push({
        kind: 'line',
        x1: cmd.x1,
        y1: cmd.y1,
        x2: cmd.x2,
        y2: cmd.y2,
        thickness: cmd.thickness,
        color: cmd.color
      });
      return true;
    }
    if (cmd.op === 'ADD_PIXEL') {
      state.drawOrder.push({ kind: 'pixel', x: cmd.x, y: cmd.y, color: cmd.color });
      return true;
    }
    if (cmd.op === 'ADD_TEXT') {
      state.drawOrder.push({
        kind: 'text',
        x: cmd.x,
        y: cmd.y,
        size: cmd.size,
        color: cmd.color,
        text: cmd.text
      });
      return true;
    }
    if (cmd.op === 'ADD_PIXELS_BLIT') {
      state.drawOrder.push({
        kind: 'pixelsBlit',
        x: cmd.x,
        y: cmd.y,
        dw: cmd.dw,
        dh: cmd.dh,
        alpha: cmd.alpha,
        w: cmd.w,
        h: cmd.h,
        channels: cmd.channels,
        data: cmd.data,
        surface: null,
        surfaceUnavailable: false
      });
      return true;
    }

    if (cmd.op === 'ANIM_CIRCLE_CLEAR') {
      clearAnimTrack(state.anim.circle);
      return true;
    }
    if (cmd.op === 'ANIM_CIRCLE_PLAY') {
      playAnimTrack(state.anim.circle, nowMs);
      return true;
    }
    if (cmd.op === 'ANIM_CIRCLE_STOP') {
      stopAnimTrack(state.anim.circle);
      return true;
    }
    if (cmd.op === 'ANIM_CIRCLE_ADD') {
      state.anim.circle.frames.push(cmd);
      return true;
    }

    if (cmd.op === 'ANIM_TRIANGLE_CLEAR') {
      clearAnimTrack(state.anim.triangle);
      return true;
    }
    if (cmd.op === 'ANIM_TRIANGLE_PLAY') {
      playAnimTrack(state.anim.triangle, nowMs);
      return true;
    }
    if (cmd.op === 'ANIM_TRIANGLE_STOP') {
      stopAnimTrack(state.anim.triangle);
      return true;
    }
    if (cmd.op === 'ANIM_TRIANGLE_ADD') {
      state.anim.triangle.frames.push(cmd);
      return true;
    }

    if (cmd.op === 'ANIM_RECT_CLEAR') {
      clearAnimTrack(state.anim.rect);
      return true;
    }
    if (cmd.op === 'ANIM_RECT_PLAY') {
      playAnimTrack(state.anim.rect, nowMs);
      return true;
    }
    if (cmd.op === 'ANIM_RECT_STOP') {
      stopAnimTrack(state.anim.rect);
      return true;
    }
    if (cmd.op === 'ANIM_RECT_ADD') {
      state.anim.rect.frames.push(cmd);
      return true;
    }

    if (cmd.op === 'ANIM_LINE_CLEAR') {
      clearAnimTrack(state.anim.line);
      return true;
    }
    if (cmd.op === 'ANIM_LINE_PLAY') {
      playAnimTrack(state.anim.line, nowMs);
      return true;
    }
    if (cmd.op === 'ANIM_LINE_STOP') {
      stopAnimTrack(state.anim.line);
      return true;
    }
    if (cmd.op === 'ANIM_LINE_ADD') {
      state.anim.line.frames.push(cmd);
      return true;
    }

    if (cmd.op === 'ANIM_POINT_CLEAR') {
      clearAnimTrack(state.anim.point);
      return true;
    }
    if (cmd.op === 'ANIM_POINT_PLAY') {
      playAnimTrack(state.anim.point, nowMs);
      return true;
    }
    if (cmd.op === 'ANIM_POINT_STOP') {
      stopAnimTrack(state.anim.point);
      return true;
    }
    if (cmd.op === 'ANIM_POINT_ADD') {
      state.anim.point.frames.push(cmd);
      return true;
    }

    if (cmd.op === 'ANIM_TEXT_CLEAR') {
      clearAnimTrack(state.anim.text);
      return true;
    }
    if (cmd.op === 'ANIM_TEXT_PLAY') {
      playAnimTrack(state.anim.text, nowMs);
      return true;
    }
    if (cmd.op === 'ANIM_TEXT_STOP') {
      stopAnimTrack(state.anim.text);
      return true;
    }
    if (cmd.op === 'ANIM_TEXT_ADD') {
      state.anim.text.frames.push(cmd);
      return true;
    }

    if (cmd.op === 'ANIM_PIXELS_CLEAR') {
      clearAnimPixelsTrack(state.anim.pixels);
      return true;
    }
    if (cmd.op === 'ANIM_PIXELS_PLAY') {
      playAnimPixelsTrack(state.anim.pixels, nowMs);
      return true;
    }
    if (cmd.op === 'ANIM_PIXELS_STOP') {
      stopAnimPixelsTrack(state.anim.pixels);
      return true;
    }
    if (cmd.op === 'ANIM_PIXELS_RATE') {
      state.anim.pixels.rateMs = window.CanvasRuntimeCore.clampRateMs(cmd.rateMs);
      return true;
    }
    if (cmd.op === 'ANIM_PIXELS_ADD') {
      if (cmd.frame >= 0) {
        state.anim.pixels.rects.push(cmd);
        if (cmd.frame + 1 > state.anim.pixels.frameCount) {
          state.anim.pixels.frameCount = cmd.frame + 1;
        }
      }
      return true;
    }

    return false;
  }

  function advanceAnimTrack(track, nowMs) {
    if (!track.playing || track.frames.length === 0) {
      return false;
    }

    if (track.frameStartedAtMs <= 0) {
      track.frameStartedAtMs = nowMs;
      return false;
    }

    let moved = false;
    let guard = 0;
    while (guard < 512) {
      const frame = track.frames[track.frame % track.frames.length];
      const rateMs = window.CanvasRuntimeCore.clampRateMs(frame.rateMs);
      if (nowMs - track.frameStartedAtMs < rateMs) {
        break;
      }
      track.frameStartedAtMs += rateMs;
      track.frame = (track.frame + 1) % track.frames.length;
      moved = true;
      guard += 1;
    }

    if (guard >= 512) {
      track.frameStartedAtMs = nowMs;
    }
    return moved;
  }

  function advanceAnimPixelsTrack(track, nowMs) {
    if (!track.playing || track.frameCount <= 0) {
      return false;
    }

    if (track.frameStartedAtMs <= 0) {
      track.frameStartedAtMs = nowMs;
      return false;
    }

    const rateMs = window.CanvasRuntimeCore.clampRateMs(track.rateMs);
    let moved = false;
    let guard = 0;
    while (guard < 512) {
      if (nowMs - track.frameStartedAtMs < rateMs) {
        break;
      }
      track.frameStartedAtMs += rateMs;
      track.frame = (track.frame + 1) % track.frameCount;
      moved = true;
      guard += 1;
    }

    if (guard >= 512) {
      track.frameStartedAtMs = nowMs;
    }
    return moved;
  }

  function hasActiveAnimations(state) {
    const a = state.anim;
    return (
      (a.circle.playing && a.circle.frames.length > 0) ||
      (a.triangle.playing && a.triangle.frames.length > 0) ||
      (a.rect.playing && a.rect.frames.length > 0) ||
      (a.line.playing && a.line.frames.length > 0) ||
      (a.point.playing && a.point.frames.length > 0) ||
      (a.text.playing && a.text.frames.length > 0) ||
      (a.pixels.playing && a.pixels.frameCount > 0)
    );
  }

  function advanceAnimations(state, nowMs) {
    let moved = false;
    moved = advanceAnimTrack(state.anim.circle, nowMs) || moved;
    moved = advanceAnimTrack(state.anim.triangle, nowMs) || moved;
    moved = advanceAnimTrack(state.anim.rect, nowMs) || moved;
    moved = advanceAnimTrack(state.anim.line, nowMs) || moved;
    moved = advanceAnimTrack(state.anim.point, nowMs) || moved;
    moved = advanceAnimTrack(state.anim.text, nowMs) || moved;
    moved = advanceAnimPixelsTrack(state.anim.pixels, nowMs) || moved;
    return moved;
  }

  window.CanvasRuntimeState = {
    createSceneState,
    applyCommand,
    advanceAnimations,
    hasActiveAnimations
  };
})();
