(function () {
  const NOOP_OPS = new Set(['PING', 'EVENT_DRAIN', 'EVENT_CLEAR']);
  const RESET_OPS = new Set(['CLEAR', 'CLOSE']);
  const TRACK_KEYS = ['circle', 'triangle', 'rect', 'line', 'point', 'text'];
  const ADVANCE_GUARD_LIMIT = 512;

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
    for (const key of TRACK_KEYS) {
      clearAnimTrack(state.anim[key]);
    }
    clearAnimPixelsTrack(state.anim.pixels);
  }

  function addTriangle(state, cmd) {
    state.drawOrder.push({ kind: 'triangle', x: cmd.x, y: cmd.y, r: cmd.r, color: cmd.color });
    return true;
  }

  function addCircle(state, cmd) {
    state.drawOrder.push({ kind: 'circle', x: cmd.x, y: cmd.y, r: cmd.r, color: cmd.color });
    return true;
  }

  function addSquare(state, cmd) {
    state.drawOrder.push({ kind: 'rect', x: cmd.x - cmd.r, y: cmd.y - cmd.r, w: 2 * cmd.r, h: 2 * cmd.r, color: cmd.color });
    return true;
  }

  function addRect(state, cmd) {
    state.drawOrder.push({ kind: 'rect', x: cmd.x, y: cmd.y, w: cmd.w, h: cmd.h, color: cmd.color });
    return true;
  }

  function addLine(state, cmd) {
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

  function addPixel(state, cmd) {
    state.drawOrder.push({ kind: 'pixel', x: cmd.x, y: cmd.y, color: cmd.color });
    return true;
  }

  function addText(state, cmd) {
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

  function addPixelsBlit(state, cmd) {
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

  const STATIC_DRAW_HANDLERS = {
    ADD_TRIANGLE: addTriangle,
    ADD_CIRCLE: addCircle,
    ADD_SQUARE: addSquare,
    ADD_RECT: addRect,
    ADD_LINE: addLine,
    ADD_PIXEL: addPixel,
    ADD_TEXT: addText,
    ADD_PIXELS_BLIT: addPixelsBlit
  };

  function handleTrackClear(state, key) {
    clearAnimTrack(state.anim[key]);
    return true;
  }

  function handleTrackPlay(state, key, nowMs) {
    playAnimTrack(state.anim[key], nowMs);
    return true;
  }

  function handleTrackStop(state, key) {
    stopAnimTrack(state.anim[key]);
    return true;
  }

  function handleTrackAdd(state, key, cmd) {
    state.anim[key].frames.push(cmd);
    return true;
  }

  // Build animation handlers from one template to keep all tracks in sync.
  const ANIM_HANDLERS = {
    ANIM_CIRCLE_CLEAR: (state) => handleTrackClear(state, 'circle'),
    ANIM_CIRCLE_PLAY: (state, _, nowMs) => handleTrackPlay(state, 'circle', nowMs),
    ANIM_CIRCLE_STOP: (state) => handleTrackStop(state, 'circle'),
    ANIM_CIRCLE_ADD: (state, cmd) => handleTrackAdd(state, 'circle', cmd),

    ANIM_TRIANGLE_CLEAR: (state) => handleTrackClear(state, 'triangle'),
    ANIM_TRIANGLE_PLAY: (state, _, nowMs) => handleTrackPlay(state, 'triangle', nowMs),
    ANIM_TRIANGLE_STOP: (state) => handleTrackStop(state, 'triangle'),
    ANIM_TRIANGLE_ADD: (state, cmd) => handleTrackAdd(state, 'triangle', cmd),

    ANIM_RECT_CLEAR: (state) => handleTrackClear(state, 'rect'),
    ANIM_RECT_PLAY: (state, _, nowMs) => handleTrackPlay(state, 'rect', nowMs),
    ANIM_RECT_STOP: (state) => handleTrackStop(state, 'rect'),
    ANIM_RECT_ADD: (state, cmd) => handleTrackAdd(state, 'rect', cmd),

    ANIM_LINE_CLEAR: (state) => handleTrackClear(state, 'line'),
    ANIM_LINE_PLAY: (state, _, nowMs) => handleTrackPlay(state, 'line', nowMs),
    ANIM_LINE_STOP: (state) => handleTrackStop(state, 'line'),
    ANIM_LINE_ADD: (state, cmd) => handleTrackAdd(state, 'line', cmd),

    ANIM_POINT_CLEAR: (state) => handleTrackClear(state, 'point'),
    ANIM_POINT_PLAY: (state, _, nowMs) => handleTrackPlay(state, 'point', nowMs),
    ANIM_POINT_STOP: (state) => handleTrackStop(state, 'point'),
    ANIM_POINT_ADD: (state, cmd) => handleTrackAdd(state, 'point', cmd),

    ANIM_TEXT_CLEAR: (state) => handleTrackClear(state, 'text'),
    ANIM_TEXT_PLAY: (state, _, nowMs) => handleTrackPlay(state, 'text', nowMs),
    ANIM_TEXT_STOP: (state) => handleTrackStop(state, 'text'),
    ANIM_TEXT_ADD: (state, cmd) => handleTrackAdd(state, 'text', cmd),

    ANIM_PIXELS_CLEAR: (state) => {
      clearAnimPixelsTrack(state.anim.pixels);
      return true;
    },
    ANIM_PIXELS_PLAY: (state, _, nowMs) => {
      playAnimPixelsTrack(state.anim.pixels, nowMs);
      return true;
    },
    ANIM_PIXELS_STOP: (state) => {
      stopAnimPixelsTrack(state.anim.pixels);
      return true;
    },
    ANIM_PIXELS_RATE: (state, cmd) => {
      state.anim.pixels.rateMs = window.CanvasRuntimeCore.clampRateMs(cmd.rateMs);
      return true;
    },
    ANIM_PIXELS_ADD: (state, cmd) => {
      if (cmd.frame >= 0) {
        state.anim.pixels.rects.push(cmd);
        if (cmd.frame + 1 > state.anim.pixels.frameCount) {
          state.anim.pixels.frameCount = cmd.frame + 1;
        }
      }
      return true;
    }
  };

  function applyCommand(state, cmd, nowMs) {
    if (NOOP_OPS.has(cmd.op)) {
      return false;
    }

    if (RESET_OPS.has(cmd.op)) {
      resetScene(state);
      return true;
    }

    const drawHandler = STATIC_DRAW_HANDLERS[cmd.op];
    if (drawHandler) {
      return drawHandler(state, cmd);
    }

    const animHandler = ANIM_HANDLERS[cmd.op];
    if (animHandler) {
      return animHandler(state, cmd, nowMs);
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
    while (guard < ADVANCE_GUARD_LIMIT) {
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

    if (guard >= ADVANCE_GUARD_LIMIT) {
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
    while (guard < ADVANCE_GUARD_LIMIT) {
      if (nowMs - track.frameStartedAtMs < rateMs) {
        break;
      }
      track.frameStartedAtMs += rateMs;
      track.frame = (track.frame + 1) % track.frameCount;
      moved = true;
      guard += 1;
    }

    if (guard >= ADVANCE_GUARD_LIMIT) {
      track.frameStartedAtMs = nowMs;
    }
    return moved;
  }

  function hasActiveAnimations(state) {
    for (const key of TRACK_KEYS) {
      const track = state.anim[key];
      if (track.playing && track.frames.length > 0) {
        return true;
      }
    }
    return state.anim.pixels.playing && state.anim.pixels.frameCount > 0;
  }

  function advanceAnimations(state, nowMs) {
    let moved = false;
    for (const key of TRACK_KEYS) {
      moved = advanceAnimTrack(state.anim[key], nowMs) || moved;
    }
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
