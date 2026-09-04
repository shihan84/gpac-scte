FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG TSDUCK_DEB_URL=https://github.com/tsduck/tsduck/releases/download/v3.44-4676/tsduck_3.44-4676.ubuntu24_amd64.deb

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl ffmpeg bash jq procps net-tools iproute2 \
 && rm -rf /var/lib/apt/lists/*

# Current stable TSDuck Ubuntu 24 package. Keep the URL as a build ARG so
# the image can be updated/pinned without rewriting the Dockerfile.
RUN curl -fL "$TSDUCK_DEB_URL" -o /tmp/tsduck.deb \
 && apt-get update \
 && apt-get install -y /tmp/tsduck.deb \
 && rm -f /tmp/tsduck.deb \
 && rm -rf /var/lib/apt/lists/*

CMD ["sleep", "infinity"]
