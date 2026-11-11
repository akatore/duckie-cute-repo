#!/usr/bin/env perl
# usage: probe_report.pl FILE...
use strict;
use warnings;
use JSON::PP;
use File::Basename qw(basename);

die "usage: $0 FILE...\n" unless @ARGV;

my $status = 0;
for my $file (@ARGV) {
    my $probe = eval { probe($file) };
    if (!$probe) {
        warn "skipping $file: " . ($@ || "no data from ffprobe\n");
        $status = 1;
        next;
    }
    print report_line($file, $probe), "\n";
}
exit $status;

sub probe {
    my ($file) = @_;
    open my $fh, '-|', 'ffprobe', qw(-v error -print_format json -show_format -show_streams), $file
        or die "cannot run ffprobe: $!\n";
    my $json = do { local $/; <$fh> };
    close $fh or die "ffprobe exited with status " . ($? >> 8) . "\n";
    my $data = decode_json($json);
    die "no format information\n" unless $data->{format};
    return $data;
}

sub first_stream {
    my ($probe, $type) = @_;
    for my $stream (@{ $probe->{streams} || [] }) {
        return $stream if ($stream->{codec_type} // '') eq $type;
    }
    return undef;
}

sub fps {
    my ($rate) = @_;
    my ($num, $den) = split m{/}, $rate // '0/1';
    return $den ? $num / $den : 0;
}

sub report_line {
    my ($file, $probe) = @_;
    my $format = $probe->{format};
    my $v      = first_stream($probe, 'video');
    my $au     = first_stream($probe, 'audio');

    my $video = $v
        ? sprintf('%s %dx%d %.2ffps', $v->{codec_name}, $v->{width}, $v->{height}, fps($v->{r_frame_rate}))
        : 'none';
    my $audio = $au
        ? sprintf('%s %dHz %dch', $au->{codec_name}, $au->{sample_rate}, $au->{channels})
        : 'none';

    return join ' | ',
        basename($file),
        "container=$format->{format_name}",
        "video=$video",
        "audio=$audio",
        sprintf('duration=%.2fs', $format->{duration} // 0),
        sprintf('bitrate=%d kb/s', ($format->{bit_rate} // 0) / 1000);
}
