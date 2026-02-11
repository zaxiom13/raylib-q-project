# Project Progress Tracker

Last updated: 2026-02-11
Source roadmap: `NEXT_STEPS.md`

## Current Status by Roadmap Step

| Step | Title | Status | Notes |
| --- | --- | --- | --- |
| 1 | Complete the Primitive Layer | Partial | Implemented: `triangle`, `circle`, `rect`, `line`, `point`, `text`, `pixels`. Not yet present: polyline/path, texture/sprite draw. |
| 2 | Pixel Arrays as First-Class Render Input | Done | `.raylib.pixels[t]` supports static and animated payloads, including `ANIM_PIXELS_*` flow. |
| 3 | Unified Draw Schema and Validation | Done | Added shared schema validator across draw/animate APIs with required-column enforcement, permissive extra-column tolerance, explicit common optional metadata (`color`, `alpha`, `layer`, `rotation`, `stroke`, `fill`), and consistent defaults. |
| 4 | Scene Management API | Done | Implemented: upsert/delete/clear layer/visibility/list/reset with auto-refresh behavior. |
| 5 | Frame/Animation System | Done | Added tween/keyframe builders (`.raylib.tween.table`, `.raylib.keyframesTable`) plus fixed-step callback loop (`.raylib.frame.*`) with tick/step/run and callback registration APIs. |
| 6 | Event/Input Pipeline Back to q | Done | Added renderer event queue + drain protocol, q event polling/callback APIs, and interactive mode loop that updates mouse/window vars (`mx`,`my`, etc.) and redraws live callable draw tables. |
| 7 | Data-Driven UI Toolkit on Top | Done | Added table-first UI APIs for panels, buttons, sliders, line/bar charts, and inspectors with interactive state helpers and docs/tests coverage. |
| 8 | Performance and Throughput | Not started | No binary protocol or batching/dirty-region/pooling optimization layer yet. |
| 9 | Reliability and Developer Ergonomics | Partial | Added `.raylib.status[]`, `.raylib.version[]`, and no-op diagnostics/toggles; deeper auto-restart/acknowledgement flows still pending. |
| 10 | Sharing and Social Distribution | Not started | No standard demo/share workflow defined yet. |
| 11 | Multi-Window and Viewports | Not started | Single-window flow today. |

## Update Protocol (How We Keep This Current)

- Update this file in every PR/session where roadmap progress changes.
- If a step is intentionally deferred, add a log entry with reason.
- If work is started but incomplete, mark `Partial` and list exactly what is missing.
- Keep `Last updated` date in ISO format (`YYYY-MM-DD`).

Status meanings:
- `Done`: roadmap intent for that step is functionally complete.
- `Partial`: meaningful implementation exists, but key roadmap scope is still missing.
- `Not started`: no concrete implementation yet.

## Change Log

### 2026-02-06

- Created this tracker and captured baseline status for roadmap steps 1-11.
- Confirmed test suite passes at baseline (`make test`).
- Completed Step 3: unified draw schema/validation contract with required-column checks, extra-column tolerance, and shared optional metadata handling.
- Added tests for schema errors, permissive extra-column handling, and alpha override behavior in static and animated draw APIs.
- Completed Step 5: added tween/keyframe APIs and fixed-step frame callbacks (`.raylib.frame.on/.tick/.step/.run`).
- Added tests covering tween interpolation, keyframe expansion, callback tick execution, and frame dt validation.
- Completed Step 6: added renderer-to-q input events (mouse/keyboard/window), q-side polling/subscription APIs, and interactive mode (`.raylib.interactive.mode[0|1]`) with symbol-reference live redraw support.
- Added tests for event parsing/callback dispatch, interactive mode toggle, and mouse-follow circle behavior via `x:\`mx`/`y:\`my`.

### 2026-02-08

- Completed Step 7: added data-driven UI toolkit APIs (`.raylib.ui.panel`, `.raylib.ui.button`, `.raylib.ui.slider`, `.raylib.ui.chartLine`, `.raylib.ui.chartBar`, `.raylib.ui.inspector`) plus dispatcher/helpers.
- Added interaction/state helpers for UI workflows (`.raylib.ui.hit.rect`, `.raylib.ui.buttonState`, `.raylib.ui.sliderValue`) driven by interactive mouse vars.
- Added help docs and README usage for Step 7 UI APIs.
- Added tests covering UI draw command generation, chart rendering behavior, slider/button state behavior, and help entries.
- Added high-level UI frame/button APIs with per-button configurable click mode (`press`/`release`) and edge-state handling to avoid multi-fire on held clicks.

### 2026-02-09

- Synced docs with actual schema behavior: required columns are enforced and extra columns are tolerated in draw APIs.
- Fixed compatibility state updates for cursor visibility, trace log level, and exit key (`.raylib.interactive._escKey` now follows `SetExitKey`).
- Fixed callable-reference resolution to allow callable string results (notably for dynamic text columns).
- Corrected help docs for `.raylib.shape.show` return semantics (`::`).

### 2026-02-11

- Added runtime diagnostics and reliability APIs: `.raylib.status[]`, `.raylib.version[]`, `.raylib.noop.mode[0|1]`, `.raylib.noop.status[]`.
- Added native runtime version export (`rq_version`) and native-open probe wiring (`rq_is_open`) into q init load path.
- Refactored no-op handling to track count, last message, and timestamp in core runtime state.
- Added a dedicated reliability regression suite (`tests/raylib_q_init_tests_runtime_status.q`) and integrated it into the unified test loader.
- Updated docs/help entries for the new diagnostics and reliability APIs.
