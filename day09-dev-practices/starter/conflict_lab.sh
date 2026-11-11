#!/usr/bin/env bash
# usage: conflict_lab.sh [LAB_DIR]   (default: ~/conflict-lab)
# Creates a git repository with two branches that conflict on purpose.
set -euo pipefail

lab="${1:-$HOME/conflict-lab}"
if [ -e "$lab" ]; then
    echo "$lab already exists. Remove it first: rm -rf '$lab'" >&2
    exit 1
fi

mkdir -p "$lab"
cd "$lab"
git init -q -b main
bot() { git -c user.name="Lab Bot" -c user.email="lab@example.com" "$@"; }

cat > greet.pl <<'EOF'
#!/usr/bin/env perl
use strict;
use warnings;

my $name = shift;
print "Hi, $name\n";
EOF
bot add greet.pl
bot commit -q -m "Add greeting script"

git switch -q -c feature/welcome
cat > greet.pl <<'EOF'
#!/usr/bin/env perl
use strict;
use warnings;

my $name = shift;
die "usage: $0 NAME\n" unless defined $name;
print "Hi, $name! Welcome to the media team.\n";
EOF
bot commit -q -am "Add usage check and welcome message"

git switch -q main
cat > greet.pl <<'EOF'
#!/usr/bin/env perl
use strict;
use warnings;

my $name = shift;
print "Hello, $name!\n";
EOF
bot commit -q -am "Use a more formal greeting"

echo "Lab ready in $lab (you are on 'main')."
echo "Next: cd $lab && git merge feature/welcome"
