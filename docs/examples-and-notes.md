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
