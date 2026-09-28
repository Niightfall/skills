#!/usr/bin/env bash
set -euo pipefail

role="${1:-}"
shift || true

case "$role" in
  planning)
    model="gpt-5.6-luna"
    reasoning="high"
    ;;
  implementation)
    model="gpt-5.6-luna"
    reasoning="medium"
    ;;
  *)
    echo "usage: $0 {planning|implementation} [codex exec arguments...]" >&2
    exit 2
    ;;
esac

export CODEX_AGENT_ROLE="$role"

exec codex exec \
  --model "$model" \
  -c "model_reasoning_effort=$reasoning" \
  "$@"
