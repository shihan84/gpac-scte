#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-/output/hls}"
TIMEOUT="${SCTE_VALIDATE_TIMEOUT:-180}"
INTERVAL="${SCTE_VALIDATE_INTERVAL:-1}"

if [[ ! -d "$ROOT" ]]; then
  echo "ERROR: HLS directory not found: $ROOT" >&2
  exit 2
fi

echo "Watching HLS media playlists for real SCTE/ad-break signaling"
echo "Root: $ROOT"
echo "Timeout: ${TIMEOUT}s"

start=$(date +%s)
while true; do
  now=$(date +%s)
  if (( now - start >= TIMEOUT )); then
    echo "FAIL: no SCTE-35/ad-break tags observed during validation window" >&2
    exit 1
  fi

  mapfile -t playlists < <(find "$ROOT" -type f -name '*.m3u8' -print 2>/dev/null)
  for pl in "${playlists[@]:-}"; do
    [[ -f "$pl" ]] || continue
    # Media playlists contain EXTINF; do not treat the master playlist alone as proof.
    if ! grep -q '^#EXTINF:' "$pl"; then
      continue
    fi

    if grep -Eiq 'EXT-X-(DATERANGE|CUE-OUT|CUE-OUT-CONT|CUE-IN)|SCTE35|SCTE-35|OATCLS' "$pl"; then
      echo
      echo "PASS: SCTE/ad-break signaling observed in media playlist: $pl"
      grep -Ein 'EXT-X-(DATERANGE|CUE-OUT|CUE-OUT-CONT|CUE-IN)|SCTE35|SCTE-35|OATCLS' "$pl" || true
      exit 0
    fi
  done

  sleep "$INTERVAL"
done
