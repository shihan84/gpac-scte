#!/usr/bin/env bash
set -euo pipefail

URL="${1:-${SRT_URL:-}}"
SEG="${HLS_SEGMENT_DURATION:-6}"
TSB="${HLS_TIMESHIFT_SECONDS:-60}"

if [[ -z "$URL" ]]; then
  echo "ERROR: provide SRT URL as argument or SRT_URL env var" >&2
  exit 2
fi

OUT=/output/hls
mkdir -p "$OUT" /logs
rm -f "$OUT"/*.m3u8 "$OUT"/*.ts "$OUT"/*.m4s "$OUT"/*.mp4 2>/dev/null || true

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
LOG="/logs/gpac-hls-${STAMP}.log"

echo "Starting GPAC live HLS packaging"
echo "Input: $URL"
echo "Output: $OUT/index.m3u8"
echo "Segment duration: ${SEG}s"
echo "Timeshift: ${TSB}s"

# Phase 1 intentionally performs packaging/remuxing only; no A/V transcoding.
# `hlsc` enables HLS cue handling where supported by the active GPAC build.
# If the installed GPAC version changes option names, inspect `gpac -h dasher`
# and document the exact replacement rather than fabricating output tags.
exec gpac \
  -i "$URL" \
  -o "$OUT/index.m3u8:segdur=${SEG}:dmode=dynamic:tsb=${TSB}:hlsc" \
  2>&1 | tee "$LOG"
