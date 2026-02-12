# Lesson 04: Legacy Bindings and Reference

## Table-First Draw (Preferred)

```q
.draw.open[]
.draw.circle ([] x:enlist 400f; y:enlist 225f; r:enlist 60f; color:enlist .raylib.Color.BLUE)
.draw.close[]
```

## Legacy Binding Surface

```q
.raylib.InitWindow[800;450;"legacy"]
.raylib.DrawCircle ([] x:enlist 400f; y:enlist 225f; r:enlist 60f; color:enlist .raylib.Color.BLUE)
.raylib.CloseWindow[]
```

## Reference

- `docs/RAYUA_BINDINGS_REFERENCE.md`
- `docs/getting-started.md`
- `docs/api-core-scene-frame.md`
- `docs/api-animation-events-ui.md`
