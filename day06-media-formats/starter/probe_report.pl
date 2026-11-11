#!/usr/bin/env perl
# usage: probe_report.pl FILE...
use strict;
use warnings;
use JSON::PP;
use File::Basename qw(basename);

die "usage: $0 FILE...\n" unless @ARGV;

my $status = 0;
for my $file (@ARGV) {
    # TODO: probe the file (catch failures with eval, warn, set $status = 1, next)
    # TODO: print report_line($file, $probe)
}
exit $status;

sub probe {
    my ($file) = @_;
    # TODO: run ffprobe with list-form open '-|', slurp the output, check close, decode_json
}

sub fps {
    my ($rate) = @_;
    # TODO: "30000/1001" -> 29.97..., guard against division by zero
}

sub report_line {
    my ($file, $probe) = @_;
    # TODO: find the first video and first audio stream and build the line from PROBLEM.md
}
