#!/usr/bin/env perl
# usage: scan.pl MEDIA_DIR > probes.json
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use JSON::PP;
use MediaProbe qw(probe summarize);

my $dir = shift or die "usage: $0 MEDIA_DIR\n";

opendir my $dh, $dir or die "cannot open $dir: $!\n";
my @names = sort grep { !/^\./ && -f "$dir/$_" } readdir $dh;
closedir $dh;

my @catalog;
my $skipped = 0;
for my $name (@names) {
    my $probe = eval { probe("$dir/$name") };
    if (!$probe) {
        warn "skipping $name: $@";
        $skipped++;
        next;
    }
    push @catalog, summarize($name, $probe);
}

print JSON::PP->new->canonical->pretty->encode(\@catalog);
warn "$skipped file(s) skipped\n" if $skipped;
