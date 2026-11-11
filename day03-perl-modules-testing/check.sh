#!/usr/bin/env bash
# usage: bash check.sh [DIR_WITH_lib_AND_t]   (default: ./starter)
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/../lib/check_lib.sh"
DIR="$(resolve_dir "${1:-}" "$HERE/starter")"

echo "Checking $DIR"
need perl; need prove

check "lib/MediaName.pm compiles" perl -I"$DIR/lib" -c "$DIR/lib/MediaName.pm"

shopt -s nullglob
tests=("$DIR"/t/*.t)
if [ ${#tests[@]} -eq 0 ]; then
    fail "you have test files in t/"
else
    if prove -I"$DIR/lib" "${tests[@]}" >/dev/null 2>&1; then
        pass "your own tests pass"
    else
        fail "your own tests pass (run: cd $DIR && prove -lv t)"
    fi
    oks=0
    for t in "${tests[@]}"; do
        n=$(perl -I"$DIR/lib" "$t" 2>/dev/null | grep -cE '^[[:space:]]*ok ')
        oks=$((oks + n))
    done
    if [ "$oks" -ge 10 ]; then
        pass "you wrote at least 10 passing assertions ($oks)"
    else
        fail "you wrote at least 10 passing assertions (found $oks)"
    fi
fi

GRADER_OUT="$(mktemp)"
if prove -v -I"$DIR/lib" "$HERE/check/grader.t" > "$GRADER_OUT" 2>&1; then
    pass "hidden grader tests pass"
else
    fail "hidden grader tests pass. Failing cases:"
    grep -E '^not ok|#   (Failed|got|expected)' "$GRADER_OUT" | head -n 20 | sed 's/^/        /'
fi
rm -f "$GRADER_OUT"

summary
