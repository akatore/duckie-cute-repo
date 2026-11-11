#!/usr/bin/env bash
# usage: bash check.sh [DIR_WITH_logstats.pl]   (default: ./starter)
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/../lib/check_lib.sh"
DIR="$(resolve_dir "${1:-}" "$HERE/starter")"
SCRIPT="$DIR/logstats.pl"
LOG="$HERE/../day01-linux-git/starter/access.log"
EXPECTED="$HERE/../day01-linux-git/check/expected_output.txt"

echo "Checking $SCRIPT"
need perl

if [ ! -f "$SCRIPT" ]; then fail "logstats.pl exists"; summary; exit; fi
pass "logstats.pl exists"

check "compiles (perl -c)" perl -c "$SCRIPT"
check "uses strict" grep -q '^use strict;' "$SCRIPT"
check "uses warnings" grep -q '^use warnings;' "$SCRIPT"

ACTUAL="$(mktemp)"; ERRS="$(mktemp)"; NOISY="$(mktemp)"
perl "$SCRIPT" "$LOG" > "$ACTUAL" 2> "$ERRS"
if diff -q "$EXPECTED" "$ACTUAL" >/dev/null; then
    pass "output identical to Day 1 report"
else
    fail "output identical to Day 1 report (diff: - expected, + yours)"
    show_diff "$EXPECTED" "$ACTUAL"
fi
if [ -s "$ERRS" ]; then
    fail "no warnings on stderr"; sed 's/^/        /' "$ERRS" | head -n 5
else
    pass "no warnings on stderr"
fi

{ echo "this line is garbage"; cat "$LOG"; echo ""; } > "$NOISY"
if perl "$SCRIPT" "$NOISY" 2>/dev/null | diff -q "$EXPECTED" - >/dev/null; then
    pass "skips lines that don't match the log format"
else
    fail "skips lines that don't match the log format"
fi

if perl "$SCRIPT" >/dev/null 2>&1; then fail "exits non-zero without an argument"; else pass "exits non-zero without an argument"; fi
if perl "$SCRIPT" /no/such/file >/dev/null 2>&1; then fail "exits non-zero for a missing file"; else pass "exits non-zero for a missing file"; fi

rm -f "$ACTUAL" "$ERRS" "$NOISY"
summary
