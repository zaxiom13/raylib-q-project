#ifndef RAYLIB_Q_EVENTS_H
#define RAYLIB_Q_EVENTS_H

#include "raylib_q_types.h"
#include "k.h"

void event_queue_push(Runtime *rt, long long timeMs, const char *type, int a, int b, int c, int d);
void event_queue_clear(Runtime *rt);
K events_to_text(Runtime *rt);

#endif
