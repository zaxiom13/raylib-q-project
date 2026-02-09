static int process_basic_message(Runtime *rt, const char *msg) {
    if (strcmp(msg, "CLEAR") == 0) {
        clear_scene(rt);
        return 1;
    }
    if (strcmp(msg, "CLOSE") == 0) {
        event_queue_push(rt, (long long)llround(GetTime() * 1000.0), "window_close", 1, 0, 0, 0);
        rt->shouldClose = true;
        return 1;
    }
    if (strcmp(msg, "PING") == 0) {
        return 1;
    }
    if (strcmp(msg, "EVENT_DRAIN") == 0) {
        return 1;
    }
    if (strcmp(msg, "EVENT_CLEAR") == 0) {
        event_queue_clear(rt);
        return 1;
    }
    return 0;
}

static int process_anim_control_message(const char *msg, const char *name, int count, AnimState *state, int *targetCount) {
    char cmd[32];

    snprintf(cmd, sizeof(cmd), "%s_CLEAR", name);
    if (strcmp(msg, cmd) == 0) {
        *targetCount = 0;
        anim_state_reset(state, GetTime());
        return 1;
    }

    snprintf(cmd, sizeof(cmd), "%s_PLAY", name);
    if (strcmp(msg, cmd) == 0) {
        anim_state_start(state, count > 0, GetTime());
        return 1;
    }

    snprintf(cmd, sizeof(cmd), "%s_STOP", name);
    if (strcmp(msg, cmd) == 0) {
        anim_state_stop(state);
        return 1;
    }

    return 0;
}

static int process_message(Runtime *rt, const char *msg) {
    if (process_basic_message(rt, msg)) {
        return 1;
    }

    if (process_anim_control_message(msg, "ANIM_CIRCLE", rt->animCircleCount, &rt->animCircleState, &rt->animCircleCount)) {
        return 1;
    }
    {
        float x, y, r;
        int cr, cg, cb, ca, rateMs, interp;
        if (sscanf(msg, "ANIM_CIRCLE_ADD %f %f %f %d %d %d %d %d %d", &x, &y, &r, &cr, &cg, &cb, &ca, &rateMs, &interp) == 9) {
            if (rt->animCircleCount < (int)(sizeof(rt->animCircleFrames) / sizeof(rt->animCircleFrames[0])) && r > 0.0f) {
                rateMs = clamp_rate_ms(rateMs);
                rt->animCircleFrames[rt->animCircleCount++] = (AnimCircleFrame){
                    .rateMs = rateMs,
                    .interpolateToNext = interp != 0,
                    .x = x,
                    .y = y,
                    .r = r,
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
            }
            return 1;
        }
    }

    if (process_anim_control_message(msg, "ANIM_TRIANGLE", rt->animTriangleCount, &rt->animTriangleState, &rt->animTriangleCount)) {
        return 1;
    }
    {
        float x, y, r;
        int cr, cg, cb, ca, rateMs, interp;
        if (sscanf(msg, "ANIM_TRIANGLE_ADD %f %f %f %d %d %d %d %d %d", &x, &y, &r, &cr, &cg, &cb, &ca, &rateMs, &interp) == 9) {
            if (rt->animTriangleCount < (int)(sizeof(rt->animTriangleFrames) / sizeof(rt->animTriangleFrames[0])) && r > 0.0f) {
                rateMs = clamp_rate_ms(rateMs);
                rt->animTriangleFrames[rt->animTriangleCount++] = (AnimTriangleFrame){
                    .rateMs = rateMs,
                    .interpolateToNext = interp != 0,
                    .x = x,
                    .y = y,
                    .r = r,
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
            }
            return 1;
        }
    }

    if (process_anim_control_message(msg, "ANIM_RECT", rt->animRectCount, &rt->animRectState, &rt->animRectCount)) {
        return 1;
    }
    {
        float x, y, w, h;
        int cr, cg, cb, ca, rateMs, interp;
        if (sscanf(msg, "ANIM_RECT_ADD %f %f %f %f %d %d %d %d %d %d", &x, &y, &w, &h, &cr, &cg, &cb, &ca, &rateMs, &interp) == 10) {
            if (rt->animRectCount < (int)(sizeof(rt->animRectFrames) / sizeof(rt->animRectFrames[0])) && w > 0.0f && h > 0.0f) {
                rateMs = clamp_rate_ms(rateMs);
                rt->animRectFrames[rt->animRectCount++] = (AnimRectFrame){
                    .rateMs = rateMs,
                    .interpolateToNext = interp != 0,
                    .x = x,
                    .y = y,
                    .w = w,
                    .h = h,
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
            }
            return 1;
        }
    }

    if (process_anim_control_message(msg, "ANIM_LINE", rt->animLineCount, &rt->animLineState, &rt->animLineCount)) {
        return 1;
    }
    {
        float x1, y1, x2, y2, thickness;
        int cr, cg, cb, ca, rateMs, interp;
        if (sscanf(msg, "ANIM_LINE_ADD %f %f %f %f %f %d %d %d %d %d %d", &x1, &y1, &x2, &y2, &thickness, &cr, &cg, &cb, &ca, &rateMs, &interp) == 11) {
            if (rt->animLineCount < (int)(sizeof(rt->animLineFrames) / sizeof(rt->animLineFrames[0])) && thickness > 0.0f) {
                rateMs = clamp_rate_ms(rateMs);
                rt->animLineFrames[rt->animLineCount++] = (AnimLineFrame){
                    .rateMs = rateMs,
                    .interpolateToNext = interp != 0,
                    .x1 = x1,
                    .y1 = y1,
                    .x2 = x2,
                    .y2 = y2,
                    .thickness = thickness,
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
            }
            return 1;
        }
    }

    if (process_anim_control_message(msg, "ANIM_POINT", rt->animPointCount, &rt->animPointState, &rt->animPointCount)) {
        return 1;
    }
    {
        float x, y;
        int cr, cg, cb, ca, rateMs, interp;
        if (sscanf(msg, "ANIM_POINT_ADD %f %f %d %d %d %d %d %d", &x, &y, &cr, &cg, &cb, &ca, &rateMs, &interp) == 8) {
            if (rt->animPointCount < (int)(sizeof(rt->animPointFrames) / sizeof(rt->animPointFrames[0]))) {
                rateMs = clamp_rate_ms(rateMs);
                rt->animPointFrames[rt->animPointCount++] = (AnimPointFrame){
                    .rateMs = rateMs,
                    .interpolateToNext = interp != 0,
                    .x = x,
                    .y = y,
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
            }
            return 1;
        }
    }

    if (process_anim_control_message(msg, "ANIM_TEXT", rt->animTextCount, &rt->animTextState, &rt->animTextCount)) {
        return 1;
    }
    {
        float x, y;
        int size, cr, cg, cb, ca, rateMs, interp, consumed = 0;
        if (sscanf(msg, "ANIM_TEXT_ADD %f %f %d %d %d %d %d %d %d %n", &x, &y, &size, &cr, &cg, &cb, &ca, &rateMs, &interp, &consumed) == 9) {
            const char *payload = msg + consumed;
            if (rt->animTextCount < (int)(sizeof(rt->animTextFrames) / sizeof(rt->animTextFrames[0])) && size > 0 && *payload != '\0') {
                rateMs = clamp_rate_ms(rateMs);
                rt->animTextFrames[rt->animTextCount] = (AnimTextFrame){
                    .rateMs = rateMs,
                    .interpolateToNext = interp != 0,
                    .x = x,
                    .y = y,
                    .size = size,
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
                strncpy(rt->animTextFrames[rt->animTextCount].text, payload, sizeof(rt->animTextFrames[rt->animTextCount].text) - 1);
                rt->animTextFrames[rt->animTextCount].text[sizeof(rt->animTextFrames[rt->animTextCount].text) - 1] = '\0';
                rt->animTextCount++;
            }
            return 1;
        }
    }

    if (strcmp(msg, "ANIM_PIXELS_CLEAR") == 0) {
        rt->animPixelRectCount = 0;
        rt->animPixelFrameCount = 0;
        rt->animPixelRateMs = 100;
        anim_state_reset(&rt->animPixelState, GetTime());
        return 1;
    }
    if (strcmp(msg, "ANIM_PIXELS_PLAY") == 0) {
        anim_state_start(&rt->animPixelState, rt->animPixelFrameCount > 0, GetTime());
        return 1;
    }
    if (strcmp(msg, "ANIM_PIXELS_STOP") == 0) {
        anim_state_stop(&rt->animPixelState);
        return 1;
    }
    {
        int rateMs;
        if (sscanf(msg, "ANIM_PIXELS_RATE %d", &rateMs) == 1) {
            rt->animPixelRateMs = clamp_rate_ms(rateMs);
            return 1;
        }
    }
    {
        int frame;
        float x, y, w, h;
        int cr, cg, cb, ca;
        if (sscanf(msg, "ANIM_PIXELS_ADD %d %f %f %f %f %d %d %d %d", &frame, &x, &y, &w, &h, &cr, &cg, &cb, &ca) == 9) {
            if (frame >= 0 && w > 0.0f && h > 0.0f && rt->animPixelRectCount < (int)(sizeof(rt->animPixelRects) / sizeof(rt->animPixelRects[0]))) {
                rt->animPixelRects[rt->animPixelRectCount++] = (AnimPixelRect){
                    .frame = frame,
                    .position = {x, y},
                    .size = {w, h},
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
                if (frame + 1 > rt->animPixelFrameCount) {
                    rt->animPixelFrameCount = frame + 1;
                }
            }
            return 1;
        }
    }

    {
        float x, y, r;
        int cr, cg, cb, ca;
        if (sscanf(msg, "ADD_TRIANGLE %f %f %f %d %d %d %d", &x, &y, &r, &cr, &cg, &cb, &ca) == 7) {
            if (rt->triangleCount < (int)(sizeof(rt->triangles) / sizeof(rt->triangles[0])) && r > 0.0f) {
                float dx = 0.8660254f * r;
                int idx = rt->triangleCount++;
                rt->triangles[idx] = (Triangle){
                    .a = {x, y - r},
                    .b = {x - dx, y + 0.5f * r},
                    .c = {x + dx, y + 0.5f * r},
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
                draw_order_push(rt, PRIM_TRIANGLE, idx);
            }
            return 1;
        }
    }

    {
        float x, y, r;
        int cr, cg, cb, ca;
        if (sscanf(msg, "ADD_CIRCLE %f %f %f %d %d %d %d", &x, &y, &r, &cr, &cg, &cb, &ca) == 7) {
            if (rt->circleCount < (int)(sizeof(rt->circles) / sizeof(rt->circles[0])) && r > 0.0f) {
                int idx = rt->circleCount++;
                rt->circles[idx] = (CircleShape){
                    .center = {x, y},
                    .radius = r,
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
                draw_order_push(rt, PRIM_CIRCLE, idx);
            }
            return 1;
        }
    }

    {
        float x, y, r;
        int cr, cg, cb, ca;
        if (sscanf(msg, "ADD_SQUARE %f %f %f %d %d %d %d", &x, &y, &r, &cr, &cg, &cb, &ca) == 7) {
            if (rt->rectCount < (int)(sizeof(rt->rects) / sizeof(rt->rects[0])) && r > 0.0f) {
                float side = 2.0f * r;
                int idx = rt->rectCount++;
                rt->rects[idx] = (RectShape){
                    .position = {x - r, y - r},
                    .size = {side, side},
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
                draw_order_push(rt, PRIM_RECT, idx);
            }
            return 1;
        }
    }

    {
        float x, y, w, h;
        int cr, cg, cb, ca;
        if (sscanf(msg, "ADD_RECT %f %f %f %f %d %d %d %d", &x, &y, &w, &h, &cr, &cg, &cb, &ca) == 8) {
            if (rt->rectCount < (int)(sizeof(rt->rects) / sizeof(rt->rects[0])) && w > 0.0f && h > 0.0f) {
                int idx = rt->rectCount++;
                rt->rects[idx] = (RectShape){
                    .position = {x, y},
                    .size = {w, h},
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
                draw_order_push(rt, PRIM_RECT, idx);
            }
            return 1;
        }
    }

    {
        float x1, y1, x2, y2, thickness;
        int cr, cg, cb, ca;
        if (sscanf(msg, "ADD_LINE %f %f %f %f %f %d %d %d %d", &x1, &y1, &x2, &y2, &thickness, &cr, &cg, &cb, &ca) == 9) {
            if (rt->lineCount < (int)(sizeof(rt->lines) / sizeof(rt->lines[0])) && thickness > 0.0f) {
                int idx = rt->lineCount++;
                rt->lines[idx] = (LineShape){
                    .start = {x1, y1},
                    .end = {x2, y2},
                    .thickness = thickness,
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
                draw_order_push(rt, PRIM_LINE, idx);
            }
            return 1;
        }
    }

    {
        float x, y;
        int cr, cg, cb, ca;
        if (sscanf(msg, "ADD_PIXEL %f %f %d %d %d %d", &x, &y, &cr, &cg, &cb, &ca) == 6) {
            if (rt->pixelCount < (int)(sizeof(rt->pixels) / sizeof(rt->pixels[0]))) {
                int idx = rt->pixelCount++;
                rt->pixels[idx] = (PixelShape){
                    .position = {x, y},
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
                draw_order_push(rt, PRIM_PIXEL, idx);
            }
            return 1;
        }
    }

    {
        float x, y;
        int size, cr, cg, cb, ca, consumed = 0;
        if (sscanf(msg, "ADD_TEXT %f %f %d %d %d %d %d %n", &x, &y, &size, &cr, &cg, &cb, &ca, &consumed) == 7) {
            const char *payload = msg + consumed;
            if (rt->textCount < (int)(sizeof(rt->texts) / sizeof(rt->texts[0])) && size > 0 && *payload != '\0') {
                int idx = rt->textCount;
                rt->texts[idx] = (TextShape){
                    .position = {x, y},
                    .size = size,
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
                strncpy(rt->texts[idx].text, payload, sizeof(rt->texts[idx].text) - 1);
                rt->texts[idx].text[sizeof(rt->texts[idx].text) - 1] = '\0';
                rt->textCount++;
                draw_order_push(rt, PRIM_TEXT, idx);
            }
            return 1;
        }
    }

    if (strcmp(msg, "ADD_TRIANGLE") == 0 && rt->triangleCount < (int)(sizeof(rt->triangles) / sizeof(rt->triangles[0]))) {
        int idx = rt->triangleCount++;
        rt->triangles[idx] = (Triangle){
            .a = {400.0f, 120.0f},
            .b = {250.0f, 340.0f},
            .c = {550.0f, 340.0f},
            .color = MAROON};
        draw_order_push(rt, PRIM_TRIANGLE, idx);
        return 1;
    }

    return 0;
}

