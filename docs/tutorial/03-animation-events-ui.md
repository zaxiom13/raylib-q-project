# Lesson 03: Animation, Events, UI

## Animation

```q
frames:([] x:100 200 300f; y:200 100 200f; r:20 30 20f; rate:0.3 0.3 0.3f; interpolate:1 1 1b)
.raylib.animate.circle frames
```

## Events

```q
.raylib.events.on {[ev] show ev}
.raylib.events.pump[]
```

## UI Widgets

```q
.raylib.ui.begin[]
.raylib.ui.buttonTable ([] x:enlist 40f; y:enlist 40f; w:enlist 160f; h:enlist 44f; label:enlist "Click")
.raylib.ui.end[]
```
