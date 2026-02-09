# Lesson 01: Quick Start

## Build and Install

```bash
make
make test
make install
```

## Open a Window and Draw

```q
.raylib.open[]
circles:([] x:100 250 400f; y:200 200 200f; r:30 50 40f)
.raylib.circle circles
```

## Interactive Cursor Circle

```q
mx:400f
my:225f
cursor:([] x:enlist {mx}; y:enlist {my}; r:enlist 25f)
.raylib.circle cursor
.raylib.interactive.start[]
```
