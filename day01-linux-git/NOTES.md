# Day 1: Linux and git, from zero

**How to read this:** every section explains one idea in plain words, then shows a command
to type, then shows what you should see. **Type every example yourself.** Don't copy-paste:
typing is how your fingers learn. Lines starting with `$` are what you type (don't type the `$`).
Lines without `$` are what the computer prints back.

Before you start, go to the Day 1 folder, which has a practice log file:
```
$ cd ~/prep/day01-linux-git/starter
$ ls
access.log  logstats.sh
```

---

## Part 1: The basics

### 1.1 Terminal, shell, command
- The **terminal** is the black window where you type.
- The **shell** (here: `bash`) is the program inside it that reads what you type and runs it.
- A **command** is a program name, optionally followed by **arguments** (what to work on) and
  **options** (how to behave; they start with `-`).

```
$ echo hello world
hello world
```
`echo` is the command, `hello` and `world` are arguments. It just prints them back.

```
$ ls -l access.log
-rw-r--r-- 1 asha asha 3241 Nov 11 09:00 access.log
```
`ls` is the command, `-l` is an option ("long format"), `access.log` is the argument. (Your name, size and date will differ.)

**Getting help:** `man ls` opens the manual for `ls` (press `q` to quit, `/word` to search).
Most commands also accept `--help`: `ls --help`.

**Useful keys:** `Tab` completes file names (type `acc` then Tab). `Up arrow` brings back the
previous command. `Ctrl+C` stops a running command. `Ctrl+L` clears the screen.

### 1.2 Where am I? Paths and folders
Linux files live in one big tree starting at `/` (called "root"). Folders are called **directories**.

- `pwd` = "print working directory": shows the folder you are in.
- `cd FOLDER` = "change directory": moves you somewhere else.
- `ls` = "list": shows what's in a folder.

```
$ pwd
/home/asha/prep/day01-linux-git/starter
```

Special names:
| Name | Means |
|------|-------|
| `/` | the very top of the tree |
| `~` | your home folder (`/home/asha`) |
| `.` | the folder you're in right now |
| `..` | the folder one level up |

```
$ cd ..
$ pwd
/home/asha/prep/day01-linux-git
$ ls
INTERVIEW.md  NOTES.md  PROBLEM.md  check  check.sh  starter
$ cd starter
```

An **absolute path** starts with `/` and works from anywhere: `/home/asha/prep`.
A **relative path** starts from where you are: `starter/access.log`.

`ls -la` also shows hidden files (names starting with `.`, like `.git`) and details:
```
$ ls -la
total 16
drwxr-xr-x 2 asha asha 4096 Nov 11 09:00 .
drwxr-xr-x 4 asha asha 4096 Nov 11 09:00 ..
-rw-r--r-- 1 asha asha 3241 Nov 11 09:00 access.log
-rw-r--r-- 1 asha asha  640 Nov 11 09:00 logstats.sh
```
A first letter `d` means directory, `-` means a normal file.

### 1.3 Creating, copying, moving, deleting
Make a playground so you can't break anything:
```
$ mkdir -p ~/practice        # make directory (-p: also create parents, no error if it exists)
$ cd ~/practice
$ touch notes.txt            # create an empty file
$ ls
notes.txt
$ cp notes.txt copy.txt      # copy
$ mv copy.txt renamed.txt    # move = rename
$ ls
notes.txt  renamed.txt
$ rm renamed.txt             # remove (delete). There is NO recycle bin!
$ mkdir old && rm -r old     # rm -r removes a folder and everything in it. Be careful.
```
Everything after `#` is a **comment**: the shell ignores it. `&&` means "run the second command only if the first one worked".

Go back for the next parts:
```
$ cd ~/prep/day01-linux-git/starter
```

### 1.4 Looking inside files
| Command | What it does |
|---------|--------------|
| `cat FILE` | prints the whole file |
| `head -n 3 FILE` | first 3 lines |
| `tail -n 3 FILE` | last 3 lines |
| `less FILE` | scrollable viewer (arrows/space to move, `q` to quit) |
| `wc -l FILE` | counts lines ("word count", `-l` = lines) |

```
$ head -n 2 access.log
10.0.0.1 - - [11/Nov/2026:09:01:12 +0000] "GET / HTTP/1.1" 200 512 "-" "curl/8.0"
10.0.0.2 - - [11/Nov/2026:09:05:40 +0000] "GET /videos HTTP/1.1" 200 2048 "-" "Mozilla/5.0"
$ wc -l access.log
30 access.log
```

`tail -f FILE` keeps the file open and prints new lines as they are added. That's how people
watch a live server log (`Ctrl+C` to stop).

### 1.5 Reading a web server log line
Every line of `access.log` is one request that a visitor made to a web server:
```
10.0.0.1 - - [11/Nov/2026:09:01:12 +0000] "GET / HTTP/1.1" 200 512 "-" "curl/8.0"
```
| Piece | Meaning |
|-------|---------|
| `10.0.0.1` | the visitor's IP address (who) |
| `[11/Nov/2026:09:01:12 +0000]` | date and time (when); `09` is the hour |
| `"GET / HTTP/1.1"` | what they asked for: method `GET`, path `/` |
| `200` | the **status code**: 2xx = OK, 4xx = client mistake (404 = not found), 5xx = server error |
| `512` | size of the answer in bytes |
| `"curl/8.0"` | the program they used (browser, app, bot) |

---

## Part 2: Finding and cutting text

### 2.1 `grep`: find lines that contain something
`grep PATTERN FILE` prints only the lines that contain PATTERN.
```
$ grep POST access.log
10.0.0.7 - - [11/Nov/2026:09:48:29 +0000] "POST /upload HTTP/1.1" 201 64 "-" "python-requests/2.31"
192.168.1.5 - - [11/Nov/2026:10:41:09 +0000] "POST /api/upload HTTP/1.1" 201 64 "-" "Mozilla/5.0"
```
Useful options:
| Option | Meaning | Example |
|--------|---------|---------|
| `-c` | count matching lines instead of printing them | `grep -c ' 404 ' access.log` prints `2` |
| `-i` | ignore upper/lower case | `grep -i mozilla access.log` |
| `-v` | invert: lines that do NOT match | `grep -v GET access.log` |
| `-n` | show line numbers | `grep -n admin access.log` |

```
$ grep -n admin access.log
11:203.0.113.4 - - [11/Nov/2026:10:15:00 +0000] "GET /admin HTTP/1.1" 403 64 "-" "sqlmap/1.7"
24:203.0.113.4 - - [11/Nov/2026:11:42:18 +0000] "GET /admin HTTP/1.1" 403 64 "-" "sqlmap/1.7"
```
(Someone is trying to break into `/admin` with a hacking tool called sqlmap. Logs tell stories!)

Why `' 404 '` with spaces? Without them, `404` would also match a line where `404` appears inside
a bigger number. The quotes keep the spaces as part of the pattern.

### 2.2 `awk`: pick columns
`awk` splits every line into **fields** at spaces and numbers them `$1`, `$2`, `$3`...
`awk '{print $1}'` means "for every line, print field 1".

Counting the fields of our log line:
```
10.0.0.1  -  -  [11/Nov/2026:09:01:12  +0000]  "GET  /  HTTP/1.1"  200  512  "-"  "curl/8.0"
   $1     $2 $3          $4               $5     $6  $7    $8      $9   $10  $11     $12
```
So `$1` = IP, `$4` = date and time, `$7` = path, `$9` = status code.

```
$ awk '{print $1}' access.log | head -n 3
10.0.0.1
10.0.0.2
192.168.1.5
$ awk '{print $9, $7}' access.log | head -n 3
200 /
200 /videos
200 /index.html
```
(The `| head -n 3` part only shows the first 3 lines; pipes are explained in Part 3.)

awk can also **filter**: put a condition before the `{ }`.
```
$ awk '$9 >= 500 {print $1, $9}' access.log
10.0.0.1 500
10.0.0.2 502
192.168.1.5 503
10.0.0.2 500
```
"Print IP and status for lines where the status is 500 or more" = the server errors.

awk can **count**, too. `n++` adds 1 to `n`, and `END { }` runs once after the last line:
```
$ awk '$9 >= 500 {n++} END {print n}' access.log
4
```

awk can split a field further. `split($4, t, ":")` cuts `$4` at every `:` into pieces `t[1]`, `t[2]`, ...:
```
$4 = [11/Nov/2026:09:01:12
     t[1]=[11/Nov/2026   t[2]=09   t[3]=01   t[4]=12
```
```
$ awk '{split($4, t, ":"); print t[2]}' access.log | head -n 3
09
09
09
```
That's the hour of each request.

Always put the awk program in **single quotes** `'...'`, so the shell doesn't touch the `$1` inside.

### 2.3 `cut`: a simpler column picker
`cut -d' ' -f1` = "split at spaces (`-d` delimiter), give me field 1". Good for simple cases; awk is more flexible.
```
$ cut -d' ' -f1 access.log | head -n 2
10.0.0.1
10.0.0.2
```

### 2.4 `sed` and `tr`: change text
`sed 's/OLD/NEW/'` replaces the first OLD with NEW on each line (`s` = substitute; add `g` at the end to replace all of them).
```
$ head -n 1 access.log | sed 's/GET/FETCH/'
10.0.0.1 - - [11/Nov/2026:09:01:12 +0000] "FETCH / HTTP/1.1" 200 512 "-" "curl/8.0"
```
`tr` replaces or deletes single characters:
```
$ echo hello | tr 'a-z' 'A-Z'
HELLO
$ echo '"GET' | tr -d '"'
GET
```
These commands never change the file itself; they print a changed copy. (`sed -i` would edit the file in place.)

---

## Part 3: Pipes, the superpower

### 3.1 What a pipe is
The `|` symbol (called a pipe) sends the **output of one command into the next command** as its input.
Small tools that each do one job get chained into something powerful, like a factory line.

```
$ grep POST access.log | wc -l
2
```
`grep` finds the POST lines, then `wc -l` counts them.

### 3.2 `sort` and `uniq`: counting things
- `sort` puts lines in order. `sort -n` sorts as numbers, `-r` reverses (biggest first).
- `uniq -c` collapses **neighbouring** identical lines into one and puts the count in front.
  That's why you always `sort` before `uniq`: identical lines must be next to each other.

### 3.3 Building a pipeline step by step
Question: **which pages are requested most?** Build the answer one step at a time and look at the
output after every step. This is exactly how professionals do it.

Step 1: take only the path column:
```
$ awk '{print $7}' access.log | head -n 5
/
/videos
/index.html
/api/files
/missing
```
Step 2: sort, so identical paths sit together:
```
$ awk '{print $7}' access.log | sort | head -n 5
/
/admin
/admin
/api/files
/api/files
```
Step 3: count neighbours with `uniq -c`:
```
$ awk '{print $7}' access.log | sort | uniq -c | head -n 5
      1 /
      2 /admin
      7 /api/files
      1 /api/files/7
      3 /api/health
```
Step 4: sort by the count, biggest first, and keep the top 3:
```
$ awk '{print $7}' access.log | sort | uniq -c | sort -rn | head -n 3
      7 /api/files
      6 /index.html
      3 /api/health
```
Notice the spaces in front of the numbers: `uniq -c` adds them. Step 5 removes them with awk
(fields don't include the spaces):
```
$ awk '{print $7}' access.log | sort | uniq -c | sort -rn | head -n 3 | awk '{print $1, $2}'
7 /api/files
6 /index.html
3 /api/health
```
Today's problem uses the same pattern for IPs and hours.

**Ties:** when two lines have the same count, `sort -rn` alone picks an order you didn't ask for.
`sort -k1,1nr -k2,2` means "sort by column 1 as a number, reversed; if equal, by column 2 alphabetically".

---

## Part 4: Redirection, saving output

The shell sends normal output to the screen. You can redirect it:
| Symbol | Meaning | Example |
|--------|---------|---------|
| `>` | write output to a file (replaces the file!) | `grep POST access.log > posts.txt` |
| `>>` | add output to the end of a file | `date >> history.txt` |
| `<` | read input from a file | `wc -l < access.log` prints just `30` |
| `2>` | write **error messages** to a file | `ls nothere 2> errors.txt` |
| `2>&1` | send errors to the same place as normal output | `cmd > all.txt 2>&1` |

```
$ cd ~/practice
$ echo first > file.txt
$ echo second >> file.txt
$ cat file.txt
first
second
$ echo replaced > file.txt
$ cat file.txt
replaced
```

Programs have two output channels: **stdout** (normal output, number 1) and **stderr** (error messages,
number 2). That's why `2>` means "redirect channel 2".
```
$ ls nothere
ls: cannot access 'nothere': No such file or directory
$ ls nothere 2> errors.txt          # nothing on the screen now
$ cat errors.txt
ls: cannot access 'nothere': No such file or directory
```

---

## Part 5: Did it work? Exit status

Every command, when it finishes, reports a number called its **exit status**:
**0 means success**, anything else means failure. The shell keeps the last one in `$?`.
```
$ ls ~ > /dev/null
$ echo $?
0
$ ls nothere 2> /dev/null
$ echo $?
2
```
`/dev/null` is a black hole: anything written there disappears. Handy to hide output.

`&&` and `||` use the exit status:
```
$ mkdir -p ~/practice && echo "folder ready"
folder ready
$ ls nothere 2> /dev/null || echo "that failed"
that failed
```
`A && B`: run B only if A succeeded. `A || B`: run B only if A failed.

---

## Part 6: Permissions

Every file says who may **r**ead, **w**rite, and e**x**ecute (run) it, for three groups of people:
the **u**ser who owns it, the owner's **g**roup, and **o**thers (everyone else).
```
$ ls -l logstats.sh
-rw-r--r-- 1 asha asha 640 Nov 11 09:00 logstats.sh
 rw-          owner: read + write
    r--       group: read only
       r--    others: read only
```
`chmod` ("change mode") changes permissions. `+x` adds execute permission so you can run the file directly:
```
$ chmod +x logstats.sh
$ ls -l logstats.sh
-rwxr-xr-x 1 asha asha 640 Nov 11 09:00 logstats.sh
$ ./logstats.sh access.log        # ./ means "the file in this folder"
```
Without `+x` you can still run a script with `bash logstats.sh access.log`.

People also write permissions as numbers: r=4, w=2, x=1, added up per group.
`chmod 755` = `rwx r-x r-x` (7=4+2+1, 5=4+1). `chmod 644` = `rw- r-- r--`.

`sudo COMMAND` runs a command as the administrator ("root"). You need it to install software:
`sudo apt install tree`. Use it only when needed.

---

## Part 7: Processes, programs that are running

A running program is a **process**, and each one has a number called its **PID**.
```
$ sleep 100 &              # & runs it in the background, so you get the prompt back
[1] 4242
$ ps                       # list your processes
    PID TTY          TIME CMD
   4100 pts/0    00:00:00 bash
   4242 pts/0    00:00:00 sleep
   4243 pts/0    00:00:00 ps
$ kill 4242                # politely ask process 4242 to stop (use YOUR number)
[1]+  Terminated              sleep 100
```
- `ps aux` lists every process on the machine; `ps aux | grep sleep` finds one.
- `top` shows a live view of what uses CPU and memory (`q` to quit).
- `kill -9 PID` forces a process to die immediately. It's a last resort, because the program can't clean up.

---

## Part 8: Variables and your first script

### 8.1 Variables
```
$ name=Asha                 # NO spaces around =
$ echo "Hello, $name"
Hello, Asha
$ count=$(wc -l < access.log)      # $( ) runs a command and captures its output
$ echo "The log has $count lines"
The log has 30 lines
```
Use **double quotes** around `"$variable"`. Without quotes, a value with a space in it is split
into two separate words, which breaks file names like `my file.txt`.

**Single** quotes print things exactly as typed:
```
$ echo 'Hello, $name'
Hello, $name
```

### 8.2 A script is a file full of commands
```
$ cd ~/practice
$ nano hello.sh
```
`nano` is a simple text editor in the terminal. Type this, then save with `Ctrl+O`, `Enter`, and exit with `Ctrl+X`:
```bash
#!/usr/bin/env bash
set -euo pipefail

name="${1:?usage: hello.sh NAME}"
echo "Hello, $name!"
```
What each line means:
- `#!/usr/bin/env bash`: the **shebang**. It tells Linux to run this file with bash.
- `set -euo pipefail`: safety switches. `-e` stops at the first failing command, `-u` stops if you use a
  variable that was never set (catches typos), `pipefail` makes a pipe fail if any part of it fails.
- `$1` is the first argument given to the script, `$2` the second, and so on.
- `${1:?message}` means "use `$1`, or if it's missing, print the message and stop with an error".

```
$ bash hello.sh Asha
Hello, Asha!
$ bash hello.sh
hello.sh: line 4: 1: usage: hello.sh NAME
$ echo $?
1
```

### 8.3 if and for
```bash
count=$(wc -l < access.log)
if [ "$count" -gt 10 ]; then        # -gt = greater than (-lt less, -eq equal)
    echo "big log"
else
    echo "small log"
fi

for f in *.log; do                  # *.log = every file whose name ends in .log
    echo "found: $f"
done
```

---

## Part 9: Running things on a schedule (cron)
**cron** is a built-in alarm clock that runs commands at set times. `crontab -e` opens your list
of scheduled jobs (choose `nano` if it asks). Each line has five time fields, then the command:
```
minute  hour  day-of-month  month  day-of-week   command
  */5     *        *          *         *         bash /home/asha/logstats.sh /var/log/access.log >> /tmp/stats.txt
```
`*` means "every". `*/5` in the minute field means "every 5 minutes". `0 2 * * *` means "every day at 02:00".

---

## Part 10: Remote servers (ssh)
At work, servers are other computers you control through a terminal over the network:
```
$ ssh asha@server.example.com          # log in to another machine
$ scp report.txt asha@server.example.com:/tmp/     # copy a file to it
```
After `ssh`, every command you type runs on the other machine until you type `exit`.

---

## Part 11: git, saving the history of your work

### 11.1 What git is
git takes **snapshots** of your project, called **commits**. You can always go back to an old snapshot,
see exactly what changed, and work on several ideas at once without them mixing. Every software team uses it.

Vocabulary:
| Word | Meaning |
|------|---------|
| repository (repo) | a project folder that git is tracking (it has a hidden `.git` folder) |
| commit | a saved snapshot, with a message saying what changed and why |
| staging | choosing which changes go into the next commit (`git add`) |
| branch | a separate line of work; `main` is the main line |
| merge | bringing the commits from one branch into another |
| remote / push | a copy of the repo on a server (GitHub); `push` uploads your commits |

### 11.2 First commits, step by step
One-time setup (use your own details):
```
$ git config --global user.name "Asha Sharma"
$ git config --global user.email "asha@example.com"
```
```
$ mkdir ~/practice/myrepo && cd ~/practice/myrepo
$ git init
Initialized empty Git repository in /home/asha/practice/myrepo/.git/
$ echo "hello" > greeting.txt
$ git status                   # what changed? (red = not staged yet)
On branch main

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        greeting.txt

nothing added to commit but untracked files present (use "git add" to track)
$ git add greeting.txt         # stage it (now it shows green in git status)
$ git commit -m "Add greeting"
[main (root-commit) 1a2b3c4] Add greeting
 1 file changed, 1 insertion(+)
 create mode 100644 greeting.txt
$ echo "hello again" >> greeting.txt
$ git diff                     # show exactly what changed since the last commit
diff --git a/greeting.txt b/greeting.txt
index ce01362..c66f159 100644
--- a/greeting.txt
+++ b/greeting.txt
@@ -1 +1,2 @@
 hello
+hello again
```
Read the diff like this: lines starting with `+` were added, lines starting with `-` were removed,
and lines with a space in front didn't change (shown for context). Ignore the header lines for now.
```
$ git commit -am "Add second line"     # -a stages changed files, -m sets the message
$ git log --oneline
5d6e7f8 Add second line
1a2b3c4 Add greeting
```
(The 7-character codes are commit IDs; yours will differ.)

### 11.3 Branches and merging
```
$ git switch -c feature/shout        # create a new branch and switch to it
$ echo "HELLO!" >> greeting.txt
$ git commit -am "Shout"
$ git switch main                    # back to main: the HELLO! line is gone from the file...
$ cat greeting.txt
hello
hello again
$ git merge feature/shout            # ...until you merge the branch in
$ cat greeting.txt
hello
hello again
HELLO!
$ git log --oneline --graph --all    # a picture of the history
```

Good commit messages say **why**, not just what: "Fix crash on empty log file", not "changes".

---

## Cheat sheet (keep it open while you solve the problem)
```
pwd  ls -la  cd DIR  cd ..  mkdir -p DIR  cp A B  mv A B  rm FILE  rm -r DIR
cat F  head -n N F  tail -n N F  tail -f F  less F  wc -l F
grep PAT F   grep -c / -i / -v / -n
awk '{print $1}' F      awk '$9 >= 500' F      awk '{n++} END {print n}' F
sort  sort -n  sort -rn  sort -k1,1nr -k2,2   uniq -c   head -n 5
cmd > file   cmd >> file   cmd 2> errors   cmd > all 2>&1   echo $?
chmod +x F   ps aux   kill PID   top
git status  git add F  git commit -m "msg"  git log --oneline  git switch -c B  git merge B
```

## Self-check before the problem
Try to answer without looking (answers are in the sections above):
1. How many requests in `access.log` got status 403? (Hint: `grep -c`.)
2. Print only the paths of the requests that came from `10.0.0.7`.
3. What's the difference between `>` and `>>`?
4. Why do you `sort` before `uniq -c`?
5. What does `echo $?` print after a command that failed?

Now open `PROBLEM.md`.
