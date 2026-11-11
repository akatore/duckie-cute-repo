use strict;
use warnings;
use Test::More;

use_ok('MediaName', qw(parse group_by_show)) or BAIL_OUT('MediaName does not load');

is_deeply(
    parse('Breaking_News_S01E02_1080p_h264.mkv'),
    {   title => 'Breaking News', type => 'episode', season => 1, episode => 2,
        resolution => '1080p', height => 1080, codec => 'h264', container => 'mkv' },
    'episode name'
);

is_deeply(
    parse('Big.Buck.Bunny_2008_720p_hevc.MP4'),
    {   title => 'Big Buck Bunny', type => 'movie', year => 2008,
        resolution => '720p', height => 720, codec => 'h265', container => 'mp4' },
    'movie name, dots in title, hevc alias, uppercase extension'
);

is_deeply(
    parse('show_s10e100_2160P_AV1.webm'),
    {   title => 'show', type => 'episode', season => 10, episode => 100,
        resolution => '2160p', height => 2160, codec => 'av1', container => 'webm' },
    'lowercase s/e markers, uppercase resolution and codec'
);

sub field { my ($name, $key) = @_; my $info = parse($name) || {}; return $info->{$key} }

is(field('/media/tv/News_S01E01_720p_h264.ts', 'title'), 'News', 'directory is ignored');
is(field('Blade_Runner_2049_1982_1080p_vp9.mkv', 'title'), 'Blade Runner 2049', 'number inside the title');
is(field('Blade_Runner_2049_1982_1080p_vp9.mkv', 'year'), 1982, 'year after a numeric title word');
is(field('News_S01E01_720p_h264.mp4', 'season'), '1', 'season has no leading zero');

is(parse('random.txt'),                    undef, 'random name');
is(parse('Show_S01E02_1080p_mpeg2.mkv'),   undef, 'unknown codec');
is(parse('Show_S01E02_1080p_h264'),        undef, 'no extension');
is(parse('Show_S01E02_1080p_h264.avi'),    undef, 'unknown extension');
is(parse('Show_S01E02_1080_h264.mkv'),     undef, 'resolution without p');
is(parse(''),                              undef, 'empty string');
is(parse(undef),                           undef, 'undef');

my $shows = group_by_show(
    'B_S01E02_720p_h264.mkv',
    'A_S02E01_720p_h264.mkv',
    'B_S01E01_720p_h264.mkv',
    'Movie_2001_720p_h264.mkv',
    'A_S01E05_720p_h264.mkv',
    'A_S01E10_720p_h264.mkv',
    'junk.txt',
);
is(ref $shows, 'HASH', 'group_by_show returns a hash ref') or $shows = {};
is_deeply([ sort keys %$shows ], [ 'A', 'B' ], 'only episodes are grouped');
is_deeply(
    [ map { "S$_->{season}E$_->{episode}" } @{ $shows->{A} || [] } ],
    [ 'S1E5', 'S1E10', 'S2E1' ],
    'sorted numerically by season then episode'
);
is_deeply(
    [ map { $_->{episode} } @{ $shows->{B} || [] } ],
    [ 1, 2 ],
    'second show sorted too'
);
is_deeply(group_by_show(), {}, 'no files gives an empty hash ref');

done_testing();
