# Day 1 problem: `logstats.sh`

Ops asks: "Which clients hit us the most, how many server errors did we have, and when is peak time?"

Write `starter/logstats.sh`, a **bash** script that takes the log file path as its only argument
and prints a report. Use only standard tools (`awk`, `sort`, `uniq`, `head`, `grep`, ...), no Perl/Python.

```bash
bash starter/logstats.sh starter/access.log
```

## Required output (exact format)

```
Top 5 IPs:
<count> <ip>
<count> <ip>
<count> <ip>
<count> <ip>
<count> <ip>
5xx errors: <n>
Busiest hour: <HH> (<n> requests)
```

- IPs sorted by request count, highest first (break ties by IP, alphabetically).
- `5xx errors` counts requests whose status is 500-599.
- `Busiest hour` is the two-digit hour with the most requests.
- No leading spaces on the count lines (`uniq -c` adds them; get rid of them).
- Without an argument the script prints a usage message to stderr and exits non-zero.

## Acceptance criteria
- `bash check.sh` passes.
- `set -euo pipefail` at the top, variables quoted.

## git part (do it, it's not auto-checked)
1. `git switch -c feature/logstats` before you start.
2. Commit at least twice (e.g. "Add top IPs", "Add 5xx count and busiest hour").
3. `git switch main && git merge feature/logstats`.
4. Show the history: `git log --oneline --graph --all`.

## Stretch goals
- Add a cron line that runs the script every 5 minutes and appends to `/tmp/stats.txt`; verify with `tail -f`.
- Add a 4th section: number of requests per HTTP method (`GET`, `POST`, `DELETE`). Field `$6` looks like `"GET`, so remove the quote with `tr -d '"'`.
- Make it work on a gzip'd log too (`zcat`).
