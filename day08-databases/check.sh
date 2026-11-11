#!/usr/bin/env bash
# usage: bash check.sh [DIR]   (default: ./starter)
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/../lib/check_lib.sh"
DIR="$(resolve_dir "${1:-}" "$HERE/starter")"
PROBES="$HERE/starter/data/probes.json"

echo "Checking $DIR"
need sqlite3; need perl
need_perl_module DBD::SQLite

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
DB="$TMP/catalog.db"
sql() { sqlite3 "$DB" "$1" 2>/dev/null; }

echo "Schema"
if sqlite3 "$DB" < "$DIR/schema.sql" 2> "$TMP/schema.err"; then
    pass "schema.sql runs"
else
    fail "schema.sql runs"; head -n 5 "$TMP/schema.err" | sed 's/^/        /'
fi
has_column() { sqlite3 "$DB" "PRAGMA table_info($1);" | cut -d'|' -f2 | grep -qx "$2"; }
has_codec_index() {
    local ix
    for ix in $(sqlite3 "$DB" "SELECT name FROM pragma_index_list('stream');"); do
        sqlite3 "$DB" "SELECT name FROM pragma_index_info('$ix');" | grep -qx codec && return 0
    done
    return 1
}
for col in id path container duration_s bit_rate; do
    check "media_file.$col exists" has_column media_file "$col"
done
for col in id file_id stream_index kind codec width height sample_rate channels; do
    check "stream.$col exists" has_column stream "$col"
done
check "index on stream(codec)" has_codec_index

echo "Loader"
if perl "$DIR/load_catalog.pl" "$DB" "$PROBES" > "$TMP/load.out" 2> "$TMP/load.err"; then
    pass "load_catalog.pl runs"
else
    fail "load_catalog.pl runs"; head -n 5 "$TMP/load.err" | sed 's/^/        /'
fi
[ "$(sql 'SELECT COUNT(*) FROM media_file;')" = 8 ] && pass "8 files loaded" || fail "8 files loaded (got $(sql 'SELECT COUNT(*) FROM media_file;'))"
[ "$(sql 'SELECT COUNT(*) FROM stream;')" = 15 ] && pass "15 streams loaded" || fail "15 streams loaded (got $(sql 'SELECT COUNT(*) FROM stream;'))"
[ "$(sql "SELECT COUNT(*) FROM media_file WHERE bit_rate IS NULL;")" = 1 ] && pass "JSON null becomes SQL NULL" || fail "JSON null becomes SQL NULL"

perl "$DIR/load_catalog.pl" "$DB" "$PROBES" >/dev/null 2>&1
[ "$(sql 'SELECT COUNT(*) FROM media_file;')|$(sql 'SELECT COUNT(*) FROM stream;')" = "8|15" ] \
    && pass "loading twice creates no duplicates" || fail "loading twice creates no duplicates"

check "loader uses placeholders (?)" grep -q '?' "$DIR/load_catalog.pl"
check "loader uses a transaction (begin_work / commit)" grep -qE 'begin_work|AutoCommit *=> *0' "$DIR/load_catalog.pl"
check "loader enables foreign keys" grep -qi 'foreign_keys' "$DIR/load_catalog.pl"

printf '[{"path":"bad.mp4","container":"mp4","duration":1,"bit_rate":1,"streams":[{"index":0,"type":"subtitle","codec":"srt"}]}]' > "$TMP/bad.json"
before=$(sql 'SELECT COUNT(*) FROM media_file;')
if perl "$DIR/load_catalog.pl" "$DB" "$TMP/bad.json" >/dev/null 2>&1; then
    fail "invalid stream kind makes the loader fail"
else
    pass "invalid stream kind makes the loader fail (CHECK constraint)"
fi
[ "$(sql 'SELECT COUNT(*) FROM media_file;')" = "$before" ] && pass "failed load is rolled back" || fail "failed load is rolled back (bad.mp4 was left behind)"

echo "Constraints"
if sqlite3 "$DB" "PRAGMA foreign_keys=ON; INSERT INTO stream (file_id, stream_index, kind, codec) VALUES (999, 0, 'video', 'h264');" 2>/dev/null; then
    fail "stream with unknown file_id is rejected"
else
    pass "stream with unknown file_id is rejected (foreign key)"
fi
if sqlite3 "$DB" "INSERT INTO media_file (path, container, duration_s) VALUES ('audio/jingle.wav', 'wav', 1);" 2>/dev/null; then
    fail "duplicate path is rejected"
else
    pass "duplicate path is rejected (UNIQUE)"
fi
sqlite3 "$DB" "PRAGMA foreign_keys=ON; DELETE FROM media_file WHERE path = 'movies/sintel_720p.mkv';"
[ "$(sql 'SELECT COUNT(*) FROM stream;')" = 12 ] && pass "deleting a file deletes its streams (ON DELETE CASCADE)" || fail "deleting a file deletes its streams (ON DELETE CASCADE)"

echo "Queries"
rm -f "$DB"
sqlite3 "$DB" < "$DIR/schema.sql" 2>/dev/null
perl "$DIR/load_catalog.pl" "$DB" "$PROBES" >/dev/null 2>&1
for i in 1 2 3 4 5; do
    if [ -f "$DIR/q$i.sql" ] && sqlite3 "$DB" < "$DIR/q$i.sql" > "$TMP/q$i.out" 2>&1 \
        && diff -q "$HERE/check/expected_q$i.txt" "$TMP/q$i.out" >/dev/null; then
        pass "q$i.sql output"
    else
        fail "q$i.sql output (diff: - expected, + yours)"
        show_diff "$HERE/check/expected_q$i.txt" "$TMP/q$i.out"
    fi
done

echo "PHP page"
if command -v php >/dev/null 2>&1; then
    if CATALOG_DB="$DB" php "$DIR/www/index.php" > "$TMP/page.html" 2> "$TMP/php.err"; then
        pass "index.php renders"
    else
        fail "index.php renders"; head -n 5 "$TMP/php.err" "$TMP/page.html" | sed 's/^/        /'
    fi
    check "page has a <table>" grep -qi '<table' "$TMP/page.html"
    missing=0
    while read -r p; do grep -qF "$p" "$TMP/page.html" || missing=$((missing + 1)); done < <(sql 'SELECT path FROM media_file;')
    [ "$missing" = 0 ] && pass "page lists all 8 paths" || fail "page lists all 8 paths ($missing missing)"
    check "page shows codecs (GROUP_CONCAT)" grep -q 'pcm_s16le' "$TMP/page.html"
    check "page shows duration with 1 decimal" grep -q '596\.5' "$TMP/page.html"

    sqlite3 "$DB" "INSERT INTO media_file (path, container, duration_s) VALUES ('<script>alert(1)</script>.mp4', 'mp4', 1);"
    CATALOG_DB="$DB" php "$DIR/www/index.php" > "$TMP/page2.html" 2>/dev/null
    if grep -qF '<script>alert(1)' "$TMP/page2.html"; then fail "values are HTML-escaped (XSS)"; else pass "values are HTML-escaped (XSS)"; fi
else
    echo "  SKIP  php not installed"
fi

summary
