# Shared helpers for the day checkers. Source it, don't run it.

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASS_COUNT=0
FAIL_COUNT=0

pass() { printf '  PASS  %s\n' "$1"; PASS_COUNT=$((PASS_COUNT + 1)); }
fail() { printf '  FAIL  %s\n' "$1"; FAIL_COUNT=$((FAIL_COUNT + 1)); }

# check "description" command args...   -> PASS if the command exits 0
check() {
    local desc="$1"; shift
    if "$@" >/dev/null 2>&1; then pass "$desc"; else fail "$desc"; fi
}

# code_grep ERE FILE -> like grep -qE, but ignores comment lines (so TODO hints don't count)
code_grep() {
    [ -f "$2" ] || return 1
    grep -vE '^[[:space:]]*(#|//|--|<!--|\*)' "$2" | grep -qE "$1"
}

need() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Missing tool '$1'. Run the setup from prep/README.md (Day 0)."
        exit 2
    fi
}

need_perl_module() {
    if ! perl -M"$1" -e1 >/dev/null 2>&1; then
        echo "Missing Perl module '$1'. Run the setup from prep/README.md (Day 0)."
        exit 2
    fi
}

# json_eq ACTUAL_FILE EXPECTED_FILE -> 0 if both contain the same JSON value
json_eq() { perl "$LIB_DIR/json_eq.pl" "$1" "$2" >/dev/null 2>&1; }

# json_eq_str ACTUAL_FILE 'expected json text'
json_eq_str() {
    local tmp rc
    tmp="$(mktemp)"
    printf '%s' "$2" > "$tmp"
    json_eq "$1" "$tmp"
    rc=$?
    rm -f "$tmp"
    return $rc
}

# show_diff EXPECTED_FILE ACTUAL_FILE  -> prints a short diff for debugging
show_diff() { diff -u "$1" "$2" | head -n 20 | sed 's/^/        /'; }

summary() {
    echo
    echo "Result: $PASS_COUNT passed, $FAIL_COUNT failed"
    [ "$FAIL_COUNT" -eq 0 ]
}

# resolve_dir ARG DEFAULT -> absolute path of the folder being checked
resolve_dir() {
    local d="${1:-$2}"
    if [ ! -d "$d" ]; then
        echo "No such directory: $d"
        exit 2
    fi
    (cd "$d" && pwd)
}
