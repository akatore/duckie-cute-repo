#ifndef WAV_H
#define WAV_H

#include <stdint.h>
#include <stdio.h>

enum wav_error {
    WAV_OK = 0,
    WAV_ERR_NOT_WAV = -1,
    WAV_ERR_BAD_FMT = -2,
    WAV_ERR_UNSUPPORTED = -3,
    WAV_ERR_NO_DATA = -4,
    WAV_ERR_TRUNCATED = -5
};

struct wav_info {
    int channels;
    int sample_rate;
    int bits_per_sample;
    uint32_t data_bytes;
    int peak;               /* largest absolute sample value, 0..32768 */
};

/* Reads a whole 16-bit PCM WAV stream. Returns WAV_OK or a negative wav_error. */
int wav_analyze(FILE *f, struct wav_info *out);

/* Seconds of audio described by info (0 if the format is unknown). */
double wav_duration(const struct wav_info *info);

/* Peak level relative to full scale (32768) in dB. Only meaningful if peak > 0. */
double wav_peak_dbfs(const struct wav_info *info);

const char *wav_strerror(int err);

#endif
