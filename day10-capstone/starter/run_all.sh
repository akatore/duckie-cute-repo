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

# TODO 1: rm -rf "$WORK"; mkdir -p "$MEDIA"; generate 3 clips with ffmpeg (see day06 gen_clips.sh)
# TODO 2: perl "$ROOT/bin/scan.pl" "$MEDIA" > "$WORK/probes.json"
# TODO 3: create the DB from sql/schema.sql and load probes.json
# TODO 4: start bin/server.pl in the background, remember its PID, and
#         trap 'kill "$SERVER_PID" 2>/dev/null || true' EXIT
# TODO 5: wait (up to ~10 s) until /health answers
# TODO 6: fetch /catalog, count the entries (perl -MJSON::PP ...), expect 3
# TODO 7: echo "ALL GOOD"
die "not implemented yet"
