#!/usr/bin/env bash
# usage: healthcheck.sh URL [TIMEOUT_SECONDS]
# Exit codes (Nagios convention): 0 OK, 1 WARNING, 2 CRITICAL
set -u

url="${1:?usage: healthcheck.sh URL [TIMEOUT_SECONDS]}"
timeout="${2:-3}"

# TODO: request $url with curl, failing on HTTP errors (-f) and with --max-time "$timeout"
# TODO: CRITICAL (exit 2, message on stderr) if curl fails
# TODO: OK (exit 0) if the body contains "ok", else WARNING (exit 1)
echo "UNKNOWN: not implemented" >&2
exit 3
