# Day 8: Databases (SQL, SQLite, Perl DBI, PHP PDO)

## Why it matters for this job
Media metadata, job queues, users, and logs all live in databases. You need to design a small schema,
write correct queries, and access the database safely from Perl and PHP.

## Relational basics
- **Table** = rows and columns; each row has a **primary key** (`id INTEGER PRIMARY KEY`).
- **Foreign key** links tables: `stream.file_id REFERENCES media_file(id)`. One file has many streams (1:N).
  N:M relationships need a join table (e.g. `file_tag(file_id, tag_id)`).
- **Normalisation**: store each fact once. Don't put "h264,aac" in one column; give streams their own table.
- **Constraints** protect data: `NOT NULL`, `UNIQUE`, `CHECK (kind IN ('video','audio'))`, `FOREIGN KEY ... ON DELETE CASCADE`.
- **Index**: a B-tree on a column so `WHERE codec = 'h264'` doesn't scan the whole table. Costs space and slows writes a bit.
- **Transaction**: `BEGIN ... COMMIT` (or `ROLLBACK`). ACID: Atomic, Consistent, Isolated, Durable.
  Loading 1000 rows in one transaction is also *much* faster than 1000 auto-committed inserts.

## SQL cheat sheet

```sql
CREATE TABLE media_file (
    id          INTEGER PRIMARY KEY,
    path        TEXT NOT NULL UNIQUE,
    duration_s  REAL NOT NULL
);
INSERT INTO media_file (path, duration_s) VALUES ('a.mp4', 5.0);
UPDATE media_file SET duration_s = 6 WHERE id = 1;
DELETE FROM media_file WHERE id = 1;

SELECT path, duration_s FROM media_file WHERE duration_s > 60 ORDER BY duration_s DESC LIMIT 5;

-- aggregate: one output row per group
SELECT container, COUNT(*) AS n FROM media_file GROUP BY container HAVING COUNT(*) > 1;

-- join: combine rows from two tables
SELECT f.path, s.codec
FROM media_file f
JOIN stream s ON s.file_id = f.id
WHERE s.kind = 'video';

-- LEFT JOIN keeps files without a match (s.* columns are NULL)
SELECT f.path FROM media_file f
LEFT JOIN stream s ON s.file_id = f.id AND s.kind = 'video'
WHERE s.id IS NULL;                    -- "files with no video stream"

SELECT ROUND(SUM(duration_s) / 3600.0, 2) FROM media_file;
SELECT path FROM media_file WHERE id IN (SELECT file_id FROM stream WHERE codec = 'opus');  -- subquery
CREATE INDEX idx_stream_codec ON stream(codec);
EXPLAIN QUERY PLAN SELECT * FROM stream WHERE codec = 'h264';   -- SEARCH ... USING INDEX vs SCAN
```

`WHERE` filters rows before grouping; `HAVING` filters groups after. `NULL` is never `= NULL`; use `IS NULL`.

## SQLite on the command line

```bash
sqlite3 catalog.db < schema.sql       # run a script
sqlite3 catalog.db                    # interactive: .tables  .schema  .headers on  .mode column  .quit
sqlite3 catalog.db "SELECT COUNT(*) FROM media_file;"
```
SQLite is a file, no server. MySQL/MariaDB and PostgreSQL are client/server; the SQL is almost the same.
**SQLite enforces foreign keys only after `PRAGMA foreign_keys = ON;`** (per connection).

## Perl DBI

```perl
use DBI;
my $dbh = DBI->connect('dbi:SQLite:dbname=catalog.db', '', '', { RaiseError => 1, AutoCommit => 1 });
$dbh->do('PRAGMA foreign_keys = ON');

my $ins = $dbh->prepare('INSERT INTO media_file (path, duration_s) VALUES (?, ?)');   # placeholders!
$dbh->begin_work;
$ins->execute($path, $duration);
my $id = $dbh->last_insert_id(undef, undef, 'media_file', 'id');
$dbh->commit;                      # or $dbh->rollback on error

my $rows = $dbh->selectall_arrayref('SELECT path, duration_s FROM media_file', { Slice => {} });
print "$_->{path}\n" for @$rows;
```
**Never** build SQL with string interpolation (`"... WHERE path = '$path'"`): that is SQL injection.
Placeholders (`?`) send data separately from the SQL text.

## PHP PDO

```php
<?php
$pdo = new PDO('sqlite:/path/catalog.db', null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$stmt = $pdo->prepare('SELECT path FROM media_file WHERE container = ?');
$stmt->execute([$container]);
foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
    echo htmlspecialchars($row['path'], ENT_QUOTES, 'UTF-8'), "\n";
}
```

## SQL vs NoSQL (one-liner for interviews)
Relational: fixed schema, joins, transactions, strong consistency. Key-value/document stores (Redis, MongoDB):
flexible schema, easy horizontal scaling, fewer guarantees. Caches (Redis/memcached) sit in front of either.
