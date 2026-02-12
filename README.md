# raylib-q-project

A modular q + raylib toolkit with table-first drawing, animations, scene graphs, events, interactive loops, and legacy Rayua-style bindings.

## Quick Start

1. Build:
   `make`
2. Run tests:
   `make test`
3. Install to `~/.kx`:
   `make install`

## Repository Layout

- `qsrc/`: q modules loaded in order from `qsrc/modules.list`
- `csrc/`: C runtime support modules
- `tests/`: q test suites
- `scripts/`: build/install helpers
- `docs/`: split documentation set

## Documentation Index

- `docs/getting-started.md`
- `docs/api-core-scene-frame.md`
- `docs/api-animation-events-ui.md`
- `docs/examples-and-notes.md`
- `docs/RAYUA_BINDINGS_REFERENCE.md`

## Notes

- The q init loader is generated via `scripts/build_raylib_q_init.sh`.
- Always run `make install` after changes so the latest shim and q init script are available in `~/.kx`.
