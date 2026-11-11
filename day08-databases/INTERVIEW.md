# Day 8 interview questions: databases

1. **INNER JOIN vs LEFT JOIN?**
   INNER returns only rows with a match on both sides. LEFT returns every row from the left table, with NULLs
   where the right side has no match: that's how you find "files without a video stream".

2. **WHERE vs HAVING?**
   WHERE filters rows before grouping; HAVING filters groups after aggregation (`HAVING COUNT(*) > 1`).

3. **What is an index and when does it hurt?**
   A sorted structure (B-tree) that makes lookups by that column O(log n) instead of a full scan. It costs disk
   space and slows inserts/updates, and doesn't help low-selectivity columns much.

4. **What is SQL injection and how do you prevent it?**
   User input ends up as SQL code: `'; DROP TABLE media_file; --`. Use prepared statements with placeholders,
   never string concatenation; also run the app with a DB user that has minimal privileges.

5. **What does ACID mean?**
   Atomicity (all or nothing), Consistency (constraints hold), Isolation (concurrent transactions don't see each
   other's partial work), Durability (committed data survives a crash).

6. **Why wrap a bulk load in one transaction?**
   Atomicity (a failure leaves no half-loaded data) and speed: one commit (one fsync) instead of thousands.

7. **What is normalisation? When would you denormalise?**
   Store each fact once and link with keys, to avoid update anomalies. Denormalise (duplicate data, precompute)
   for read-heavy reporting when joins are too slow.

8. **Primary key vs unique constraint?**
   Both enforce uniqueness. A table has one primary key (the row identity, NOT NULL); it can have many unique constraints.

9. **How would you find slow queries?**
   Slow query log (MySQL) / `pg_stat_statements` (PostgreSQL), then `EXPLAIN` to see full scans or bad join orders,
   then add an index or rewrite the query.

10. **SQLite vs MySQL/PostgreSQL?**
    SQLite is an embedded library storing a single file: perfect for tools, tests and small apps, but one writer at a time.
    MySQL/PostgreSQL are servers with users, network access, many concurrent writers, and replication.
