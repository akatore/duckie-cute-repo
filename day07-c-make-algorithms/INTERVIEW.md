# Day 7 interview questions: C/C++, toolchain, algorithms, PHP

1. **What are the stages of building a C program?**
   Preprocess (`#include`, macros) -> compile to assembly -> assemble to an object file -> link objects and
   libraries into an executable. "undefined reference" is a linker error; a syntax error is a compiler error.

2. **How does Make decide what to rebuild?**
   It compares timestamps: a target is rebuilt if any prerequisite is newer. That's why headers must be listed as prerequisites.

3. **Your program segfaults in production. What do you do?**
   Get a core dump (`ulimit -c unlimited`) and open it with `gdb ./prog core`, then `bt`. Reproduce locally
   with `-g -O0`, run under valgrind or ASan to find invalid memory access.

4. **Stack vs heap?**
   The stack holds local variables and call frames, automatically freed, limited size. The heap is
   `malloc`/`new`, lives until freed, bigger, slower to allocate, can leak.

5. **Why not `fread` a WAV header straight into a struct?**
   Struct padding and endianness are compiler/CPU-specific; the file format is fixed little-endian bytes.
   Reading bytes and assembling values is portable.

6. **`std::vector` vs `std::list`?**
   `vector` is contiguous: fast iteration and random access, cache friendly. `list` has stable iterators and O(1)
   insert/erase in the middle given an iterator. Default to `vector`.

7. **Design an LRU cache with O(1) operations.**
   Hash map from key to a node in a doubly linked list ordered by recency. `get`: look up and move the node to the
   front. `put`: insert at the front; if over capacity, remove the tail and its map entry.

8. **Find the top 10 most frequent IPs in a 50 GB log.**
   Stream it once, counting with a hash map (or `sort | uniq -c` which spills to disk), then a min-heap of size 10: O(n log 10).
   If the distinct keys don't fit in memory, hash-partition the IPs into files and process each partition.

9. **What is RAII?**
   Resource Acquisition Is Initialization: tie a resource (memory, file, lock) to an object's lifetime so the
   destructor releases it. `std::unique_ptr`, `std::lock_guard`, `std::fstream`.

10. **What's special about PHP arrays?**
    One type is both list and dictionary: an ordered hash map. `$a[] = x` appends; keys can be ints or strings.
    PHP runs per request (shared-nothing), so every request starts with fresh state.
