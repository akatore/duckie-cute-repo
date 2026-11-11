# Day 9: Professional development practices

The job lists: 24x7 uptime, Linux clusters, git, issue tracking, code reviews, automated unit
testing, CI/CD. Interviewers for interns mostly check that you understand **why** these exist and
that you'll fit into the workflow.

## The everyday workflow

```
issue/ticket -> branch -> small commits -> push -> pull/merge request -> CI runs tests
   -> code review -> fixes -> approve -> merge to main -> CD deploys -> monitor
```

### Issue tracking (Jira, GitLab/GitHub issues, Redmine...)
A good bug report: what you did (steps), what you expected, what happened, environment, logs. Reference the
issue in branches and commits (`fix/1234-wav-odd-chunk`, `Fix #1234: skip pad byte after odd chunks`).

## git beyond the basics

```bash
git switch -c fix/1234-odd-chunk
git add -p                          # stage hunks interactively: keep commits focused
git commit                          # subject <= 50 chars, blank line, body explains WHY
git fetch origin && git rebase origin/main     # update your branch with a linear history
git push -u origin fix/1234-odd-chunk          # then open a merge/pull request
git log --oneline --graph --decorate --all
git blame file.c                    # who changed this line, in which commit
git bisect start; git bisect bad; git bisect good v1.2   # binary search for the commit that broke something
git revert <sha>                    # undo a pushed commit safely (new commit)
git commit --amend                  # fix the last commit (only if not pushed)
```

### Merge conflicts
```
<<<<<<< HEAD
print "Hello, $name!\n";            <- your branch (what you have checked out)
=======
print "Hi, $name! Welcome.\n";      <- the branch being merged in
>>>>>>> feature/welcome
```
1. `git status` shows the conflicted files. 2. Edit to the correct combined result and delete the markers.
3. Run the tests! 4. `git add file && git commit` (for a rebase: `git rebase --continue`). Abort with `git merge --abort`.

## Code review

As the **author**: small PRs (under ~400 lines), a description saying what and why and how it was tested,
self-review your diff first, respond to every comment, don't take it personally.

As the **reviewer** (checklist):
- Correctness: edge cases, error handling, off-by-one, NULL/undef, resource leaks.
- Security: input validation, injection (shell, SQL, HTML), path traversal, secrets in code or logs.
- Readability: names, function size, duplication, comments that explain why.
- Tests: is the change covered? would the test fail without the fix?
- Operations: logging, configuration, performance on big inputs, backwards compatibility.
Be specific and kind: "This interpolates `$name` into the shell command; a name with `;` runs arbitrary commands. Could we use the list form of `system`?"
Label nitpicks as such ("nit:").

## Automated testing levels
Unit (one function, milliseconds) -> integration (components together: DB + loader) -> end-to-end (whole system
through its real interface). A healthy suite has many unit tests and a few end-to-end ones (the "test pyramid").
Run them on every push in CI; a red build blocks the merge.

## CI/CD

- **Continuous Integration**: every push is built and tested automatically on a clean machine.
- **Continuous Delivery/Deployment**: every green build on main can be (or is) deployed automatically, often in stages
  (staging -> canary on a few servers -> everywhere), with automatic rollback.

GitHub Actions example (`.github/workflows/ci.yml`):
```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: sudo apt-get update && sudo apt-get install -y libdbd-sqlite3-perl
      - name: Build and test C code
        run: make -C day07-c-make-algorithms/starter test
      - name: Perl tests
        run: prove -l -r day03-perl-modules-testing/starter/t
```
GitLab CI uses `.gitlab-ci.yml` with `stages:` and `script:`; Jenkins uses a `Jenkinsfile`. Same idea.

## 24x7 uptime: running services in production

**systemd** keeps services running:
```ini
# /etc/systemd/system/mediacatalog.service
[Unit]
Description=Media catalog HTTP API
After=network-online.target

[Service]
ExecStart=/usr/bin/perl /opt/mediacatalog/bin/server.pl 8080 /srv/media
User=mediacat
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
```
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now mediacatalog      # start now and on boot
systemctl status mediacatalog
journalctl -u mediacatalog -f                 # follow its logs
sudo systemctl restart mediacatalog
```

**Availability math**: 99.9% ("three nines") = 8.8 hours of downtime per year; 99.99% = 53 minutes per year.
You get there with redundancy, not perfect code:
- Several instances behind a **load balancer** that uses **health checks** (`GET /health`) to drop broken ones.
- **Rolling deploys** (one server at a time) and quick **rollback**.
- **Monitoring and alerting** (Prometheus/Grafana, Nagios/Icinga, Zabbix): metrics like request rate, error rate, latency, disk, memory.
- **Logs** centralised and rotated (`logrotate`), structured enough to grep.
- **Graceful shutdown** (finish in-flight requests on SIGTERM), timeouts on every network call, retries with backoff.
- **Runbooks** and on-call rotation; blameless post-mortems after incidents.

Health check scripts follow the Nagios convention: exit `0` OK, `1` WARNING, `2` CRITICAL, `3` UNKNOWN.
