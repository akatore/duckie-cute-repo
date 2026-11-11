# Setting up Ubuntu for the prep kit

The kit needs an Ubuntu terminal. There are two ways to get one. Pick **A** if you work on your
own Windows laptop (nothing gets wiped), or **B** if you use the KodeKloud Playground.
No desktop/GUI is needed in either case.

## A. Ubuntu on Windows (WSL), about 15 minutes, 2-3 GB of disk

1. Open **PowerShell** and run:
   ```powershell
   wsl --install -d Ubuntu-24.04
   ```
   If it says WSL itself is missing, run PowerShell **as Administrator**, run `wsl --install`, reboot,
   and then run the command above again.
2. An Ubuntu window opens and asks for a **Linux username and password**. Choose a simple
   username (lowercase, no spaces) and remember the password: `sudo` will ask for it.
3. Later, open Ubuntu from the Start menu ("Ubuntu 24.04"), or type `wsl` in PowerShell.
4. Get the kit into your Linux home folder. Your Windows drive is available under `/mnt/c`:
   ```bash
   cp -r "/mnt/c/Users/<Windows user>/Downloads/new/prep" ~/prep
   cd ~/prep
   ```
   Work in `~/prep`, not in `/mnt/c/...`. It's much faster, and file permissions behave like a real Linux server.
   You can still edit the files from Windows: in File Explorer open `\\wsl$\Ubuntu-24.04\home\<linux user>\prep`,
   or in VS Code/Cursor install the "WSL" extension and run `code ~/prep` (or `cursor ~/prep`) from Ubuntu.

## B. KodeKloud Playground (Ubuntu VM in the browser)

1. Start an **Ubuntu** playground. You get a terminal, which is all you need.
2. Get the kit onto the VM by cloning it from your GitHub repo (see "Getting the kit onto the VM" in `../README.md`):
   ```bash
   git clone https://github.com/<you>/internship-prep.git prep
   cd prep
   ```
3. The VM is **wiped** when the playground session ends. Push your work before you stop:
   `git add -A && git commit -m "Day N" && git push`.
4. To view the HTML pages (days 5 and 8), start a web server on a port (e.g. `python3 -m http.server 8000`)
   and open it with the playground's "View port"/URL option.

## Install the tools (same for A and B)

From inside the `prep` folder:
```bash
bash ubuntu/install.sh
```
It asks for your password once (for `sudo`), installs the packages below, and finishes by running
`setup_check.sh`, which must end with **"All set."**

| Package | Used for |
|---------|----------|
| `build-essential`, `gdb`, `valgrind` | gcc/g++/make, debugger, memory checker (day 7) |
| `git`, `curl` | version control, HTTP requests (days 1, 4, 9) |
| `perl`, `libxml-libxml-perl` | Perl and its XML parser (days 2-6) |
| `sqlite3`, `libdbd-sqlite3-perl` | database and its Perl driver (day 8) |
| `php-cli`, `php-sqlite3` | PHP and its SQLite driver (days 7-8) |
| `ffmpeg` | `ffmpeg` and `ffprobe` (day 6) |
| `python3` | quick web server for viewing HTML (day 5) |

Then tell git who you are (once per machine/VM):
```bash
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

## Check that the kit itself works

Every day's checker can be run against the reference solution. All of these should pass;
if one doesn't, the problem is in the kit or the setup, not in your work:
```bash
for d in day0[1-8]* day10*; do
    n=$(echo "$d" | sed -E 's/^day([0-9]+).*/\1/')
    echo "=== $d"; bash "$d/check.sh" "solutions/day$n" | tail -n 1
done
```
Day 9 also needs the merge-conflict lab, so check it by following `day09-dev-practices/PROBLEM.md`.

## Troubleshooting

- **`$'\r': command not found`** when running a script: the file has Windows line endings. Fix with
  `sed -i 's/\r$//' file.sh`, and make sure the repo has the `.gitattributes` file from this kit.
- **`E: Unable to locate package ...`**: run `sudo apt-get update` first, then `install.sh` again.
- **`Address already in use`**: a server from an earlier run is still running. `ss -tlnp | grep 180` shows it; stop it with `kill <pid>`.
- **WSL: `wsl --install` hangs or fails**: make sure "Virtual Machine Platform" is enabled
  (Windows Features) and virtualization is enabled in the BIOS, then reboot.
- **Playground has no `sudo`**: you are probably root already. `install.sh` detects that and runs without sudo.
