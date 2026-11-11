#!/usr/bin/env bash
# usage: bash check.sh [DIR_WITH_logstats.sh]   (default: ./starter)
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/../lib/check_lib.sh"
DIR="$(resolve_dir "${1:-}" "$HERE/starter")"
SCRIPT="$DIR/logstats.sh"

echo "Checking $SCRIPT"
need awk; need sort; need uniq

if [ ! -f "$SCRIPT" ]; then fail "logstats.sh exists"; summary; exit; fi
pass "logstats.sh exists"

check "starts with a bash shebang" grep -qE '^#!.*(bash)' <(head -n 1 "$SCRIPT")
check "uses set -euo pipefail" grep -q 'set -euo pipefail' "$SCRIPT"
if grep -qE '\b(perl|python3?)\b' "$SCRIPT"; then
    fail "does not call perl/python (use awk/sort/uniq today)"
else
    pass "does not call perl/python"
fi

ACTUAL="$(mktemp)"
if bash "$SCRIPT" "$HERE/starter/access.log" > "$ACTUAL" 2>/dev/null; then
    pass "runs successfully on access.log"
else
    fail "runs successfully on access.log (non-zero exit status)"
fi

if diff -q "$HERE/check/expected_output.txt" "$ACTUAL" >/dev/null; then
    pass "output matches expected report exactly"
else
    fail "output matches expected report exactly (diff: - expected, + yours)"
    show_diff "$HERE/check/expected_output.txt" "$ACTUAL"
fi
rm -f "$ACTUAL"

if bash "$SCRIPT" >/dev/null 2>&1; then
    fail "exits non-zero when no argument is given"
else
    pass "exits non-zero when no argument is given"
fi

summary
