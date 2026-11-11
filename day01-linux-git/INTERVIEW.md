# Day 1 interview questions: Linux and git

Answer out loud first, then read the short answer.

1. **What does `2>&1` do?**
   Redirects stderr (fd 2) to wherever stdout (fd 1) currently points. Order matters:
   `cmd > out.txt 2>&1` sends both to the file; `cmd 2>&1 > out.txt` sends only stdout to the file.

2. **A disk is full on a production server. How do you find out why?**
   `df -h` to find the filesystem, then `du -sh /* | sort -h` and drill down. Check for huge logs
   (`/var/log`), and for deleted-but-still-open files with `lsof +L1` (space is freed only when the process closes them).

3. **Difference between a process and a thread?**
   A process has its own address space; threads share the address space of their process.
   `fork()` creates a process; `pthread_create()` creates a thread.

4. **How do you find which process listens on port 8080?**
   `ss -tlnp | grep 8080` (or `lsof -i :8080`).

5. **What does `kill -9` do and why is it a last resort?**
   Sends SIGKILL, which can't be caught, so the process can't clean up (flush files, remove locks).
   Try SIGTERM (`kill PID`) first.

6. **What is `set -euo pipefail` for?**
   `-e` exits on the first failing command, `-u` treats unset variables as errors, and `pipefail`
   makes a pipeline fail if any command in it fails (not just the last one).

7. **`git merge` vs `git rebase`?**
   Merge keeps history as it happened and adds a merge commit. Rebase replays your commits on top
   of another branch for a linear history. Don't rebase commits that others already pulled.

8. **You committed to the wrong branch. How do you fix it?**
   `git switch correct-branch && git cherry-pick <sha>`, then on the wrong branch `git reset --hard HEAD~1`
   (only if it wasn't pushed yet; otherwise `git revert`).

9. **What do file permissions `640` mean?**
   Owner read+write (6), group read (4), others nothing (0).

10. **How do you run a script every night at 2am?**
    A cron entry: `0 2 * * * /path/script.sh >> /var/log/script.log 2>&1` (or a systemd timer).
