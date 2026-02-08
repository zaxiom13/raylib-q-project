# Refactor Guidelines

These guidelines are tuned for this project to balance DRY, KISS, and maintainability.

## Practical guardrails

- Keep each file focused on one clear responsibility.
- Prefer medium-sized files (rough target: ~120-400 lines).
- Split files when one of these happens:
  - Mixed concerns (CLI + runtime loop in one file)
  - Repeated parsing/rendering patterns that are hard to trace
  - High change-churn in unrelated sections
- Avoid micro-files with trivial wrappers unless they create a stable boundary.
- Optimize for reader clarity over cleverness.
- Preserve behavior while refactoring: move/reshape first, then optimize.

## Project-specific module boundaries

- `raylib_q_window.c`: native-only shim notice for deprecated entrypoint.
- `raylib_q_runtime.c`: raylib runtime loop, command handling, draw/update flow.
- `qsrc/*.q`: q API split by concern and composed into `raylib_q_init.q`.

## Source references

- Linux kernel coding style (functions should be short, focused, and split when complex):
  https://docs.kernel.org/6.5/process/coding-style.html
- Google C++ Style Guide (optimize for reader, consistency, self-contained headers):
  https://google.github.io/styleguide/cppguide
- Pragmatic Programmer Tips (DRY, reuse, and independent components):
  https://pragprog.com/tips/
