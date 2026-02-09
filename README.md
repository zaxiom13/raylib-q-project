# raylib-q-project

Open and control a persistent raylib window from any q session.

This project installs:
- C renderer shim: `/Users/zak1726/.kx/bin/raylib_q_window`
- q init script: `/Users/zak1726/.kx/raylib_q_init.q`
- startup config: `QINIT=/Users/zak1726/.kx/raylib_q_init.q` in `/Users/zak1726/.kx/config`

## Project progress

Roadmap implementation status is tracked in `PROGRESS.md` (kept current as work is completed, partially completed, or deferred).

## Build and install

```sh
make clean && make
make test
make install
```

Required workflow: always run `make install` after project changes so q sessions pick up the latest local install in `~/.kx`.

Refactor note:
- C shim is split by responsibility:
- `raylib_q_window.c` (native-only shim notice for deprecated entrypoint)
- `raylib_q_runtime.c` (native in-process renderer runtime used by q)
- `raylib_q_init.q` is generated from modular sources in `qsrc/*.q`.
- Module composition order lives in `qsrc/modules.list` and is reused by `make` + `scripts/build_raylib_q_init.sh`.
- Run `make` (or `scripts/build_raylib_q_init.sh`) after editing `qsrc` modules.

## Core API

Start/reuse renderer:

```q
.raylib.open[]
```

On first successful open, scene registry state is reset implicitly.

Legacy alias of open:

```q
.raylib.start[]
```

Clear all shapes and animation tracks:

```q
.raylib.clear[]
```

Rebuild frame from scene registry (recommended when table rows change):

```q
.raylib.refresh[]
```

Run one render/event tick:

```q
.raylib.tick[]
```

Close renderer:

```q
.raylib.close[]
```

Array shape helper:

```q
.raylib.shape.info 3 3 2#til 49
/ 3 3 2
```

Built-in function help:

```q
.raylib.help[`scene.upsert]
```

## Complex numbers

Complex support is loaded through `QINIT`, so after `make install` it is available in every q session as `.cx.*`.

Representation:
- complex values are dictionaries with keys `` `re`im`` and float scalars

Constructors and coercion:

```q
.cx.new[3;4]              / re=3, im=4
.cx.z[3;4]                / alias of .cx.new
.cx.from 5                / 5 + 0i
.cx.from 3 4              / 3 + 4i
.cx.from `re`im!(3;4)     / normalize to float re/im
```

Accessors and helpers:

```q
.cx.re z
.cx.im z
.cx.conj z
.cx.neg z
.cx.abs z                 / magnitude
.cx.modulus z             / alias of .cx.abs
.cx.arg z                 / phase angle (radians)
.cx.recip z
.cx.normalize z
.cx.str z
```

Arithmetic:

```q
.cx.add[a;b]
.cx.sub[a;b]
.cx.mul[a;b]
.cx.div[a;b]
.cx.mod[a;b]              / component-wise modulo
.cx.powEach[a;b]          / component-wise exponent on re/im
```

Constants:

```q
.cx.zero   / 0 + 0i
.cx.one    / 1 + 0i
.cx.i      / 0 + 1i
```

Rounding operators (component-wise on `re` and `im`):

```q
.cx.floor z
.cx.ceil z
.cx.round z
.cx.frac z
```

Polar/transcendental operators:

```q
.cx.polar z               / `r`theta dictionary
.cx.fromPolar[r;theta]
.cx.exp z
.cx.log z
.cx.pow[a;b]              / complex exponentiation
.cx.sqrt z
.cx.sin z
.cx.cos z
.cx.tan z
```

Power behavior:
- `.cx.pow[a;b]` computes complex power (for example `(3+4i)^2 = -7+24i`)
- `.cx.powEach[a;b]` computes component-wise power (for example `3^2` and `4^2` -> `9+16i`)

Example:

```q
z1:.cx.from 3 4;
z2:.cx.from 1 -2;
.cx.add[z1;z2]   / 4 + 2i
.cx.mul[z1;z2]   / 11 - 2i
.cx.div[z1;z2]   / -1 + 2i
```

## Scene API

Scene entries are keyed by id and redrawn in `layer` + insertion order.

```q
/ add/update entries
.raylib.scene.circle[`player; tPlayer]
.raylib.scene.text[`hud; tHud]

/ patch one source table by id
.raylib.scene.set[`player;`x`y;(120f;80f)]

/ visibility and deletion
.raylib.scene.visible[`hud;0b]
.raylib.scene.delete[`player]
```

Additional helpers:
- `.raylib.scene.list[]`
- `.raylib.scene.reset[]`
- `.raylib.scene.clearLayer[layerInt]`

## Frame API

Fixed-step frame loop utilities:

```q
.raylib.frame.setDt 0.016f
cb:.raylib.frame.on {[state] / state has frame/time/dt
  :0N
 }
.raylib.frame.step 60
.raylib.frame.off cb
```

Convenience aliases:
- `.raylib.each.frame[{...}]` (register no-arg callback)
- `.raylib.frame.tick[]`, `.raylib.frame.run[n]`, `.raylib.frame.reset[]`, `.raylib.frame.clear[]`

## Events and Interactive Mode

Input/window events:

```q
.raylib.events.clear[]
ev:.raylib.events.poll[]
id:.raylib.events.on {[ev] show ev}
.raylib.events.off id
```

Interactive timer loop (Esc stops):

```q
.raylib.interactive.start[]
.raylib.interactive.stop[]
```

Starting interactive mode clears frame callbacks implicitly, so each run begins from a clean callback set.

Live interactive redraw helpers:
- `.raylib.interactive.live.list[]`
- `.raylib.interactive.live.clear[]`

## Shape pretty printing

Use these helpers to inspect nested arrays in an aligned, readable panel view:

```q
.raylib.shape.info x
.raylib.shape.pretty x
.raylib.shape.show x
```

- `.raylib.shape.info x` returns only the shape vector.
- `.raylib.shape.pretty x` returns a pretty-formatted string.
- `.raylib.shape.show x` prints the pretty view directly (no trailing escaped return blob).

4D layout (`a b c d`) uses an `a x b` grid of `c x d` slices.

```q
.raylib.shape.show 5 3 2 4#til 49
```

<details>
<summary>Actual output: <code>.raylib.shape.show 5 3 2 4#til 49</code></summary>

```text
shape 5 3 2 4
slice[0, 0]              slice[0, 1]              slice[0, 2]
+---------------------   +---------------------   +---------------------
| 0    1    2    3       | 8    9    10   11      | 16   17   18   19
| 4    5    6    7       | 12   13   14   15      | 20   21   22   23
+---------------------   +---------------------   +---------------------

slice[1, 0]              slice[1, 1]              slice[1, 2]
+---------------------   +---------------------   +---------------------
| 24   25   26   27      | 32   33   34   35      | 40   41   42   43
| 28   29   30   31      | 36   37   38   39      | 44   45   46   47
+---------------------   +---------------------   +---------------------

slice[2, 0]              slice[2, 1]              slice[2, 2]
+---------------------   +---------------------   +---------------------
| 48   0    1    2       | 7    8    9    10      | 15   16   17   18
| 3    4    5    6       | 11   12   13   14      | 19   20   21   22
+---------------------   +---------------------   +---------------------

slice[3, 0]              slice[3, 1]              slice[3, 2]
+---------------------   +---------------------   +---------------------
| 23   24   25   26      | 31   32   33   34      | 39   40   41   42
| 27   28   29   30      | 35   36   37   38      | 43   44   45   46
+---------------------   +---------------------   +---------------------

slice[4, 0]              slice[4, 1]              slice[4, 2]
+---------------------   +---------------------   +---------------------
| 47   48   0    1       | 6    7    8    9       | 14   15   16   17
| 2    3    4    5       | 10   11   12   13      | 18   19   20   21
+---------------------   +---------------------   +---------------------
```

</details>

5D layout (`a b c d e`) prints one `layer[k]` per third-dimension index, where each layer is an `a x b` grid of `d x e` slices.

```q
.raylib.shape.show 2 2 2 2 3#til 49
```

<details>
<summary>Actual output: <code>.raylib.shape.show 2 2 2 2 3#til 49</code></summary>

```text
shape 2 2 2 2 3
layer[0]
slice[0, 0, 0]   slice[0, 0, 1]
+-------------   +-------------
| 0   1   2      | 12  13  14
| 3   4   5      | 15  16  17
+-------------   +-------------

slice[0, 1, 0]   slice[0, 1, 1]
+-------------   +-------------
| 24  25  26     | 36  37  38
| 27  28  29     | 39  40  41
+-------------   +-------------


layer[1]
slice[1, 0, 0]   slice[1, 0, 1]
+-------------   +-------------
| 6   7   8      | 18  19  20
| 9   10  11     | 21  22  23
+-------------   +-------------

slice[1, 1, 0]   slice[1, 1, 1]
+-------------   +-------------
| 30  31  32     | 42  43  44
| 33  34  35     | 45  46  47
+-------------   +-------------
```

</details>

Formatting behavior:
- fixed-width numeric alignment across the rendered panel
- consistent box widths per panel column
- stable output for higher-rank nested arrays via slice labels

## Primitive table API

Each function returns number of processed rows.

```q
.raylib.triangle[t]
.raylib.square[t]
.raylib.circle[t]
.raylib.rect[t]
.raylib.line[t]
.raylib.point[t]
.raylib.text[t]
.raylib.pixels[t]
```

Simplified generic dispatcher (non-breaking addition):

```q
.raylib.draw[`circle;t]
.raylib.draw[`text;t]
.raylib.draw[`pixels;t]
```

Required columns by primitive:
- `triangle`: `x y r`
- `square`: `x y r`
- `circle`: `x y r`
- `rect`: `x y w h`
- `line`: `x1 y1 x2 y2`
- `point`: `x y`
- `text`: `x y text size`
- `pixels`: `pixels x y`

Optional columns:
- `color` for all primitives (RGBA int vector, e.g. `255 0 0 255i`)
- `alpha` for all primitives (0..255, overrides color alpha channel)
- `layer` / `rotation` / `stroke` / `fill` accepted as schema metadata columns
- `thickness` for `line` (defaults to `1f`)
- `w`/`h` for `pixels` (optional explicit source dimensions; must match inferred payload shape)
- `scale` for `pixels` (uniform destination scaling; defaults to `1f`)
- `dw`/`dh` for `pixels` (explicit destination width/height, overrides `scale`)
- `alpha` for `pixels` (0..255 alpha multiplier)
- `rate` for animated `pixels` payloads (seconds per frame, defaults to `0.1`)
- static `pixels` rows larger than `.raylib._pixelBlitThreshold` (default `1024`) auto-use a texture blit path to avoid per-rect caps

Schema behavior:
- required columns are enforced consistently across all draw APIs
- extra columns are tolerated/ignored by draw APIs (useful for richer source tables)
- defaults are consistent (`color` defaults per primitive, `line.thickness=1f`, pixel defaults as documented)

`pixels` payload formats:
- flat grayscale: `n` values (inferred as `w=n,h=1`)
- flat RGB: `n` values where `n mod 3=0` (inferred as `w=n/3,h=1`)
- flat RGBA: `n` values where `n mod 4=0` (inferred as `w=n/4,h=1`)
- grayscale matrix: `h x w`
- animated frames: nested frame payloads (for example `t` frames of `h x w` matrices), loops automatically

Helper for filling a per-row color column (single color or cycled list):

```q
t:.raylib.fillColor[t;.raylib.Color.RED]
t:.raylib.fillColor[t;(.raylib.Color.RED;.raylib.Color.BLUE)] / repeats RED,BLUE,RED,...
```

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

Dynamic scene columns (no `.raylib.bind` needed):

```q
theta:0f;
radii:0 45 75f;
phases:0 0 0.5*acos -1f;
mx:100f;
my:200f;
orbitIdx:til count radii;
orbitXFns:{value raze ("{(mx+radii*cos theta+phases) ";string x;"}")} each orbitIdx;
orbitYFns:{value raze ("{(my+radii*sin theta+phases) ";string x;"}")} each orbitIdx;
orbits:([] x:orbitXFns; y:orbitYFns; r:14 8 8f; color:(.raylib.Color.BLUE;.raylib.Color.RED;.raylib.Color.YELLOW));
.raylib.scene.circle[`orbits;orbits];
theta+:0.08f;
.raylib.refresh[];
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

## Color constants

Available under `.raylib.Color`:
- `.raylib.Color.RED`
- `.raylib.Color.GREEN`
- `.raylib.Color.BLUE`
- `.raylib.Color.YELLOW`
- `.raylib.Color.ORANGE`
- `.raylib.Color.PURPLE`
- `.raylib.Color.WHITE`
- `.raylib.Color.BLACK`
- `.raylib.Color.MAROON`

## Examples

Draw circles:

```q
c:([] x:120 220 320f; y:120 140 180f; r:20 30 25f; color:(enlist .raylib.Color.RED),enlist .raylib.Color.GREEN,enlist .raylib.Color.BLUE);
.raylib.circle c
```

Animated rectangle with variable per-row rate and interpolation:

```q
ar:([] x:100 250 400;y:120 220 120; w:60 140 60; h:40 80 40;rate:0.06 0.20 0.10; interpolate:111b);
.raylib.fillColor[ar;.raylib.Color.BLUE];
.raylib.animate.rect ar;
```

Draw a pixel array (grayscale, scaled):

```q
px:([] pixels:enlist 10 60 180 255i; x:enlist 120f; y:enlist 80f; scale:enlist 16f);
.raylib.pixels px
```

Animated pixel loop inferred by nested shape:

```q
gifLike:([] pixels:enlist ((1 2i;3 4i);(5 6i;7 8i)); x:enlist 200f; y:enlist 120f; scale:enlist 20f; rate:enlist 0.15f);
.raylib.pixels gifLike
```

## Notes

- Renderer keeps state in memory while running.
- Closing renderer resets state.
- Transport is native in-process runtime (`raylib_q_runtime.so`).
- Renderer target FPS defaults to `240` (override with `RAYLIB_Q_TARGET_FPS`, e.g. `120`, `240`, `360`).
- If an API call is malformed, usage errors are returned as strings.
