use strict;
use warnings;
use Test::More;
use JSON::PP;

use_ok('MediaProbe', qw(probe summarize)) or BAIL_OUT('MediaProbe does not load');

# ffprobe returns most numbers as strings; summarize must turn them into numbers.
my $video_file = {
    format => {
        format_name => 'mov,mp4,m4a,3gp,3g2,mj2',
        duration    => '5.000000',
        bit_rate    => '412345',
    },
    streams => [
        { index => 0, codec_type => 'video', codec_name => 'h264', width => 1280, height => 720, r_frame_rate => '25/1' },
        { index => 1, codec_type => 'audio', codec_name => 'aac', sample_rate => '44100', channels => 1 },
        { index => 2, codec_type => 'data',  codec_name => 'bin_data' },
    ],
};

my $got = summarize('clip.mp4', $video_file);
is_deeply($got, {
    path      => 'clip.mp4',
    container => 'mov,mp4,m4a,3gp,3g2,mj2',
    duration  => 5,
    bit_rate  => 412345,
    streams   => [
        { index => 0, type => 'video', codec => 'h264', width => 1280, height => 720 },
        { index => 1, type => 'audio', codec => 'aac', sample_rate => 44100, channels => 1 },
    ],
}, 'video file: data streams dropped, numbers converted');

my $json = JSON::PP->new->canonical->encode($got);
like($json, qr/"duration":5[,}]/, 'duration is encoded as a JSON number');
like($json, qr/"sample_rate":44100[,}]/, 'sample_rate is encoded as a JSON number');

my $audio_only = summarize('tone.wav', {
    format  => { format_name => 'wav', duration => '3.000000' },
    streams => [ { index => 0, codec_type => 'audio', codec_name => 'pcm_s16le', sample_rate => '48000', channels => 2 } ],
});
is($audio_only->{bit_rate}, undef, 'missing bit_rate becomes undef');
is(scalar @{ $audio_only->{streams} }, 1, 'one audio stream');
is($audio_only->{streams}[0]{codec}, 'pcm_s16le', 'audio codec');

my $empty = summarize('weird.bin', { format => { format_name => 'data', duration => '0' } });
is_deeply($empty->{streams}, [], 'no streams key gives an empty list');

ok(!eval { probe('/no/such/file.mp4'); 1 }, 'probe dies for a missing file');

done_testing();
