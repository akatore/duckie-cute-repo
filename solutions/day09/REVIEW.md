# Review of `review/upload_handler.pl`

Summary for the author: thanks for getting the upload flow started! Before this can merge there are
several security problems (shell injection, SQL injection, path traversal, a leaked password), so I'm
requesting changes. Details below, most severe first.

## Blocking

- **[blocking] line 24**: `ffprobe` runs through backticks with `$name` interpolated, so a file named
  `x.mp4; rm -rf /srv` runs arbitrary shell commands as the service user. Use the list form:
  `open my $fh, '-|', 'ffprobe', '-v', 'error', '-print_format', 'json', '-show_format', $path`, and check `close` for the exit status.
- **[blocking] line 28**: the SQL is built by string interpolation of `$name`, `$user` and the ffprobe output:
  SQL injection (`$user = "x'); DROP TABLE media_file; --"`). Use `prepare` with `?` placeholders and `execute(@values)`.
- **[blocking] line 16**: `$name` comes from the client and is used directly in the path, so `../../etc/cron.d/evil`
  writes outside the upload folder (path traversal). Also the 2-argument `open` lets a name starting with `>` or ending in `|`
  change the open mode. Use `basename`, allow only `[A-Za-z0-9._-]+`, and a 3-argument open: `open my $fh, '>:raw', $path`.
- **[blocking] lines 7 and 30**: the production DB password is committed to git and then printed to the log on every upload.
  Rotate the password now, load it from the environment or a config file readable only by the service user, and never log secrets.

## Should fix

- **[should fix] line 20**: `if ($size = 0)` assigns instead of comparing, so the condition is always false and empty
  files are never rejected. Use `==`. The check also happens *after* the file was written; validate first.
- **[should fix] lines 12-14**: the extension check doesn't reject anything (it only prints), and the regex is not anchored,
  so `movie.mp4.sh` passes. Use `return "unsupported type" unless $name =~ /\.(mp4|mkv|webm)\z/i;`
  and better, trust `ffprobe`'s format, not the name.
- **[should fix] lines 16-17**: `open` and `print` are not checked for errors (disk full, permissions), and the file is never
  closed, so the data may still be in the buffer when ffprobe reads it on line 24. Check `open ... or die`, `close ... or die`.
- **[should fix] line 25**: `decode_json` dies on empty or invalid output, e.g. when ffprobe fails; and the exit status of ffprobe
  is ignored. Wrap in `eval`, return a clear error, and delete the stored upload if it isn't valid media.
- **[should fix] line 27**: `DBI->connect` has no `RaiseError` and no error check, so a DB outage silently drops the insert.
  Use `{ RaiseError => 1 }`; consider one connection per process instead of one per upload.
- **[should fix] line 3**: no `use strict; use warnings;`. Warnings would have flagged the assignment in line 20 ("Found = in conditional").

## Nits

- **[nit] line 16**: bareword global filehandle `FH`; use a lexical `my $fh`.
- **[nit] line 28**: `duration` is interpolated unquoted; if ffprobe has no duration the SQL becomes invalid. Placeholders fix this too.
- **[nit] lines 13 and 30**: `print` to STDOUT for logging; use the service's logger with levels.
- **[nit] line 1**: `#!/usr/bin/env perl` is more portable than a hard-coded path.
- **[nit]**: there are no tests. A unit test for filename validation and an integration test with a tiny generated MP4 would catch most of the above.
