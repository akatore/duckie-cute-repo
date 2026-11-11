#!/usr/bin/env bash
# usage: logstats.sh ACCESS_LOG
set -euo pipefail

log="${1:?usage: logstats.sh ACCESS_LOG}"

echo "Top 5 IPs:"
# TODO: field 1 is the IP. Count per IP, sort by count (desc) then IP, keep 5,
#       and print "<count> <ip>" without leading spaces.

# TODO: count lines whose status (field 9) is 5xx and print "5xx errors: N"

# TODO: field 4 looks like "[11/Nov/2026:09:01:12". Extract HH, find the hour
#       with the most requests and print "Busiest hour: HH (N requests)"
