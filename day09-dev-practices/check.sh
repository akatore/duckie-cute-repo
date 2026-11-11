#!/usr/bin/env bash
# usage: [LAB=~/conflict-lab] bash check.sh [DIR]   (default: ./starter)
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/../lib/check_lib.sh"
DIR="$(resolve_dir "${1:-}" "$HERE/starter")"
LAB="${LAB:-$HOME/conflict-lab}"

echo "Checking $DIR"
need git; need perl; need curl

TMP="$(mktemp -d)"
SERVER_PID=""
trap '[ -n "$SERVER_PID" ] && kill "$SERVER_PID" 2>/dev/null; rm -rf "$TMP"' EXIT

echo "1. Merge conflict lab ($LAB)"
if [ ! -d "$LAB/.git" ]; then
    fail "lab repository exists (run: bash starter/conflict_lab.sh $LAB)"
else
    [ "$(git -C "$LAB" branch --show-current)" = main ] && pass "on branch main" || fail "on branch main"
    [ "$(git -C "$LAB" log --merges --oneline main | wc -l)" -ge 1 ] && pass "main has a merge commit" || fail "main has a merge commit (finish with git commit)"
    git -C "$LAB" merge-base --is-ancestor feature/welcome main 2>/dev/null && pass "feature/welcome is merged into main" || fail "feature/welcome is merged into main"
    [ -z "$(git -C "$LAB" status --porcelain)" ] && pass "working tree is clean" || fail "working tree is clean (git status shows changes)"
    if grep -qE '^(<<<<<<<|=======|>>>>>>>)' "$LAB/greet.pl"; then fail "no conflict markers left"; else pass "no conflict markers left"; fi
    out=$(perl "$LAB/greet.pl" Asha 2>&1)
    [ "$out" = "Hello, Asha! Welcome to the media team." ] && pass "greet.pl prints the combined greeting" || fail "greet.pl prints the combined greeting (got: $out)"
    if perl "$LAB/greet.pl" >/dev/null 2>&1; then fail "usage check kept (no argument -> error)"; else pass "usage check kept (no argument -> error)"; fi
fi

echo "2. CI workflow"
CI="$DIR/.github/workflows/ci.yml"
if [ -f "$CI" ]; then
    check "has an 'on:' trigger section" grep -qE '^on:' "$CI"
    check "triggers on push" grep -qE '^\s+push:|^on:.*push' "$CI"
    check "triggers on pull_request" grep -q 'pull_request' "$CI"
    check "has a jobs: section" grep -qE '^jobs:' "$CI"
    check "runs on ubuntu" grep -qE 'runs-on: *ubuntu' "$CI"
    check "checks out the code" grep -q 'actions/checkout' "$CI"
    check "installs packages with apt-get" grep -q 'apt-get install' "$CI"
    check "runs make ... test" grep -qE 'make .*test' "$CI"
    check "runs prove" grep -q 'prove' "$CI"
    if ! code_grep '^jobs:' "$CI"; then
        fail "no tab characters (write the workflow first)"
    elif grep -q $'\t' "$CI"; then
        fail "no tab characters (YAML forbids tabs for indentation)"
    else
        pass "no tab characters"
    fi
else
    fail "$CI exists"
fi

echo "3. systemd unit and health check"
UNIT="$DIR/mediacatalog.service"
for section in Unit Service Install; do
    check "unit has [$section]" grep -q "^\[$section\]" "$UNIT"
done
check "ExecStart runs server.pl" grep -qE '^ExecStart=.*server\.pl' "$UNIT"
check "Restart= is set" grep -qE '^Restart=(on-failure|always)' "$UNIT"
check "runs as a non-root User=" grep -qE '^User=[a-z_][a-z0-9_-]*$' "$UNIT"
if grep -qE '^User=root' "$UNIT"; then fail "does not run as root"; fi
check "WantedBy=multi-user.target" grep -q '^WantedBy=multi-user.target' "$UNIT"

HC="$DIR/healthcheck.sh"
PORT=18089
bash "$HC" "http://127.0.0.1:1/health" 1 > /dev/null 2> "$TMP/hc_err"
rc=$?
[ "$rc" = 2 ] && pass "unreachable service -> exit 2 (CRITICAL)" || fail "unreachable service -> exit 2 (got $rc)"
grep -q CRITICAL "$TMP/hc_err" && pass "prints CRITICAL on stderr" || fail "prints CRITICAL on stderr"

mkdir -p "$TMP/media"
perl "$HERE/../solutions/day04/server.pl" "$PORT" "$TMP/media" > /dev/null 2>&1 &
SERVER_PID=$!
for _ in $(seq 1 40); do curl -s -o /dev/null "http://127.0.0.1:$PORT/health" && break; sleep 0.25; done

out=$(bash "$HC" "http://127.0.0.1:$PORT/health" 2>/dev/null); rc=$?
[ "$rc" = 0 ] && pass "healthy service -> exit 0" || fail "healthy service -> exit 0 (got $rc)"
[[ "$out" == OK* ]] && pass "prints OK" || fail "prints OK (got: $out)"
bash "$HC" "http://127.0.0.1:$PORT/nope" >/dev/null 2>&1; rc=$?
[ "$rc" = 2 ] && pass "HTTP 404 -> exit 2" || fail "HTTP 404 -> exit 2 (got $rc)"
bash "$HC" "http://127.0.0.1:$PORT/files" >/dev/null 2>&1; rc=$?
[ "$rc" = 1 ] && pass "unexpected body -> exit 1 (WARNING)" || fail "unexpected body -> exit 1 (got $rc)"

echo "4. Code review"
REVIEW="$DIR/REVIEW.md"
n=$(grep -cE '^\s*([-*]|[0-9]+\.)\s+\S' "$REVIEW" 2>/dev/null)
[ "${n:-0}" -ge 6 ] && pass "REVIEW.md has at least 6 findings ($n)" || fail "REVIEW.md has at least 6 findings (found ${n:-0})"
lines=$(grep -ciE 'line[s]? *[0-9]+|L[0-9]+' "$REVIEW" 2>/dev/null)
[ "${lines:-0}" -ge 6 ] && pass "findings reference line numbers" || fail "findings reference line numbers"

summary
