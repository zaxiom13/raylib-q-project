#ifndef RAYLIB_Q_ANIMATION_H
#define RAYLIB_Q_ANIMATION_H

#include "raylib_q_types.h"

void anim_state_reset(AnimState *state, double now);
void anim_state_start(AnimState *state, bool enabled, double now);
void anim_state_stop(AnimState *state);
void anim_state_advance(AnimState *state, int count, int currentRateMs, double now);
float anim_progress(const AnimState *state, int rateMs);
void advance_anim_track(AnimState *state, int count, int rateMs, double now);
void advance_anims(Runtime *rt);

#endif
