#!/usr/bin/env bash
# usage: bash check.sh [DIR_WITH_probe_report.pl]   (default: ./starter)
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/../lib/check_lib.sh"
DIR="$(resolve_dir "${1:-}" "$HERE/starter")"
SCRIPT="$DIR/probe_report.pl"

echo "Checking $SCRIPT"
need perl; need ffmpeg; need ffprobe

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "  (generating test clips, takes a few seconds...)"
if ! bash "$HERE/starter/gen_clips.sh" "$TMP/clips" > "$TMP/gen.log" 2>&1; then
    echo "gen_clips.sh failed:"; cat "$TMP/gen.log"; exit 2
fi

check "probe_report.pl compiles" perl -c "$SCRIPT"
check "uses list-form open (no shell)" grep -qE "open[ (]+my +\\\$[a-z_]+, *'-\\|', *'ffprobe'" "$SCRIPT"

if perl "$SCRIPT" "$TMP"/clips/clip_h264.mp4 "$TMP"/clips/clip_vp9.webm "$TMP"/clips/clip_mpeg2.ts "$TMP"/clips/tone.wav > "$TMP/out" 2> "$TMP/err"; then
    pass "runs on all clips"
else
    fail "runs on all clips"; head -n 5 "$TMP/err" | sed 's/^/        /'
fi
lines=$(wc -l < "$TMP/out" | tr -d ' ')
[ "$lines" = 4 ] && pass "prints one line per file" || fail "prints one line per file (got $lines lines)"

# expect FILE "fixed text that must appear on that file's line"
expect() {
    local line
    line=$(grep -F "$1 |" "$TMP/out" | head -n 1)
    if [[ "$line" == *"$2"* ]]; then pass "$1: $2"; else fail "$1: $2"; echo "        your line: $line"; fi
}
expect_re() {
    local line
    line=$(grep -F "$1 |" "$TMP/out" | head -n 1)
    if [[ "$line" =~ $2 ]]; then pass "$1: matches /$2/"; else fail "$1: matches /$2/"; echo "        your line: $line"; fi
}

expect clip_h264.mp4 "container=mov,mp4,m4a,3gp,3g2,mj2"
expect clip_h264.mp4 "video=h264 1280x720 25.00fps"
expect clip_h264.mp4 "audio=aac 44100Hz 1ch"
expect_re clip_h264.mp4 'duration=(4\.9[0-9]|5\.[0-9][0-9])s \| bitrate=[0-9]+ kb/s$'

expect clip_vp9.webm "container=matroska,webm"
expect clip_vp9.webm "video=vp9 640x360 30.00fps"
expect clip_vp9.webm "audio=opus 48000Hz 1ch"

expect clip_mpeg2.ts "container=mpegts"
expect clip_mpeg2.ts "video=mpeg2video 720x576 25.00fps"
expect clip_mpeg2.ts "audio=mp2 44100Hz 1ch"

expect tone.wav "tone.wav | container=wav | video=none | audio=pcm_s16le 48000Hz 2ch | duration=3.00s | bitrate=1536 kb/s"

touch "$TMP/empty.mp4"
perl "$SCRIPT" "$TMP/empty.mp4" "$TMP/clips/tone.wav" > "$TMP/out2" 2> "$TMP/err2"
rc=$?
[ "$rc" -ne 0 ] && pass "exits non-zero when a file can't be probed" || fail "exits non-zero when a file can't be probed"
grep -q '^tone.wav |' "$TMP/out2" && pass "continues with the next file after a failure" || fail "continues with the next file after a failure"
[ -s "$TMP/err2" ] && pass "warns on stderr about the bad file" || fail "warns on stderr about the bad file"

summary
