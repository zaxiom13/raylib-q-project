# Next Steps and Ambitious Directions

The current foundation is strong:
- q controls a persistent native raylib renderer
- commands are exposed through compact q APIs
- table-first drawing is practical and ergonomic

The goal of this roadmap is to keep that momentum while scaling from useful tooling to a full interactive platform.

---

## Completed

### 1. Complete the Primitive Layer ✓

Implemented table-first APIs for core raylib primitives: triangle, circle, square, rect, line, point, text, pixels. Each function takes a table with required columns and optional metadata (color, alpha, layer, rotation, stroke, fill). A generic `.raylib.draw[`kind;t]` dispatcher routes to all primitives. Polyline/path and texture/sprite remain future work.

### 2. Pixel Arrays as First-Class Render Input ✓

`.raylib.pixels[t]` renders raster payloads from table rows. Array shape determines interpretation (grayscale, RGB, RGBA, matrix, animated frames). Supports destination scaling (dw/dh), alpha modulation, and automatic frame looping for animated payloads.

### 3. Unified Draw Schema and Validation ✓

All draw and animate APIs share a common schema validator. Required columns are checked per primitive, extra columns are tolerated for richer source tables, and optional metadata columns are handled consistently. Error messages include usage strings with expected required columns.

### 4. Scene Management API ✓

Scene entries keyed by id with upsert/delete/visibility/layer operations. Auto-refresh redraws in layer + insertion order. Symbol references and lambda bindings enable dynamic columns that resolve at draw time.

### 5. Frame/Animation System ✓

C-side looping animation tracks with per-row rate and optional interpolation. Q-side tween builders (`.raylib.tween.table`, `.raylib.keyframesTable`) with four easing functions. Fixed-step frame loop with callback registration (`.raylib.frame.on/tick/step/run`).

### 6. Event/Input Pipeline Back to q ✓

Renderer publishes mouse, keyboard, and window events. Q polls via `.raylib.events.poll[]` or subscribes via `.raylib.events.on[fn]`. Interactive mode (`.raylib.interactive.start[]`) runs a timer-driven loop updating mouse/window vars and redrawing live callable draw tables.

### 7. Data-Driven UI Toolkit on Top ✓

Table-first widget APIs: panels, buttons (with press/release click modes and edge-state detection), sliders, line/bar charts, and inspectors. Immediate-mode frame pattern with `.raylib.ui.frame[fn]` for batched rendering. Hit detection and button state machine for interactive workflows.

---

## Active Roadmap

### 8. Performance and Throughput

For large scenes, optimize command and draw paths:
- binary command protocol instead of string parsing
- batching and dirty-region updates
- pooled objects / arena allocators in C
- command compression
- fast path for unchanged frame state

Add profiling hooks:
- command throughput
- frame timing (CPU/GPU)
- dropped-frame counters

### 9. Reliability and Developer Ergonomics

Add operational robustness:
- health checks (`.raylib.status[]`)
- auto-restart and reconnect
- command acknowledgements and error reporting
- version handshake between q init and shim binary
- verbose debug toggles

### 10. Sharing and Social Distribution

Make demos easy to share and easy to watch:
- screen-share-friendly scripts that produce clean, repeatable visual runs
- short, social-media-friendly example flows (fast setup + visual payoff)
- standard demo formats so posts/videos are consistent and recognizable
- copy/paste q snippets that recreate the same scene for anyone watching

### 11. Multi-Window and Viewports

Add support for:
- named windows
- multiple render contexts
- split viewports

q can route different tables to different windows (for example: `chart`, `world`, `ui`).
