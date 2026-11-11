# Day 3 interview questions: modules, data structures, testing

1. **Why does a Perl module end with `1;`?**
   `require` needs the file to return a true value to signal it loaded successfully.

2. **`@EXPORT` vs `@EXPORT_OK`?**
   `@EXPORT` pushes names into the caller automatically (namespace pollution); `@EXPORT_OK` only
   exports what the caller asks for. Prefer `@EXPORT_OK`.

3. **What is a reference, and why do you need one for nested data?**
   A scalar that points to another value (like a pointer, but safe and reference-counted). Arrays and
   hashes can only contain scalars, so nesting needs references: `{ eps => [1, 2] }`.

4. **What is autovivification?**
   Perl creates intermediate structures on demand: `push @{ $h{x} }, 1;` creates the array ref.
   Handy, but `exists $h{a}{b}` silently creates `$h{a}`.

5. **How does Perl free memory?**
   Reference counting: a value is freed when its count drops to 0. Circular references leak unless
   you break them or use `Scalar::Util::weaken`.

6. **What makes a good unit test?**
   Fast, independent, deterministic, tests one behaviour, has a clear name, covers edge cases and error paths.

7. **Unit test vs integration test?**
   A unit test checks one function/module in isolation (e.g. `parse`). An integration test checks
   components together (e.g. scanner + database + HTTP server).

8. **What is TAP?**
   Test Anything Protocol: the `ok 1 - name` / `not ok 2` text output that `prove` and CI read.

9. **How would you test code that calls `ffprobe`?**
   Separate pure logic (parsing JSON into a summary) from the side effect (running the program).
   Unit-test the pure part with fixture data; mock the command or use a small real file in an integration test.

10. **What is greedy vs non-greedy matching?**
    `.*` takes as much as possible and backtracks; `.*?` takes as little as possible. For
    `Blade_Runner_2049_1982_...` a non-greedy title still works because the regex backtracks until the rest matches.
