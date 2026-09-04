# Phase 1: Windows + Docker Desktop

## Goal
Prove that real SCTE-35 present in the existing SRT MPEG-TS source can be detected and represented in GPAC-generated HLS media playlists without transcoding.

## Prerequisites
- Windows 10/11
- Docker Desktop using WSL2 backend
- Git

## Checkout
```powershell
git clone https://github.com/shihan84/gpac-scte.git
cd gpac-scte
git checkout codex/phase1-srt-hls
Copy-Item .env.example .env
```

Review `.env` and confirm the SRT URL.

## Build/start
```powershell
docker compose build analyzer
docker compose up -d
```

Check containers:
```powershell
docker compose ps
```

## 1. Verify installed tools
```powershell
docker compose exec analyzer tsp --version
docker compose exec analyzer ffprobe -version
docker compose exec gpac gpac -version
```

## 2. Analyze the incoming SRT MPEG-TS
```powershell
docker compose exec analyzer bash /scripts/analyze-srt.sh
```

Do not proceed on assumption alone. Confirm the input contains a real SCTE-35 PID/event. If the current TSDuck SRT input plugin syntax differs, inspect:

```powershell
docker compose exec analyzer tsp --list-plugins
docker compose exec analyzer tsp -I srt --help
```

Then update the analyzer script and document the exact working syntax.

## 3. Start GPAC HLS packaging
Run in a separate PowerShell terminal:

```powershell
docker compose exec gpac bash /scripts/start-hls-packager.sh
```

The expected local master URL is:

```text
http://localhost:8080/hls/index.m3u8
```

## 4. Validate real SCTE signaling
In another terminal:

```powershell
docker compose exec gpac bash /scripts/validate-hls-scte35.sh
```

The validator only passes when a media playlist (not merely the master) contains real SCTE/ad-break signaling such as `EXT-X-DATERANGE`, `EXT-X-CUE-OUT`, `EXT-X-CUE-OUT-CONT`, `EXT-X-CUE-IN`, or a supported SCTE payload tag.

## 5. Inspect output manually
```powershell
curl.exe http://localhost:8080/hls/index.m3u8
```

Find the child media playlist referenced by the master and inspect it while a real cue is sent.

## Phase 1 pass criteria
- SRT connects.
- Input MPEG-TS contains real SCTE-35.
- GPAC produces playable HLS without A/V transcoding.
- Corresponding SCTE/ad-break signaling is observed in a generated HLS media playlist.
- The validation script reports PASS during a real cue.

If any command fails because a current tool version uses different syntax, fix the integration based on the installed tool's own help/docs and record the exact command. Never generate fake tags to satisfy the validator.
