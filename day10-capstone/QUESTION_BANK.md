# Question bank (mixed topics)

Each day's `INTERVIEW.md` has answers to its own topic. These are extra questions, short answers included.
Cover the answer, say yours out loud, then compare.

## Perl
1. **How do you read a file line by line and count words?**
   `while (my $l = <$fh>) { $count{$_}++ for split /\W+/, lc $l }`; then sort keys by count.
2. **What does `local $/;` do?**
   Temporarily undefines the input record separator so `<$fh>` reads the whole file (slurp), restored at the end of the block.
3. **How do you handle errors in Perl?**
   `die` to throw, `eval { ... ; 1 } or do { ... $@ ... }` to catch (or `Try::Tiny`, or `try/catch` in Perl 5.34+). Check return values of `open`, `close`, `system`.
4. **What does `wantarray` do?**
   Tells a sub whether it was called in list, scalar or void context.
5. **How do you run an external command safely and get its exit code?**
   `system('ffmpeg', @args) == 0 or die "failed: " . ($? >> 8)`; list form avoids the shell.
6. **What's CPAN?**
   The Comprehensive Perl Archive Network: Perl's module repository. Install with `cpanm Module::Name` or the distro packages (`apt install libxyz-perl`).

## Linux
7. **How do you see what a running process is doing?**
   `top`/`htop` for CPU and memory, `strace -p PID` for system calls, `lsof -p PID` for open files, `/proc/PID/`.
8. **What's the load average?**
   The average number of runnable (plus uninterruptible) processes over 1, 5 and 15 minutes. Compare it with the number of CPU cores.
9. **Hard link vs symbolic link?**
   A hard link is another name for the same inode (same filesystem only); a symlink is a small file containing a path (can dangle).
10. **How do you find the 10 biggest files under /srv?**
    `find /srv -type f -printf '%s %p\n' | sort -rn | head` (or `du -ah /srv | sort -rh | head`).
11. **What is a zombie process?**
    A child that has exited but whose parent hasn't called `wait()` yet; it only holds a process-table entry.

## Media
12. **Why might audio drift out of sync with video?**
    Wrong or missing timestamps, variable frame rate treated as constant, sample rate mismatch, or dropped frames without timestamp correction.
13. **What's the difference between interlaced and progressive?**
    Interlaced sends alternating fields (odd/even lines) at twice the frame rate (broadcast legacy); progressive sends full frames. Deinterlace before web delivery.
14. **What is a CDN and why is it used for video?**
    A network of edge caches close to users; segments are cached at the edge so the origin isn't overloaded and latency is low.
15. **What is HDR in one sentence?**
    Higher dynamic range and wider colour gamut (e.g. HDR10 with 10-bit PQ transfer, or HLG), carried as metadata alongside the video.
16. **What's a codec profile/level (e.g. H.264 High@4.1)?**
    Profile = which features the encoder may use; level = limits on resolution, bitrate and frame rate so decoders know if they can play it.
17. **How would you check a file for corruption?**
    `ffmpeg -v error -i file -f null -` decodes everything and prints errors without writing output.

## Web, HTTP, networking
18. **What is a cookie vs a session?**
    A cookie is data the browser stores and sends back; a session is server-side state usually identified by a cookie holding a session ID.
19. **What does HTTPS protect?**
    Confidentiality and integrity of the traffic and the server's identity (certificate). It doesn't hide which IP/host you connect to.
20. **What is a reverse proxy?**
    A server (nginx, HAProxy) in front of application servers: TLS termination, load balancing, caching, compression.
21. **What is DNS TTL and why does it matter for a migration?**
    How long resolvers cache a record. Lower it before moving a service so clients pick up the new address quickly.

## C/C++ and algorithms
22. **What's undefined behaviour? Give examples.**
    Code the standard gives no meaning to: signed overflow, out-of-bounds access, use after free, null dereference. The compiler may do anything.
23. **`malloc` vs `new`?**
    `malloc` returns raw memory; `new` allocates and runs the constructor (and `delete` runs the destructor). Never mix them.
24. **What is a memory leak and how do you find one?**
    Allocated memory that is no longer reachable and never freed. `valgrind --leak-check=full` or `-fsanitize=address`.
25. **Reverse a linked list.**
    Iterate with `prev = NULL`, `cur = head`: `next = cur->next; cur->next = prev; prev = cur; cur = next;`. O(n) time, O(1) space.
26. **Detect a duplicate in an array of n numbers.**
    Hash set O(n) time/O(n) space, or sort first O(n log n)/O(1) extra.
27. **What's the complexity of binary search and what does it need?**
    O(log n) on sorted, random-access data.

## PHP
28. **`include` vs `require`?**
    Both insert a file; `require` stops with a fatal error if it's missing, `include` only warns. `_once` variants load a file at most once.
29. **How do you prevent XSS and SQL injection in PHP?**
    `htmlspecialchars()` on output into HTML; PDO prepared statements with bound parameters for SQL.
30. **`==` vs `===` in PHP?**
    `==` compares after type juggling (`"1" == "01"` is true); `===` requires the same type and value.

## Databases
31. **What is a deadlock?**
    Two transactions each wait for a lock the other holds. The DB kills one; avoid by locking in a consistent order and keeping transactions short.
32. **What is replication?**
    Copying data from a primary to replicas for read scaling and failover; usually asynchronous, so replicas can lag.
33. **COUNT(*) vs COUNT(column)?**
    `COUNT(*)` counts rows; `COUNT(col)` counts rows where `col` is not NULL.

## Process, teamwork, scientific work
34. **How do you make sure your experiment/benchmark result is valid?**
    Clear hypothesis, controlled variables, repeat runs and report the variance, a baseline to compare against, record versions and parameters so it can be reproduced.
35. **How do you estimate a task?**
    Break it into small pieces, estimate each, add time for testing and review, and say early when the estimate turns out wrong.
36. **What would you do in your first week?**
    Set up the environment, read the docs and the code of one service, fix a small bug end to end (branch, test, review, deploy), and ask lots of questions.

## Behavioural (prepare a STAR story for each)
37. Tell me about a time you had to learn a new technology quickly.
38. Tell me about a bug that took you a long time to find.
39. Tell me about a disagreement with a teammate.
40. Tell me about a mistake you made.
41. Tell me about your most complex scientific or technical project.
42. Why this internship? Why this company?
43. Where do you see yourself in two years?
