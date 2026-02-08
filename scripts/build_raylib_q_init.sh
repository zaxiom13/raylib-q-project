#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$ROOT_DIR/qsrc"
OUT_FILE="$ROOT_DIR/raylib_q_init.q"

parts=(
  "00_core.q"
  "10_shape.q"
  "20_pixels_and_send.q"
  "30_draw.q"
  "40_animation.q"
  "45_callbacks.q"
  "50_tween_frame.q"
  "55_events.q"
  "60_scene.q"
  "65_ui.q"
  "70_docs.q"
)

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

for part in "${parts[@]}"; do
  src_file="$SRC_DIR/$part"
  if [[ ! -f "$src_file" ]]; then
    echo "Missing q module: $src_file" >&2
    exit 1
  fi
  cat "$src_file" >> "$tmp_file"
  printf '\n\n' >> "$tmp_file"
done

mv "$tmp_file" "$OUT_FILE"
