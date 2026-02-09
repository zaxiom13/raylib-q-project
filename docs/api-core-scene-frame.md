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

