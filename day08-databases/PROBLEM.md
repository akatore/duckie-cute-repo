# Day 8 problem: the media catalog database

Input: `starter/data/probes.json`, a summary of 8 media files (the same shape you can produce from
Day 6's ffprobe output; in the capstone you will generate it yourself).

## 1. `starter/schema.sql`

Write the DDL for exactly these tables and columns (the queries and the checker rely on the names):

**`media_file`**: `id` (integer primary key), `path` (text, required, unique), `container` (text, required),
`duration_s` (real, required), `bit_rate` (integer, may be NULL).

**`stream`**: `id` (integer primary key), `file_id` (required, foreign key to `media_file.id`,
**deleting a file deletes its streams**), `stream_index` (integer, required), `kind` (text, required,
only `'video'` or `'audio'` allowed), `codec` (text, required), `width`, `height`, `sample_rate`, `channels`
(integers, may be NULL). The pair (`file_id`, `stream_index`) is unique.

Plus an index on `stream(codec)`.

## 2. `starter/load_catalog.pl`

```bash
sqlite3 /tmp/catalog.db < starter/schema.sql
perl starter/load_catalog.pl /tmp/catalog.db starter/data/probes.json
```
- Perl DBI with placeholders only, `RaiseError => 1`, `PRAGMA foreign_keys = ON`.
- All inserts in **one transaction**; on any error roll back and exit non-zero.
- Running it twice must not duplicate anything: replace a file that already exists (by `path`) together with its streams.
- JSON field mapping: `duration` -> `duration_s`, stream `index` -> `stream_index`, stream `type` -> `kind`.

## 3. Queries `starter/q1.sql` ... `starter/q5.sql`

One `SELECT` per file. The checker runs `sqlite3 catalog.db < qN.sql` and compares the output exactly
(default `sqlite3` output: columns separated by `|`, no header).

1. Number of files per container, most first, then by container name: `container|count`.
2. Paths of files with **no video stream**, alphabetically.
3. Per video codec: number of video streams and the maximum height, ordered by codec: `codec|streams|max_height`.
4. Total duration of all files in hours, rounded to 2 decimals.
5. Files with more than one audio stream: `path|audio_streams`.

## 4. `starter/www/index.php`

An HTML page listing the catalog: path, container, duration (1 decimal), and the codecs of the file
(`GROUP_CONCAT`). The DB path comes from the environment variable `CATALOG_DB`, default `../catalog.db`
relative to the script. Escape every value with `htmlspecialchars`. Errors: HTTP 500 and a short message.

```bash
cd starter && CATALOG_DB=/tmp/catalog.db php -S 0.0.0.0:8000 -t www
```

## Acceptance criteria
`bash check.sh` passes (schema constraints, loader idempotency, the 5 query outputs, the PHP page rendering).

## Stretch goals
- `EXPLAIN QUERY PLAN` for query 3 with and without the index. What changes?
- Add a `tag` table and a `file_tag` join table (N:M), and a query "all files tagged `trailer`".
- Point the loader at a fresh DB on every run with a `--create` option that runs `schema.sql` itself.
