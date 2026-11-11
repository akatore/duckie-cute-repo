# Day 10 problem: the media catalog, end to end

Bring days 3-9 together into one small project in `starter/` (later: its own GitHub repo, your portfolio piece).

```
starter/
  README.md               project README (fill in the template)
  Makefile                `make test` runs the unit tests (given)
  run_all.sh              end-to-end pipeline (you write it)
  bin/scan.pl             MEDIA_DIR -> probes.json        (Day 6 code + lib/MediaProbe.pm)
  bin/load_catalog.pl     probes.json -> SQLite           (copy from Day 8)
  bin/server.pl           HTTP API incl. /catalog         (Day 4 + DBI)
  lib/MediaProbe.pm       probe() and summarize()          (you write it)
  sql/schema.sql          (copy from Day 8)
  t/media_probe.t         unit tests for MediaProbe (given: make them pass)
  .github/workflows/ci.yml  CI for this project
```

## Steps

1. **`lib/MediaProbe.pm`**: `probe($file)` runs ffprobe and returns the decoded JSON (Day 6).
   `summarize($path, $ffprobe_data)` turns it into one entry of Day 8's `probes.json` format:
   `{ path, container, duration, bit_rate, streams => [ { index, type, codec, width, height } | { index, type, codec, sample_rate, channels } ] }`.
   Only video and audio streams; numbers must be numbers; a missing `bit_rate` becomes `undef` (JSON `null`).
   `make test` must pass.
2. **`bin/scan.pl MEDIA_DIR`** prints the JSON array for all regular, non-hidden files in the folder, sorted by name.
   Paths are relative to MEDIA_DIR (just the file name). Files that can't be probed are skipped with a warning.
3. **`bin/load_catalog.pl`** and **`sql/schema.sql`**: copy from Day 8.
4. **`bin/server.pl PORT MEDIA_DIR CATALOG_DB`**: Day 4 server plus `GET /catalog`, returning a JSON array
   with `path`, `container`, `duration_s` (number), `bit_rate`, and `codecs` (array of strings) per file, sorted by path.
   A database error returns 500 instead of killing the server.
5. **`run_all.sh [WORK_DIR]`** (default `./work`, port from `$PORT`, default 18090):
   1. recreate WORK_DIR and generate 3 short clips with ffmpeg in `WORK_DIR/media` (e.g. H.264 MP4, MPEG-2 TS without audio, WAV),
   2. scan to `WORK_DIR/probes.json`,
   3. create `WORK_DIR/catalog.db` with the schema and load it,
   4. start the server in the background and **always** stop it when the script exits (`trap`),
   5. wait until `/health` answers, then check that `/catalog` returns 3 entries,
   6. print `ALL GOOD` and exit 0; any failure exits non-zero with a clear message.
6. **README.md**: what it does, an architecture section (a diagram in text is fine), how to run, how to test, what you'd do next.
7. **CI**: `.github/workflows/ci.yml` that installs dependencies, runs `make test` and `bash run_all.sh`.

## Acceptance criteria
`bash check.sh` passes.

## Then: rehearse
- Explain the project in 2 minutes using the pitch template in `NOTES.md`. Record yourself on your phone, listen back once.
- Do the mock interview in `INTERVIEW.md` with a friend (or alone, timed).
