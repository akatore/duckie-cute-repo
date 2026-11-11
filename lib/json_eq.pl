#!/usr/bin/env perl
# usage: json_eq.pl ACTUAL_FILE EXPECTED_FILE
# Exits 0 when both files hold the same JSON value (key order and whitespace ignored).
use strict;
use warnings;
use JSON::PP;

my ($actual_file, $expected_file) = @ARGV;
die "usage: $0 ACTUAL_FILE EXPECTED_FILE\n" unless defined $expected_file;

my $json = JSON::PP->new->canonical->allow_nonref;

sub load {
    my ($path) = @_;
    open my $fh, '<', $path or die "cannot open $path: $!\n";
    local $/;
    my $text = <$fh>;
    return $json->decode($text);
}

my $actual = eval { $json->encode(load($actual_file)) };
if (!defined $actual) {
    print "actual output is not valid JSON: $@";
    exit 1;
}
my $expected = $json->encode(load($expected_file));

if ($actual eq $expected) {
    exit 0;
}
print "expected: $expected\nactual:   $actual\n";
exit 1;
