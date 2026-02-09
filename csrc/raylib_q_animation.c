#include "raylib_q_types.h"
#include "raylib_q_utils.h"
#include <string.h>

void anim_state_reset(AnimState *state, double now) {
    state->frame = 0;
    state->elapsedMs = 0.0;
    state->lastTick = now;
    state->playing = false;
}

void anim_state_start(AnimState *state, bool enabled, double now) {
    state->frame = 0;
    state->elapsedMs = 0.0;
    state->lastTick = now;
    state->playing = enabled;
}

void anim_state_stop(AnimState *state) { state->playing = false; }

void anim_state_advance(AnimState *state, int count, int currentRateMs, double now) {
    if (!state->playing || count <= 0) return;

    double deltaMs = (now - state->lastTick) * 1000.0;
    state->lastTick = now;
    if (deltaMs < 0.0) deltaMs = 0.0;
    state->elapsedMs += deltaMs;

    for (;;) {
        if (currentRateMs < 1) currentRateMs = 1;
        if (state->elapsedMs < (double)currentRateMs) break;
        state->elapsedMs -= (double)currentRateMs;
        state->frame = (state->frame + 1) % count;
    }
}

float anim_progress(const AnimState *state, int rateMs) {
    if (!state->playing || rateMs <= 0) return 0.0f;
    float t = (float)(state->elapsedMs / (double)rateMs);
    if (t < 0.0f) t = 0.0f;
    if (t > 1.0f) t = 1.0f;
    return t;
}

void advance_anim_track(AnimState *state, int count, int rateMs, double now) {
    anim_state_advance(state, count, rateMs, now);
}

void advance_anims(Runtime *rt) {
    double now = GetTime();
    anim_state_advance(&rt->animCircleState, rt->animCircleCount, rt->animCircleState.playing ? rt->animCircleFrames[rt->animCircleState.frame].rateMs : 16, now);
    anim_state_advance(&rt->animTriangleState, rt->animTriangleCount, rt->animTriangleState.playing ? rt->animTriangleFrames[rt->animTriangleState.frame].rateMs : 16, now);
    anim_state_advance(&rt->animRectState, rt->animRectCount, rt->animRectState.playing ? rt->animRectFrames[rt->animRectState.frame].rateMs : 16, now);
    anim_state_advance(&rt->animLineState, rt->animLineCount, rt->animLineState.playing ? rt->animLineFrames[rt->animLineState.frame].rateMs : 16, now);
    anim_state_advance(&rt->animPointState, rt->animPointCount, rt->animPointState.playing ? rt->animPointFrames[rt->animPointState.frame].rateMs : 16, now);
    anim_state_advance(&rt->animTextState, rt->animTextCount, rt->animTextState.playing ? rt->animTextFrames[rt->animTextState.frame].rateMs : 16, now);
    
    if (rt->animPixelRectCount > 0 && rt->animPixelFrameCount > 0) {
        anim_state_advance(&rt->animPixelState, rt->animPixelFrameCount, rt->animPixelRateMs, now);
    }
}
