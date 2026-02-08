# Refactor Safety Checklist

Use this checklist to confirm behavior parity during refactors.

## Build/Test gate

- [ ] `make`
- [ ] `make test`
- [ ] `make install`

## Runtime lifecycle

- [ ] `.raylib.open[]` opens/reuses runtime
- [ ] `.raylib.close[]` closes runtime and remains idempotent
- [ ] `.raylib.start[]` remains alias of open

## Draw APIs

- [ ] Primitive draws still validate schema and reject unknown columns
- [ ] Default colors and per-row alpha overrides are unchanged
- [ ] Pixel payload modes (gray/rgb/rgba/matrix/animated) remain unchanged

## Animation APIs

- [ ] `.raylib.animate.*` still sends clear/add/play with per-row rate
- [ ] `interpolate` flag behavior unchanged
- [ ] `.raylib.animate.stop[]` and `.raylib.animate.start[]` still control all tracks

## Scene and refresh

- [ ] Scene upsert/delete/set/visible/clearLayer behavior unchanged
- [ ] `.raylib.refresh[]` draws by `layer` then insertion `ord`
- [ ] Auto-refresh behavior preserved

## Events and interactive

- [ ] `.raylib.events.poll[]`/`.raylib.events.pump[]` output and callback behavior unchanged
- [ ] Interactive mode toggles (`start/stop/spin/mode`) unchanged
- [ ] Timer ownership restoration remains safe

## Docs/help surface

- [ ] `.raylib.help` entries still resolve for all supported names
- [ ] Backward-compatible aliases continue to work
