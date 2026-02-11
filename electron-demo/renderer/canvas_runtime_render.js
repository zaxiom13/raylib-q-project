(function () {
  function drawBackground(ctx, canvas) {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.fillStyle = window.CanvasRuntimeCore.BACKGROUND_COLOR;
    ctx.fillRect(0, 0, canvas.width, canvas.height);
  }

  function drawTriangleCenter(ctx, x, y, r, color) {
    const dx = window.CanvasRuntimeCore.TRIANGLE_DX_FACTOR * r;
    ctx.beginPath();
    ctx.moveTo(x, y - r);
    ctx.lineTo(x - dx, y + 0.5 * r);
    ctx.lineTo(x + dx, y + 0.5 * r);
    ctx.closePath();
    ctx.fillStyle = window.CanvasRuntimeCore.colorToCss(color);
    ctx.fill();
  }

  function drawRect(ctx, x, y, w, h, color) {
    ctx.fillStyle = window.CanvasRuntimeCore.colorToCss(color);
    ctx.fillRect(x, y, w, h);
  }

  function drawLine(ctx, x1, y1, x2, y2, thickness, color) {
    ctx.strokeStyle = window.CanvasRuntimeCore.colorToCss(color);
    ctx.lineWidth = thickness > 0 ? thickness : 1;
    ctx.beginPath();
    ctx.moveTo(x1, y1);
    ctx.lineTo(x2, y2);
    ctx.stroke();
  }

  function drawPoint(ctx, x, y, color) {
    ctx.fillStyle = window.CanvasRuntimeCore.colorToCss(color);
    ctx.fillRect(Math.round(x), Math.round(y), 1, 1);
  }

  function drawText(ctx, x, y, size, color, text) {
    const clampedSize = Math.max(1, Math.trunc(size));
    ctx.fillStyle = window.CanvasRuntimeCore.colorToCss(color);
    ctx.font = `${clampedSize}px ${window.CanvasRuntimeCore.DEFAULT_FONT_FAMILY}`;
    ctx.fillText(String(text ?? ''), x, y);
  }

  function ensureBlitSurface(blit) {
    if (blit.surfaceUnavailable) {
      return null;
    }
    if (blit.surface) {
      return blit.surface;
    }

    const channels = blit.channels;
    const validChannels = channels === 1 || channels === 3 || channels === 4;
    const pixelCount = blit.w > 0 && blit.h > 0 ? blit.w * blit.h : 0;
    const expected = validChannels ? pixelCount * channels : 0;
    if (!validChannels || expected <= 0 || blit.data.length < expected) {
      blit.surfaceUnavailable = true;
      return null;
    }

    if (typeof document === 'undefined' || typeof document.createElement !== 'function') {
      blit.surfaceUnavailable = true;
      return null;
    }

    const surface = document.createElement('canvas');
    surface.width = blit.w;
    surface.height = blit.h;
    const sctx = surface.getContext('2d');
    if (!sctx) {
      blit.surfaceUnavailable = true;
      return null;
    }

    const image = sctx.createImageData(blit.w, blit.h);
    const alphaMul = window.CanvasRuntimeCore.clampInt(blit.alpha, 0, 255);
    let i = 0;
    while (i < pixelCount) {
      const srcBase = i * channels;
      const dstBase = i * 4;
      const r = blit.data[srcBase];
      const g = channels === 1 ? r : blit.data[srcBase + 1];
      const b = channels === 1 ? r : blit.data[srcBase + 2];
      const srcA = channels === 4 ? blit.data[srcBase + 3] : 255;
      image.data[dstBase] = r;
      image.data[dstBase + 1] = g;
      image.data[dstBase + 2] = b;
      image.data[dstBase + 3] = window.CanvasRuntimeCore.clampInt(Math.round((srcA * alphaMul) / 255), 0, 255);
      i += 1;
    }
    sctx.putImageData(image, 0, 0);

    blit.surface = surface;
    return surface;
  }

  function drawPixelsBlit(ctx, blit) {
    const surface = ensureBlitSurface(blit);
    if (!surface) {
      return;
    }
    const prev = ctx.imageSmoothingEnabled;
    ctx.imageSmoothingEnabled = false;
    ctx.drawImage(surface, blit.x, blit.y, blit.dw, blit.dh);
    ctx.imageSmoothingEnabled = prev;
  }

  function drawStaticItem(ctx, item) {
    if (item.kind === 'triangle') {
      drawTriangleCenter(ctx, item.x, item.y, item.r, item.color);
      return;
    }
    if (item.kind === 'circle') {
      ctx.beginPath();
      ctx.arc(item.x, item.y, item.r, 0, Math.PI * 2);
      ctx.fillStyle = window.CanvasRuntimeCore.colorToCss(item.color);
      ctx.fill();
      return;
    }
    if (item.kind === 'rect') {
      drawRect(ctx, item.x, item.y, item.w, item.h, item.color);
      return;
    }
    if (item.kind === 'line') {
      drawLine(ctx, item.x1, item.y1, item.x2, item.y2, item.thickness, item.color);
      return;
    }
    if (item.kind === 'pixel') {
      drawPoint(ctx, item.x, item.y, item.color);
      return;
    }
    if (item.kind === 'text') {
      drawText(ctx, item.x, item.y, item.size, item.color, item.text);
      return;
    }
    if (item.kind === 'pixelsBlit') {
      drawPixelsBlit(ctx, item);
    }
  }

  function currentTrackFrame(track) {
    if (track.frames.length === 0) {
      return null;
    }
    return track.frames[track.frame % track.frames.length];
  }

  function frameProgress(track, frame, nowMs) {
    if (!track.playing || !frame.interpolateToNext || track.frames.length < 2) {
      return 0;
    }
    const elapsed = Math.max(0, nowMs - track.frameStartedAtMs);
    const rateMs = window.CanvasRuntimeCore.clampRateMs(frame.rateMs);
    const t = elapsed / rateMs;
    if (t < 0) {
      return 0;
    }
    if (t > 1) {
      return 1;
    }
    return t;
  }

  function drawAnimCircle(ctx, track, nowMs) {
    const cur = currentTrackFrame(track);
    if (!cur) {
      return;
    }

    let x = cur.x;
    let y = cur.y;
    let r = cur.r;
    let color = cur.color;
    if (cur.interpolateToNext && track.frames.length > 1) {
      const next = track.frames[(track.frame + 1) % track.frames.length];
      const t = frameProgress(track, cur, nowMs);
      x = window.CanvasRuntimeCore.lerp(cur.x, next.x, t);
      y = window.CanvasRuntimeCore.lerp(cur.y, next.y, t);
      r = window.CanvasRuntimeCore.lerp(cur.r, next.r, t);
      color = window.CanvasRuntimeCore.lerpColor(cur.color, next.color, t);
    }

    ctx.beginPath();
    ctx.arc(x, y, r, 0, Math.PI * 2);
    ctx.fillStyle = window.CanvasRuntimeCore.colorToCss(color);
    ctx.fill();
  }

  function drawAnimTriangle(ctx, track, nowMs) {
    const cur = currentTrackFrame(track);
    if (!cur) {
      return;
    }

    let x = cur.x;
    let y = cur.y;
    let r = cur.r;
    let color = cur.color;
    if (cur.interpolateToNext && track.frames.length > 1) {
      const next = track.frames[(track.frame + 1) % track.frames.length];
      const t = frameProgress(track, cur, nowMs);
      x = window.CanvasRuntimeCore.lerp(cur.x, next.x, t);
      y = window.CanvasRuntimeCore.lerp(cur.y, next.y, t);
      r = window.CanvasRuntimeCore.lerp(cur.r, next.r, t);
      color = window.CanvasRuntimeCore.lerpColor(cur.color, next.color, t);
    }

    drawTriangleCenter(ctx, x, y, r, color);
  }

  function drawAnimRect(ctx, track, nowMs) {
    const cur = currentTrackFrame(track);
    if (!cur) {
      return;
    }

    let x = cur.x;
    let y = cur.y;
    let w = cur.w;
    let h = cur.h;
    let color = cur.color;
    if (cur.interpolateToNext && track.frames.length > 1) {
      const next = track.frames[(track.frame + 1) % track.frames.length];
      const t = frameProgress(track, cur, nowMs);
      x = window.CanvasRuntimeCore.lerp(cur.x, next.x, t);
      y = window.CanvasRuntimeCore.lerp(cur.y, next.y, t);
      w = window.CanvasRuntimeCore.lerp(cur.w, next.w, t);
      h = window.CanvasRuntimeCore.lerp(cur.h, next.h, t);
      color = window.CanvasRuntimeCore.lerpColor(cur.color, next.color, t);
    }

    drawRect(ctx, x, y, w, h, color);
  }

  function drawAnimLine(ctx, track, nowMs) {
    const cur = currentTrackFrame(track);
    if (!cur) {
      return;
    }

    let x1 = cur.x1;
    let y1 = cur.y1;
    let x2 = cur.x2;
    let y2 = cur.y2;
    let thickness = cur.thickness;
    let color = cur.color;
    if (cur.interpolateToNext && track.frames.length > 1) {
      const next = track.frames[(track.frame + 1) % track.frames.length];
      const t = frameProgress(track, cur, nowMs);
      x1 = window.CanvasRuntimeCore.lerp(cur.x1, next.x1, t);
      y1 = window.CanvasRuntimeCore.lerp(cur.y1, next.y1, t);
      x2 = window.CanvasRuntimeCore.lerp(cur.x2, next.x2, t);
      y2 = window.CanvasRuntimeCore.lerp(cur.y2, next.y2, t);
      thickness = window.CanvasRuntimeCore.lerp(cur.thickness, next.thickness, t);
      color = window.CanvasRuntimeCore.lerpColor(cur.color, next.color, t);
    }

    drawLine(ctx, x1, y1, x2, y2, thickness, color);
  }

  function drawAnimPoint(ctx, track, nowMs) {
    const cur = currentTrackFrame(track);
    if (!cur) {
      return;
    }

    let x = cur.x;
    let y = cur.y;
    let color = cur.color;
    if (cur.interpolateToNext && track.frames.length > 1) {
      const next = track.frames[(track.frame + 1) % track.frames.length];
      const t = frameProgress(track, cur, nowMs);
      x = window.CanvasRuntimeCore.lerp(cur.x, next.x, t);
      y = window.CanvasRuntimeCore.lerp(cur.y, next.y, t);
      color = window.CanvasRuntimeCore.lerpColor(cur.color, next.color, t);
    }

    drawPoint(ctx, x, y, color);
  }

  function drawAnimText(ctx, track, nowMs) {
    const cur = currentTrackFrame(track);
    if (!cur) {
      return;
    }

    let x = cur.x;
    let y = cur.y;
    let size = cur.size;
    let color = cur.color;
    if (cur.interpolateToNext && track.frames.length > 1) {
      const next = track.frames[(track.frame + 1) % track.frames.length];
      const t = frameProgress(track, cur, nowMs);
      x = window.CanvasRuntimeCore.lerp(cur.x, next.x, t);
      y = window.CanvasRuntimeCore.lerp(cur.y, next.y, t);
      size = Math.max(1, Math.round(window.CanvasRuntimeCore.lerp(cur.size, next.size, t)));
      color = window.CanvasRuntimeCore.lerpColor(cur.color, next.color, t);
    }

    drawText(ctx, x, y, size, color, cur.text);
  }

  function drawAnimPixels(ctx, track) {
    if (track.rects.length <= 0 || track.frameCount <= 0) {
      return;
    }
    const frame = track.frame % track.frameCount;
    let i = 0;
    while (i < track.rects.length) {
      const rect = track.rects[i];
      if (rect.frame === frame) {
        drawRect(ctx, rect.x, rect.y, rect.w, rect.h, rect.color);
      }
      i += 1;
    }
  }

  function renderScene(ctx, canvas, state, nowMs) {
    drawBackground(ctx, canvas);

    let i = 0;
    while (i < state.drawOrder.length) {
      drawStaticItem(ctx, state.drawOrder[i]);
      i += 1;
    }

    drawAnimCircle(ctx, state.anim.circle, nowMs);
    drawAnimTriangle(ctx, state.anim.triangle, nowMs);
    drawAnimRect(ctx, state.anim.rect, nowMs);
    drawAnimLine(ctx, state.anim.line, nowMs);
    drawAnimPoint(ctx, state.anim.point, nowMs);
    drawAnimText(ctx, state.anim.text, nowMs);
    drawAnimPixels(ctx, state.anim.pixels);
  }

  window.CanvasRuntimeRender = {
    drawBackground,
    renderScene
  };
})();
