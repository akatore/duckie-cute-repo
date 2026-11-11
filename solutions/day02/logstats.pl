#!/usr/bin/env perl
# usage: logstats.pl ACCESS_LOG
use strict;
use warnings;

my $file = shift @ARGV or die "usage: $0 ACCESS_LOG\n";
open my $fh, '<', $file or die "cannot open $file: $!\n";

my (%by_ip, %by_hour);
my $errors = 0;

while (my $line = <$fh>) {
    my ($ip, $hour, $status) = $line =~ m{
        ^(\S+) \s \S+ \s \S+ \s         # ip, ident, user
        \[ [^:]+ : (\d\d) : [^\]]+ \] \s  # [date:HH:MM:SS zone]
        "[^"]*" \s                      # "GET /path HTTP/1.1"
        (\d{3}) \s                      # status
    }x or next;

    $by_ip{$ip}++;
    $by_hour{$hour}++;
    $errors++ if $status =~ /^5/;
}
close $fh;

my @top = sort { $by_ip{$b} <=> $by_ip{$a} || $a cmp $b } keys %by_ip;
splice @top, 5 if @top > 5;

print "Top 5 IPs:\n";
printf "%d %s\n", $by_ip{$_}, $_ for @top;
print "5xx errors: $errors\n";

my ($busiest) = sort { $by_hour{$b} <=> $by_hour{$a} || $a cmp $b } keys %by_hour;
printf "Busiest hour: %s (%d requests)\n", $busiest, $by_hour{$busiest} if defined $busiest;
