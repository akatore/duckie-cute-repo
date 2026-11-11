#!/usr/bin/env bash
# usage: logstats.sh ACCESS_LOG
set -euo pipefail

log="${1:?usage: logstats.sh ACCESS_LOG}"

echo "Top 5 IPs:"
awk '{print $1}' "$log" \
    | sort | uniq -c \
    | sort -k1,1nr -k2,2 \
    | head -n 5 \
    | awk '{print $1, $2}'

awk '$9 ~ /^5[0-9][0-9]$/ {n++} END {print "5xx errors: " n + 0}' "$log"

awk '{split($4, t, ":"); print t[2]}' "$log" \
    | sort | uniq -c \
    | sort -k1,1nr -k2,2 \
    | head -n 1 \
    | awk '{printf "Busiest hour: %s (%d requests)\n", $2, $1}'
