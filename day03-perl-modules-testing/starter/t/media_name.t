use strict;
use warnings;
use Test::More;
use MediaName qw(parse group_by_show);

my $ep = parse('Breaking_News_S01E02_1080p_h264.mkv');
is($ep->{title}, 'Breaking News', 'episode title uses spaces');
is($ep->{season}, 1, 'season is a number');

# TODO: add at least 8 more assertions. Ideas:
#   - the full structure with is_deeply
#   - a movie name with dots in the title
#   - hevc is reported as h265
#   - uppercase extension / codec
#   - a name with a directory in front
#   - names that must return undef: wrong codec, no extension, empty string, undef
#   - group_by_show ordering, and that movies are ignored

done_testing();
