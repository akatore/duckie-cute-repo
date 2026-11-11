#define _POSIX_C_SOURCE 200809L /* for fmemopen */

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "wav.h"

static int failures = 0;
static int checks = 0;

#define CHECK(cond)                                                     \
    do {                                                                \
        checks++;                                                       \
        if (!(cond)) {                                                  \
            failures++;                                                 \
            fprintf(stderr, "%s:%d: CHECK failed: %s\n", __FILE__,      \
                    __LINE__, #cond);                                   \
        }                                                               \
    } while (0)

static size_t put_u16(unsigned char *p, unsigned v)
{
    p[0] = v & 0xff;
    p[1] = (v >> 8) & 0xff;
    return 2;
}

static size_t put_u32(unsigned char *p, unsigned long v)
{
    for (int i = 0; i < 4; i++)
        p[i] = (v >> (8 * i)) & 0xff;
    return 4;
}

/* Builds a WAV file in buf. extra (may be NULL) becomes a LIST chunk placed before data. */
static size_t build_wav(unsigned char *buf, int channels, int rate,
                        const int16_t *samples, size_t n, const char *extra)
{
    size_t pos = 12;
    memcpy(buf + pos, "fmt ", 4); pos += 4;
    pos += put_u32(buf + pos, 16);
    pos += put_u16(buf + pos, 1);
    pos += put_u16(buf + pos, (unsigned)channels);
    pos += put_u32(buf + pos, (unsigned long)rate);
    pos += put_u32(buf + pos, (unsigned long)rate * channels * 2);
    pos += put_u16(buf + pos, (unsigned)channels * 2);
    pos += put_u16(buf + pos, 16);

    if (extra) {
        size_t len = strlen(extra);
        memcpy(buf + pos, "LIST", 4); pos += 4;
        pos += put_u32(buf + pos, len);
        memcpy(buf + pos, extra, len); pos += len;
        if (len % 2)
            buf[pos++] = 0;
    }

    memcpy(buf + pos, "data", 4); pos += 4;
    pos += put_u32(buf + pos, n * 2);
    for (size_t i = 0; i < n; i++)
        pos += put_u16(buf + pos, (uint16_t)samples[i]);

    memcpy(buf, "RIFF", 4);
    put_u32(buf + 4, pos - 8);
    memcpy(buf + 8, "WAVE", 4);
    return pos;
}

static int analyze_buffer(unsigned char *buf, size_t len, struct wav_info *info)
{
    FILE *f = fmemopen(buf, len, "r");
    if (!f) {
        perror("fmemopen");
        exit(2);
    }
    int rc = wav_analyze(f, info);
    fclose(f);
    return rc;
}

int main(void)
{
    unsigned char buf[4096];
    struct wav_info info;

    /* basic stereo file */
    const int16_t stereo[] = {100, -200, 1000, -999};
    size_t len = build_wav(buf, 2, 44100, stereo, 4, NULL);
    CHECK(analyze_buffer(buf, len, &info) == WAV_OK);
    CHECK(info.channels == 2);
    CHECK(info.sample_rate == 44100);
    CHECK(info.bits_per_sample == 16);
    CHECK(info.data_bytes == 8);
    CHECK(info.peak == 1000);

    /* -32768 has no positive int16_t counterpart */
    const int16_t extreme[] = {0, -32768, 32767};
    len = build_wav(buf, 1, 8000, extreme, 3, NULL);
    CHECK(analyze_buffer(buf, len, &info) == WAV_OK);
    CHECK(info.peak == 32768);

    /* unknown chunk with an odd size must be skipped including its pad byte */
    const int16_t mono[] = {5, -7, 3, 2};
    len = build_wav(buf, 1, 16000, mono, 4, "odd");
    CHECK(analyze_buffer(buf, len, &info) == WAV_OK);
    CHECK(info.channels == 1);
    CHECK(info.peak == 7);
    CHECK(fabs(wav_duration(&info) - 4.0 / 16000.0) < 1e-9);

    /* not a WAV file */
    unsigned char text[] = "hello, this is definitely not RIFF data";
    CHECK(analyze_buffer(text, sizeof text, &info) == WAV_ERR_NOT_WAV);

    /* data chunk cut short */
    len = build_wav(buf, 2, 44100, stereo, 4, NULL);
    CHECK(analyze_buffer(buf, len - 3, &info) == WAV_ERR_TRUNCATED);

    /* header only, no data chunk */
    len = build_wav(buf, 2, 44100, stereo, 4, NULL);
    CHECK(analyze_buffer(buf, 36, &info) == WAV_ERR_NO_DATA);

    /* dBFS helper */
    info.peak = 16384;
    CHECK(fabs(wav_peak_dbfs(&info) - (-6.0206)) < 0.001);

    CHECK(strcmp(wav_strerror(WAV_ERR_NOT_WAV), "") != 0);

    if (failures) {
        fprintf(stderr, "%d of %d checks FAILED\n", failures, checks);
        return 1;
    }
    printf("all %d checks passed\n", checks);
    return 0;
}
