# Day 2: Perl basics

## Why it matters for this job
Perl is listed first in the requirements. It is the glue language of many Linux media pipelines:
parse logs and tool output, call `ffmpeg`, talk to databases, serve small HTTP endpoints.

## Perl for a C programmer

| C | Perl |
|---|------|
| `int x = 5; char *s = "hi";` | `my $x = 5; my $s = "hi";` (scalars: numbers *and* strings) |
| `int a[3] = {1,2,3};` | `my @a = (1, 2, 3);` element: `$a[0]`, size: `scalar @a`, last index: `$#a` |
| hash table (you write it yourself) | `my %h = (apple => 3, pear => 5);` element: `$h{apple}` |
| `int *p = a;` | references: `my $ref = \@a;` then `$ref->[0]`, `@$ref`; hash ref `$h->{key}` |
| `struct` | hash ref: `my $f = { name => 'a.mp4', size => 10 };` |
| `printf("%d\n", x);` | `printf "%d\n", $x;` or `print "x is $x\n";` (interpolation in double quotes) |
| `strcmp(a,b)==0` | `$a eq $b` (strings) vs `$a == $b` (numbers). Using the wrong one is a classic bug. |
| `fopen/fgets` | `open my $fh, '<', $path or die "can't open $path: $!";` then `while (my $line = <$fh>) {...}` |
| `exit(1)` with message | `die "message\n";` (exits 255, message to stderr) |

The sigil shows **what you get back**: `$` one thing, `@` a list, `%` a hash. That is why element
access uses `$`: `$a[0]`, `$h{key}`.

## Always start with

```perl
#!/usr/bin/env perl
use strict;     # must declare variables with my; catches typos
use warnings;   # warns on undefined values, bad numeric conversions, etc.
```

## Cheat sheet

```perl
my @words = split /\s+/, $line;          # split on whitespace
my $joined = join ', ', @words;
chomp $line;                              # remove trailing newline
push @a, $x; my $last = pop @a; my $first = shift @a;
my @sorted = sort { $a <=> $b } @nums;    # numeric; { $a cmp $b } for strings
my @big   = grep { $_ > 10 } @nums;       # filter
my @sq    = map  { $_ * $_ } @nums;       # transform
for my $k (sort keys %h) { print "$k=$h{$k}\n" }
exists $h{x}; delete $h{x};
$count{$ip}++;                            # counting: undef + 1 = 1, no initialisation needed
my @top = (sort { $count{$b} <=> $count{$a} } keys %count)[0..4];   # list slice
```

## Regular expressions (the reason people use Perl)

```perl
if ($line =~ /^(\S+) .*" (\d{3}) /) {   # () capture into $1, $2, ...
    my ($ip, $status) = ($1, $2);
}
my ($ip, $status) = $line =~ /^(\S+) .*" (\d{3}) /;   # list context: captures returned directly
(my $clean = $name) =~ s/_/ /g;          # copy then substitute
$s =~ tr/a-z/A-Z/;                         # transliterate
if ($line =~ m{^/api/(\w+)}) {...}         # any delimiter: m{} avoids escaping /
```

`\d` digit, `\w` word char, `\s` space, `\S` non-space, `+` one or more, `*` zero or more,
`?` optional / non-greedy (`.*?`), `^`/`$` anchors, `{3}` exactly three.

## One-liners (very handy in interviews and on servers)

```bash
perl -ne 'print if /ERROR/' app.log                 # like grep
perl -lane 'print $F[0]' access.log                 # like awk '{print $1}'
perl -pi -e 's/old/new/g' config.txt                # in-place edit, like sed -i
perl -MData::Dumper -e 'print Dumper({a=>[1,2]})'  # inspect a data structure
```

## Docs
`perldoc perlintro`, `perldoc perlretut`, `perldoc -f split`, `perldoc perldata`.
