#!/usr/bin/env bash
# usage: bash check.sh [DIR_WITH_server.pl]   (default: ./starter)
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/../lib/check_lib.sh"
DIR="$(resolve_dir "${1:-}" "$HERE/starter")"
SCRIPT="$DIR/server.pl"
PORT=18084
BASE="http://127.0.0.1:$PORT"

echo "Checking $SCRIPT"
need perl; need curl

check "server.pl compiles" perl -c "$SCRIPT"

TMP="$(mktemp -d)"
mkdir -p "$TMP/media/subdir"
touch "$TMP/media/b.mkv" "$TMP/media/a.mp4" "$TMP/media/.hidden"
perl "$SCRIPT" "$PORT" "$TMP/media" > "$TMP/server.log" 2>&1 &
SERVER_PID=$!
trap 'kill "$SERVER_PID" 2>/dev/null; rm -rf "$TMP"' EXIT

for _ in $(seq 1 40); do
    curl -s -o /dev/null "$BASE/health" 2>/dev/null && break
    sleep 0.25
done
if ! kill -0 "$SERVER_PID" 2>/dev/null; then
    fail "server starts and keeps running"
    sed 's/^/        /' "$TMP/server.log" | head -n 10
    summary; exit
fi
pass "server starts and keeps running"

# request METHOD PATH -> sets CODE, writes body to $TMP/body and headers to $TMP/headers
request() {
    CODE=$(curl -s -X "$1" -D "$TMP/headers" -o "$TMP/body" -w '%{http_code}' --max-time 5 "$BASE$2")
}
header() { grep -i "^$1:" "$TMP/headers" | head -n 1 | cut -d: -f2- | tr -d ' \r'; }

request GET /health
[ "$CODE" = 200 ] && pass "GET /health -> 200" || fail "GET /health -> 200 (got $CODE)"
json_eq_str "$TMP/body" '{"status":"ok"}' && pass "/health body is {\"status\":\"ok\"}" || fail "/health body is {\"status\":\"ok\"} (got: $(head -c 80 "$TMP/body"))"
case "$(header Content-Type)" in
    application/json*) pass "Content-Type: application/json" ;;
    *) fail "Content-Type: application/json (got '$(header Content-Type)')" ;;
esac
body_len=$(wc -c < "$TMP/body" | tr -d ' ')
[ "$(header Content-Length)" = "$body_len" ] && pass "Content-Length matches body size" || fail "Content-Length matches body size (header '$(header Content-Length)', body $body_len bytes)"
[ "$(header Connection)" = "close" ] && pass "Connection: close" || fail "Connection: close"
head -n 1 "$TMP/headers" | grep -q $'\r$' && pass "status line ends with \\r\\n" || fail "status line ends with \\r\\n"

request GET /files
[ "$CODE" = 200 ] && pass "GET /files -> 200" || fail "GET /files -> 200 (got $CODE)"
json_eq_str "$TMP/body" '["a.mp4","b.mkv"]' && pass "/files lists sorted regular files, no hidden files, no dirs" || fail "/files lists sorted regular files (got: $(head -c 120 "$TMP/body"))"

request GET '/files?type=video'
[ "$CODE" = 200 ] && pass "query string is ignored" || fail "query string is ignored (got $CODE)"

request GET /nope
[ "$CODE" = 404 ] && pass "unknown path -> 404" || fail "unknown path -> 404 (got $CODE)"
json_eq_str "$TMP/body" '{"error":"not found"}' && pass "404 body" || fail "404 body is {\"error\":\"not found\"}"

request POST /health
[ "$CODE" = 405 ] && pass "POST -> 405" || fail "POST -> 405 (got $CODE)"
[ "$(header Allow)" = "GET" ] && pass "405 has Allow: GET" || fail "405 has Allow: GET"

ok=1
for _ in $(seq 1 10); do request GET /health; [ "$CODE" = 200 ] || ok=0; done
[ "$ok" = 1 ] && pass "handles 10 requests in a row" || fail "handles 10 requests in a row"

grep -q 'GET /files 200' "$TMP/server.log" && pass "logs 'GET /files 200' to STDOUT" || fail "logs 'GET /files 200' to STDOUT"

summary
