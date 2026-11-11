# Day 7: C/C++ toolchain, Make, algorithms, and a PHP primer

You already know C/C++. Today is about the **professional toolchain** the job lists
(gcc, GNU Make, debugging, memory checking) plus algorithm talk and enough PHP to read and write it.

## gcc

```bash
gcc -std=c11 -Wall -Wextra -Werror -g -O2 -c wav.c -o wav.o   # compile only (-c) to an object file
gcc wav.o main.o -o wavinfo -lm                                # link; -lm = math library, libraries go LAST
gcc -E file.c | less        # preprocessor output     gcc -S file.c   # assembly
gcc -fsanitize=address,undefined -g ...                        # ASan/UBSan: catch overflows at runtime
```
- `-Wall -Wextra` turn on warnings; `-Werror` makes them errors (common in CI).
- `-g` adds debug symbols; `-O0` for debugging, `-O2` for release.
- Linker errors (`undefined reference to 'log10'`) vs compiler errors: know which stage failed.

## GNU Make

```make
CC      = gcc
CFLAGS  = -std=c11 -Wall -Wextra -Werror -O2 -g
LDLIBS  = -lm

all: wavinfo                         # first target = default target

wavinfo: main.o wav.o                # target: prerequisites
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)
#	^ recipe lines MUST start with a TAB character

%.o: %.c wav.h                       # pattern rule: any .o from its .c (rebuild if wav.h changes)
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o wavinfo

.PHONY: all clean                    # not real files
```
Automatic variables: `$@` target, `$<` first prerequisite, `$^` all prerequisites.
Make rebuilds a target only if a prerequisite is **newer** (timestamps). `make -n` = dry run, `make -j8` = parallel.

## gdb (debugger)

```bash
gdb --args ./wavinfo test.wav
(gdb) break wav_analyze      # or: break wav.c:42
(gdb) run
(gdb) next / step / finish   # over, into, out of a function
(gdb) print out->channels    # inspect;  print *out
(gdb) bt                     # backtrace after a crash (segfault)
(gdb) watch out->peak        # stop when it changes
```
Core dumps: `ulimit -c unlimited`, then `gdb ./prog core`.

## valgrind

```bash
valgrind --leak-check=full --error-exitcode=1 ./wavinfo test.wav
```
Reports invalid reads/writes, use of uninitialised values, and leaks ("definitely lost: 0 bytes" is the goal).

## Binary file parsing (today's problem)
- WAV = RIFF container: `"RIFF" <u32 size> "WAVE"` followed by chunks `<4-char id> <u32 size> <data>`.
  Chunks are padded to an **even** size. Important chunks: `fmt ` (format) and `data` (samples). Skip unknown ones (`LIST`, `fact`, ...).
- All integers are **little-endian**. Don't `fread` straight into a struct: padding and endianness make that non-portable. Read bytes and assemble: `p[0] | p[1] << 8`.
- `fmt ` layout (16 bytes): audio_format u16 (1 = PCM), channels u16, sample_rate u32, byte_rate u32, block_align u16, bits_per_sample u16.
- 16-bit samples are signed: `(int16_t)`. Careful: `abs(-32768)` doesn't fit in int16_t; use `int`.
- dBFS = 20 * log10(peak / 32768.0). Full scale = 0 dBFS, half = -6.02 dBFS.

## Algorithms: what interviewers expect

| Structure | Lookup | Insert | Notes |
|-----------|--------|--------|-------|
| Array | O(1) by index, O(n) search | O(n) middle | cache friendly; sorted + binary search = O(log n) |
| Linked list | O(n) | O(1) given a node | `std::list` |
| Hash map | O(1) average | O(1) average | `std::unordered_map`, Perl hash, PHP array |
| Balanced tree | O(log n) | O(log n) | `std::map`, ordered |
| Heap | O(1) min/max | O(log n) | `std::priority_queue`; top-K in O(n log k) |

Sorting: quicksort O(n log n) average / O(n^2) worst, mergesort O(n log n) stable, counting sort O(n + k).
Patterns: two pointers, sliding window, BFS/DFS, binary search on the answer, dynamic programming, hashing for "have I seen this?".

**LRU cache** (bonus problem): a hash map from key to a node in a doubly linked list. The list is
ordered by recency; `get` moves the node to the front, `put` inserts at the front and evicts the back.
Both O(1). In C++ `std::list::splice` moves a node without reallocating. CDNs and players cache segments like this.

Talk through problems out loud: clarify input, give a brute-force solution, then improve; state the complexity; test with an edge case.

## PHP primer (for C and Perl people)

```php
<?php
declare(strict_types=1);                  // like use strict for types

$name = "world";                          // all variables start with $, like Perl scalars
echo "Hello, $name\n";                    // interpolation in double quotes, as in Perl
$list = [3, 1, 2];                        // arrays are ordered hash maps (both list and dict)
$file = ['path' => 'a.mp4', 'size' => 10];
$file['codec'] = 'h264';
foreach ($file as $key => $value) { echo "$key=$value\n"; }
sort($list); count($list); in_array(2, $list); array_map(fn($x) => $x * 2, $list);

function kbps(int $bits): string {        // type hints, return types
    return sprintf("%.1f kbps", $bits / 1000);
}
$len = strlen("abc"); $parts = explode(",", "a,b"); $joined = implode(", ", $parts);
if ($x === null) { ... }                  // === like JavaScript
$data = json_decode($json, true);         // true -> associative arrays
echo json_encode($data);
echo htmlspecialchars($userInput, ENT_QUOTES, 'UTF-8');   // ALWAYS when printing into HTML
```

| Perl | PHP |
|------|-----|
| `my @a = (1,2)` / `my %h = (a=>1)` | `$a = [1, 2]` / `$h = ['a' => 1]` (same type) |
| `$h{a}` / `$a[0]` | `$h['a']` / `$a[0]` |
| `.` string concat | `.` string concat (same!) |
| `scalar @a` | `count($a)` |
| `die "msg"` | `throw new Exception("msg")` |
| `use DBI` | `new PDO(...)` |

Run: `php script.php`, `php -a` (interactive), `php -S 0.0.0.0:8000` (dev web server serving the current folder).
PHP code runs inside `<?php ... ?>`; anything outside is sent as-is (that's how PHP templates HTML).
