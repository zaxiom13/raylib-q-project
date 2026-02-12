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

Starter scene (background + planets):

```q
bg:([] x:enlist 0f; y:enlist 0f; w:enlist 800f; h:enlist 450f; color:enlist 20 24 38 255i);
stars:([] x:80 180 300 420 560 700f; y:70 40 100 55 90 65f; r:2 3 2 2 3 2f; color:6#enlist 255 255 255 255i);
planets:([] x:200 360 560f; y:280 180 300f; r:32 22 42f; color:(.raylib.Color.ORANGE;.raylib.Color.BLUE;.raylib.Color.GREEN));
.raylib.rect bg;
.raylib.circle stars;
.raylib.circle planets
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

Mini HUD example:

```q
hud:([] x:enlist 20f; y:enlist 20f; text:enlist "Mission: collect 3 stars"; size:enlist 24i; color:enlist .raylib.Color.WHITE);
hint:([] x:enlist 20f; y:enlist 52f; text:enlist "Move -> px+:10f; py-:10f; .raylib.refresh[]"; size:enlist 18i; color:enlist 180 210 255 255i);
.raylib.text hud;
.raylib.text hint
```

## Notes

- Renderer keeps state in memory while running.
- Closing renderer resets state.
- Transport is native in-process runtime (`raylib_q_runtime.so`).
- Renderer target FPS defaults to `240` (override with `RAYLIB_Q_TARGET_FPS`, e.g. `120`, `240`, `360`).
- If an API call is malformed, usage errors are returned as strings.
