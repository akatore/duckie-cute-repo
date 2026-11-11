#!/usr/bin/env bash
# usage: bash check.sh [DIR_WITH_Makefile_AND_wav.c]   (default: ./starter)
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/../lib/check_lib.sh"
DIR="$(resolve_dir "${1:-}" "$HERE/starter")"

echo "Checking $DIR"
need make; need gcc; need perl

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Makefile"
for target in all test clean; do
    check "Makefile has a '$target' target" grep -qE "^$target:" "$DIR/Makefile"
done
check "Makefile declares .PHONY" grep -q '^\.PHONY' "$DIR/Makefile"
check "Makefile links with -lm" grep -q -- '-lm' "$DIR/Makefile"

make -C "$DIR" clean >/dev/null 2>&1
if make -C "$DIR" > "$TMP/build.log" 2>&1; then
    pass "'make' builds wavinfo with -Wall -Wextra -Werror"
else
    fail "'make' builds wavinfo with -Wall -Wextra -Werror"
    tail -n 15 "$TMP/build.log" | sed 's/^/        /'
fi
check "wavinfo binary exists" test -x "$DIR/wavinfo"

if make -C "$DIR" > "$TMP/rebuild.log" 2>&1 && ! grep -q 'gcc' "$TMP/rebuild.log"; then
    pass "second 'make' does nothing (nothing changed)"
else
    fail "second 'make' does nothing (nothing changed)"
fi
touch "$DIR/wav.h"
if make -C "$DIR" > "$TMP/hdr.log" 2>&1 && grep -q 'wav\.c' "$TMP/hdr.log"; then
    pass "touching wav.h rebuilds wav.o"
else
    fail "touching wav.h rebuilds wav.o (add wav.h as a prerequisite)"
fi

if make -C "$DIR" test > "$TMP/test.log" 2>&1; then
    pass "'make test' passes"
else
    fail "'make test' passes"
    grep -E 'CHECK failed|FAILED|error' "$TMP/test.log" | head -n 15 | sed 's/^/        /'
fi

echo "wavinfo output"
perl "$HERE/check/make_wavs.pl" "$TMP"
for t in test1 test2; do
    if "$DIR/wavinfo" "$TMP/$t.wav" > "$TMP/$t.out" 2>/dev/null && diff -q "$HERE/check/$t.expected" "$TMP/$t.out" >/dev/null; then
        pass "$t.wav output matches"
    else
        fail "$t.wav output matches (diff: - expected, + yours)"
        show_diff "$HERE/check/$t.expected" "$TMP/$t.out"
    fi
done
if "$DIR/wavinfo" "$TMP/not_a_wav.wav" >/dev/null 2>&1; then fail "non-WAV file exits non-zero"; else pass "non-WAV file exits non-zero"; fi
if "$DIR/wavinfo" "$TMP/missing.wav" >/dev/null 2>&1; then fail "missing file exits non-zero"; else pass "missing file exits non-zero"; fi

if command -v valgrind >/dev/null 2>&1; then
    if valgrind --error-exitcode=9 --leak-check=full --errors-for-leak-kinds=definite -q \
        "$DIR/wavinfo" "$TMP/test1.wav" > /dev/null 2> "$TMP/vg.log"; then
        pass "valgrind: no memory errors or leaks"
    else
        fail "valgrind: no memory errors or leaks"
        head -n 15 "$TMP/vg.log" | sed 's/^/        /'
    fi
else
    echo "  SKIP  valgrind not installed"
fi

echo "Bonus: LRU cache"
if [ -f "$DIR/lru/lru.hpp" ] && command -v g++ >/dev/null 2>&1; then
    if g++ -std=c++17 -Wall -Wextra -I"$DIR/lru" "$HERE/starter/lru/lru_test.cpp" -o "$TMP/lru_test" 2> "$TMP/lru_build.log" \
        && "$TMP/lru_test" > "$TMP/lru.log" 2>&1; then
        pass "LRU cache tests pass"
    else
        fail "LRU cache tests pass (bonus)"
        cat "$TMP/lru_build.log" "$TMP/lru.log" 2>/dev/null | head -n 10 | sed 's/^/        /'
    fi
else
    echo "  SKIP  no lru/lru.hpp"
fi

summary
