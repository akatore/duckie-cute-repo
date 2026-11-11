#!/usr/bin/env bash
# usage: gen_clips.sh [OUTPUT_DIR]   (default: ./clips)
# Generates small synthetic test files with ffmpeg's built-in sources (lavfi).
set -euo pipefail

out="${1:-clips}"
mkdir -p "$out"

ff() { ffmpeg -hide_banner -loglevel error -y "$@"; }

# H.264 video + AAC audio in MP4 (the web default)
ff -f lavfi -i testsrc2=size=1280x720:rate=25:duration=5 \
   -f lavfi -i sine=frequency=440:duration=5 \
   -c:v libx264 -preset veryfast -pix_fmt yuv420p \
   -c:a aac -b:a 128k -shortest "$out/clip_h264.mp4"

# VP9 video + Opus audio in WebM (royalty-free web)
ff -f lavfi -i testsrc=size=640x360:rate=30:duration=5 \
   -f lavfi -i sine=frequency=660:duration=5 \
   -c:v libvpx-vp9 -b:v 500k -deadline realtime -cpu-used 8 \
   -c:a libopus -b:a 64k -shortest "$out/clip_vp9.webm"

# MPEG-2 video + MP2 audio in MPEG-TS (classic broadcast)
ff -f lavfi -i testsrc=size=720x576:rate=25:duration=5 \
   -f lavfi -i sine=frequency=880:duration=5 \
   -c:v mpeg2video -b:v 2M \
   -c:a mp2 -b:a 128k -shortest "$out/clip_mpeg2.ts"

# Uncompressed 16-bit stereo PCM in WAV (also used on Day 7)
ff -f lavfi -i sine=frequency=1000:duration=3:sample_rate=48000 \
   -ac 2 -c:a pcm_s16le "$out/tone.wav"

echo "generated in $out:"
ls -l "$out"
