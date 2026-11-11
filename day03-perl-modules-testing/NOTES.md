# Day 3: Perl modules, data structures and unit testing

## Why it matters for this job
"Automated unit testing" and "code reviews" are in the job description. Production Perl lives in
modules (`.pm` files) with tests in `t/*.t`, run by `prove` in CI.

## Modules (think: a `.c` file + its `.h`)

`lib/MediaName.pm`:
```perl
package MediaName;          # namespace, like a C prefix MediaName_*
use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw(parse); # functions callers may import

sub parse {
    my ($path) = @_;        # @_ holds the arguments (aliases to the caller's values)
    ...
    return \%info;          # return a hash REFERENCE, not a hash (that would flatten to a list)
}

1;                          # a module must return a true value
```

Using it:
```perl
use lib 'lib';              # or run with: perl -Ilib script.pl / prove -l
use MediaName qw(parse);
my $info = parse('Show_S01E02_1080p_h264.mkv');
print $info->{title};
```

## Complex data structures

```perl
my %shows = (
    'News' => [                                 # hash of arrays of hashes
        { season => 1, episode => 1 },
        { season => 1, episode => 2 },
    ],
);
push @{ $shows{'Sport'} }, { season => 2, episode => 5 };   # autovivification creates the array
for my $title (sort keys %shows) {
    for my $ep (@{ $shows{$title} }) {          # or with Perl 5.24+: $shows{$title}->@*
        printf "%s S%02dE%02d\n", $title, $ep->{season}, $ep->{episode};
    }
}

use Data::Dumper; $Data::Dumper::Sortkeys = 1;
print Dumper(\%shows);                           # your printf-debugger for structures
```

## Named captures and `/x` (readable regexes)

```perl
my $re = qr/
    ^ (?<title> .+? )                 # non-greedy: shortest title that still lets the rest match
    _ S (?<season> \d+ ) E (?<ep> \d+ )
    \. (?<ext> mkv | mp4 )
    $
/xi;                                  # x = allow spaces/comments, i = ignore case
if ($name =~ $re) { print "$+{title} $+{season}\n" }   # %+ holds named captures
```

## Test::More

`t/media_name.t`:
```perl
use strict;
use warnings;
use Test::More;
use MediaName qw(parse);

my $got = parse('News_S01E02_720p_h264.mp4');
is($got->{title}, 'News', 'title parsed');
is_deeply($got, { title => 'News', ... }, 'whole structure');   # deep compare
ok(!defined parse('junk.txt'), 'junk returns undef');
like($got->{codec}, qr/^h26[45]$/, 'codec looks right');
done_testing();
```

Run: `prove -l t/` (`-l` adds `lib/` to the path, `-v` shows each test).

Useful: `is`, `isnt`, `ok`, `is_deeply`, `like`, `cmp_ok($x, '>', 3)`, `subtest`, `diag` (prints debug info),
`plan skip_all => 'no ffmpeg' unless ...`.

## Gotcha: returning "nothing"
`return;` returns an empty list in list context. `is(parse('junk'), undef, '...')` calls `parse` in
list context, so `return;` would shift all of `is`'s arguments! For a function that always returns
one scalar, use `return undef;`. (Perl::Critic disagrees in general; it's a deliberate choice for a scalar API.)

## Good test habits (say these in the interview)
- One behaviour per test, with a descriptive name.
- Test the edge cases: empty input, `undef`, uppercase, unknown values, paths with directories.
- Tests are documentation: a reviewer should understand the spec by reading them.
- Write a failing test before fixing a bug (regression test).
