package MediaName;
use strict;
use warnings;
use Exporter 'import';
use File::Basename qw(basename);

our @EXPORT_OK = qw(parse group_by_show);

my %CODEC_ALIAS = (hevc => 'h265');

my $NAME_RE = qr/
    ^ (?<title> .+? )
    _ (?: S (?<season> \d{1,2} ) E (?<episode> \d{1,3} )
        | (?<year> (?:19|20) \d\d ) )
    _ (?<height> \d{3,4} ) p
    _ (?<codec> h264 | h265 | hevc | av1 | vp9 )
    \. (?<ext> mkv | mp4 | ts | webm | mov )
    $
/xi;

sub parse {
    my ($path) = @_;
    return undef unless defined $path && length $path;
    my $name = basename($path);
    return undef unless $name =~ $NAME_RE;
    my %m = %+;

    (my $title = $m{title}) =~ tr/_./  /;
    $title =~ s/^\s+|\s+$//g;
    $title =~ s/\s+/ /g;

    my $codec = lc $m{codec};
    $codec = $CODEC_ALIAS{$codec} // $codec;

    my %info = (
        title      => $title,
        resolution => "$m{height}p",
        height     => 0 + $m{height},
        codec      => $codec,
        container  => lc $m{ext},
    );
    if (defined $m{season}) {
        @info{qw(type season episode)} = ('episode', 0 + $m{season}, 0 + $m{episode});
    }
    else {
        @info{qw(type year)} = ('movie', 0 + $m{year});
    }
    return \%info;
}

sub group_by_show {
    my %shows;
    for my $file (@_) {
        my $info = parse($file) or next;
        next unless $info->{type} eq 'episode';
        push @{ $shows{ $info->{title} } }, $info;
    }
    for my $episodes (values %shows) {
        @$episodes = sort {
            $a->{season} <=> $b->{season} || $a->{episode} <=> $b->{episode}
        } @$episodes;
    }
    return \%shows;
}

1;
