#!/usr/bin/env perl
# usage: scan.pl MEDIA_DIR > probes.json
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use JSON::PP;
use MediaProbe qw(probe summarize);

my $dir = shift or die "usage: $0 MEDIA_DIR\n";

# TODO: list regular, non-hidden files in $dir sorted by name,
#       probe + summarize each (skip failures with a warning),
#       print the array with JSON::PP->new->canonical->pretty
