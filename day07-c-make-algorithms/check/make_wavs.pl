#!/usr/bin/env perl
# usage: make_wavs.pl OUTPUT_DIR
# Writes deterministic WAV files for the Day 7 checker.
use strict;
use warnings;

my $dir = shift // '.';

sub chunk {
    my ($id, $payload) = @_;
    my $c = $id . pack('V', length $payload) . $payload;
    $c .= "\0" if length($payload) % 2;
    return $c;
}

sub wav {
    my (%o) = @_;
    my $data = pack 's<*', @{ $o{samples} };
    my $fmt  = pack 'vvVVvv', 1, $o{channels}, $o{rate},
        $o{rate} * $o{channels} * 2, $o{channels} * 2, 16;
    my $body = 'WAVE' . chunk('fmt ', $fmt);
    $body .= chunk('LIST', $o{list}) if defined $o{list};
    $body .= chunk('data', $data);
    return 'RIFF' . pack('V', length $body) . $body;
}

sub write_file {
    my ($path, $bytes) = @_;
    open my $fh, '>:raw', $path or die "cannot write $path: $!\n";
    print {$fh} $bytes;
    close $fh or die "cannot close $path: $!\n";
}

# 1 second of 48 kHz stereo sawtooth between -16384 and 15872, with an odd-sized LIST chunk
my @s1 = map { my $v = (($_ % 64) - 32) * 512; ($v, $v) } 0 .. 47999;
write_file("$dir/test1.wav", wav(channels => 2, rate => 48000, samples => \@s1, list => 'INFOabc'));

# 0.5 seconds of 8 kHz mono containing both extremes
my @s2 = map { ($_ % 7) * 100 } 0 .. 3999;
$s2[100] = 32767;
$s2[200] = -32768;
write_file("$dir/test2.wav", wav(channels => 1, rate => 8000, samples => \@s2));

write_file("$dir/not_a_wav.wav", "this is not a wav file\n");
