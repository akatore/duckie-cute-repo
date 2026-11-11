#include "wav.h"

#include <math.h>
#include <string.h>

/* Helpers you will want:
 *   static uint16_t le16(const unsigned char *p)  -> p[0] | p[1] << 8
 *   static uint32_t le32(const unsigned char *p)
 *   static int read_exact(FILE *f, unsigned char *buf, size_t n)  -> 0 if all n bytes were read
 */

int wav_analyze(FILE *f, struct wav_info *out)
{
    memset(out, 0, sizeof *out);
    (void)f;

    /* TODO:
     * 1. read 12 bytes: "RIFF" <size> "WAVE", else return WAV_ERR_NOT_WAV
     * 2. loop: read an 8-byte chunk header (id + little-endian size)
     *    - "fmt ": read 16 bytes, check PCM + 16 bit, fill out->..., skip the rest
     *    - "data": read the samples in blocks, track out->peak, return WAV_OK
     *    - anything else: fseek past size + (size & 1)
     * 3. no data chunk found -> WAV_ERR_NO_DATA
     */
    return WAV_ERR_NOT_WAV;
}

double wav_duration(const struct wav_info *info)
{
    /* TODO: data_bytes / (channels * bytes per sample) / sample_rate */
    (void)info;
    return 0.0;
}

double wav_peak_dbfs(const struct wav_info *info)
{
    /* TODO: 20 * log10(peak / 32768.0) */
    (void)info;
    return 0.0;
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
