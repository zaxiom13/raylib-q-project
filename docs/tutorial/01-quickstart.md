# Lesson 01: Quick Start

## Build and Install

```bash
make
make test
make install
```

## Draw Something Fun in 30 Seconds

```q
.draw.open[]
bg:([] x:enlist 0f; y:enlist 0f; w:enlist 800f; h:enlist 450f; color:enlist 15 18 30 255i)
sun:([] x:enlist 400f; y:enlist 225f; r:enlist 52f; color:enlist .raylib.Color.YELLOW)
planets:([] x:280 520 400f; y:225 225 110f; r:18 24 12f; color:(.raylib.Color.BLUE;.raylib.Color.GREEN;.raylib.Color.ORANGE))
.draw.rect bg
.draw.circle sun
.draw.circle planets
```

## Make It Interactive

```q
mx:400f
my:225f
cursor:([] x:enlist {mx}; y:enlist {my}; r:enlist 25f)
.draw.circle cursor
.draw.interactive.start[]
mx:620f; my:300f; .draw.refresh[]
```

## Tiny Scene Workflow (Beginner Friendly)

```q
px:120f
py:225f
player:([] x:enlist {px}; y:enlist {py}; r:enlist 18f; color:enlist .raylib.Color.RED)
.draw.scene.reset[]
.draw.scene.circle[`player;player]
.draw.refresh[]
px+:40f; py-:20f; .draw.refresh[]
```
