static void draw_order_push(Runtime *rt, PrimitiveKind kind, int index) {
    if (rt->drawOrderCount >= DRAW_ORDER_CAP) {
        return;
    }
    rt->drawOrder[rt->drawOrderCount++] = (DrawItem){.kind = (unsigned char)kind, .index = index};
}

static float lerpf(float a, float b, float t) { return a + (b - a) * t; }

static unsigned char lerpuc(unsigned char a, unsigned char b, float t) {
    return (unsigned char)lroundf((float)a + ((float)b - (float)a) * t);
}

static Color lerp_color(Color a, Color b, float t) {
    return (Color){
        .r = lerpuc(a.r, b.r, t),
        .g = lerpuc(a.g, b.g, t),
        .b = lerpuc(a.b, b.b, t),
        .a = lerpuc(a.a, b.a, t)};
}

static void draw_triangle_center(float x, float y, float r, Color color) {
    float dx = 0.8660254f * r;
    Vector2 a = {x, y - r};
    Vector2 b = {x - dx, y + 0.5f * r};
    Vector2 c = {x + dx, y + 0.5f * r};
    DrawTriangle(a, b, c, color);
}

static void anim_state_reset(AnimState *state, double now) {
    state->frame = 0;
    state->elapsedMs = 0.0;
    state->lastTick = now;
    state->playing = false;
}

static void anim_state_start(AnimState *state, bool enabled, double now) {
    state->frame = 0;
    state->elapsedMs = 0.0;
    state->lastTick = now;
    state->playing = enabled;
}

static void anim_state_stop(AnimState *state) { state->playing = false; }

static void anim_state_advance(AnimState *state, int count, int currentRateMs, double now) {
    if (!state->playing || count <= 0) {
        return;
    }

    double deltaMs = (now - state->lastTick) * 1000.0;
    state->lastTick = now;
    if (deltaMs < 0.0) {
        deltaMs = 0.0;
    }
    state->elapsedMs += deltaMs;

    for (;;) {
        if (currentRateMs < 1) {
            currentRateMs = 1;
        }
        if (state->elapsedMs < (double)currentRateMs) {
            break;
        }
        state->elapsedMs -= (double)currentRateMs;
        state->frame = (state->frame + 1) % count;
    }
}

static float anim_progress(const AnimState *state, int rateMs) {
    if (!state->playing || rateMs <= 0) {
        return 0.0f;
    }
    float t = (float)(state->elapsedMs / (double)rateMs);
    if (t < 0.0f) {
        t = 0.0f;
    }
    if (t > 1.0f) {
        t = 1.0f;
    }
    return t;
}

static void event_queue_push(Runtime *rt, long long timeMs, const char *type, int a, int b, int c, int d) {
    if (rt->eventCount >= EVENT_QUEUE_CAP) {
        rt->eventHead = (rt->eventHead + 1) % EVENT_QUEUE_CAP;
        rt->eventCount = EVENT_QUEUE_CAP - 1;
        rt->eventDropped++;
    }

    int idx = (rt->eventHead + rt->eventCount) % EVENT_QUEUE_CAP;
    rt->eventQueue[idx].seq = rt->eventNextSeq++;
    rt->eventQueue[idx].timeMs = timeMs;
    strncpy(rt->eventQueue[idx].type, type, EVENT_TYPE_LEN - 1);
    rt->eventQueue[idx].type[EVENT_TYPE_LEN - 1] = '\0';
    rt->eventQueue[idx].a = a;
    rt->eventQueue[idx].b = b;
    rt->eventQueue[idx].c = c;
    rt->eventQueue[idx].d = d;
    rt->eventCount++;
}

static void event_queue_clear(Runtime *rt) {
    rt->eventHead = 0;
    rt->eventCount = 0;
    rt->eventDropped = 0ULL;
}

static unsigned char clamp_u8_int(int x) {
    if (x < 0) {
        return 0;
    }
    if (x > 255) {
        return 255;
    }
    return (unsigned char)x;
}

static int k_list_to_u8(K x, unsigned char **out, int *outLen) {
    if (x == NULL || out == NULL || outLen == NULL || x->t <= 0) {
        return 0;
    }
    if (x->t == 0 || x->n <= 0) {
        return 0;
    }

    J n = x->n;
    if (n > INT_MAX) {
        return 0;
    }
    unsigned char *buf = (unsigned char *)malloc((size_t)n);
    if (buf == NULL) {
        return 0;
    }

    switch (x->t) {
    case KB:
    case KG: {
        unsigned char *src = (unsigned char *)kG(x);
        for (J i = 0; i < n; i++) {
            buf[i] = src[i];
        }
        break;
    }
    case KH: {
        H *src = kH(x);
        for (J i = 0; i < n; i++) {
            buf[i] = clamp_u8_int((int)src[i]);
        }
        break;
    }
    case KI: {
        I *src = kI(x);
        for (J i = 0; i < n; i++) {
            buf[i] = clamp_u8_int(src[i]);
        }
        break;
    }
    case KJ: {
        J *src = kJ(x);
        for (J i = 0; i < n; i++) {
            int v = (src[i] > INT_MAX) ? INT_MAX : (src[i] < INT_MIN ? INT_MIN : (int)src[i]);
            buf[i] = clamp_u8_int(v);
        }
        break;
    }
    case KE: {
        E *src = kE(x);
        for (J i = 0; i < n; i++) {
            buf[i] = clamp_u8_int((int)lroundf(src[i]));
        }
        break;
    }
    case KF: {
        F *src = kF(x);
        for (J i = 0; i < n; i++) {
            double dv = src[i];
            if (dv > (double)INT_MAX) {
                dv = (double)INT_MAX;
            } else if (dv < (double)INT_MIN) {
                dv = (double)INT_MIN;
            }
            buf[i] = clamp_u8_int((int)llround(dv));
        }
        break;
    }
    default:
        free(buf);
        return 0;
    }

    *out = buf;
    *outLen = (int)n;
    return 1;
}

static void clear_pixel_blits(Runtime *rt) {
    for (int i = 0; i < rt->pixelBlitCount; i++) {
        if (rt->pixelBlits[i].texture.id > 0) {
            UnloadTexture(rt->pixelBlits[i].texture);
        }
    }
    rt->pixelBlitCount = 0;
}

static void clear_scene(Runtime *rt) {
    double now = GetTime();
    clear_pixel_blits(rt);
    rt->triangleCount = 0;
    rt->circleCount = 0;
    rt->rectCount = 0;
    rt->lineCount = 0;
    rt->pixelCount = 0;
    rt->textCount = 0;
    rt->drawOrderCount = 0;

    rt->animCircleCount = 0;
    rt->animTriangleCount = 0;
    rt->animRectCount = 0;
    rt->animLineCount = 0;
    rt->animPointCount = 0;
    rt->animTextCount = 0;
    rt->animPixelRectCount = 0;
    rt->animPixelFrameCount = 0;
    rt->animPixelRateMs = 100;

    anim_state_reset(&rt->animCircleState, now);
    anim_state_reset(&rt->animTriangleState, now);
    anim_state_reset(&rt->animRectState, now);
    anim_state_reset(&rt->animLineState, now);
    anim_state_reset(&rt->animPointState, now);
    anim_state_reset(&rt->animTextState, now);
    anim_state_reset(&rt->animPixelState, now);
    rt->showOverlayText = false;
}

static int clamp_rate_ms(int rateMs) {
    return rateMs < 1 ? 1 : rateMs;
}

static int k_get_int(K x, int *out) {
    if (x == NULL || out == NULL) {
        return 0;
    }
    switch (x->t) {
    case -KB:
    case -KG:
        *out = (int)x->g;
        return 1;
    case -KH:
        *out = (int)x->h;
        return 1;
    case -KI:
        *out = x->i;
        return 1;
    case -KJ:
        *out = (int)x->j;
        return 1;
    case -KE:
        *out = (int)lroundf(x->e);
        return 1;
    case -KF:
        *out = (int)llround(x->f);
        return 1;
    default:
        return 0;
    }
}

static int k_get_float(K x, float *out) {
    if (x == NULL || out == NULL) {
        return 0;
    }
    switch (x->t) {
    case -KB:
    case -KG:
        *out = (float)x->g;
        return 1;
    case -KH:
        *out = (float)x->h;
        return 1;
    case -KI:
        *out = (float)x->i;
        return 1;
    case -KJ:
        *out = (float)x->j;
        return 1;
    case -KE:
        *out = x->e;
        return 1;
    case -KF:
        *out = (float)x->f;
        return 1;
    default:
        return 0;
    }
}

static int k_get_text(K x, char *out, size_t cap) {
    if (x == NULL || out == NULL || cap == 0) {
        return 0;
    }
    if (x->t == KC) {
        size_t n = (size_t)x->n;
        if (n >= cap) {
            n = cap - 1;
        }
        memcpy(out, kC(x), n);
        out[n] = '\0';
        return 1;
    }
    if (x->t == -KS && x->s != NULL) {
        strncpy(out, x->s, cap - 1);
        out[cap - 1] = '\0';
        return 1;
    }
    if (x->t == -KC) {
        out[0] = x->g;
        out[1] = '\0';
        return 1;
    }
    return 0;
}

static int k_get_color4(K *args, J argc, J idx, Color *out) {
    int cr, cg, cb, ca;
    if ((idx + 3) >= argc || out == NULL) {
        return 0;
    }
    if (!k_get_int(args[idx], &cr) || !k_get_int(args[idx + 1], &cg) || !k_get_int(args[idx + 2], &cb) || !k_get_int(args[idx + 3], &ca)) {
        return 0;
    }
    out->r = (unsigned char)cr;
    out->g = (unsigned char)cg;
    out->b = (unsigned char)cb;
    out->a = (unsigned char)ca;
    return 1;
}

