#include "raylib_q_types.h"
#include "raylib.h"
#include <stdio.h>
#include <string.h>

void event_queue_push(Runtime *rt, long long timeMs, const char *type, int a, int b, int c, int d) {
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

void event_queue_clear(Runtime *rt) {
    rt->eventHead = 0;
    rt->eventCount = 0;
    rt->eventDropped = 0ULL;
}

K events_to_text(Runtime *rt) {
    if (rt->eventCount <= 0) return knk(0);

    char buf[256];
    int totalLen = 0;
    for (int i = 0; i < rt->eventCount; i++) {
        int idx = (rt->eventHead + i) % EVENT_QUEUE_CAP;
        InputEvent *ev = &rt->eventQueue[idx];
        totalLen += snprintf(buf, sizeof(buf), "%llu|%lld|%s|%d|%d|%d|%d\n",
                            ev->seq, ev->timeMs, ev->type, ev->a, ev->b, ev->c, ev->d);
    }

    K result = kpn("", 0);
    for (int i = 0; i < rt->eventCount; i++) {
        int idx = (rt->eventHead + i) % EVENT_QUEUE_CAP;
        InputEvent *ev = &rt->eventQueue[idx];
        int n = snprintf(buf, sizeof(buf), "%llu|%lld|%s|%d|%d|%d|%d\n",
                        ev->seq, ev->timeMs, ev->type, ev->a, ev->b, ev->c, ev->d);
        jk(&result, kpn(buf, n));
    }
    
    event_queue_clear(rt);
    return result;
}
