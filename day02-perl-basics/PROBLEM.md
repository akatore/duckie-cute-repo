# Day 2 problem: `logstats.pl`

Rewrite yesterday's `logstats.sh` in Perl: `starter/logstats.pl`.

```bash
perl starter/logstats.pl ../day01-linux-git/starter/access.log
```

## Requirements
- Output must be **identical** to Day 1's report (same format, same tie-breaking: count desc, then IP asc).
- Read the file **once**, line by line, using **one regex** per line to capture IP, hour and status.
- Use hashes for counting (`$by_ip{$ip}++`).
- `use strict; use warnings;` and no warnings at runtime.
- Without an argument, or if the file can't be opened: message on stderr, non-zero exit.
- Lines that don't match the log format are skipped (the checker adds a garbage line).

## Acceptance criteria
`bash check.sh` passes.

## Stretch goals
- Add `--top N` with `Getopt::Long` (`perldoc Getopt::Long`).
- Read from STDIN when no file is given, so `zcat access.log.gz | perl logstats.pl` works.
- Print the busiest hour as a little ASCII bar chart of all hours (`'#' x $count`).
