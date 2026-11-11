#!/usr/bin/env perl
# usage: server.pl [PORT] [MEDIA_DIR]
use strict;
use warnings;
use IO::Socket::INET;
use JSON::PP;

my $port      = shift // 8080;
my $media_dir = shift // './media';

my %REASON = (200 => 'OK', 404 => 'Not Found', 405 => 'Method Not Allowed');
my $JSON   = JSON::PP->new->canonical;

my $server = IO::Socket::INET->new(
    LocalAddr => '0.0.0.0',
    LocalPort => $port,
    Proto     => 'tcp',
    Listen    => 10,
    ReuseAddr => 1,
) or die "cannot listen on port $port: $!\n";

$| = 1;
print "listening on http://localhost:$port (media: $media_dir)\n";

while (my $client = $server->accept) {
    handle($client);
    close $client;
}

sub handle {
    my ($client) = @_;

    my $request_line = <$client>;
    return unless defined $request_line;
    $request_line =~ s/\r?\n\z//;

    while (my $header = <$client>) {
        last if $header =~ /^\r?\n\z/;
    }

    my ($method, $target) = split / /, $request_line;
    $method //= '';
    (my $path = $target // '/') =~ s/\?.*//;

    my $code;
    if ($method ne 'GET') {
        $code = respond($client, 405, { error => 'method not allowed' }, 'Allow: GET');
    }
    elsif ($path eq '/health') {
        $code = respond($client, 200, { status => 'ok' });
    }
    elsif ($path eq '/files') {
        $code = respond($client, 200, list_files());
    }
    else {
        $code = respond($client, 404, { error => 'not found' });
    }
    print "$method $path $code\n";
}

sub list_files {
    opendir my $dh, $media_dir or return [];
    my @files = sort grep { !/^\./ && -f "$media_dir/$_" } readdir $dh;
    closedir $dh;
    return \@files;
}

sub respond {
    my ($client, $code, $data, @extra_headers) = @_;
    my $body = $JSON->encode($data);
    print {$client}
        "HTTP/1.1 $code $REASON{$code}\r\n",
        "Content-Type: application/json\r\n",
        "Content-Length: " . length($body) . "\r\n",
        "Connection: close\r\n",
        (map { "$_\r\n" } @extra_headers),
        "\r\n",
        $body;
    return $code;
}
