#!/usr/bin/env perl
# usage: server.pl [PORT] [MEDIA_DIR]
use strict;
use warnings;
use IO::Socket::INET;
use JSON::PP;

my $port      = shift // 8080;
my $media_dir = shift // './media';

my %REASON = (200 => 'OK', 404 => 'Not Found', 405 => 'Method Not Allowed');

my $server = IO::Socket::INET->new(
    LocalAddr => '0.0.0.0',
    LocalPort => $port,
    Proto     => 'tcp',
    Listen    => 10,
    ReuseAddr => 1,
) or die "cannot listen on port $port: $!\n";

$| = 1;    # flush STDOUT immediately so log lines show up right away
print "listening on http://localhost:$port (media: $media_dir)\n";

while (my $client = $server->accept) {
    handle($client);
    close $client;
}

sub handle {
    my ($client) = @_;

    # TODO: read the request line, e.g. "GET /files?x=1 HTTP/1.1\r\n"
    # TODO: read header lines until an empty line ("\r\n")
    # TODO: split method and path, drop the query string
    # TODO: route: 405 for non-GET, /health, /files, otherwise 404
}

sub list_files {
    # TODO: return an array ref of sorted, non-hidden regular file names in $media_dir
    return [];
}

sub respond {
    my ($client, $code, $data, @extra_headers) = @_;
    # TODO: encode $data as JSON and write status line, headers and body.
    #       Content-Length must be the number of bytes in the body.
}
