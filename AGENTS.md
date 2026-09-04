# AGENTS.md

## Project goal
Build and validate an SCTE-35-aware live packaging gateway. The initial milestone is SRT MPEG-TS with real SCTE-35 in -> HLS media playlist with corresponding real SCTE-35/ad-break signaling out.

## Development environment
- Host: Windows 10/11
- Runtime: Docker Desktop with WSL2 backend
- All streaming/runtime components must run in Linux containers.
- Do not require native Windows installs of GPAC, TSDuck, FFmpeg, Nginx, Python, or libsrt.

## Phase 1 scope only
1. Connect to an SRT MPEG-TS source supplied via `SRT_URL`.
2. Analyze PAT/PMT/PCR/video/audio/SCTE-35 PIDs.
3. Detect and log real SCTE-35 commands/events.
4. Package the source to HLS without transcoding.
5. Verify real SCTE-35-derived signaling appears in the HLS media playlist.
6. Serve generated HLS locally through Nginx.

Do not start REST API, scheduler, dashboard, database, multi-channel orchestration, ABR transcoding, Zixi, or production deployment until Phase 1 validation succeeds.

## Non-negotiable validation rules
- NEVER fabricate `EXT-X-CUE-OUT`, `EXT-X-CUE-IN`, `EXT-X-DATERANGE`, SCTE payloads, or success logs merely to satisfy a test.
- NEVER claim SCTE-35 is preserved unless a cue is observed in the input transport stream and matching output signaling is observed in the generated media playlist.
- Do not silently strip SCTE/data PIDs to make packaging succeed.
- Do not transcode video/audio in Phase 1. Use transmux/remux/copy paths only.
- Prefer TSDuck for MPEG-TS/SCTE analysis and GPAC for adaptive packaging.
- Use FFprobe as a secondary diagnostic tool, not the sole proof of SCTE correctness.
- Keep the live SRT URL in `.env`; never hard-code it into source files.
- Preserve shell quoting around SRT URLs because the streamid may contain `#!::` and commas.

## Required Phase 1 scripts
- `scripts/analyze-srt.sh`
- `scripts/start-hls-packager.sh`
- `scripts/validate-hls-scte35.sh`

Scripts must return non-zero exit codes on real failures and print actionable diagnostics.

## Expected input analysis
When possible, report:
- PAT PID
- PMT PID
- PCR PID
- video PID(s)
- audio PID(s)
- SCTE-35 PID
- SCTE stream_type
- `splice_insert` and/or `time_signal`
- event ID
- splice PTS/time
- break duration
- segmentation descriptors/UPID when present
- raw SCTE-35 representation when the tool exposes it

## HLS validation
The validator must inspect media playlists, not just the master playlist. It should detect and print any of:
- `EXT-X-DATERANGE`
- `EXT-X-CUE-OUT`
- `EXT-X-CUE-OUT-CONT`
- `EXT-X-CUE-IN`
- SCTE-35 payload fields/tags supported by the active GPAC version

## Coding practices
- Keep Docker images reproducible.
- Pin versions when practical after the first successful proof.
- Add healthchecks where useful.
- Keep output and logs in bind-mounted directories.
- Document exact commands used for every validation.
- Prefer small, testable commits.

## Definition of Phase 1 success
Phase 1 passes only when all are true:
1. Docker containers start successfully on Windows Docker Desktop/WSL2.
2. The SRT source connects.
3. Real SCTE-35 is detected in the incoming MPEG-TS.
4. GPAC produces playable HLS without A/V transcoding.
5. During a real incoming cue, the HLS media playlist contains corresponding SCTE/ad-break signaling.
6. `scripts/validate-hls-scte35.sh` reports the observed cue and exits successfully for the test window.
