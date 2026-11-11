#!/usr/bin/env perl
# usage: logstats.pl ACCESS_LOG
use strict;
use warnings;

my $file = shift @ARGV or die "usage: $0 ACCESS_LOG\n";

# TODO: open the file (die with $! on failure)

my (%by_ip, %by_hour);
my $errors = 0;

# TODO: loop over lines. With ONE regex capture ip, hour and status, e.g. for
#   10.0.0.1 - - [11/Nov/2026:09:01:12 +0000] "GET / HTTP/1.1" 200 512 "-" "curl/8.0"
# capture "10.0.0.1", "09", "200". Skip lines that don't match.

# TODO: print the report in exactly the same format as Day 1
