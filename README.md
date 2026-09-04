# GPAC SCTE-35 Gateway

Experimental SCTE-35-aware live packaging pipeline for SRT MPEG-TS to HLS/DASH.

Initial development target:

- Windows 10/11 host
- Docker Desktop with WSL2 backend
- Linux containers only
- Existing SRT MPEG-TS input carrying SCTE-35
- GPAC for SCTE-aware HLS/DASH packaging
- TSDuck/FFprobe for transport-stream and SCTE-35 analysis
- Nginx for local HLS serving

## Phase 1 objective

Prove, without transcoding or fabricated markers, that SCTE-35 present in the SRT input can be detected and represented in generated HLS media playlists.

The live test source will be provided through environment variables and must not be hard-coded into production scripts.
