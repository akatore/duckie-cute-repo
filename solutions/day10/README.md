# Media Catalog

A small service that scans a folder of audio/video files, extracts their technical metadata with
`ffprobe`, stores it in SQLite, and serves it as a JSON HTTP API. Built as an end-to-end exercise
in Perl, SQL, HTTP and media formats.

## Architecture

```
 media files ──> bin/scan.pl ──> probes.json ──> bin/load_catalog.pl ──> catalog.db ──> bin/server.pl ──> GET /catalog
                 (ffprobe via                    (DBI, one transaction,   (SQLite)       (IO::Socket,
                  lib/MediaProbe.pm)              placeholders)                           JSON::PP)
```

- `lib/MediaProbe.pm`: runs `ffprobe` safely (no shell) and turns its JSON into a compact summary. Pure function `summarize` is unit tested.
- `bin/scan.pl`: probes every file in a folder, skips files that aren't media, prints a JSON array.
- `bin/load_catalog.pl`: loads the JSON into `media_file` and `stream` tables in one transaction; re-running replaces existing entries.
- `sql/schema.sql`: normalised schema with foreign keys (`ON DELETE CASCADE`), `CHECK` and `UNIQUE` constraints, and an index on `stream.codec`.
- `bin/server.pl`: HTTP API with `/health`, `/files`, `/catalog`; errors return 500 without killing the server.

## Requirements

Ubuntu: `sudo apt install ffmpeg sqlite3 curl perl libdbd-sqlite3-perl`

## Running

```bash
perl bin/scan.pl /srv/media > probes.json
sqlite3 catalog.db < sql/schema.sql
perl bin/load_catalog.pl catalog.db probes.json
perl bin/server.pl 8080 /srv/media catalog.db
curl http://localhost:8080/catalog
```

Or everything at once with generated test media: `bash run_all.sh` (uses `./work`, port `$PORT` or 18090).

## Testing

- `make test`: unit tests (`prove -l t`).
- `bash run_all.sh`: end-to-end test from media generation to an HTTP check.
- CI: GitHub Actions runs both on every push to `main` and on every pull request (`.github/workflows/ci.yml`).

## Design decisions

- **SQLite**: zero setup and a single file; the SQL would carry over to MySQL/PostgreSQL almost unchanged.
- **Placeholders everywhere**: no SQL injection, and NULLs/numbers are handled by the driver.
- **List-form `open` for ffprobe**: file names with spaces or `;` can't inject shell commands.
- **One transaction per load**: all-or-nothing and much faster than auto-commit.
- **Pure `summarize` function**: the logic is testable without ffmpeg installed.

## Next steps

- Serve the files themselves with `Range` support (206) for seeking.
- Handle requests concurrently (pre-fork) and run under systemd with a health check.
- Pagination and filters on `/catalog` (`?codec=h264`).
- Watch the folder for changes (inotify) instead of a full rescan.
