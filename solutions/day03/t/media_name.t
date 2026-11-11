use strict;
use warnings;
use Test::More;
use MediaName qw(parse group_by_show);

subtest 'episodes' => sub {
    my $ep = parse('Breaking_News_S01E02_1080p_h264.mkv');
    is_deeply($ep, {
        title => 'Breaking News', type => 'episode', season => 1, episode => 2,
        resolution => '1080p', height => 1080, codec => 'h264', container => 'mkv',
    }, 'full structure');
    is(parse('/srv/media/News_S03E07_720p_h264.ts')->{title}, 'News', 'leading directory ignored');
    is(parse('news_s03e07_720P_H264.TS')->{container}, 'ts', 'case-insensitive, lowercased output');
};

subtest 'movies' => sub {
    my $movie = parse('Big.Buck.Bunny_2008_720p_hevc.mp4');
    is($movie->{title}, 'Big Buck Bunny', 'dots become spaces');
    is($movie->{type},  'movie',          'type');
    is($movie->{year},  2008,             'year');
    is($movie->{codec}, 'h265',           'hevc alias');
    ok(!exists $movie->{season}, 'movies have no season');
};

subtest 'rejects bad names' => sub {
    is(parse($_), undef, "rejects '$_'") for (
        'random.txt',
        'Show_S01E02_1080p_mpeg2.mkv',
        'Show_S01E02_1080p_h264',
        'Show_S01E02_1080p_h264.avi',
        'Show_1850_1080p_h264.mkv',
        '',
    );
    is(parse(undef), undef, 'undef input');
};

subtest 'group_by_show' => sub {
    my $shows = group_by_show(qw(
        B_S01E02_720p_h264.mkv A_S02E01_720p_h264.mkv B_S01E01_720p_h264.mkv
        Movie_2001_720p_h264.mkv A_S01E10_720p_h264.mkv A_S01E05_720p_h264.mkv junk.txt
    ));
    is_deeply([ sort keys %$shows ], [qw(A B)], 'movies and junk ignored');
    is_deeply([ map { "$_->{season}x$_->{episode}" } @{ $shows->{A} } ],
              [qw(1x5 1x10 2x1)], 'numeric sort, not string sort');
};

done_testing();
