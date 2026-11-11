#!/usr/bin/env bash
# usage: healthcheck.sh URL [TIMEOUT_SECONDS]
# Exit codes (Nagios convention): 0 OK, 1 WARNING, 2 CRITICAL
set -u

url="${1:?usage: healthcheck.sh URL [TIMEOUT_SECONDS]}"
timeout="${2:-3}"

if ! body=$(curl -fsS --max-time "$timeout" "$url" 2>&1); then
    echo "CRITICAL: $url failed: $body" >&2
    exit 2
fi

if [[ "$body" == *'"ok"'* ]]; then
    echo "OK: $url"
    exit 0
fi

echo "WARNING: $url answered with an unexpected body: ${body:0:200}" >&2
exit 1
