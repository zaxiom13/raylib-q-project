(function () {
  const TRIANGLE_DX_FACTOR = 0.8660254;
  const BACKGROUND_COLOR = '#f8f1e4';
  const DEFAULT_FONT_FAMILY = 'Avenir Next';

  function clampInt(value, min, max) {
    const n = Math.trunc(Number(value));
    if (!Number.isFinite(n)) {
      return min;
    }
    if (n < min) {
      return min;
    }
    if (n > max) {
      return max;
    }
    return n;
  }

  function parseFloatToken(token) {
    const n = Number(token);
    return Number.isFinite(n) ? n : null;
  }

  function parseIntToken(token) {
    const n = Number(token);
    if (!Number.isFinite(n)) {
      return null;
    }
    return Math.trunc(n);
  }

  function parseByteToken(token) {
    const n = parseIntToken(token);
    if (n === null) {
      return null;
    }
    return clampInt(n, 0, 255);
  }

  function parseColorTokens(parts, startIdx) {
    const r = parseByteToken(parts[startIdx]);
    const g = parseByteToken(parts[startIdx + 1]);
    const b = parseByteToken(parts[startIdx + 2]);
    const a = parseByteToken(parts[startIdx + 3]);
    if (r === null || g === null || b === null || a === null) {
      return null;
    }
    return { r, g, b, a };
  }

  function parseByteArray(parts, startIdx) {
    const out = [];
    let i = startIdx;
    while (i < parts.length) {
      const v = parseByteToken(parts[i]);
      if (v === null) {
        return null;
      }
      out.push(v);
      i += 1;
    }
    return out;
  }

  function clampRateMs(value) {
    const n = parseIntToken(value);
    if (n === null || n < 1) {
      return 1;
    }
    return n;
  }

  function parseFlagToken(token) {
    const n = parseIntToken(token);
    if (n === null) {
      return null;
    }
    return n !== 0;
  }

  function colorToCss(c) {
    return `rgba(${c.r}, ${c.g}, ${c.b}, ${c.a / 255})`;
  }

  function lerp(a, b, t) {
    return a + (b - a) * t;
  }

  function lerpColor(a, b, t) {
    return {
      r: clampInt(Math.round(lerp(a.r, b.r, t)), 0, 255),
      g: clampInt(Math.round(lerp(a.g, b.g, t)), 0, 255),
      b: clampInt(Math.round(lerp(a.b, b.b, t)), 0, 255),
      a: clampInt(Math.round(lerp(a.a, b.a, t)), 0, 255)
    };
  }

  function parseQDrawCommand(line) {
    const trimmed = String(line ?? '').trim();
    if (!trimmed.length) {
      return null;
    }

    const parts = trimmed.split(/\s+/);
    const op = parts[0];
    if (!op) {
      return null;
    }

    if (op === 'CLEAR' || op === 'CLOSE' || op === 'PING' || op === 'EVENT_DRAIN' || op === 'EVENT_CLEAR') {
      return { op };
    }

    if (op === 'ADD_TRIANGLE' && parts.length >= 8) {
      const x = parseFloatToken(parts[1]);
      const y = parseFloatToken(parts[2]);
      const r = parseFloatToken(parts[3]);
      const color = parseColorTokens(parts, 4);
      if (x === null || y === null || r === null || !color) {
        return null;
      }
      return { op, x, y, r, color };
    }

    if (op === 'ADD_CIRCLE' && parts.length >= 8) {
      const x = parseFloatToken(parts[1]);
      const y = parseFloatToken(parts[2]);
      const r = parseFloatToken(parts[3]);
      const color = parseColorTokens(parts, 4);
      if (x === null || y === null || r === null || !color) {
        return null;
      }
      return { op, x, y, r, color };
    }

    if (op === 'ADD_SQUARE' && parts.length >= 8) {
      const x = parseFloatToken(parts[1]);
      const y = parseFloatToken(parts[2]);
      const r = parseFloatToken(parts[3]);
      const color = parseColorTokens(parts, 4);
      if (x === null || y === null || r === null || !color) {
        return null;
      }
      return { op, x, y, r, color };
    }

    if (op === 'ADD_RECT' && parts.length >= 9) {
      const x = parseFloatToken(parts[1]);
      const y = parseFloatToken(parts[2]);
      const w = parseFloatToken(parts[3]);
      const h = parseFloatToken(parts[4]);
      const color = parseColorTokens(parts, 5);
      if (x === null || y === null || w === null || h === null || !color) {
        return null;
      }
      return { op, x, y, w, h, color };
    }

    if (op === 'ADD_LINE' && parts.length >= 10) {
      const x1 = parseFloatToken(parts[1]);
      const y1 = parseFloatToken(parts[2]);
      const x2 = parseFloatToken(parts[3]);
      const y2 = parseFloatToken(parts[4]);
      const thickness = parseFloatToken(parts[5]);
      const color = parseColorTokens(parts, 6);
      if (x1 === null || y1 === null || x2 === null || y2 === null || thickness === null || !color) {
        return null;
      }
      return { op, x1, y1, x2, y2, thickness, color };
    }

    if (op === 'ADD_PIXEL' && parts.length >= 7) {
      const x = parseFloatToken(parts[1]);
      const y = parseFloatToken(parts[2]);
      const color = parseColorTokens(parts, 3);
      if (x === null || y === null || !color) {
        return null;
      }
      return { op, x, y, color };
    }

    if (op === 'ADD_TEXT' && parts.length >= 8) {
      const x = parseFloatToken(parts[1]);
      const y = parseFloatToken(parts[2]);
      const size = parseIntToken(parts[3]);
      const color = parseColorTokens(parts, 4);
      if (x === null || y === null || size === null || !color) {
        return null;
      }
      return { op, x, y, size, color, text: parts.slice(8).join(' ') };
    }

    if (op === 'ADD_PIXELS_BLIT' && parts.length >= 9) {
      const x = parseFloatToken(parts[1]);
      const y = parseFloatToken(parts[2]);
      const dw = parseFloatToken(parts[3]);
      const dh = parseFloatToken(parts[4]);
      const alpha = parseByteToken(parts[5]);
      const w = parseIntToken(parts[6]);
      const h = parseIntToken(parts[7]);
      const channels = parseIntToken(parts[8]);
      const data = parseByteArray(parts, 9);
      if (x === null || y === null || dw === null || dh === null || alpha === null || w === null || h === null || channels === null || !data) {
        return null;
      }
      return { op, x, y, dw, dh, alpha, w, h, channels, data };
    }

    if (op === 'ANIM_CIRCLE_CLEAR' || op === 'ANIM_CIRCLE_PLAY' || op === 'ANIM_CIRCLE_STOP') {
      return { op };
    }
    if (op === 'ANIM_TRIANGLE_CLEAR' || op === 'ANIM_TRIANGLE_PLAY' || op === 'ANIM_TRIANGLE_STOP') {
      return { op };
    }
    if (op === 'ANIM_RECT_CLEAR' || op === 'ANIM_RECT_PLAY' || op === 'ANIM_RECT_STOP') {
      return { op };
    }
    if (op === 'ANIM_LINE_CLEAR' || op === 'ANIM_LINE_PLAY' || op === 'ANIM_LINE_STOP') {
      return { op };
    }
    if (op === 'ANIM_POINT_CLEAR' || op === 'ANIM_POINT_PLAY' || op === 'ANIM_POINT_STOP') {
      return { op };
    }
    if (op === 'ANIM_TEXT_CLEAR' || op === 'ANIM_TEXT_PLAY' || op === 'ANIM_TEXT_STOP') {
      return { op };
    }
    if (op === 'ANIM_PIXELS_CLEAR' || op === 'ANIM_PIXELS_PLAY' || op === 'ANIM_PIXELS_STOP') {
      return { op };
    }

    if (op === 'ANIM_CIRCLE_ADD' && parts.length >= 10) {
      const x = parseFloatToken(parts[1]);
      const y = parseFloatToken(parts[2]);
      const r = parseFloatToken(parts[3]);
      const color = parseColorTokens(parts, 4);
      const rateMs = parseIntToken(parts[8]);
      const interpolateToNext = parseFlagToken(parts[9]);
      if (x === null || y === null || r === null || !color || rateMs === null || interpolateToNext === null) {
        return null;
      }
      return { op, x, y, r, color, rateMs, interpolateToNext };
    }

    if (op === 'ANIM_TRIANGLE_ADD' && parts.length >= 10) {
      const x = parseFloatToken(parts[1]);
      const y = parseFloatToken(parts[2]);
      const r = parseFloatToken(parts[3]);
      const color = parseColorTokens(parts, 4);
      const rateMs = parseIntToken(parts[8]);
      const interpolateToNext = parseFlagToken(parts[9]);
      if (x === null || y === null || r === null || !color || rateMs === null || interpolateToNext === null) {
        return null;
      }
      return { op, x, y, r, color, rateMs, interpolateToNext };
    }

    if (op === 'ANIM_RECT_ADD' && parts.length >= 11) {
      const x = parseFloatToken(parts[1]);
      const y = parseFloatToken(parts[2]);
      const w = parseFloatToken(parts[3]);
      const h = parseFloatToken(parts[4]);
      const color = parseColorTokens(parts, 5);
      const rateMs = parseIntToken(parts[9]);
      const interpolateToNext = parseFlagToken(parts[10]);
      if (x === null || y === null || w === null || h === null || !color || rateMs === null || interpolateToNext === null) {
        return null;
      }
      return { op, x, y, w, h, color, rateMs, interpolateToNext };
    }

    if (op === 'ANIM_LINE_ADD' && parts.length >= 12) {
      const x1 = parseFloatToken(parts[1]);
      const y1 = parseFloatToken(parts[2]);
      const x2 = parseFloatToken(parts[3]);
      const y2 = parseFloatToken(parts[4]);
      const thickness = parseFloatToken(parts[5]);
      const color = parseColorTokens(parts, 6);
      const rateMs = parseIntToken(parts[10]);
      const interpolateToNext = parseFlagToken(parts[11]);
      if (x1 === null || y1 === null || x2 === null || y2 === null || thickness === null || !color || rateMs === null || interpolateToNext === null) {
        return null;
      }
      return { op, x1, y1, x2, y2, thickness, color, rateMs, interpolateToNext };
    }

    if (op === 'ANIM_POINT_ADD' && parts.length >= 9) {
      const x = parseFloatToken(parts[1]);
      const y = parseFloatToken(parts[2]);
      const color = parseColorTokens(parts, 3);
      const rateMs = parseIntToken(parts[7]);
      const interpolateToNext = parseFlagToken(parts[8]);
      if (x === null || y === null || !color || rateMs === null || interpolateToNext === null) {
        return null;
      }
      return { op, x, y, color, rateMs, interpolateToNext };
    }

    if (op === 'ANIM_TEXT_ADD' && parts.length >= 10) {
      const x = parseFloatToken(parts[1]);
      const y = parseFloatToken(parts[2]);
      const size = parseIntToken(parts[3]);
      const color = parseColorTokens(parts, 4);
      const rateMs = parseIntToken(parts[8]);
      const interpolateToNext = parseFlagToken(parts[9]);
      if (x === null || y === null || size === null || !color || rateMs === null || interpolateToNext === null) {
        return null;
      }
      return { op, x, y, size, color, rateMs, interpolateToNext, text: parts.slice(10).join(' ') };
    }

    if (op === 'ANIM_PIXELS_RATE' && parts.length >= 2) {
      const rateMs = parseIntToken(parts[1]);
      if (rateMs === null) {
        return null;
      }
      return { op, rateMs };
    }

    if (op === 'ANIM_PIXELS_ADD' && parts.length >= 10) {
      const frame = parseIntToken(parts[1]);
      const x = parseFloatToken(parts[2]);
      const y = parseFloatToken(parts[3]);
      const w = parseFloatToken(parts[4]);
      const h = parseFloatToken(parts[5]);
      const color = parseColorTokens(parts, 6);
      if (frame === null || x === null || y === null || w === null || h === null || !color) {
        return null;
      }
      return { op, frame, x, y, w, h, color };
    }

    return null;
  }

  window.CanvasRuntimeCore = {
    TRIANGLE_DX_FACTOR,
    BACKGROUND_COLOR,
    DEFAULT_FONT_FAMILY,
    clampInt,
    clampRateMs,
    colorToCss,
    lerp,
    lerpColor,
    parseQDrawCommand
  };
})();
