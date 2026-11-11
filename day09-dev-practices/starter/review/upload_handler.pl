#!/usr/bin/perl
# Handles an uploaded media file: saves it, probes it, records it in the catalog.
use DBI;
use JSON::PP;

my $UPLOAD_DIR = "/srv/media/uploads";
my $DB_PASS = "s3cret-prod-password";

sub handle_upload {
    my ($name, $content, $user) = @_;

    if ($name =~ /\.mp4/) {
        print "accepted $name\n";
    }

    open(FH, ">$UPLOAD_DIR/$name");
    print FH $content;

    my $size = length($content);
    if ($size = 0) {
        return "empty file";
    }

    my $json = `ffprobe -v error -print_format json -show_format $UPLOAD_DIR/$name`;
    my $info = decode_json($json);

    my $dbh = DBI->connect("dbi:mysql:catalog", "app", $DB_PASS);
    $dbh->do("INSERT INTO media_file (path, container, duration_s, owner) VALUES ('$name', '$info->{format}{format_name}', $info->{format}{duration}, '$user')");

    print "connected with password $DB_PASS\n";
    return "ok";
}

1;
