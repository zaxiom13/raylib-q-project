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
.draw.open[]
```

On first successful open, scene registry state is reset implicitly.

Legacy alias of open:

```q
.draw.start[]
```

Clear all shapes and animation tracks:

```q
.draw.clear[]
```

Rebuild frame from scene registry (recommended when table rows change):

```q
.draw.refresh[]
```

Run one render/event tick:

```q
.draw.tick[]
```

Close renderer:

```q
.draw.close[]
```

Runtime diagnostics:

```q
.draw.status[]
.draw.version[]
.draw.noop.status[]
```

Array shape helper:

```q
.draw.shape.info 3 3 2#til 49
/ 3 3 2
```

Built-in function help:

```q
.draw.help[`scene.upsert]
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
