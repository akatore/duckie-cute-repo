# 10-Day Internship Prep Kit

A hands-on prep course for a software internship that asks for Perl, Linux, media formats,
web technologies, networking, C/C++, PHP, databases and professional dev practices
(git, code review, unit tests, CI/CD, 24x7 uptime).

It assumes you already know **C/C++**. Every day has one module and one problem to solve.
All the problems build up one small project, a **media catalog**:

```
media files --> ffprobe + Perl --> SQLite --> HTTP server (Perl/PHP) --> HTML/JS page
                 (days 2,3,6)      (day 8)       (days 4,8)               (day 5)
C WAV analyzer + Makefile (day 7)       git + tests + CI + systemd (days 1, 9)
                    all of it glued together in the capstone (day 10)
```

By day 10 you have a working project in your own git repo that you can explain in an interview.

## Schedule (about 4-6 hours per day)

| Day | Folder | Topic | Problem |
|-----|--------|-------|---------|
| 0 | this file | Setup (30 min) | Install tools, run `setup_check.sh` |
| 1 | `day01-linux-git` | Linux shell, pipes, git | `logstats.sh`: analyse a web server log |
| 2 | `day02-perl-basics` | Perl basics | `logstats.pl`: same report in Perl |
| 3 | `day03-perl-modules-testing` | Perl modules, data structures, Test::More | `MediaName.pm` + unit tests |
| 4 | `day04-http-networking` | TCP/IP, HTTP, curl | Minimal HTTP/JSON server in Perl |
| 5 | `day05-html-js-xml` | HTML, JavaScript, XML/XPath | Parse a DASH manifest, show it in a web page |
| 6 | `day06-media-formats` | Containers, codecs, ffmpeg/ffprobe | `probe_report.pl`: media report |
| 7 | `day07-c-make-algorithms` | gcc, Make, gdb, valgrind, algorithms, PHP intro | `wavinfo` in C + LRU cache in C++ |
| 8 | `day08-databases` | SQL, SQLite, Perl DBI, PHP PDO | Media catalog database + PHP page |
| 9 | `day09-dev-practices` | git conflicts, code review, CI/CD, systemd, uptime | Merge lab, CI workflow, service, review |
| 10 | `day10-capstone` | Everything together + mock interview | `run_all.sh` end-to-end pipeline |

Each day folder contains:

- `NOTES.md` - read first (about 1 hour). Must-know concepts, a cheat sheet, and "if you know C..." hints.
- `PROBLEM.md` - the task and its acceptance criteria (2-3 hours).
- `starter/` - skeleton files and sample data. **Write your solution here.**
- `check.sh` - automatic checker. Prints PASS/FAIL for each requirement.
- `INTERVIEW.md` - likely interview questions with short answers (30 min). Answer out loud before reading.

Reference solutions are in `solutions/dayNN/`. Only look after you have a passing attempt,
or after you have been stuck for 30+ minutes on one thing.

## Day 0: setup on KodeKloud Playground (Ubuntu)

No desktop/GUI is needed; the terminal is enough. For the HTML pages (days 5 and 8) either use
the playground's "open port"/URL feature, or copy the `.html` file to Windows and open it in a browser.

```bash
sudo apt update
sudo apt install -y build-essential gdb valgrind git curl perl libxml-libxml-perl \
    libdbd-sqlite3-perl sqlite3 php-cli php-sqlite3 ffmpeg python3

git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
```

Then get the kit onto the VM (below) and run `bash prep/setup_check.sh`.

### Getting the kit onto the VM (once)

**Playground VMs are wiped after a while**, so the kit lives in a private GitHub repo:

1. On Windows, install [Git for Windows](https://git-scm.com/download/win), create an empty private repo
   `internship-prep` on GitHub, then in PowerShell:
   ```powershell
   cd "$HOME\Downloads\new\prep"
   git init -b main; git add .; git commit -m "Prep kit"
   git remote add origin https://github.com/<you>/internship-prep.git
   git push -u origin main
   ```
   (`.gitattributes` makes sure the scripts arrive on Linux with Unix line endings.)
2. On every fresh VM:
   ```bash
   git clone https://github.com/<you>/internship-prep.git prep    # password = a GitHub personal access token
   ```
3. At the end of every session: `cd prep && git add -A && git commit -m "Day N" && git push`.

## How to use the checkers

```bash
cd prep/day01-linux-git
bash check.sh                      # checks your work in ./starter
bash check.sh ../solutions/day01   # checks the reference solution (to see what PASS looks like)
```

A checker exits with status 0 only when everything passes.

## Daily routine

1. Read `NOTES.md`; type every command from the cheat sheet yourself.
2. Solve `PROBLEM.md` in `starter/`. Run `check.sh` often.
3. Compare with `solutions/` and note anything you would do differently.
4. Answer `INTERVIEW.md` questions **out loud, in English**, in 1-2 minutes each.
5. `git add -A && git commit -m "Day N: ..." && git push`.

## Tips

- Run `man <cmd>`, `perldoc -f <function>`, `perldoc perlretut` before searching the web. Interviewers like people who can read docs.
- Keep a `LEARNINGS.md` with one line per surprise you hit. It turns into great interview stories.
- Day 10 has a mixed question bank and communication tips: `day10-capstone/QUESTION_BANK.md`.
