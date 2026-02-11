#include "k.h"
#include "raylib.h"

#include <limits.h>
#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define RAYLIB_Q_RUNTIME_VERSION "2026.02.11"

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
    Texture2D texture;
    Rectangle src;
    Rectangle dst;
    Color tint;
} PixelBlit;

typedef enum {
    PRIM_TRIANGLE = 0,
    PRIM_CIRCLE = 1,
    PRIM_RECT = 2,
    PRIM_LINE = 3,
    PRIM_PIXEL = 4,
    PRIM_PIXEL_BLIT = 5,
    PRIM_TEXT = 6
} PrimitiveKind;

typedef struct {
    unsigned char kind;
    int index;
} DrawItem;

typedef struct {
    int frame;
    double elapsedMs;
    double lastTick;
    bool playing;
} AnimState;

#define EVENT_QUEUE_CAP 8192
#define EVENT_TYPE_LEN 24
#define DRAW_ORDER_CAP 20000

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
    PixelBlit pixelBlits[128];
    DrawItem drawOrder[DRAW_ORDER_CAP];

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
    int pixelBlitCount;
    int drawOrderCount;

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

#include "csrc/runtime/runtime_helpers.inc"
#include "csrc/runtime/runtime_command_q.inc"
#include "csrc/runtime/runtime_command_text.inc"
#include "csrc/runtime/runtime_runtime_and_api.inc"
