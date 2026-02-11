static void capture_input(Runtime *rt) {
    long long nowMs = (long long)llround(GetTime() * 1000.0);
    Vector2 mousePos = GetMousePosition();
    int mouseX = (int)lroundf(mousePos.x);
    int mouseY = (int)lroundf(mousePos.y);

    if (!rt->hasPrevMouse) {
        rt->prevMouseX = mouseX;
        rt->prevMouseY = mouseY;
        rt->hasPrevMouse = true;
    }

    int mouseDx = mouseX - rt->prevMouseX;
    int mouseDy = mouseY - rt->prevMouseY;
    if (mouseDx != 0 || mouseDy != 0) {
        event_queue_push(rt, nowMs, "mouse_move", mouseX, mouseY, mouseDx, mouseDy);
    }
    event_queue_push(rt, nowMs, "mouse_state", mouseX, mouseY, mouseDx, mouseDy);
    rt->prevMouseX = mouseX;
    rt->prevMouseY = mouseY;

    for (int button = 0; button <= 6; button++) {
        if (IsMouseButtonPressed(button)) {
            event_queue_push(rt, nowMs, "mouse_down", button, mouseX, mouseY, 0);
        }
        if (IsMouseButtonReleased(button)) {
            event_queue_push(rt, nowMs, "mouse_up", button, mouseX, mouseY, 0);
        }
    }

    float wheel = GetMouseWheelMove();
    if (fabsf(wheel) > 0.0001f) {
        event_queue_push(rt, nowMs, "mouse_wheel", (int)lroundf(wheel * 1000.0f), mouseX, mouseY, 0);
    }

    for (;;) {
        int key = GetKeyPressed();
        if (key <= 0) {
            break;
        }
        event_queue_push(rt, nowMs, "key_down", key, 0, 0, 0);
    }

    for (;;) {
        int codepoint = GetCharPressed();
        if (codepoint <= 0) {
            break;
        }
        event_queue_push(rt, nowMs, "char_input", codepoint, 0, 0, 0);
    }

    if (IsWindowResized()) {
        event_queue_push(rt, nowMs, "window_resize", GetScreenWidth(), GetScreenHeight(), 0, 0);
    }

    bool isWindowFocused = IsWindowFocused();
    if (isWindowFocused != rt->lastWindowFocused) {
        event_queue_push(rt, nowMs, "window_focus", isWindowFocused ? 1 : 0, 0, 0, 0);
        rt->lastWindowFocused = isWindowFocused;
    }
}

static void advance_anim_track(AnimState *state, int count, int rateMs, double now) {
    if (count > 0) {
        anim_state_advance(state, count, rateMs, now);
    }
}

static void advance_anims(Runtime *rt) {
    double now = GetTime();
    if (rt->animCircleCount > 0) {
        advance_anim_track(&rt->animCircleState, rt->animCircleCount, rt->animCircleFrames[rt->animCircleState.frame].rateMs, now);
    }
    if (rt->animTriangleCount > 0) {
        advance_anim_track(&rt->animTriangleState, rt->animTriangleCount, rt->animTriangleFrames[rt->animTriangleState.frame].rateMs, now);
    }
    if (rt->animRectCount > 0) {
        advance_anim_track(&rt->animRectState, rt->animRectCount, rt->animRectFrames[rt->animRectState.frame].rateMs, now);
    }
    if (rt->animLineCount > 0) {
        advance_anim_track(&rt->animLineState, rt->animLineCount, rt->animLineFrames[rt->animLineState.frame].rateMs, now);
    }
    if (rt->animPointCount > 0) {
        advance_anim_track(&rt->animPointState, rt->animPointCount, rt->animPointFrames[rt->animPointState.frame].rateMs, now);
    }
    if (rt->animTextCount > 0) {
        advance_anim_track(&rt->animTextState, rt->animTextCount, rt->animTextFrames[rt->animTextState.frame].rateMs, now);
    }
    if (rt->animPixelFrameCount > 0) {
        advance_anim_track(&rt->animPixelState, rt->animPixelFrameCount, rt->animPixelRateMs, now);
    }
}

static void draw_static_shapes(Runtime *rt) {
    for (int i = 0; i < rt->drawOrderCount; i++) {
        DrawItem it = rt->drawOrder[i];
        switch ((PrimitiveKind)it.kind) {
        case PRIM_TRIANGLE:
            if (it.index >= 0 && it.index < rt->triangleCount) {
                DrawTriangle(rt->triangles[it.index].a, rt->triangles[it.index].b, rt->triangles[it.index].c, rt->triangles[it.index].color);
            }
            break;
        case PRIM_CIRCLE:
            if (it.index >= 0 && it.index < rt->circleCount) {
                DrawCircleV(rt->circles[it.index].center, rt->circles[it.index].radius, rt->circles[it.index].color);
            }
            break;
        case PRIM_RECT:
            if (it.index >= 0 && it.index < rt->rectCount) {
                DrawRectangleV(rt->rects[it.index].position, rt->rects[it.index].size, rt->rects[it.index].color);
            }
            break;
        case PRIM_LINE:
            if (it.index >= 0 && it.index < rt->lineCount) {
                DrawLineEx(rt->lines[it.index].start, rt->lines[it.index].end, rt->lines[it.index].thickness, rt->lines[it.index].color);
            }
            break;
        case PRIM_PIXEL:
            if (it.index >= 0 && it.index < rt->pixelCount) {
                DrawPixelV(rt->pixels[it.index].position, rt->pixels[it.index].color);
            }
            break;
        case PRIM_PIXEL_BLIT:
            if (it.index >= 0 && it.index < rt->pixelBlitCount) {
                PixelBlit *b = &rt->pixelBlits[it.index];
                if (b->texture.id > 0) {
                    DrawTexturePro(b->texture, b->src, b->dst, (Vector2){0.0f, 0.0f}, 0.0f, b->tint);
                }
            }
            break;
        case PRIM_TEXT:
            if (it.index >= 0 && it.index < rt->textCount) {
                DrawText(rt->texts[it.index].text, (int)roundf(rt->texts[it.index].position.x), (int)roundf(rt->texts[it.index].position.y), rt->texts[it.index].size, rt->texts[it.index].color);
            }
            break;
        default:
            break;
        }
    }
}

static void draw_anim_circle(Runtime *rt) {
    if (rt->animCircleCount <= 0) {
        return;
    }
    int i = rt->animCircleState.frame % rt->animCircleCount;
    AnimCircleFrame cur = rt->animCircleFrames[i];
    if (cur.interpolateToNext && rt->animCircleCount > 1) {
        int nextIdx = (i + 1) % rt->animCircleCount;
        AnimCircleFrame next = rt->animCircleFrames[nextIdx];
        float t = anim_progress(&rt->animCircleState, cur.rateMs);
        DrawCircleV((Vector2){lerpf(cur.x, next.x, t), lerpf(cur.y, next.y, t)}, lerpf(cur.r, next.r, t), lerp_color(cur.color, next.color, t));
        return;
    }
    DrawCircleV((Vector2){cur.x, cur.y}, cur.r, cur.color);
}

static void draw_anim_triangle(Runtime *rt) {
    if (rt->animTriangleCount <= 0) {
        return;
    }
    int i = rt->animTriangleState.frame % rt->animTriangleCount;
    AnimTriangleFrame cur = rt->animTriangleFrames[i];
    if (cur.interpolateToNext && rt->animTriangleCount > 1) {
        int nextIdx = (i + 1) % rt->animTriangleCount;
        AnimTriangleFrame next = rt->animTriangleFrames[nextIdx];
        float t = anim_progress(&rt->animTriangleState, cur.rateMs);
        draw_triangle_center(lerpf(cur.x, next.x, t), lerpf(cur.y, next.y, t), lerpf(cur.r, next.r, t), lerp_color(cur.color, next.color, t));
        return;
    }
    draw_triangle_center(cur.x, cur.y, cur.r, cur.color);
}

static void draw_anim_rect(Runtime *rt) {
    if (rt->animRectCount <= 0) {
        return;
    }
    int i = rt->animRectState.frame % rt->animRectCount;
    AnimRectFrame cur = rt->animRectFrames[i];
    if (cur.interpolateToNext && rt->animRectCount > 1) {
        int nextIdx = (i + 1) % rt->animRectCount;
        AnimRectFrame next = rt->animRectFrames[nextIdx];
        float t = anim_progress(&rt->animRectState, cur.rateMs);
        DrawRectangleV((Vector2){lerpf(cur.x, next.x, t), lerpf(cur.y, next.y, t)}, (Vector2){lerpf(cur.w, next.w, t), lerpf(cur.h, next.h, t)}, lerp_color(cur.color, next.color, t));
        return;
    }
    DrawRectangleV((Vector2){cur.x, cur.y}, (Vector2){cur.w, cur.h}, cur.color);
}

static void draw_anim_line(Runtime *rt) {
    if (rt->animLineCount <= 0) {
        return;
    }
    int i = rt->animLineState.frame % rt->animLineCount;
    AnimLineFrame cur = rt->animLineFrames[i];
    if (cur.interpolateToNext && rt->animLineCount > 1) {
        int nextIdx = (i + 1) % rt->animLineCount;
        AnimLineFrame next = rt->animLineFrames[nextIdx];
        float t = anim_progress(&rt->animLineState, cur.rateMs);
        DrawLineEx((Vector2){lerpf(cur.x1, next.x1, t), lerpf(cur.y1, next.y1, t)}, (Vector2){lerpf(cur.x2, next.x2, t), lerpf(cur.y2, next.y2, t)}, lerpf(cur.thickness, next.thickness, t), lerp_color(cur.color, next.color, t));
        return;
    }
    DrawLineEx((Vector2){cur.x1, cur.y1}, (Vector2){cur.x2, cur.y2}, cur.thickness, cur.color);
}

static void draw_anim_point(Runtime *rt) {
    if (rt->animPointCount <= 0) {
        return;
    }
    int i = rt->animPointState.frame % rt->animPointCount;
    AnimPointFrame cur = rt->animPointFrames[i];
    if (cur.interpolateToNext && rt->animPointCount > 1) {
        int nextIdx = (i + 1) % rt->animPointCount;
        AnimPointFrame next = rt->animPointFrames[nextIdx];
        float t = anim_progress(&rt->animPointState, cur.rateMs);
        DrawPixelV((Vector2){lerpf(cur.x, next.x, t), lerpf(cur.y, next.y, t)}, lerp_color(cur.color, next.color, t));
        return;
    }
    DrawPixelV((Vector2){cur.x, cur.y}, cur.color);
}

static void draw_anim_text(Runtime *rt) {
    if (rt->animTextCount <= 0) {
        return;
    }
    int i = rt->animTextState.frame % rt->animTextCount;
    AnimTextFrame cur = rt->animTextFrames[i];
    if (cur.interpolateToNext && rt->animTextCount > 1) {
        int nextIdx = (i + 1) % rt->animTextCount;
        AnimTextFrame next = rt->animTextFrames[nextIdx];
        float t = anim_progress(&rt->animTextState, cur.rateMs);
        float x = lerpf(cur.x, next.x, t);
        float y = lerpf(cur.y, next.y, t);
        int size = (int)lroundf(lerpf((float)cur.size, (float)next.size, t));
        if (size < 1) {
            size = 1;
        }
        DrawText(cur.text, (int)lroundf(x), (int)lroundf(y), size, lerp_color(cur.color, next.color, t));
        return;
    }
    DrawText(cur.text, (int)lroundf(cur.x), (int)lroundf(cur.y), cur.size, cur.color);
}

static void draw_anim_pixels(Runtime *rt) {
    if (rt->animPixelRectCount <= 0 || rt->animPixelFrameCount <= 0) {
        return;
    }
    int curFrame = rt->animPixelState.frame % rt->animPixelFrameCount;
    for (int i = 0; i < rt->animPixelRectCount; i++) {
        if (rt->animPixelRects[i].frame == curFrame) {
            DrawRectangleV(rt->animPixelRects[i].position, rt->animPixelRects[i].size, rt->animPixelRects[i].color);
        }
    }
}

static void draw_overlay(Runtime *rt) {
    if (!rt->showOverlayText) {
        return;
    }

    DrawText("q + raylib command window", 225, 30, 30, DARKGRAY);
    DrawText("Per-row rate + interpolate supported", 170, 95, 20, GRAY);
    DrawText("Use .raylib.animate.stop[] / start[]", 165, 120, 20, GRAY);
    DrawText("Use .raylib.clear[] to clear shapes", 215, 145, 20, GRAY);
    DrawText("Use .raylib.close[] to close window", 225, 170, 20, GRAY);

    int total = rt->triangleCount + rt->circleCount + rt->rectCount + rt->lineCount + rt->pixelCount + rt->textCount;
    total += rt->pixelBlitCount;
    total += rt->animCircleCount + rt->animTriangleCount + rt->animRectCount + rt->animLineCount + rt->animPointCount + rt->animTextCount;
    total += rt->animPixelRectCount;
    if (total == 0) {
        DrawText("No primitives yet", 315, 210, 28, LIGHTGRAY);
    } else {
        DrawText(TextFormat("Primitives/frames: %i", total), 280, 400, 24, DARKGRAY);
    }
    DrawText("Close window or press Esc", 260, 425, 20, GRAY);
}

static void draw_frame(Runtime *rt) {
    BeginDrawing();
    ClearBackground(RAYWHITE);

    draw_static_shapes(rt);
    draw_anim_circle(rt);
    draw_anim_triangle(rt);
    draw_anim_rect(rt);
    draw_anim_line(rt);
    draw_anim_point(rt);
    draw_anim_text(rt);
    draw_anim_pixels(rt);
    draw_overlay(rt);

    EndDrawing();
}

static void runtime_init(Runtime *rt) {
    if (rt->initialized) {
        return;
    }
    memset(rt, 0, sizeof(*rt));
    rt->showOverlayText = true;
    rt->animPixelRateMs = 100;
    rt->eventNextSeq = 1ULL;

    int targetFps = 240;
    const char *fpsEnv = getenv("RAYLIB_Q_TARGET_FPS");

    SetTraceLogLevel(LOG_ERROR);
    InitWindow(800, 450, "raylib window from q");
    if (fpsEnv != NULL && *fpsEnv != '\0') {
        int v = atoi(fpsEnv);
        if (v >= 1 && v <= 2000) {
            targetFps = v;
        }
    }
    SetTargetFPS(targetFps);
    rt->lastWindowFocused = IsWindowFocused();

    {
        double now = GetTime();
        anim_state_reset(&rt->animCircleState, now);
        anim_state_reset(&rt->animTriangleState, now);
        anim_state_reset(&rt->animRectState, now);
        anim_state_reset(&rt->animLineState, now);
        anim_state_reset(&rt->animPointState, now);
        anim_state_reset(&rt->animTextState, now);
        anim_state_reset(&rt->animPixelState, now);
    }

    rt->initialized = true;
}

static void runtime_close(Runtime *rt) {
    if (!rt->initialized) {
        return;
    }
    clear_pixel_blits(rt);
    CloseWindow();
    // Keep queued close/input events available for rq_poll_events[] after shutdown.
    // runtime_init() fully resets state on next open.
    rt->initialized = false;
    rt->shouldClose = false;
    rt->hasPrevMouse = false;
    rt->lastWindowFocused = false;
}

static void runtime_pump_once(Runtime *rt) {
    if (!rt->initialized) {
        return;
    }

    if (WindowShouldClose()) {
        event_queue_push(rt, (long long)llround(GetTime() * 1000.0), "window_close", 1, 0, 0, 0);
        runtime_close(rt);
        return;
    }

    capture_input(rt);
    advance_anims(rt);
    draw_frame(rt);

    if (rt->shouldClose) {
        runtime_close(rt);
    }
}

static K events_to_text(Runtime *rt) {
    size_t cap = 256 + (size_t)(rt->eventCount + 2) * 96;
    char *buf = (char *)malloc(cap);
    if (buf == NULL) {
        return kpn("", 0);
    }

    size_t len = 0;
    if (rt->eventDropped > 0ULL) {
        int droppedCount = rt->eventDropped > (unsigned long long)INT_MAX ? INT_MAX : (int)(rt->eventDropped);
        long long nowMs = (long long)llround(GetTime() * 1000.0);
        int n = snprintf(buf + len, cap - len, "%llu|%lld|dropped|%d|0|0|0\n", rt->eventNextSeq++, nowMs, droppedCount);
        if (n > 0) {
            len += (size_t)n;
        }
        rt->eventDropped = 0ULL;
    }

    for (int i = 0; i < rt->eventCount; i++) {
        int idx = (rt->eventHead + i) % EVENT_QUEUE_CAP;
        const InputEvent *ev = &rt->eventQueue[idx];
        int n = snprintf(buf + len, cap - len, "%llu|%lld|%s|%d|%d|%d|%d\n", ev->seq, ev->timeMs, ev->type, ev->a, ev->b, ev->c, ev->d);
        if (n > 0) {
            len += (size_t)n;
        }
        if (len + 128 >= cap) {
            cap *= 2;
            char *grown = (char *)realloc(buf, cap);
            if (grown == NULL) {
                break;
            }
            buf = grown;
        }
    }

    K out = kpn(buf, (J)len);
    free(buf);
    rt->eventHead = 0;
    rt->eventCount = 0;
    return out;
}

K rq_init(K x) {
    (void)x;
    runtime_init(&g_rt);
    return kb(g_rt.initialized ? 1 : 0);
}

K rq_is_open(K x) {
    (void)x;
    return kb(g_rt.initialized ? 1 : 0);
}

K rq_version(K x) {
    (void)x;
    return kpn(RAYLIB_Q_RUNTIME_VERSION, (J)strlen(RAYLIB_Q_RUNTIME_VERSION));
}

K rq_submit(K x) {
    runtime_init(&g_rt);
    if (!g_rt.initialized) {
        return kb(0);
    }

    if (x->t == 0) {
        if (x->n > 0 && kK(x)[0] != NULL && kK(x)[0]->t == -KS) {
            (void)process_command(&g_rt, x);
        } else {
            for (J i = 0; i < x->n; i++) {
                (void)process_command(&g_rt, kK(x)[i]);
            }
        }
        return ki(0);
    }

    if (x->t == KC) {
        const char *src = (const char *)kC(x);
        J n = x->n;
        char line[1024];
        int li = 0;

        for (J i = 0; i < n; i++) {
            char c = src[i];
            if (c == '\r') {
                continue;
            }
            if (c == '\n') {
                line[li] = '\0';
                if (li > 0) {
                    (void)process_message(&g_rt, line);
                }
                li = 0;
                continue;
            }
            if (li < (int)sizeof(line) - 1) {
                line[li++] = c;
            }
        }
        if (li > 0) {
            line[li] = '\0';
            (void)process_message(&g_rt, line);
        }
        return ki(0);
    }

    return krr("type");
}

K rq_pump(K x) {
    (void)x;
    runtime_pump_once(&g_rt);
    return kb(g_rt.initialized ? 1 : 0);
}

K rq_poll_events(K x) {
    (void)x;
    if (g_rt.eventCount <= 0 && g_rt.eventDropped == 0ULL) {
        return kpn("", 0);
    }
    return events_to_text(&g_rt);
}

K rq_clear_events(K x) {
    (void)x;
    event_queue_clear(&g_rt);
    return ki(0);
}

K rq_close(K x) {
    (void)x;
    int wasOpen = g_rt.initialized ? 1 : 0;
    if (g_rt.initialized) {
        event_queue_push(&g_rt, (long long)llround(GetTime() * 1000.0), "window_close", 1, 0, 0, 0);
    }
    runtime_close(&g_rt);
    return kb(wasOpen);
}
