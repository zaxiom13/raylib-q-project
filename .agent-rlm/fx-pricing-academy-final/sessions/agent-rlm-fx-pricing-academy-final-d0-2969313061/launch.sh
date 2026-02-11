#!/usr/bin/env bash
set -euo pipefail

SLOTS_DIR="/Users/zak1726/Desktop/coding/raylib-q-project/.agent-rlm/fx-pricing-academy-final/slots"
MAX_PARALLEL="8"
SESSION_DIR="/Users/zak1726/Desktop/coding/raylib-q-project/.agent-rlm/fx-pricing-academy-final/sessions/agent-rlm-fx-pricing-academy-final-d0-2969313061"

acquire_slot() {
  while true; do
    i=1
    while [[ "$i" -le "$MAX_PARALLEL" ]]; do
      lock="${SLOTS_DIR}/slot_${i}.lock"
      if mkdir "$lock" 2>/dev/null; then
        echo "$$" > "${lock}/pid"
        echo "$i"
        return 0
      fi

      if [[ -f "${lock}/pid" ]]; then
        holder="$(cat "${lock}/pid" 2>/dev/null || true)"
        if [[ -n "$holder" ]] && ! kill -0 "$holder" 2>/dev/null; then
          rm -rf "$lock"
        fi
      fi
      i=$((i + 1))
    done
    sleep 1
  done
}

slot_num="$(acquire_slot)"
slot_lock="${SLOTS_DIR}/slot_${slot_num}.lock"
trap 'rm -rf "$slot_lock" 2>/dev/null || true' EXIT

export PATH="/Users/zak1726/Desktop/rlm/agent-rlm/scripts:$PATH"
export RLM_DEPTH="1"
export RLM_MAX_DEPTH="2"
export RLM_MAX_PARALLEL="8"
export RLM_TIMEOUT="1800"
export RLM_TASK="fx-pricing-academy-final"
export RLM_MODEL="opencode/kimi-k2.5-free"

cd "/Users/zak1726/Desktop/coding/raylib-q-project"
prompt_payload="$(cat "/Users/zak1726/Desktop/coding/raylib-q-project/.agent-rlm/fx-pricing-academy-final/sessions/agent-rlm-fx-pricing-academy-final-d0-2969313061/prompt.md")"
cmd=(opencode run --format json --model "opencode/kimi-k2.5-free" "${prompt_payload}")
"${cmd[@]}" > "/Users/zak1726/Desktop/coding/raylib-q-project/.agent-rlm/fx-pricing-academy-final/sessions/agent-rlm-fx-pricing-academy-final-d0-2969313061/events.log" 2> "/Users/zak1726/Desktop/coding/raylib-q-project/.agent-rlm/fx-pricing-academy-final/sessions/agent-rlm-fx-pricing-academy-final-d0-2969313061/stderr.log" || echo "$?" > "/Users/zak1726/Desktop/coding/raylib-q-project/.agent-rlm/fx-pricing-academy-final/sessions/agent-rlm-fx-pricing-academy-final-d0-2969313061/exit_code"
if [[ ! -f "/Users/zak1726/Desktop/coding/raylib-q-project/.agent-rlm/fx-pricing-academy-final/sessions/agent-rlm-fx-pricing-academy-final-d0-2969313061/exit_code" ]]; then
  jq -r 'select(.type == "text") | .part.text' "/Users/zak1726/Desktop/coding/raylib-q-project/.agent-rlm/fx-pricing-academy-final/sessions/agent-rlm-fx-pricing-academy-final-d0-2969313061/events.log" > "/Users/zak1726/Desktop/coding/raylib-q-project/.agent-rlm/fx-pricing-academy-final/result.out" || echo "$?" > "/Users/zak1726/Desktop/coding/raylib-q-project/.agent-rlm/fx-pricing-academy-final/sessions/agent-rlm-fx-pricing-academy-final-d0-2969313061/exit_code"
fi
touch "/Users/zak1726/Desktop/coding/raylib-q-project/.agent-rlm/fx-pricing-academy-final/sessions/agent-rlm-fx-pricing-academy-final-d0-2969313061/.done"
