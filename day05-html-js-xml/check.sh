#!/usr/bin/env bash
# usage: bash check.sh [DIR_WITH_mpd2json.pl_AND_index.html]   (default: ./starter)
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/../lib/check_lib.sh"
DIR="$(resolve_dir "${1:-}" "$HERE/starter")"

echo "Checking $DIR"
need perl
need_perl_module XML::LibXML

SCRIPT="$DIR/mpd2json.pl"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Part 1: mpd2json.pl"
check "mpd2json.pl compiles" perl -c "$SCRIPT"
if perl "$SCRIPT" "$HERE/starter/manifest.mpd" > "$TMP/out.json" 2> "$TMP/err"; then
    pass "runs on manifest.mpd"
else
    fail "runs on manifest.mpd"; head -n 5 "$TMP/err" | sed 's/^/        /'
fi
if json_eq "$TMP/out.json" "$HERE/check/expected.json"; then
    pass "output matches expected representations (numbers as numbers, inherited codecs, types)"
else
    fail "output matches expected representations"
    perl "$LIB_DIR/json_eq.pl" "$TMP/out.json" "$HERE/check/expected.json" | cut -c1-300 | sed 's/^/        /'
fi

printf '<MPD><Period>' > "$TMP/broken.mpd"
if perl "$SCRIPT" "$TMP/broken.mpd" >/dev/null 2>&1; then fail "fails on malformed XML"; else pass "fails on malformed XML"; fi
if perl "$SCRIPT" "$TMP/missing.mpd" >/dev/null 2>&1; then fail "fails on a missing file"; else pass "fails on a missing file"; fi

echo "Part 2: index.html (building blocks only; test the behaviour in a browser)"
HTML="$DIR/index.html"
check "index.html exists" test -f "$HTML"
check "fetches representations.json" grep -q 'fetch(.*representations\.json' "$HTML"
check "has a table with a tbody" grep -q '<tbody' "$HTML"
check "has header cells with data-key" grep -q '<th[^>]*data-key=' "$HTML"
check "listens to events (addEventListener)" grep -q 'addEventListener' "$HTML"
check "uses textContent for values" grep -q 'textContent' "$HTML"
check "handles fetch errors (catch or res.ok)" grep -qE '\.catch\(|catch *\(|\.ok' "$HTML"
if grep -q 'innerHTML *[+]\?= *[^"'"'"'`]' "$HTML"; then
    fail "does not put data into innerHTML"
else
    pass "does not put data into innerHTML"
fi

summary
