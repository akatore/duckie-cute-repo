#!/usr/bin/env bash
# usage: [PORT=18090] run_all.sh [WORK_DIR]
# End-to-end test: generate media -> scan -> load DB -> serve -> verify over HTTP.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
WORK="${1:-$ROOT/work}"
PORT="${PORT:-18090}"
MEDIA="$WORK/media"
DB="$WORK/catalog.db"
BASE="http://127.0.0.1:$PORT"

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
ff()  { ffmpeg -hide_banner -loglevel error -y "$@"; }

for tool in ffmpeg ffprobe sqlite3 curl perl; do
    command -v "$tool" >/dev/null || die "missing tool: $tool"
done

log "generating test media in $MEDIA"
rm -rf "$WORK"
mkdir -p "$MEDIA"
ff -f lavfi -i testsrc2=size=640x360:rate=25:duration=2 -f lavfi -i sine=frequency=440:duration=2 \
   -c:v libx264 -preset veryfast -pix_fmt yuv420p -c:a aac -shortest "$MEDIA/demo_h264.mp4"
ff -f lavfi -i testsrc=size=720x576:rate=25:duration=2 -c:v mpeg2video "$MEDIA/demo_mpeg2.ts"
ff -f lavfi -i sine=frequency=1000:duration=2:sample_rate=48000 -ac 2 -c:a pcm_s16le "$MEDIA/demo_tone.wav"

log "scanning"
perl "$ROOT/bin/scan.pl" "$MEDIA" > "$WORK/probes.json"

log "loading $DB"
sqlite3 "$DB" < "$ROOT/sql/schema.sql"
perl "$ROOT/bin/load_catalog.pl" "$DB" "$WORK/probes.json"

log "starting server on port $PORT"
perl "$ROOT/bin/server.pl" "$PORT" "$MEDIA" "$DB" > "$WORK/server.log" 2>&1 &
SERVER_PID=$!
trap 'kill "$SERVER_PID" 2>/dev/null || true' EXIT

for _ in $(seq 1 40); do
    curl -fsS -o /dev/null "$BASE/health" 2>/dev/null && break
    kill -0 "$SERVER_PID" 2>/dev/null || die "server exited early: $(cat "$WORK/server.log")"
    sleep 0.25
done

log "verifying"
health=$(curl -fsS "$BASE/health") || die "/health failed"
[[ "$health" == *'"ok"'* ]] || die "/health returned: $health"

catalog=$(curl -fsS "$BASE/catalog") || die "/catalog failed"
count=$(printf '%s' "$catalog" | perl -MJSON::PP -0777 -ne 'print scalar @{ decode_json($_) }') \
    || die "/catalog is not valid JSON: $catalog"
[ "$count" -eq 3 ] || die "expected 3 catalog entries, got $count"

echo "ALL GOOD"
