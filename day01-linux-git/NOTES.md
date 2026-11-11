# Day 1: Linux and git

## Why it matters for this job
The team runs Linux clusters with 24x7 uptime. You will live in a terminal over `ssh`,
read logs, chain small tools with pipes, and keep every change in git.

## Core ideas (if you know C...)
- **Everything is a file.** `stdin`=fd 0, `stdout`=fd 1, `stderr`=fd 2, exactly like `read(0, ...)` in C.
- **Pipes** `a | b` connect a's fd 1 to b's fd 0 (the shell calls `pipe()` + `fork()` + `dup2()` + `exec()` for you).
- **Exit status**: `0` = success, anything else = failure (like `return 0;` from `main`). `$?` holds the last one.
- **Processes**: every command is a process with a PID. `ps aux`, `top`, `kill PID`, `kill -9 PID` (last resort).
- **Permissions**: `rwx` for user/group/other. `chmod 755 file` = `rwxr-xr-x`. `chmod +x script.sh`.

## Cheat sheet

```bash
# navigation and files
pwd; ls -la; cd -; mkdir -p a/b/c; cp -r src dst; mv a b; rm -r dir
find . -name '*.log' -mtime -1        # files changed in the last day
du -sh *; df -h                        # disk usage per item, free space per filesystem
less file    # q to quit, / to search, G to end
tail -f /var/log/syslog                # follow a growing log (Ctrl+C to stop)

# text processing: the "Unix toolkit"
grep -n 'ERROR' app.log                # -i ignore case, -v invert, -c count, -E extended regex, -r recursive
cut -d' ' -f1 access.log               # first space-separated field
awk '{print $1, $9}' access.log        # fields by whitespace; $NF = last field
awk -F: '{print $1}' /etc/passwd       # custom separator
awk '$9 >= 500 {n++} END {print n}' access.log
sed 's/foo/bar/g' file                 # substitute (print result); sed -i edits in place
sort | uniq -c | sort -rn | head       # the classic "top N" pipeline
wc -l file; tr 'a-z' 'A-Z'; xargs; tee out.txt

# redirection
cmd > out.txt 2> err.txt; cmd >> append.txt; cmd > all.txt 2>&1; cmd < input.txt

# processes and services
ps aux | grep perl; pgrep -a perl; kill PID
cmd &        # run in background; jobs; fg; Ctrl+Z then bg
systemctl status ssh; journalctl -u ssh --since "1 hour ago"

# networking basics
ip addr; ss -tlnp            # listening TCP ports and the owning process
ssh user@host; scp file user@host:/tmp/

# cron: "minute hour day-of-month month day-of-week command"
crontab -e
# */5 * * * * /home/me/bin/logstats.sh /var/log/nginx/access.log >> /tmp/stats.txt 2>&1
```

## Bash scripting essentials

```bash
#!/usr/bin/env bash
set -euo pipefail        # stop on error, on unset variables, and on failures inside pipes

log="${1:?usage: $0 LOGFILE}"   # first argument, or die with a usage message
count=$(wc -l < "$log")          # command substitution
if [ "$count" -gt 100 ]; then echo "big"; fi
for f in *.log; do echo "$f"; done
while read -r line; do echo "$line"; done < "$log"
my_func() { local x="$1"; echo "got $x"; }
```

Always quote variables: `"$file"`, not `$file`. Without quotes a filename with a space becomes two arguments.

## git essentials

```bash
git init; git clone URL
git status; git diff; git diff --staged
git add file; git commit -m "Explain why, not just what"
git log --oneline --graph --all
git switch -c feature/x      # create and switch to a branch (older: git checkout -b)
git switch main; git merge feature/x
git restore file             # discard unstaged changes to a file
git stash; git stash pop
git remote -v; git push -u origin main; git pull --rebase
```

Mental model: a commit is a snapshot plus a pointer to its parent(s). A branch is just a movable
name pointing at a commit. `HEAD` is "where you are now".

## Web server log format (used in the problem)

```
10.0.0.1 - - [11/Nov/2026:09:01:12 +0000] "GET /index.html HTTP/1.1" 200 512 "-" "curl/8.0"
   $1    $2 $3          $4          $5      $6      $7        $8     $9  $10
```
With default awk whitespace splitting: `$1` = client IP, `$4` = `[date:HH:MM:SS`, `$9` = HTTP status.
