#ifndef RAYLIB_Q_TYPES_H
#define RAYLIB_Q_TYPES_H

#include "k.h"
#include "raylib.h"
#include <stdbool.h>

#define EVENT_QUEUE_CAP 8192
#define EVENT_TYPE_LEN 24
#define MAX_SHAPES 1024
#define MAX_PIXELS 2048
#define MAX_ANIM_FRAMES 4096
#define MAX_ANIM_TEXT_FRAMES 2048
#define MAX_ANIM_PIXEL_RECTS 65536
#define MAX_PIXEL_BLITS 128

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

typedef struct {
    int frame;
    double elapsedMs;
    double lastTick;
    bool playing;
} AnimState;

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

    Triangle triangles[MAX_SHAPES];
    CircleShape circles[MAX_SHAPES];
    RectShape rects[MAX_SHAPES];
    LineShape lines[MAX_SHAPES];
    PixelShape pixels[MAX_PIXELS];
    TextShape texts[MAX_SHAPES];

    AnimCircleFrame animCircleFrames[MAX_ANIM_FRAMES];
    AnimTriangleFrame animTriangleFrames[MAX_ANIM_FRAMES];
    AnimRectFrame animRectFrames[MAX_ANIM_FRAMES];
    AnimLineFrame animLineFrames[MAX_ANIM_FRAMES];
    AnimPointFrame animPointFrames[MAX_ANIM_FRAMES];
    AnimTextFrame animTextFrames[MAX_ANIM_TEXT_FRAMES];
    AnimPixelRect animPixelRects[MAX_ANIM_PIXEL_RECTS];
    PixelBlit pixelBlits[MAX_PIXEL_BLITS];

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

#endif
