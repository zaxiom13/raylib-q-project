#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$ROOT_DIR/qsrc"
OUT_FILE="$ROOT_DIR/raylib_q_init.q"
ORDER_FILE="$SRC_DIR/modules.list"

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

if [[ ! -f "$ORDER_FILE" ]]; then
  echo "Missing q module order manifest: $ORDER_FILE" >&2
  exit 1
fi

while IFS= read -r part; do
  [[ -z "$part" || "$part" == \#* ]] && continue
  src_file="$SRC_DIR/$part"
  if [[ ! -f "$src_file" ]]; then
    echo "Missing q module: $src_file" >&2
    exit 1
  fi
  cat "$src_file" >> "$tmp_file"
  printf '\n\n' >> "$tmp_file"
done < "$ORDER_FILE"

mv "$tmp_file" "$OUT_FILE"
