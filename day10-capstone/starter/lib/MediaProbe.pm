package MediaProbe;
use strict;
use warnings;
use Exporter 'import';
use JSON::PP;

our @EXPORT_OK = qw(probe summarize);

# Runs ffprobe on $file and returns the decoded JSON. Dies on failure.
sub probe {
    my ($file) = @_;
    # TODO: reuse your Day 6 code (list-form open, check close, decode_json)
    die "TODO: probe not implemented\n";
}

# Turns ffprobe data into one probes.json entry (see PROBLEM.md and t/media_probe.t).
sub summarize {
    my ($path, $probe) = @_;
    # TODO
    return {};
}

1;
