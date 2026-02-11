# Electron Demo: Draw renderer

This demo lets you switch between local canvas rendering and raylib runtime rendering.

## Targets

- `canvas`: HTML canvas renderer (default)
- `raylib`: q runtime renderer via `.draw.*` API

## Run

```bash
cd ..
make install
cd electron-demo
npm install
npm start
```

## Usage

1. Pick a render target.
2. Start q (if not already running).
3. Enter one or more `.draw.*` commands in `q command`.
4. Click `Send Command`.

## Notes

- Public API in commands uses `.draw.*`.
- `.draw` is backed by existing `.raylib` internals for compatibility.
- Demo auto-loads `raylib_q_init.q` from project root (fallback `~/.kx/raylib_q_init.q`).
- The raylib target still renders in its native window.
