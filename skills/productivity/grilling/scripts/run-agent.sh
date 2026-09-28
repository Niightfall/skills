#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: $0 {start|resume SESSION_ID} [codex exec arguments...]" >&2
  exit 2
}

command_name="${1:-}"
shift || true

case "$command_name" in
  start)
    resume_id=""
    ;;
  resume)
    resume_id="${1:-}"
    [ -n "$resume_id" ] || usage
    shift
    ;;
  *)
    usage
    ;;
esac

model="gpt-5.6-luna"
reasoning="high"
output_file="$(mktemp)"
event_file="$(mktemp)"
trap 'rm -f "$output_file" "$event_file"' EXIT

export CODEX_AGENT_ROLE="planning"

if [ -n "$resume_id" ]; then
  codex exec resume \
    --model "$model" \
    -c "model_reasoning_effort=$reasoning" \
    --skip-git-repo-check \
    --json \
    -o "$output_file" \
    "$resume_id" "$@" >"$event_file"
else
  codex exec \
    --model "$model" \
    -c "model_reasoning_effort=$reasoning" \
    --json \
    -o "$output_file" \
    "$@" >"$event_file"
fi

if [ -z "$resume_id" ]; then
  session_id="$(sed -n 's/.*"type":"thread.started".*"thread_id":"\([^"]*\)".*/\1/p' "$event_file" | head -n 1)"
  [ -n "$session_id" ] || {
    cat "$event_file" >&2
    echo "Unable to determine the grilling session ID." >&2
    exit 1
  }
  printf 'GRILLING_SESSION_ID=%s\n' "$session_id"
fi

printf '%s\n' 'GRILLING_RESPONSE_BEGIN'
cat "$output_file"
printf '%s\n' 'GRILLING_RESPONSE_END'
