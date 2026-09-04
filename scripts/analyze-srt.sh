#!/usr/bin/env bash
set -euo pipefail

URL="${1:-${SRT_URL:-}}"
if [[ -z "$URL" ]]; then
  echo "ERROR: provide SRT URL as argument or SRT_URL env var" >&2
  exit 2
fi

mkdir -p /logs
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"

printf '\n=== ffprobe stream inventory ===\n'
ffprobe -hide_banner -loglevel warning \
  -show_programs -show_streams -of json "$URL" \
  | tee "/logs/ffprobe-${STAMP}.json"

printf '\n=== TSDuck service / PID analysis ===\n'
# Use the generic SRT URL input when supported by this TSDuck build.
# If the build exposes a dedicated input plugin syntax instead, Codex must
# adapt this command based on `tsp --list-plugins` / plugin help and document it.
set +e
tsp -I srt "$URL" -P analyze --service-analysis -O drop \
  2>&1 | tee "/logs/tsduck-analysis-${STAMP}.log"
TSP_RC=${PIPESTATUS[0]}
set -e

if [[ $TSP_RC -ne 0 ]]; then
  echo "TSDuck SRT analysis command failed. Inspect plugin support with:" >&2
  echo "  tsp --list-plugins" >&2
  echo "  tsp -I srt --help" >&2
  exit "$TSP_RC"
fi

echo
printf 'Analysis logs written under /logs.\n'
