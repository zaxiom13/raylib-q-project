## Animation API (looping)

Each row in `t` is one frame of the same shape. Playback loops infinitely.

```q
.raylib.animate.circle[t]
.raylib.animate.triangle[t]
.raylib.animate.rect[t]
.raylib.animate.line[t]
.raylib.animate.point[t]
.raylib.animate.text[t]
```

Simplified generic dispatcher (non-breaking addition):

```q
.raylib.anim[`circle;t]
.raylib.anim[`line;t]
.raylib.animate.apply[`text;t] / alias of .raylib.anim
```

Required columns by animated primitive:
- `circle`: `x y r rate`
- `triangle`: `x y r rate`
- `rect`: `x y w h rate`
- `line`: `x1 y1 x2 y2 rate`
- `point`: `x y rate`
- `text`: `x y text size rate`

Animation columns:
- `rate`: seconds for this row/frame (`>0`, per-row variable)
- `interpolate` (optional): bool/int flag; if true, interpolate this row to next row for position/size/color during this frame window

Optional columns:
- `color` / `alpha` for all animated primitives
- `layer` / `rotation` / `stroke` / `fill` accepted as schema metadata columns
- `thickness` for animated `line` (defaults to `1f`)

Global animation controls:

```q
.raylib.animate.stop[]
.raylib.animate.start[]
```

- `stop[]` pauses all animation tracks
- `start[]` resumes all animation tracks from their current frame state

## Step 5 Frame/Animation Helpers

Tween between two 1-row tables:

```q
from:([] x:enlist 0f; y:enlist 0f; r:enlist 10f);
to:([] x:enlist 100f; y:enlist 50f; r:enlist 30f);
tween:.raylib.tween.table[from;to;1f;60;`inOutQuad];
```

Build interpolated rows from keyframes (`at` in seconds):

```q
kf:([] at:0 0.5 1f; x:0 50 100f; y:0 20 0f; r:10 20 30f);
frames:.raylib.keyframesTable[kf;60;`linear];
.raylib.animate.circle frames;
```

Discover supported easing names:

```q
.raylib.easings[] / `linear`inQuad`outQuad`inOutQuad
```

Discover named color constants:

```q
.raylib.colors[]
/ name    rgba
/ --------------------------
/ RED     255 0 0 255
/ GREEN   0 180 0 255
/ ...
```

Fixed-step callback loop in q:

```q
.raylib.frame.setDt 0.0166667f;
.raylib.frame.on {[state] / state has `frame`time`dt
  / mutate scene tables here
  .raylib.refresh[] };
.raylib.frame.step 120; / advance 120 ticks without sleep
```

Frame loop helpers:
- `.raylib.frame.reset[]` reset frame/time counters
- `.raylib.frame.setDt[seconds]` set fixed step
- `.raylib.frame.on[fn]` register callback (returns callback id)
- `.raylib.frame.off[id]` unregister callback(s)
- `.raylib.frame.clear[]` clear all callbacks
- `.raylib.frame.tick[]` run one tick + callbacks
- `.raylib.frame.step[n]` run `n` ticks without sleeping
- `.raylib.frame.run[n]` run `n` ticks with `sleep dt` between ticks

## Step 6 Event/Input Pipeline (renderer -> q)

Poll input/window events from the renderer:

```q
.raylib.events.poll[]
/ columns: seq time type a b c d
```

Event callback helpers:

```q
id:.raylib.events.on {[ev] show ev};
.raylib.events.pump[];         / poll + dispatch callbacks
.raylib.events.off id;
.raylib.events.callbacks.clear[];
.raylib.events.clear[];
```

Operational diagnostics:

```q
.raylib.status[]
.raylib.version[]
```

Interactive mode keeps `mx`/`my` (and related vars) updated from mouse/window events and redraws live callable draw tables:

```q
mx:100f; my:100f;
cursor:([] x:enlist {mx}; y:enlist {my}; r:enlist 10f; color:enlist .raylib.Color.RED);
.raylib.circle cursor;
.raylib.interactive.start[];   / start safe timer-driven interactive loop (Esc to stop)
/ move mouse -> circle follows mx/my
.raylib.interactive.stop[];    / stop explicitly
```

Useful interactive helpers:
- `.raylib.interactive.tick[]` run one poll+redraw tick manually
- `.raylib.interactive.start[]` start safe timer-driven interactive mode
- `.raylib.interactive.stop[]` stop interactive mode
- `.raylib.interactive.spin[0|1]` alias for timer-driven start/stop mode
- `.raylib.interactive.live.list[]` list live callable draw bindings
- `.raylib.interactive.live.clear[]` clear live callable draw bindings

## Step 7 UI Toolkit (data-driven)

Widgets are table-first and compose on top of the primitive renderer:

```q
.raylib.ui.panel tPanel
.raylib.ui.button tButtons
.raylib.ui.slider tSliders
.raylib.ui.chartLine tLineCharts
.raylib.ui.chartBar tBarCharts
.raylib.ui.inspector tInspector
```

High-level frame + button helpers (recommended for interactive controls):

```q
.raylib.ui.frame {[]
  .raylib.ui.buttonClick[`inc;40 40 180 56f;"total: ",string ctr;{[] ctr+:1i};`press];
  .raylib.ui.text[40f;120f;"click button";24i];
 }
```

Button click mode is configurable per widget id:
- `` `press``: fire on mouse-down edge inside button
- `` `release``: fire on mouse-up edge inside button

Helpers:
- `.raylib.ui.begin[]` / `.raylib.ui.end[]` for manual batched UI frames
- `.raylib.ui.buttonPress[...]` and `.raylib.ui.buttonRelease[...]` convenience wrappers
- `.raylib.ui.state.reset[]` to clear per-button edge state cache

Interaction helpers:

```q
.raylib.ui.hit.rect tRects
.raylib.ui.buttonState tButtons
tSliders:.raylib.ui.sliderValue tSliders
```

Each API accepts callback references in table columns (same behavior as core draw APIs), so UI tables remain source-of-truth state in interactive mode.

UI counter button example:

```q
.raylib.open[];
.raylib.interactive.start[];
ctrPress:0i;
ctrRelease:0i;
.raylib.ui.state.reset[];
incP:{[] ctrPress+:1i; :0};
incR:{[] ctrRelease+:1i; :0};
drawOnce:{[] .raylib.ui.buttonPress[`bP;40 40 180 56f;"press";incP]; .raylib.ui.buttonRelease[`bR;40 120 180 56f;"release";incR]; .raylib.ui.text[240f;56f;"press=",string ctrPress;20i]; .raylib.ui.text[240f;136f;"release=",string ctrRelease;20i]; :0};
cb:{[state] .raylib.ui.frame drawOnce; :0};
cbid:.raylib.frame.on cb;

/ cleanup
/ .raylib.frame.off cbid;
/ .raylib.interactive.stop[];
/ .raylib.close[];
```

## Scene API (Step 4)

Store draw sources by `id`. Scene mutations auto-refresh by default.

```q
.raylib.scene.reset[]
.raylib.scene.circle[`circles;t]
.raylib.scene.square[`squares;t]
```

Use `.raylib.refresh[]` when source tables are edited outside scene calls and you want a redraw.

Core scene functions:
- `.raylib.scene.upsert[`id;`kind;table]`
- `.raylib.scene.upsertEx[`id;`kind;table;bindingsDict;layer;visible]`
- `.raylib.scene.delete[`id]` (or symbol list)
- `.raylib.scene.visible[`id;0|1]`
- `.raylib.scene.clearLayer[layer]`
- `.raylib.scene.list[]`

Primitive helpers:
- `.raylib.scene.triangle`
- `.raylib.scene.square`
- `.raylib.scene.circle`
- `.raylib.scene.rect`
- `.raylib.scene.line`
- `.raylib.scene.point`
- `.raylib.scene.text`
- `.raylib.scene.pixels`

## Scene examples

Setup:

```q
.raylib.open[];
```

Upsert circles from a table:

```q
c:([] x:120 220f; y:120 180f; r:20 30f; color:(enlist .raylib.Color.RED),enlist .raylib.Color.BLUE);
.raylib.scene.upsert[`circles;`circle;c];
```

Upsert with explicit layer/visibility:

```q
bg:([] x:enlist 40f; y:enlist 40f; w:enlist 500f; h:enlist 280f; color:enlist 230 230 230 255i);
pts:([] x:100 140 180f; y:90 130 170f);
.raylib.scene.upsertEx[`background;`rect;bg;()!();0;1b];
.raylib.scene.upsertEx[`points;`point;pts;()!();1;1b];
```

Toggle visibility:

```q
.raylib.scene.visible[`points;0];
.raylib.scene.visible[`points;1];
```

Delete by id:

```q
.raylib.scene.delete `background;
```

Clear a whole layer:

```q
.raylib.scene.clearLayer 1;
```

Inspect registry:

```q
.raylib.scene.list[]
/ returns: id kind layer visible ord
```

Primitive helper variants:

```q
r:([] x:enlist 300f; y:enlist 220f; w:enlist 120f; h:enlist 60f);
txt:([] x:enlist 315f; y:enlist 240f; text:enlist "hello"; size:enlist 24i);
.raylib.scene.rect[`card;r];
.raylib.scene.text[`label;txt];
```

Frame callback-driven scene updates without `.raylib.bind`:

```q
theta:0f;
radii:0 45 75f;
phases:0 0 5*acos -1f;
mx:400f; my:225f;
orbits:([] x:0 0 0f; y:0 0 0f; r:14 8 8f; color:(.raylib.Color.BLUE;.raylib.Color.RED;.raylib.Color.YELLOW));

.raylib.interactive.start[]; / call before registering frame callbacks
.raylib.frame.on {orbits[`y]:my+radii*sin theta+phases};
.raylib.frame.on {orbits[`x]:mx+radii*cos theta+phases};
.raylib.frame.on {theta+:0.08f};

/ id and source can differ: pass a symbol source to track latest table values
.raylib.scene.circle[`planets;`orbits];
```

Scene source resolution order at redraw:
- if `src` is a symbol and resolves to a table, that table is used (recommended when id and variable differ)
- else if scene `id` resolves to a table variable, that table is used
- else the stored source table snapshot is used
