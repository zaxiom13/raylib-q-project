static int parse_q_command(K cmd, const char **opOut, K **argsOut, J *argcOut) {
    if (cmd == NULL || opOut == NULL || argsOut == NULL || argcOut == NULL) {
        return 0;
    }

    *opOut = NULL;
    *argsOut = NULL;
    *argcOut = 0;

    if (cmd->t == -KS && cmd->s != NULL) {
        *opOut = cmd->s;
        return 1;
    }

    if (cmd->t == KS) {
        if (cmd->n != 1) {
            return 0;
        }
        S *syms = kS(cmd);
        if (syms == NULL || syms[0] == NULL) {
            return 0;
        }
        *opOut = syms[0];
        return 1;
    }

    if (cmd->t == 0) {
        if (cmd->n < 1) {
            return 0;
        }
        K *items = kK(cmd);
        if (items == NULL || items[0] == NULL || items[0]->t != -KS || items[0]->s == NULL) {
            return 0;
        }
        *opOut = items[0]->s;
        *argsOut = items + 1;
        *argcOut = cmd->n - 1;
        return 1;
    }

    return 0;
}

static int process_basic_q_command(Runtime *rt, const char *op) {
    if (strcmp(op, "clear") == 0) {
        clear_scene(rt);
        return 1;
    }
    if (strcmp(op, "close") == 0) {
        event_queue_push(rt, (long long)llround(GetTime() * 1000.0), "window_close", 1, 0, 0, 0);
        rt->shouldClose = true;
        return 1;
    }
    if (strcmp(op, "ping") == 0 || strcmp(op, "eventDrain") == 0) {
        return 1;
    }
    if (strcmp(op, "eventClear") == 0) {
        event_queue_clear(rt);
        return 1;
    }
    return 0;
}

static int process_anim_control_q(const char *op, const char *clearOp, const char *playOp, const char *stopOp, int count, AnimState *state, int *targetCount) {
    if (strcmp(op, clearOp) == 0) {
        *targetCount = 0;
        anim_state_reset(state, GetTime());
        return 1;
    }
    if (strcmp(op, playOp) == 0) {
        anim_state_start(state, count > 0, GetTime());
        return 1;
    }
    if (strcmp(op, stopOp) == 0) {
        anim_state_stop(state);
        return 1;
    }
    return 0;
}

static int process_command(Runtime *rt, K cmd) {
    const char *op = NULL;
    K *args = NULL;
    J argc = 0;
    if (!parse_q_command(cmd, &op, &args, &argc)) {
        return 0;
    }

    if (process_basic_q_command(rt, op)) {
        return 1;
    }

    // Animation commands are grouped first so static draw commands remain easy
    // to scan separately.
    if (process_anim_control_q(op, "animCircleClear", "animCirclePlay", "animCircleStop", rt->animCircleCount, &rt->animCircleState, &rt->animCircleCount)) {
        return 1;
    }
    if (strcmp(op, "animCircleAdd") == 0) {
        float x, y, r;
        int rateMs, interp;
        Color color;
        if (argc >= 9 && k_get_float(args[0], &x) && k_get_float(args[1], &y) && k_get_float(args[2], &r) && k_get_color4(args, argc, 3, &color) &&
            k_get_int(args[7], &rateMs) && k_get_int(args[8], &interp)) {
            if (rt->animCircleCount < (int)(sizeof(rt->animCircleFrames) / sizeof(rt->animCircleFrames[0])) && r > 0.0f) {
                rt->animCircleFrames[rt->animCircleCount++] = (AnimCircleFrame){
                    .rateMs = clamp_rate_ms(rateMs),
                    .interpolateToNext = interp != 0,
                    .x = x,
                    .y = y,
                    .r = r,
                    .color = color};
            }
        }
        return 1;
    }

    if (process_anim_control_q(op, "animTriangleClear", "animTrianglePlay", "animTriangleStop", rt->animTriangleCount, &rt->animTriangleState, &rt->animTriangleCount)) {
        return 1;
    }
    if (strcmp(op, "animTriangleAdd") == 0) {
        float x, y, r;
        int rateMs, interp;
        Color color;
        if (argc >= 9 && k_get_float(args[0], &x) && k_get_float(args[1], &y) && k_get_float(args[2], &r) && k_get_color4(args, argc, 3, &color) &&
            k_get_int(args[7], &rateMs) && k_get_int(args[8], &interp)) {
            if (rt->animTriangleCount < (int)(sizeof(rt->animTriangleFrames) / sizeof(rt->animTriangleFrames[0])) && r > 0.0f) {
                rt->animTriangleFrames[rt->animTriangleCount++] = (AnimTriangleFrame){
                    .rateMs = clamp_rate_ms(rateMs),
                    .interpolateToNext = interp != 0,
                    .x = x,
                    .y = y,
                    .r = r,
                    .color = color};
            }
        }
        return 1;
    }

    if (process_anim_control_q(op, "animRectClear", "animRectPlay", "animRectStop", rt->animRectCount, &rt->animRectState, &rt->animRectCount)) {
        return 1;
    }
    if (strcmp(op, "animRectAdd") == 0) {
        float x, y, w, h;
        int rateMs, interp;
        Color color;
        if (argc >= 10 && k_get_float(args[0], &x) && k_get_float(args[1], &y) && k_get_float(args[2], &w) && k_get_float(args[3], &h) &&
            k_get_color4(args, argc, 4, &color) && k_get_int(args[8], &rateMs) && k_get_int(args[9], &interp)) {
            if (rt->animRectCount < (int)(sizeof(rt->animRectFrames) / sizeof(rt->animRectFrames[0])) && w > 0.0f && h > 0.0f) {
                rt->animRectFrames[rt->animRectCount++] = (AnimRectFrame){
                    .rateMs = clamp_rate_ms(rateMs),
                    .interpolateToNext = interp != 0,
                    .x = x,
                    .y = y,
                    .w = w,
                    .h = h,
                    .color = color};
            }
        }
        return 1;
    }

    if (process_anim_control_q(op, "animLineClear", "animLinePlay", "animLineStop", rt->animLineCount, &rt->animLineState, &rt->animLineCount)) {
        return 1;
    }
    if (strcmp(op, "animLineAdd") == 0) {
        float x1, y1, x2, y2, thickness;
        int rateMs, interp;
        Color color;
        if (argc >= 11 && k_get_float(args[0], &x1) && k_get_float(args[1], &y1) && k_get_float(args[2], &x2) && k_get_float(args[3], &y2) &&
            k_get_float(args[4], &thickness) && k_get_color4(args, argc, 5, &color) && k_get_int(args[9], &rateMs) && k_get_int(args[10], &interp)) {
            if (rt->animLineCount < (int)(sizeof(rt->animLineFrames) / sizeof(rt->animLineFrames[0])) && thickness > 0.0f) {
                rt->animLineFrames[rt->animLineCount++] = (AnimLineFrame){
                    .rateMs = clamp_rate_ms(rateMs),
                    .interpolateToNext = interp != 0,
                    .x1 = x1,
                    .y1 = y1,
                    .x2 = x2,
                    .y2 = y2,
                    .thickness = thickness,
                    .color = color};
            }
        }
        return 1;
    }

    if (process_anim_control_q(op, "animPointClear", "animPointPlay", "animPointStop", rt->animPointCount, &rt->animPointState, &rt->animPointCount)) {
        return 1;
    }
    if (strcmp(op, "animPointAdd") == 0) {
        float x, y;
        int rateMs, interp;
        Color color;
        if (argc >= 8 && k_get_float(args[0], &x) && k_get_float(args[1], &y) && k_get_color4(args, argc, 2, &color) && k_get_int(args[6], &rateMs) &&
            k_get_int(args[7], &interp)) {
            if (rt->animPointCount < (int)(sizeof(rt->animPointFrames) / sizeof(rt->animPointFrames[0]))) {
                rt->animPointFrames[rt->animPointCount++] = (AnimPointFrame){
                    .rateMs = clamp_rate_ms(rateMs),
                    .interpolateToNext = interp != 0,
                    .x = x,
                    .y = y,
                    .color = color};
            }
        }
        return 1;
    }

    if (process_anim_control_q(op, "animTextClear", "animTextPlay", "animTextStop", rt->animTextCount, &rt->animTextState, &rt->animTextCount)) {
        return 1;
    }
    if (strcmp(op, "animTextAdd") == 0) {
        float x, y;
        int size, rateMs, interp;
        char payload[128];
        Color color;
        if (argc >= 10 && k_get_float(args[0], &x) && k_get_float(args[1], &y) && k_get_int(args[2], &size) && k_get_color4(args, argc, 3, &color) &&
            k_get_int(args[7], &rateMs) && k_get_int(args[8], &interp) && k_get_text(args[9], payload, sizeof(payload))) {
            if (rt->animTextCount < (int)(sizeof(rt->animTextFrames) / sizeof(rt->animTextFrames[0])) && size > 0 && payload[0] != '\0') {
                rt->animTextFrames[rt->animTextCount] = (AnimTextFrame){
                    .rateMs = clamp_rate_ms(rateMs),
                    .interpolateToNext = interp != 0,
                    .x = x,
                    .y = y,
                    .size = size,
                    .color = color};
                strncpy(rt->animTextFrames[rt->animTextCount].text, payload, sizeof(rt->animTextFrames[rt->animTextCount].text) - 1);
                rt->animTextFrames[rt->animTextCount].text[sizeof(rt->animTextFrames[rt->animTextCount].text) - 1] = '\0';
                rt->animTextCount++;
            }
        }
        return 1;
    }

    if (strcmp(op, "animPixelsClear") == 0) {
        rt->animPixelRectCount = 0;
        rt->animPixelFrameCount = 0;
        rt->animPixelRateMs = 100;
        anim_state_reset(&rt->animPixelState, GetTime());
        return 1;
    }
    if (strcmp(op, "animPixelsPlay") == 0) {
        anim_state_start(&rt->animPixelState, rt->animPixelFrameCount > 0, GetTime());
        return 1;
    }
    if (strcmp(op, "animPixelsStop") == 0) {
        anim_state_stop(&rt->animPixelState);
        return 1;
    }
    if (strcmp(op, "animPixelsRate") == 0) {
        int rateMs;
        if (argc >= 1 && k_get_int(args[0], &rateMs)) {
            rt->animPixelRateMs = clamp_rate_ms(rateMs);
        }
        return 1;
    }
    if (strcmp(op, "animPixelsAdd") == 0) {
        int frame;
        float x, y, w, h;
        Color color;
        if (argc >= 9 && k_get_int(args[0], &frame) && k_get_float(args[1], &x) && k_get_float(args[2], &y) && k_get_float(args[3], &w) &&
            k_get_float(args[4], &h) && k_get_color4(args, argc, 5, &color)) {
            if (frame >= 0 && w > 0.0f && h > 0.0f && rt->animPixelRectCount < (int)(sizeof(rt->animPixelRects) / sizeof(rt->animPixelRects[0]))) {
                rt->animPixelRects[rt->animPixelRectCount++] = (AnimPixelRect){
                    .frame = frame,
                    .position = {x, y},
                    .size = {w, h},
                    .color = color};
                if (frame + 1 > rt->animPixelFrameCount) {
                    rt->animPixelFrameCount = frame + 1;
                }
            }
        }
        return 1;
    }

    if (strcmp(op, "addPixelsBlit") == 0) {
        float x, y, dw, dh;
        int alpha, w, h, kind;
        unsigned char *src = NULL;
        int srcLen = 0;
        if (argc >= 9 && k_get_float(args[0], &x) && k_get_float(args[1], &y) && k_get_float(args[2], &dw) && k_get_float(args[3], &dh) &&
            k_get_int(args[4], &alpha) && k_get_int(args[5], &w) && k_get_int(args[6], &h) && k_get_int(args[7], &kind) &&
            k_list_to_u8(args[8], &src, &srcLen)) {
            int chans = (kind == 1 || kind == 3 || kind == 4) ? kind : 0;
            int pixCount = (w > 0 && h > 0) ? (w * h) : 0;
            int expected = (chans > 0 && pixCount > 0) ? (pixCount * chans) : 0;
            if (dw > 0.0f && dh > 0.0f && expected > 0 && expected == srcLen && rt->pixelBlitCount < (int)(sizeof(rt->pixelBlits) / sizeof(rt->pixelBlits[0]))) {
                Color *rgba = (Color *)malloc((size_t)pixCount * sizeof(Color));
                if (rgba != NULL) {
                    unsigned char aMul = clamp_u8_int(alpha);
                    for (int i = 0; i < pixCount; i++) {
                        int base = i * chans;
                        unsigned char r = src[base];
                        unsigned char g = (chans == 1) ? r : src[base + 1];
                        unsigned char b = (chans == 1) ? r : src[base + 2];
                        unsigned char a = 255;
                        if (chans == 4) {
                            a = clamp_u8_int(((int)src[base + 3] * (int)aMul) / 255);
                        } else {
                            a = aMul;
                        }
                        rgba[i] = (Color){.r = r, .g = g, .b = b, .a = a};
                    }
                    Image img = {.data = rgba, .width = w, .height = h, .mipmaps = 1, .format = PIXELFORMAT_UNCOMPRESSED_R8G8B8A8};
                    Texture2D tex = LoadTextureFromImage(img);
                    free(rgba);
                    if (tex.id > 0) {
                        SetTextureFilter(tex, TEXTURE_FILTER_POINT);
                        int idx = rt->pixelBlitCount++;
                        rt->pixelBlits[idx] = (PixelBlit){
                            .texture = tex,
                            .src = {0.0f, 0.0f, (float)w, (float)h},
                            .dst = {x, y, dw, dh},
                            .tint = WHITE};
                        draw_order_push(rt, PRIM_PIXEL_BLIT, idx);
                    }
                }
            }
        }
        if (src != NULL) {
            free(src);
        }
        return 1;
    }

    if (strcmp(op, "addTriangle") == 0) {
        float x, y, r;
        Color color;
        if (argc >= 7 && k_get_float(args[0], &x) && k_get_float(args[1], &y) && k_get_float(args[2], &r) && k_get_color4(args, argc, 3, &color)) {
            if (rt->triangleCount < (int)(sizeof(rt->triangles) / sizeof(rt->triangles[0])) && r > 0.0f) {
                float dx = 0.8660254f * r;
                int idx = rt->triangleCount++;
                rt->triangles[idx] = (Triangle){
                    .a = {x, y - r},
                    .b = {x - dx, y + 0.5f * r},
                    .c = {x + dx, y + 0.5f * r},
                    .color = color};
                draw_order_push(rt, PRIM_TRIANGLE, idx);
            }
        }
        return 1;
    }
    if (strcmp(op, "addCircle") == 0) {
        float x, y, r;
        Color color;
        if (argc >= 7 && k_get_float(args[0], &x) && k_get_float(args[1], &y) && k_get_float(args[2], &r) && k_get_color4(args, argc, 3, &color)) {
            if (rt->circleCount < (int)(sizeof(rt->circles) / sizeof(rt->circles[0])) && r > 0.0f) {
                int idx = rt->circleCount++;
                rt->circles[idx] = (CircleShape){
                    .center = {x, y},
                    .radius = r,
                    .color = color};
                draw_order_push(rt, PRIM_CIRCLE, idx);
            }
        }
        return 1;
    }
    if (strcmp(op, "addSquare") == 0) {
        float x, y, r;
        Color color;
        if (argc >= 7 && k_get_float(args[0], &x) && k_get_float(args[1], &y) && k_get_float(args[2], &r) && k_get_color4(args, argc, 3, &color)) {
            if (rt->rectCount < (int)(sizeof(rt->rects) / sizeof(rt->rects[0])) && r > 0.0f) {
                float side = 2.0f * r;
                int idx = rt->rectCount++;
                rt->rects[idx] = (RectShape){
                    .position = {x - r, y - r},
                    .size = {side, side},
                    .color = color};
                draw_order_push(rt, PRIM_RECT, idx);
            }
        }
        return 1;
    }
    if (strcmp(op, "addRect") == 0) {
        float x, y, w, h;
        Color color;
        if (argc >= 8 && k_get_float(args[0], &x) && k_get_float(args[1], &y) && k_get_float(args[2], &w) && k_get_float(args[3], &h) &&
            k_get_color4(args, argc, 4, &color)) {
            if (rt->rectCount < (int)(sizeof(rt->rects) / sizeof(rt->rects[0])) && w > 0.0f && h > 0.0f) {
                int idx = rt->rectCount++;
                rt->rects[idx] = (RectShape){
                    .position = {x, y},
                    .size = {w, h},
                    .color = color};
                draw_order_push(rt, PRIM_RECT, idx);
            }
        }
        return 1;
    }
    if (strcmp(op, "addLine") == 0) {
        float x1, y1, x2, y2, thickness;
        Color color;
        if (argc >= 9 && k_get_float(args[0], &x1) && k_get_float(args[1], &y1) && k_get_float(args[2], &x2) && k_get_float(args[3], &y2) &&
            k_get_float(args[4], &thickness) && k_get_color4(args, argc, 5, &color)) {
            if (rt->lineCount < (int)(sizeof(rt->lines) / sizeof(rt->lines[0])) && thickness > 0.0f) {
                int idx = rt->lineCount++;
                rt->lines[idx] = (LineShape){
                    .start = {x1, y1},
                    .end = {x2, y2},
                    .thickness = thickness,
                    .color = color};
                draw_order_push(rt, PRIM_LINE, idx);
            }
        }
        return 1;
    }
    if (strcmp(op, "addPixel") == 0) {
        float x, y;
        Color color;
        if (argc >= 6 && k_get_float(args[0], &x) && k_get_float(args[1], &y) && k_get_color4(args, argc, 2, &color)) {
            if (rt->pixelCount < (int)(sizeof(rt->pixels) / sizeof(rt->pixels[0]))) {
                int idx = rt->pixelCount++;
                rt->pixels[idx] = (PixelShape){
                    .position = {x, y},
                    .color = color};
                draw_order_push(rt, PRIM_PIXEL, idx);
            }
        }
        return 1;
    }
    if (strcmp(op, "addText") == 0) {
        float x, y;
        int size;
        char payload[128];
        Color color;
        if (argc >= 8 && k_get_float(args[0], &x) && k_get_float(args[1], &y) && k_get_int(args[2], &size) && k_get_color4(args, argc, 3, &color) &&
            k_get_text(args[7], payload, sizeof(payload))) {
            if (rt->textCount < (int)(sizeof(rt->texts) / sizeof(rt->texts[0])) && size > 0 && payload[0] != '\0') {
                int idx = rt->textCount;
                rt->texts[idx] = (TextShape){
                    .position = {x, y},
                    .size = size,
                    .color = color};
                strncpy(rt->texts[idx].text, payload, sizeof(rt->texts[idx].text) - 1);
                rt->texts[idx].text[sizeof(rt->texts[idx].text) - 1] = '\0';
                rt->textCount++;
                draw_order_push(rt, PRIM_TEXT, idx);
            }
        }
        return 1;
    }

    return 0;
}

