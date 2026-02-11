(function () {
  const TRIANGLE_DX_FACTOR = 0.8660254;
  const BACKGROUND_COLOR = '#f8f1e4';
  const DEFAULT_FONT_FAMILY = 'Avenir Next';

  const CONTROL_OPS = new Set(['CLEAR', 'CLOSE', 'PING', 'EVENT_DRAIN', 'EVENT_CLEAR']);
  const ANIM_CONTROL_OPS = new Set([
    'ANIM_CIRCLE_CLEAR',
    'ANIM_CIRCLE_PLAY',
    'ANIM_CIRCLE_STOP',
    'ANIM_TRIANGLE_CLEAR',
    'ANIM_TRIANGLE_PLAY',
    'ANIM_TRIANGLE_STOP',
    'ANIM_RECT_CLEAR',
    'ANIM_RECT_PLAY',
    'ANIM_RECT_STOP',
    'ANIM_LINE_CLEAR',
    'ANIM_LINE_PLAY',
    'ANIM_LINE_STOP',
    'ANIM_POINT_CLEAR',
    'ANIM_POINT_PLAY',
    'ANIM_POINT_STOP',
    'ANIM_TEXT_CLEAR',
    'ANIM_TEXT_PLAY',
    'ANIM_TEXT_STOP',
    'ANIM_PIXELS_CLEAR',
    'ANIM_PIXELS_PLAY',
    'ANIM_PIXELS_STOP'
  ]);

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

  function parseFlagToken(token) {
    const n = parseIntToken(token);
    if (n === null) {
      return null;
    }
    return n !== 0;
  }

  function clampRateMs(value) {
    const n = parseIntToken(value);
    if (n === null || n < 1) {
      return 1;
    }
    return n;
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

  function parseStaticXyrColor(parts, op) {
    if (parts.length < 8) {
      return null;
    }
    const x = parseFloatToken(parts[1]);
    const y = parseFloatToken(parts[2]);
    const r = parseFloatToken(parts[3]);
    const color = parseColorTokens(parts, 4);
    if (x === null || y === null || r === null || !color) {
      return null;
    }
    return { op, x, y, r, color };
  }

  function parseStaticRect(parts, op) {
    if (parts.length < 9) {
      return null;
    }
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

  function parseStaticLine(parts, op) {
    if (parts.length < 10) {
      return null;
    }
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

  function parseStaticPixel(parts, op) {
    if (parts.length < 7) {
      return null;
    }
    const x = parseFloatToken(parts[1]);
    const y = parseFloatToken(parts[2]);
    const color = parseColorTokens(parts, 3);
    if (x === null || y === null || !color) {
      return null;
    }
    return { op, x, y, color };
  }

  function parseStaticText(parts, op) {
    if (parts.length < 8) {
      return null;
    }
    const x = parseFloatToken(parts[1]);
    const y = parseFloatToken(parts[2]);
    const size = parseIntToken(parts[3]);
    const color = parseColorTokens(parts, 4);
    if (x === null || y === null || size === null || !color) {
      return null;
    }
    return { op, x, y, size, color, text: parts.slice(8).join(' ') };
  }

  function parsePixelsBlit(parts, op) {
    if (parts.length < 9) {
      return null;
    }
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

  function parseAnimXyrColor(parts, op) {
    if (parts.length < 10) {
      return null;
    }
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

  function parseAnimRect(parts, op) {
    if (parts.length < 11) {
      return null;
    }
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

  function parseAnimLine(parts, op) {
    if (parts.length < 12) {
      return null;
    }
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

  function parseAnimPoint(parts, op) {
    if (parts.length < 9) {
      return null;
    }
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

  function parseAnimText(parts, op) {
    if (parts.length < 10) {
      return null;
    }
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

  function parseAnimPixelsRate(parts, op) {
    if (parts.length < 2) {
      return null;
    }
    const rateMs = parseIntToken(parts[1]);
    if (rateMs === null) {
      return null;
    }
    return { op, rateMs };
  }

  function parseAnimPixelsAdd(parts, op) {
    if (parts.length < 10) {
      return null;
    }
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

  // Command decoding is table-driven so command additions only need one new
  // parser entry instead of another long if/else branch.
  const STATIC_DRAW_PARSERS = {
    ADD_TRIANGLE: parseStaticXyrColor,
    ADD_CIRCLE: parseStaticXyrColor,
    ADD_SQUARE: parseStaticXyrColor,
    ADD_RECT: parseStaticRect,
    ADD_LINE: parseStaticLine,
    ADD_PIXEL: parseStaticPixel,
    ADD_TEXT: parseStaticText,
    ADD_PIXELS_BLIT: parsePixelsBlit
  };

  const ANIM_ADD_PARSERS = {
    ANIM_CIRCLE_ADD: parseAnimXyrColor,
    ANIM_TRIANGLE_ADD: parseAnimXyrColor,
    ANIM_RECT_ADD: parseAnimRect,
    ANIM_LINE_ADD: parseAnimLine,
    ANIM_POINT_ADD: parseAnimPoint,
    ANIM_TEXT_ADD: parseAnimText,
    ANIM_PIXELS_RATE: parseAnimPixelsRate,
    ANIM_PIXELS_ADD: parseAnimPixelsAdd
  };

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

    if (CONTROL_OPS.has(op) || ANIM_CONTROL_OPS.has(op)) {
      return { op };
    }

    const parser = STATIC_DRAW_PARSERS[op] || ANIM_ADD_PARSERS[op];
    if (!parser) {
      return null;
    }
    return parser(parts, op);
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
