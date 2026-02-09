# Lesson 02: Drawing and Scene

## Table-first Primitives

```q
.raylib.rect ([] x:enlist 40f; y:enlist 40f; w:enlist 180f; h:enlist 90f)
.raylib.text ([] x:enlist 60f; y:enlist 70f; text:enlist "hello"; size:enlist 24i)
```

## Scene Registry

```q
.raylib.scene.reset[]
.raylib.scene.circle[`player;([] x:enlist 120f; y:enlist 120f; r:enlist 24f)]
.raylib.scene.text[`hud;([] x:enlist 10f; y:enlist 10f; text:enlist "Score: 0"; size:enlist 24i)]
.raylib.refresh[]
```
