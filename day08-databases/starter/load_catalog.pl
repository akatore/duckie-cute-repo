#!/usr/bin/env perl
# usage: load_catalog.pl CATALOG_DB PROBES_JSON
use strict;
use warnings;
use DBI;
use JSON::PP;

my ($db_path, $json_path) = @ARGV;
die "usage: $0 CATALOG_DB PROBES_JSON\n" unless defined $json_path;

# TODO: read and decode the JSON file
# TODO: connect with RaiseError => 1, then PRAGMA foreign_keys = ON
# TODO: prepare statements with ? placeholders:
#         delete an existing file by path (its streams go with it: ON DELETE CASCADE)
#         insert a file, insert a stream
# TODO: begin_work; loop; commit. On error (eval): rollback and die.
