package MediaProbe;
use strict;
use warnings;
use Exporter 'import';
use JSON::PP;

our @EXPORT_OK = qw(probe summarize);

sub probe {
    my ($file) = @_;
    open my $fh, '-|', 'ffprobe', qw(-v error -print_format json -show_format -show_streams), $file
        or die "cannot run ffprobe: $!\n";
    my $json = do { local $/; <$fh> };
    close $fh or die "ffprobe failed for $file (exit " . ($? >> 8) . ")\n";
    my $data = decode_json($json);
    die "ffprobe returned no format for $file\n" unless $data->{format};
    return $data;
}

sub summarize {
    my ($path, $probe) = @_;
    my $format = $probe->{format} || {};

    my @streams;
    for my $s (@{ $probe->{streams} || [] }) {
        my $type = $s->{codec_type} // '';
        next unless $type eq 'video' || $type eq 'audio';

        my %out = (index => 0 + $s->{index}, type => $type, codec => $s->{codec_name});
        if ($type eq 'video') {
            $out{width}  = 0 + $s->{width};
            $out{height} = 0 + $s->{height};
        }
        else {
            $out{sample_rate} = 0 + $s->{sample_rate};
            $out{channels}    = 0 + $s->{channels};
        }
        push @streams, \%out;
    }

    return {
        path      => $path,
        container => $format->{format_name},
        duration  => 0 + ($format->{duration} // 0),
        bit_rate  => defined $format->{bit_rate} ? 0 + $format->{bit_rate} : undef,
        streams   => \@streams,
    };
}

1;
