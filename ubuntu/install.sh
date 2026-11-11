#!/usr/bin/env bash
# Installs everything the prep kit needs on Ubuntu (WSL or KodeKloud Playground).
# usage: bash ubuntu/install.sh        (safe to run again; apt skips what's installed)
set -euo pipefail

PACKAGES=(
    build-essential gdb valgrind      # gcc, g++, make, debugger, memory checker   (day 7)
    git curl                          # version control, HTTP client              (days 1, 4, 9)
    perl libxml-libxml-perl           # Perl and XML::LibXML                       (days 2-6)
    sqlite3 libdbd-sqlite3-perl       # SQLite CLI and Perl DBI driver            (day 8)
    php-cli php-sqlite3               # PHP and PDO SQLite                        (days 7-8)
    ffmpeg                            # ffmpeg + ffprobe                          (day 6)
    python3                           # simple web server for day 5
)

if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
elif command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
else
    echo "Need root or sudo to install packages." >&2
    exit 1
fi

echo "==> Updating package lists"
$SUDO apt-get update

echo "==> Installing packages"
$SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y "${PACKAGES[@]}"

if [ -z "$(git config --global user.name || true)" ]; then
    echo
    echo "git has no identity yet. Run (with your own details):"
    echo '  git config --global user.name  "Your Name"'
    echo '  git config --global user.email "you@example.com"'
fi
git config --global init.defaultBranch main

echo
echo "==> Checking the installation"
bash "$(cd "$(dirname "$0")/.." && pwd)/setup_check.sh"
