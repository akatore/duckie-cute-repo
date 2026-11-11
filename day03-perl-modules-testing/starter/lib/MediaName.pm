package MediaName;
use strict;
use warnings;
use Exporter 'import';
use File::Basename qw(basename);

our @EXPORT_OK = qw(parse group_by_show);

# TODO: write one regex (use qr//xi and named captures) for both naming forms:
#   <Title>_S<season>E<episode>_<height>p_<codec>.<ext>
#   <Title>_<year>_<height>p_<codec>.<ext>

sub parse {
    my ($path) = @_;
    return undef unless defined $path && length $path;
    my $name = basename($path);

    # TODO: match $name, build and return a hash ref (see PROBLEM.md)
    return undef;
}

sub group_by_show {
    my @files = @_;
    my %shows;

    # TODO: parse each file, keep episodes only, push into $shows{$title},
    #       then sort each list by season and episode

    return \%shows;
}

1;
