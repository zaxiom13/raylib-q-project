#include "k.h"
#include "raylib.h"

#include <limits.h>
#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    Vector2 a;
    Vector2 b;
    Vector2 c;
    Color color;
} Triangle;

typedef struct {
    Vector2 center;
    float radius;
    Color color;
} CircleShape;

typedef struct {
    Vector2 position;
    Vector2 size;
    Color color;
} RectShape;

typedef struct {
    Vector2 start;
    Vector2 end;
    float thickness;
    Color color;
} LineShape;

typedef struct {
    Vector2 position;
    Color color;
} PixelShape;

typedef struct {
    Vector2 position;
    int size;
    char text[128];
    Color color;
} TextShape;

typedef struct {
    int rateMs;
    bool interpolateToNext;
    float x;
    float y;
    float r;
    Color color;
} AnimCircleFrame;

typedef struct {
    int rateMs;
    bool interpolateToNext;
    float x;
    float y;
    float r;
    Color color;
} AnimTriangleFrame;

typedef struct {
    int rateMs;
    bool interpolateToNext;
    float x;
    float y;
    float w;
    float h;
    Color color;
} AnimRectFrame;

typedef struct {
    int rateMs;
    bool interpolateToNext;
    float x1;
    float y1;
    float x2;
    float y2;
    float thickness;
    Color color;
} AnimLineFrame;

typedef struct {
    int rateMs;
    bool interpolateToNext;
    float x;
    float y;
    Color color;
} AnimPointFrame;

typedef struct {
    int rateMs;
    bool interpolateToNext;
    float x;
    float y;
    int size;
    char text[128];
    Color color;
} AnimTextFrame;

typedef struct {
    int frame;
    Vector2 position;
    Vector2 size;
    Color color;
} AnimPixelRect;

typedef struct {
    int frame;
    double elapsedMs;
    double lastTick;
    bool playing;
} AnimState;

#define EVENT_QUEUE_CAP 8192
#define EVENT_TYPE_LEN 24

typedef struct {
    unsigned long long seq;
    long long timeMs;
    char type[EVENT_TYPE_LEN];
    int a;
    int b;
    int c;
    int d;
} InputEvent;

typedef struct {
    bool initialized;
    bool shouldClose;
    bool showOverlayText;

    Triangle triangles[1024];
    CircleShape circles[1024];
    RectShape rects[1024];
    LineShape lines[1024];
    PixelShape pixels[2048];
    TextShape texts[1024];

    AnimCircleFrame animCircleFrames[4096];
    AnimTriangleFrame animTriangleFrames[4096];
    AnimRectFrame animRectFrames[4096];
    AnimLineFrame animLineFrames[4096];
    AnimPointFrame animPointFrames[4096];
    AnimTextFrame animTextFrames[2048];
    AnimPixelRect animPixelRects[65536];

    int triangleCount;
    int circleCount;
    int rectCount;
    int lineCount;
    int pixelCount;
    int textCount;

    int animCircleCount;
    int animTriangleCount;
    int animRectCount;
    int animLineCount;
    int animPointCount;
    int animTextCount;
    int animPixelRectCount;
    int animPixelFrameCount;
    int animPixelRateMs;

    AnimState animCircleState;
    AnimState animTriangleState;
    AnimState animRectState;
    AnimState animLineState;
    AnimState animPointState;
    AnimState animTextState;
    AnimState animPixelState;

    InputEvent eventQueue[EVENT_QUEUE_CAP];
    int eventHead;
    int eventCount;
    int prevMouseX;
    int prevMouseY;
    bool hasPrevMouse;
    bool lastWindowFocused;
    unsigned long long eventNextSeq;
    unsigned long long eventDropped;
} Runtime;

static Runtime g_rt = {0};

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

static void clear_scene(Runtime *rt) {
    double now = GetTime();
    rt->triangleCount = 0;
    rt->circleCount = 0;
    rt->rectCount = 0;
    rt->lineCount = 0;
    rt->pixelCount = 0;
    rt->textCount = 0;

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

static int process_command(Runtime *rt, K cmd) {
    if (cmd == NULL) {
        return 0;
    }

    const char *op = NULL;
    K *args = NULL;
    J argc = 0;
    K *items = NULL;

    if (cmd->t == -KS && cmd->s != NULL) {
        op = cmd->s;
    } else if (cmd->t == KS) {
        if (cmd->n != 1) {
            return 0;
        }
        S *syms = kS(cmd);
        if (syms == NULL || syms[0] == NULL) {
            return 0;
        }
        op = syms[0];
    } else if (cmd->t == 0) {
        if (cmd->n < 1) {
            return 0;
        }
        items = kK(cmd);
        if (items[0] == NULL || items[0]->t != -KS || items[0]->s == NULL) {
            return 0;
        }
        op = items[0]->s;
        args = items + 1;
        argc = cmd->n - 1;
    } else {
        return 0;
    }

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

    if (strcmp(op, "animCircleClear") == 0) {
        rt->animCircleCount = 0;
        anim_state_reset(&rt->animCircleState, GetTime());
        return 1;
    }
    if (strcmp(op, "animCirclePlay") == 0) {
        anim_state_start(&rt->animCircleState, rt->animCircleCount > 0, GetTime());
        return 1;
    }
    if (strcmp(op, "animCircleStop") == 0) {
        anim_state_stop(&rt->animCircleState);
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

    if (strcmp(op, "animTriangleClear") == 0) {
        rt->animTriangleCount = 0;
        anim_state_reset(&rt->animTriangleState, GetTime());
        return 1;
    }
    if (strcmp(op, "animTrianglePlay") == 0) {
        anim_state_start(&rt->animTriangleState, rt->animTriangleCount > 0, GetTime());
        return 1;
    }
    if (strcmp(op, "animTriangleStop") == 0) {
        anim_state_stop(&rt->animTriangleState);
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

    if (strcmp(op, "animRectClear") == 0) {
        rt->animRectCount = 0;
        anim_state_reset(&rt->animRectState, GetTime());
        return 1;
    }
    if (strcmp(op, "animRectPlay") == 0) {
        anim_state_start(&rt->animRectState, rt->animRectCount > 0, GetTime());
        return 1;
    }
    if (strcmp(op, "animRectStop") == 0) {
        anim_state_stop(&rt->animRectState);
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

    if (strcmp(op, "animLineClear") == 0) {
        rt->animLineCount = 0;
        anim_state_reset(&rt->animLineState, GetTime());
        return 1;
    }
    if (strcmp(op, "animLinePlay") == 0) {
        anim_state_start(&rt->animLineState, rt->animLineCount > 0, GetTime());
        return 1;
    }
    if (strcmp(op, "animLineStop") == 0) {
        anim_state_stop(&rt->animLineState);
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

    if (strcmp(op, "animPointClear") == 0) {
        rt->animPointCount = 0;
        anim_state_reset(&rt->animPointState, GetTime());
        return 1;
    }
    if (strcmp(op, "animPointPlay") == 0) {
        anim_state_start(&rt->animPointState, rt->animPointCount > 0, GetTime());
        return 1;
    }
    if (strcmp(op, "animPointStop") == 0) {
        anim_state_stop(&rt->animPointState);
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

    if (strcmp(op, "animTextClear") == 0) {
        rt->animTextCount = 0;
        anim_state_reset(&rt->animTextState, GetTime());
        return 1;
    }
    if (strcmp(op, "animTextPlay") == 0) {
        anim_state_start(&rt->animTextState, rt->animTextCount > 0, GetTime());
        return 1;
    }
    if (strcmp(op, "animTextStop") == 0) {
        anim_state_stop(&rt->animTextState);
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

    if (strcmp(op, "addTriangle") == 0) {
        float x, y, r;
        Color color;
        if (argc >= 7 && k_get_float(args[0], &x) && k_get_float(args[1], &y) && k_get_float(args[2], &r) && k_get_color4(args, argc, 3, &color)) {
            if (rt->triangleCount < (int)(sizeof(rt->triangles) / sizeof(rt->triangles[0])) && r > 0.0f) {
                float dx = 0.8660254f * r;
                rt->triangles[rt->triangleCount++] = (Triangle){
                    .a = {x, y - r},
                    .b = {x - dx, y + 0.5f * r},
                    .c = {x + dx, y + 0.5f * r},
                    .color = color};
            }
        }
        return 1;
    }
    if (strcmp(op, "addCircle") == 0) {
        float x, y, r;
        Color color;
        if (argc >= 7 && k_get_float(args[0], &x) && k_get_float(args[1], &y) && k_get_float(args[2], &r) && k_get_color4(args, argc, 3, &color)) {
            if (rt->circleCount < (int)(sizeof(rt->circles) / sizeof(rt->circles[0])) && r > 0.0f) {
                rt->circles[rt->circleCount++] = (CircleShape){
                    .center = {x, y},
                    .radius = r,
                    .color = color};
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
                rt->rects[rt->rectCount++] = (RectShape){
                    .position = {x - r, y - r},
                    .size = {side, side},
                    .color = color};
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
                rt->rects[rt->rectCount++] = (RectShape){
                    .position = {x, y},
                    .size = {w, h},
                    .color = color};
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
                rt->lines[rt->lineCount++] = (LineShape){
                    .start = {x1, y1},
                    .end = {x2, y2},
                    .thickness = thickness,
                    .color = color};
            }
        }
        return 1;
    }
    if (strcmp(op, "addPixel") == 0) {
        float x, y;
        Color color;
        if (argc >= 6 && k_get_float(args[0], &x) && k_get_float(args[1], &y) && k_get_color4(args, argc, 2, &color)) {
            if (rt->pixelCount < (int)(sizeof(rt->pixels) / sizeof(rt->pixels[0]))) {
                rt->pixels[rt->pixelCount++] = (PixelShape){
                    .position = {x, y},
                    .color = color};
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
                rt->texts[rt->textCount] = (TextShape){
                    .position = {x, y},
                    .size = size,
                    .color = color};
                strncpy(rt->texts[rt->textCount].text, payload, sizeof(rt->texts[rt->textCount].text) - 1);
                rt->texts[rt->textCount].text[sizeof(rt->texts[rt->textCount].text) - 1] = '\0';
                rt->textCount++;
            }
        }
        return 1;
    }

    return 0;
}

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
                rt->triangles[rt->triangleCount++] = (Triangle){
                    .a = {x, y - r},
                    .b = {x - dx, y + 0.5f * r},
                    .c = {x + dx, y + 0.5f * r},
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
            }
            return 1;
        }
    }

    {
        float x, y, r;
        int cr, cg, cb, ca;
        if (sscanf(msg, "ADD_CIRCLE %f %f %f %d %d %d %d", &x, &y, &r, &cr, &cg, &cb, &ca) == 7) {
            if (rt->circleCount < (int)(sizeof(rt->circles) / sizeof(rt->circles[0])) && r > 0.0f) {
                rt->circles[rt->circleCount++] = (CircleShape){
                    .center = {x, y},
                    .radius = r,
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
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
                rt->rects[rt->rectCount++] = (RectShape){
                    .position = {x - r, y - r},
                    .size = {side, side},
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
            }
            return 1;
        }
    }

    {
        float x, y, w, h;
        int cr, cg, cb, ca;
        if (sscanf(msg, "ADD_RECT %f %f %f %f %d %d %d %d", &x, &y, &w, &h, &cr, &cg, &cb, &ca) == 8) {
            if (rt->rectCount < (int)(sizeof(rt->rects) / sizeof(rt->rects[0])) && w > 0.0f && h > 0.0f) {
                rt->rects[rt->rectCount++] = (RectShape){
                    .position = {x, y},
                    .size = {w, h},
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
            }
            return 1;
        }
    }

    {
        float x1, y1, x2, y2, thickness;
        int cr, cg, cb, ca;
        if (sscanf(msg, "ADD_LINE %f %f %f %f %f %d %d %d %d", &x1, &y1, &x2, &y2, &thickness, &cr, &cg, &cb, &ca) == 9) {
            if (rt->lineCount < (int)(sizeof(rt->lines) / sizeof(rt->lines[0])) && thickness > 0.0f) {
                rt->lines[rt->lineCount++] = (LineShape){
                    .start = {x1, y1},
                    .end = {x2, y2},
                    .thickness = thickness,
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
            }
            return 1;
        }
    }

    {
        float x, y;
        int cr, cg, cb, ca;
        if (sscanf(msg, "ADD_PIXEL %f %f %d %d %d %d", &x, &y, &cr, &cg, &cb, &ca) == 6) {
            if (rt->pixelCount < (int)(sizeof(rt->pixels) / sizeof(rt->pixels[0]))) {
                rt->pixels[rt->pixelCount++] = (PixelShape){
                    .position = {x, y},
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
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
                rt->texts[rt->textCount] = (TextShape){
                    .position = {x, y},
                    .size = size,
                    .color = {(unsigned char)cr, (unsigned char)cg, (unsigned char)cb, (unsigned char)ca}};
                strncpy(rt->texts[rt->textCount].text, payload, sizeof(rt->texts[rt->textCount].text) - 1);
                rt->texts[rt->textCount].text[sizeof(rt->texts[rt->textCount].text) - 1] = '\0';
                rt->textCount++;
            }
            return 1;
        }
    }

    if (strcmp(msg, "ADD_TRIANGLE") == 0 && rt->triangleCount < (int)(sizeof(rt->triangles) / sizeof(rt->triangles[0]))) {
        rt->triangles[rt->triangleCount++] = (Triangle){
            .a = {400.0f, 120.0f},
            .b = {250.0f, 340.0f},
            .c = {550.0f, 340.0f},
            .color = MAROON};
        return 1;
    }

    return 0;
}

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
    for (int i = 0; i < rt->triangleCount; i++) {
        DrawTriangle(rt->triangles[i].a, rt->triangles[i].b, rt->triangles[i].c, rt->triangles[i].color);
    }
    for (int i = 0; i < rt->circleCount; i++) {
        DrawCircleV(rt->circles[i].center, rt->circles[i].radius, rt->circles[i].color);
    }
    for (int i = 0; i < rt->rectCount; i++) {
        DrawRectangleV(rt->rects[i].position, rt->rects[i].size, rt->rects[i].color);
    }
    for (int i = 0; i < rt->lineCount; i++) {
        DrawLineEx(rt->lines[i].start, rt->lines[i].end, rt->lines[i].thickness, rt->lines[i].color);
    }
    for (int i = 0; i < rt->pixelCount; i++) {
        DrawPixelV(rt->pixels[i].position, rt->pixels[i].color);
    }
    for (int i = 0; i < rt->textCount; i++) {
        DrawText(rt->texts[i].text, (int)roundf(rt->texts[i].position.x), (int)roundf(rt->texts[i].position.y), rt->texts[i].size, rt->texts[i].color);
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

K rq_is_open(void) {
    return kb(g_rt.initialized ? 1 : 0);
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
