#!/usr/bin/env bash
# usage: bash check.sh [CAPSTONE_DIR]   (default: ./starter)
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/../lib/check_lib.sh"
DIR="$(resolve_dir "${1:-}" "$HERE/starter")"
export PORT=18090

echo "Checking $DIR"
need perl; need prove; need make; need ffmpeg; need ffprobe; need sqlite3; need curl
need_perl_module DBD::SQLite

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Project layout"
for f in README.md Makefile run_all.sh bin/scan.pl bin/load_catalog.pl bin/server.pl \
         lib/MediaProbe.pm sql/schema.sql t/media_probe.t .github/workflows/ci.yml; do
    check "$f exists" test -s "$DIR/$f"
done
for f in bin/scan.pl bin/load_catalog.pl bin/server.pl lib/MediaProbe.pm; do
    check "$f compiles" perl -I"$DIR/lib" -c "$DIR/$f"
done

echo "Unit tests"
if make -C "$DIR" test > "$TMP/unit.log" 2>&1; then
    pass "make test passes"
else
    fail "make test passes"
    grep -E '^not ok|#   (Failed|got|expected)|Dubious|BAIL' "$TMP/unit.log" | head -n 15 | sed 's/^/        /'
fi

echo "End to end (run_all.sh, takes ~10 s)"
WORK="$TMP/work"
if bash "$DIR/run_all.sh" "$WORK" > "$TMP/e2e.log" 2>&1; then
    pass "run_all.sh exits 0"
else
    fail "run_all.sh exits 0"; tail -n 15 "$TMP/e2e.log" | sed 's/^/        /'
fi
check "run_all.sh prints ALL GOOD" grep -q 'ALL GOOD' "$TMP/e2e.log"
check "media files generated in WORK/media" test "$(find "$WORK/media" -type f 2>/dev/null | wc -l)" -ge 3
if [ -s "$WORK/probes.json" ] && perl -MJSON::PP -0777 -e 'exit(@{ decode_json(<STDIN>) } == 3 ? 0 : 1)' < "$WORK/probes.json" 2>/dev/null; then
    pass "probes.json is a JSON array of 3 files"
else
    fail "probes.json is a JSON array of 3 files"
fi
n=$(sqlite3 "$WORK/catalog.db" 'SELECT COUNT(*) FROM media_file;' 2>/dev/null)
[ "$n" = 3 ] && pass "catalog.db has 3 files" || fail "catalog.db has 3 files (got '${n}')"
sleep 0.5
if curl -s -o /dev/null --max-time 2 "http://127.0.0.1:$PORT/health"; then
    fail "server is stopped when run_all.sh exits (use trap ... EXIT)"
else
    pass "server is stopped when run_all.sh exits"
fi

echo "Server details"
if [ -f "$WORK/catalog.db" ]; then
    perl "$DIR/bin/server.pl" "$PORT" "$WORK/media" "$WORK/catalog.db" > "$TMP/server.log" 2>&1 &
    SPID=$!
    for _ in $(seq 1 40); do curl -s -o /dev/null "http://127.0.0.1:$PORT/health" && break; sleep 0.25; done
    curl -s "http://127.0.0.1:$PORT/catalog" > "$TMP/catalog.json"
    check "/catalog entries have path, container, duration_s (number), codecs (array)" perl -MJSON::PP -0777 -e '
        my $d = decode_json(<STDIN>); my $ok = @$d == 3;
        for (@$d) {
            $ok &&= defined $_->{path} && defined $_->{container}
                 && ref $_->{codecs} eq "ARRAY"
                 && JSON::PP->new->allow_nonref->encode($_->{duration_s}) =~ /^[0-9.]+$/;
        }
        exit($ok ? 0 : 1)' < "$TMP/catalog.json"
    check "/catalog is sorted by path" bash -c "perl -MJSON::PP -0777 -ne 'my @p = map { \$_->{path} } @{ decode_json(\$_) }; exit(join(\"|\", @p) eq join(\"|\", sort @p) ? 0 : 1)' '$TMP/catalog.json'"

    sqlite3 "$WORK/catalog.db" 'DROP TABLE stream;'
    code=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$PORT/catalog")
    [ "$code" = 500 ] && pass "database error -> 500" || fail "database error -> 500 (got $code)"
    code=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$PORT/health")
    [ "$code" = 200 ] && pass "server survives the error" || fail "server survives the error"
    kill "$SPID" 2>/dev/null
fi

echo "README and CI"
lines=$(grep -cv '^\s*$' "$DIR/README.md" 2>/dev/null)
[ "${lines:-0}" -ge 25 ] && pass "README has content ($lines non-empty lines)" || fail "README has content (only ${lines:-0} non-empty lines)"
check "README has an Architecture section" grep -qiE '^#+ *architecture' "$DIR/README.md"
if grep -q '<!-- TODO' "$DIR/README.md"; then fail "README has no TODO placeholders left"; else pass "README has no TODO placeholders left"; fi
CI="$DIR/.github/workflows/ci.yml"
check "CI runs make test" code_grep 'make test' "$CI"
check "CI runs run_all.sh" code_grep 'run_all\.sh' "$CI"
check "CI installs ffmpeg" code_grep 'ffmpeg' "$CI"

summary
