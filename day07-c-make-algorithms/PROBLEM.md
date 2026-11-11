# Day 7 problem: `wavinfo` in C (+ LRU cache bonus in C++)

## Main problem: `wavinfo`

Files in `starter/`:
- `wav.h` - the API (given, don't change)
- `main.c` - the command-line program (given)
- `test_wav.c` - unit tests (given; read them, they are part of the spec)
- `wav.c` - **you implement this**
- `Makefile` - **you complete this**

```bash
cd starter
make && make test
./wavinfo ../../day06-media-formats/starter/clips/tone.wav
```

Expected output format (from `main.c`):
```
format: PCM
channels: 2
sample_rate: 48000
bits_per_sample: 16
duration: 3.000s
peak: 4096
peak_dbfs: -18.06
```

### `wav_analyze(FILE *f, struct wav_info *out)` must
1. Check the `RIFF....WAVE` header, otherwise return `WAV_ERR_NOT_WAV`.
2. Walk the chunks: parse `fmt `, **skip unknown chunks** (remember the pad byte for odd sizes), stop at `data`.
3. Support only PCM (`audio_format == 1`) with 16 bits per sample; otherwise `WAV_ERR_UNSUPPORTED`.
4. Read the samples in blocks (e.g. 4096 bytes) and track the peak absolute sample value (`-32768` counts as 32768).
5. Return `WAV_ERR_TRUNCATED` if the file ends before the `data` chunk does, `WAV_ERR_NO_DATA` if there's no data chunk.
6. Read little-endian values byte by byte (portable, no struct casting).

### Makefile must
- Build `wavinfo` from `main.o` and `wav.o` with `-std=c11 -Wall -Wextra -Werror -g`, linking `-lm`.
- Have targets `all` (default), `test` (build and run `test_wav`), `clean`, declared `.PHONY`.
- Rebuild objects when `wav.h` changes.

### Acceptance criteria
- `bash check.sh` passes: clean build with no warnings, `make test` passes, output matches for generated WAV files
  (including one with an odd-sized `LIST` chunk and one containing `-32768`), errors for non-WAV files, and no valgrind errors or leaks.

## Bonus: LRU cache in C++ (`starter/lru/`)

Implement `LruCache<K, V>` in `lru/lru.hpp` with O(1) `get` and `put` (hash map + `std::list`).
`lru_test.cpp` is given:
```bash
cd starter/lru && g++ -std=c++17 -Wall -Wextra -g -I. lru_test.cpp -o lru_test && ./lru_test
```

## Stretch goals
- `wavinfo -v` also prints the list of chunks with sizes.
- Support 24-bit PCM (3-byte samples, sign-extend!).
- Compile with `-fsanitize=address,undefined` and run the tests again.
- Step through `wav_analyze` in `gdb` and `print` the chunk ids as you go.
