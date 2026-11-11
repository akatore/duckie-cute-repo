#!/usr/bin/env perl
# usage: mpd2json.pl MANIFEST.mpd > representations.json
use strict;
use warnings;
use XML::LibXML;
use JSON::PP;

my $file = shift or die "usage: $0 MANIFEST.mpd\n";

# TODO: load the XML (load_xml dies on bad XML: wrap it in eval to print a clear message)
# TODO: create an XPathContext and register a prefix for urn:mpeg:dash:schema:mpd:2011
# TODO: for each AdaptationSet, work out the type and the inherited codecs,
#       then build one hash per Representation (numbers must be numbers: 0 + $value)

my @representations;

print JSON::PP->new->canonical->pretty->encode(\@representations);
