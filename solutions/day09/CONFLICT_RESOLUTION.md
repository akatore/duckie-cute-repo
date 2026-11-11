# Resolving the conflict lab

```bash
cd ~/conflict-lab
git merge feature/welcome
# CONFLICT (content): Merge conflict in greet.pl
git status
```

`greet.pl` after the merge attempt:
```perl
my $name = shift;
<<<<<<< HEAD
print "Hello, $name!\n";
=======
die "usage: $0 NAME\n" unless defined $name;
print "Hi, $name! Welcome to the media team.\n";
>>>>>>> feature/welcome
```

Resolved version (keep the usage check, combine both greetings, delete the markers):
```perl
my $name = shift;
die "usage: $0 NAME\n" unless defined $name;
print "Hello, $name! Welcome to the media team.\n";
```

```bash
perl greet.pl Asha            # Hello, Asha! Welcome to the media team.
perl greet.pl                 # usage: greet.pl NAME
git add greet.pl
git commit                    # accept the default "Merge branch 'feature/welcome'" message
git log --oneline --graph --all
```

Same exercise with rebase instead (try it in a fresh lab): `git switch feature/welcome && git rebase main`,
resolve, `git add greet.pl && git rebase --continue`, then `git switch main && git merge --ff-only feature/welcome`.
The history is linear and there is no merge commit.
