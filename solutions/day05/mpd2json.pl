#!/usr/bin/env perl
# usage: mpd2json.pl MANIFEST.mpd > representations.json
use strict;
use warnings;
use XML::LibXML;
use JSON::PP;

my $DASH_NS = 'urn:mpeg:dash:schema:mpd:2011';

my $file = shift or die "usage: $0 MANIFEST.mpd\n";
-r $file or die "cannot read $file\n";

my $doc = eval { XML::LibXML->load_xml(location => $file) }
    or die "invalid XML in $file: $@";

my $xc = XML::LibXML::XPathContext->new($doc);
$xc->registerNs(d => $DASH_NS);

my @representations;
for my $set ($xc->findnodes('//d:AdaptationSet')) {
    my $type = $set->getAttribute('contentType')
        // (split m{/}, $set->getAttribute('mimeType') // '')[0]
        // 'unknown';
    my $set_codecs = $set->getAttribute('codecs');

    for my $rep ($xc->findnodes('d:Representation', $set)) {
        my %r = (
            id        => $rep->getAttribute('id'),
            type      => $type,
            codecs    => $rep->getAttribute('codecs') // $set_codecs,
            bandwidth => 0 + $rep->getAttribute('bandwidth'),
        );
        if ($type eq 'video') {
            $r{width}  = 0 + $rep->getAttribute('width');
            $r{height} = 0 + $rep->getAttribute('height');
        }
        elsif ($type eq 'audio') {
            $r{sample_rate} = 0 + $rep->getAttribute('audioSamplingRate');
        }
        push @representations, \%r;
    }
}

print JSON::PP->new->canonical->pretty->encode(\@representations);
