#!/usr/bin/env perl
# usage: server.pl [PORT] [MEDIA_DIR] [CATALOG_DB]
use strict;
use warnings;
use DBI;
use IO::Socket::INET;
use JSON::PP;

my $port      = shift // 8080;
my $media_dir = shift // './media';
my $db_path   = shift // './catalog.db';

my %REASON = (
    200 => 'OK',
    404 => 'Not Found',
    405 => 'Method Not Allowed',
    500 => 'Internal Server Error',
);
my $JSON = JSON::PP->new->canonical;

-f $db_path or die "catalog database $db_path not found\n";
my $dbh = DBI->connect("dbi:SQLite:dbname=$db_path", '', '',
    { RaiseError => 1, PrintError => 0, AutoCommit => 1 });

my $server = IO::Socket::INET->new(
    LocalAddr => '0.0.0.0',
    LocalPort => $port,
    Proto     => 'tcp',
    Listen    => 10,
    ReuseAddr => 1,
) or die "cannot listen on port $port: $!\n";

$| = 1;
print "listening on http://localhost:$port (media: $media_dir, db: $db_path)\n";

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

    my ($code, $data, @headers) = eval { route($method, $path) };
    if (!defined $code) {
        warn "error handling $method $path: $@";
        ($code, $data, @headers) = (500, { error => 'internal error' });
    }
    respond($client, $code, $data, @headers);
    print "$method $path $code\n";
}

sub route {
    my ($method, $path) = @_;
    return (405, { error => 'method not allowed' }, 'Allow: GET') if $method ne 'GET';
    return (200, { status => 'ok' })  if $path eq '/health';
    return (200, list_files())         if $path eq '/files';
    return (200, catalog())            if $path eq '/catalog';
    return (404, { error => 'not found' });
}

sub list_files {
    opendir my $dh, $media_dir or return [];
    my @files = sort grep { !/^\./ && -f "$media_dir/$_" } readdir $dh;
    closedir $dh;
    return \@files;
}

sub catalog {
    my $rows = $dbh->selectall_arrayref(q{
        SELECT f.path, f.container, f.duration_s, f.bit_rate,
               GROUP_CONCAT(s.codec, ',') AS codecs
        FROM media_file f
        LEFT JOIN stream s ON s.file_id = f.id
        GROUP BY f.id
        ORDER BY f.path
    }, { Slice => {} });

    return [
        map {
            +{
                path       => $_->{path},
                container  => $_->{container},
                duration_s => 0 + $_->{duration_s},
                bit_rate   => defined $_->{bit_rate} ? 0 + $_->{bit_rate} : undef,
                codecs     => [ split /,/, $_->{codecs} // '' ],
            }
        } @$rows
    ];
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
}
