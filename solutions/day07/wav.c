#include "wav.h"

#include <math.h>
#include <string.h>

static uint16_t le16(const unsigned char *p)
{
    return (uint16_t)(p[0] | (p[1] << 8));
}

static uint32_t le32(const unsigned char *p)
{
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) |
           ((uint32_t)p[3] << 24);
}

static int read_exact(FILE *f, unsigned char *buf, size_t n)
{
    return fread(buf, 1, n, f) == n ? 0 : -1;
}

static int skip(FILE *f, uint32_t n)
{
    return fseek(f, (long)n, SEEK_CUR);
}

static int parse_fmt(FILE *f, uint32_t size, struct wav_info *out)
{
    unsigned char fmt[16];

    if (size < 16 || read_exact(f, fmt, sizeof fmt))
        return WAV_ERR_BAD_FMT;
    if (le16(fmt) != 1 || le16(fmt + 14) != 16)
        return WAV_ERR_UNSUPPORTED;

    out->channels = le16(fmt + 2);
    out->sample_rate = (int)le32(fmt + 4);
    out->bits_per_sample = 16;
    if (out->channels == 0 || out->sample_rate == 0)
        return WAV_ERR_BAD_FMT;

    return skip(f, size - 16 + (size & 1)) ? WAV_ERR_BAD_FMT : WAV_OK;
}

static int scan_samples(FILE *f, uint32_t size, struct wav_info *out)
{
    unsigned char buf[4096];
    uint32_t left = size;

    out->data_bytes = size;
    while (left > 0) {
        size_t want = left < sizeof buf ? left : sizeof buf;
        size_t got = fread(buf, 1, want, f);

        for (size_t i = 0; i + 1 < got; i += 2) {
            int sample = (int16_t)le16(buf + i);
            int magnitude = sample < 0 ? -sample : sample;
            if (magnitude > out->peak)
                out->peak = magnitude;
        }
        if (got < want)
            return WAV_ERR_TRUNCATED;
        left -= (uint32_t)got;
    }
    return WAV_OK;
}

int wav_analyze(FILE *f, struct wav_info *out)
{
    unsigned char header[12];
    unsigned char chunk[8];
    int have_fmt = 0;

    memset(out, 0, sizeof *out);

    if (read_exact(f, header, sizeof header) || memcmp(header, "RIFF", 4) != 0 ||
        memcmp(header + 8, "WAVE", 4) != 0)
        return WAV_ERR_NOT_WAV;

    while (read_exact(f, chunk, sizeof chunk) == 0) {
        uint32_t size = le32(chunk + 4);

        if (memcmp(chunk, "fmt ", 4) == 0) {
            int rc = parse_fmt(f, size, out);
            if (rc != WAV_OK)
                return rc;
            have_fmt = 1;
        } else if (memcmp(chunk, "data", 4) == 0) {
            if (!have_fmt)
                return WAV_ERR_BAD_FMT;
            return scan_samples(f, size, out);
        } else if (skip(f, size + (size & 1))) {
            return WAV_ERR_TRUNCATED;
        }
    }
    return WAV_ERR_NO_DATA;
}

double wav_duration(const struct wav_info *info)
{
    int frame_bytes = info->channels * info->bits_per_sample / 8;

    if (frame_bytes == 0 || info->sample_rate == 0)
        return 0.0;
    return (double)info->data_bytes / frame_bytes / info->sample_rate;
}

double wav_peak_dbfs(const struct wav_info *info)
{
    return 20.0 * log10(info->peak / 32768.0);
}

const char *wav_strerror(int err)
{
    switch (err) {
    case WAV_OK: return "ok";
    case WAV_ERR_NOT_WAV: return "not a RIFF/WAVE file";
    case WAV_ERR_BAD_FMT: return "invalid fmt chunk";
    case WAV_ERR_UNSUPPORTED: return "only 16-bit PCM is supported";
    case WAV_ERR_NO_DATA: return "no data chunk";
    case WAV_ERR_TRUNCATED: return "file is truncated";
    default: return "unknown error";
    }
}
