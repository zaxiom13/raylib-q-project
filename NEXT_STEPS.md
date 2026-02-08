# Next Steps and Ambitious Directions

The current foundation is strong:
- q controls a persistent native raylib renderer
- commands are exposed through compact q APIs
- table-first drawing is practical and ergonomic

The goal of this roadmap is to keep that momentum while scaling from useful tooling to a full interactive platform.

## 1. Complete the Primitive Layer

Expand the table-first API across core raylib primitives:
- circle
- rectangle
- line
- point/pixel
- polyline/path
- text
- texture/sprite draw

Design goals:
- one function per primitive family
- optional columns for advanced behavior
- consistent validation and error behavior across all draw APIs

Examples:
- `.raylib.circle[t]` with required `x y r`
- `.raylib.rect[t]` with required `x y w h`
- `.raylib.text[t]` with required `x y text size`

## 2. Pixel Arrays as First-Class Render Input

Add a table-first pixel-array rendering path where each row is one raster draw request.

Core idea:
- first column is an array payload
- array shape determines interpretation (for example: static image vs gif-like frame sequence, grayscale vs color)
- remaining columns carry rendering metadata

Metadata columns should include:
- width/height and source shape metadata
- destination x/y in the window
- destination size/scale
- optional timing/frame metadata for animated arrays
- optional blending/alpha flags

This creates a direct bridge from q array computation to pixel-level rendering in the window.

## 3. Unified Draw Schema and Validation

Define a formal draw-table contract:
- required columns by primitive
- optional columns (`color`, `layer`, `rotation`, `alpha`, `stroke`, `fill`)
- default-value policy
- strict, predictable schema errors

Then implement shared validators so primitive APIs behave the same way.

## 4. Scene Management API

Move beyond append-only drawing with scene operations:
- upsert by `id`
- delete by `id`
- clear by `layer`
- visibility toggles
- z-index/layer ordering

This shifts the shim from a command receiver into a lightweight scene engine.

## 5. Frame/Animation System

Introduce time-aware APIs:
- tween tables (`from`, `to`, `duration`, `easing`)
- keyframe-driven animation
- fixed-step update-loop hooks
- q callbacks on frame ticks

Ambitious goal:
- a small declarative animation DSL in q.

## 6. Event/Input Pipeline Back to q

Today the flow is mostly q -> renderer. Add renderer -> q:
- mouse move/click
- keyboard input
- window events (resize/close/focus)

Operating pattern:
- renderer publishes input events to an event socket/table
- q subscribers consume events and update scene tables

This unlocks interactive tools and lightweight games.

## 7. Data-Driven UI Toolkit on Top

Build higher-level widgets as table conventions:
- buttons
- sliders
- panels
- charts
- inspectors

Keep q tables as the source of truth and raylib as the render backend.

Ambitious goal:
- q-native immediate-mode UI for live dashboards and control surfaces.

## 8. Performance and Throughput

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

## 9. Reliability and Developer Ergonomics

Add operational robustness:
- health checks (`.raylib.status[]`)
- auto-restart and reconnect
- command acknowledgements and error reporting
- version handshake between q init and shim binary
- verbose debug toggles

## 10. Sharing and Social Distribution

Make demos easy to share and easy to watch:
- screen-share-friendly scripts that produce clean, repeatable visual runs
- short, social-media-friendly example flows (fast setup + visual payoff)
- standard demo formats so posts/videos are consistent and recognizable
- copy/paste q snippets that recreate the same scene for anyone watching

## 11. Multi-Window and Viewports

Add support for:
- named windows
- multiple render contexts
- split viewports

q can route different tables to different windows (for example: `chart`, `world`, `ui`).

## Suggested Build Order

1. Finish primitive APIs and shared validation.
2. Add table-first pixel-array rendering.
3. Add scene IDs with upsert/delete workflows.
4. Add input events back into q.
5. Add timeline/animation support.
6. Optimize protocol/perf and screen-share/social distribution workflows.

This path moves us from a useful tool to an interactive platform in controlled steps.
