#!/usr/bin/env bash
# Verifies that every tool used in the prep kit is installed.
set -u

missing=0
check_cmd() {
    if command -v "$1" >/dev/null 2>&1; then
        printf '  ok       %s\n' "$1"
    else
        printf '  MISSING  %s\n' "$1"
        missing=$((missing + 1))
    fi
}
check_perl_module() {
    if perl -M"$1" -e1 >/dev/null 2>&1; then
        printf '  ok       perl module %s\n' "$1"
    else
        printf '  MISSING  perl module %s\n' "$1"
        missing=$((missing + 1))
    fi
}

echo "Commands:"
for c in bash git curl perl prove gcc g++ make gdb valgrind sqlite3 php ffmpeg ffprobe python3; do
    check_cmd "$c"
done

echo "Perl modules:"
for m in JSON::PP Test::More IO::Socket::INET XML::LibXML DBI DBD::SQLite; do
    check_perl_module "$m"
done

echo "PHP extensions:"
if command -v php >/dev/null 2>&1 && php -m 2>/dev/null | grep -qi '^pdo_sqlite$'; then
    echo "  ok       pdo_sqlite"
else
    echo "  MISSING  pdo_sqlite (apt install php-sqlite3)"
    missing=$((missing + 1))
fi

echo
if [ "$missing" -eq 0 ]; then
    echo "All set. Start with day01-linux-git/NOTES.md"
else
    echo "$missing item(s) missing. See the apt install line in README.md"
    exit 1
fi
