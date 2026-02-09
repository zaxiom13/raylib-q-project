#ifndef RAYLIB_Q_UTILS_H
#define RAYLIB_Q_UTILS_H

#include "raylib_q_types.h"

static inline float lerpf(float a, float b, float t) { return a + (b - a) * t; }

static inline unsigned char lerpuc(unsigned char a, unsigned char b, float t) {
    return (unsigned char)(a + (int)(b - a) * t);
}

static inline Color lerp_color(Color a, Color b, float t) {
    return (Color){
        lerpuc(a.r, b.r, t),
        lerpuc(a.g, b.g, t),
        lerpuc(a.b, b.b, t),
        lerpuc(a.a, b.a, t)
    };
}

static inline void draw_triangle_center(float x, float y, float r, Color color) {
    Vector2 a = {x, y - r};
    Vector2 b = {x - r * 0.866f, y + r * 0.5f};
    Vector2 c = {x + r * 0.866f, y + r * 0.5f};
    DrawTriangle(a, b, c, color);
}

static inline unsigned char clamp_u8_int(int x) {
    if (x < 0) return 0;
    if (x > 255) return 255;
    return (unsigned char)x;
}

static inline int clamp_rate_ms(int rateMs) {
    if (rateMs < 16) return 16;
    return rateMs;
}

#endif
