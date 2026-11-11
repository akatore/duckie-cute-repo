#!/usr/bin/env perl
# usage: load_catalog.pl CATALOG_DB PROBES_JSON
use strict;
use warnings;
use DBI;
use JSON::PP;

my ($db_path, $json_path) = @ARGV;
die "usage: $0 CATALOG_DB PROBES_JSON\n" unless defined $json_path;

my $probes = do {
    open my $fh, '<', $json_path or die "cannot open $json_path: $!\n";
    local $/;
    decode_json(scalar <$fh>);
};

my $dbh = DBI->connect("dbi:SQLite:dbname=$db_path", '', '',
    { RaiseError => 1, PrintError => 0, AutoCommit => 1 });
$dbh->do('PRAGMA foreign_keys = ON');

my $delete_file = $dbh->prepare('DELETE FROM media_file WHERE path = ?');
my $insert_file = $dbh->prepare(
    'INSERT INTO media_file (path, container, duration_s, bit_rate) VALUES (?, ?, ?, ?)');
my $insert_stream = $dbh->prepare(
    'INSERT INTO stream (file_id, stream_index, kind, codec, width, height, sample_rate, channels)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)');

$dbh->begin_work;
eval {
    for my $file (@$probes) {
        $delete_file->execute($file->{path});
        $insert_file->execute(@{$file}{qw(path container duration bit_rate)});
        my $file_id = $dbh->last_insert_id(undef, undef, 'media_file', 'id');
        for my $s (@{ $file->{streams} || [] }) {
            $insert_stream->execute($file_id,
                @{$s}{qw(index type codec width height sample_rate channels)});
        }
    }
    $dbh->commit;
    1;
} or do {
    my $err = $@ || 'unknown error';
    $dbh->rollback;
    die "load failed, nothing was changed: $err";
};

printf "loaded %d files into %s\n", scalar @$probes, $db_path;
