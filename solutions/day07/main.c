#include <stdio.h>

#include "wav.h"

int main(int argc, char **argv)
{
    if (argc != 2) {
        fprintf(stderr, "usage: %s FILE.wav\n", argv[0]);
        return 2;
    }

    FILE *f = fopen(argv[1], "rb");
    if (!f) {
        perror(argv[1]);
        return 1;
    }

    struct wav_info info;
    int rc = wav_analyze(f, &info);
    fclose(f);
    if (rc != WAV_OK) {
        fprintf(stderr, "%s: %s\n", argv[1], wav_strerror(rc));
        return 1;
    }

    printf("format: PCM\n");
    printf("channels: %d\n", info.channels);
    printf("sample_rate: %d\n", info.sample_rate);
    printf("bits_per_sample: %d\n", info.bits_per_sample);
    printf("duration: %.3fs\n", wav_duration(&info));
    printf("peak: %d\n", info.peak);
    if (info.peak > 0)
        printf("peak_dbfs: %.2f\n", wav_peak_dbfs(&info));
    else
        printf("peak_dbfs: -inf\n");
    return 0;
}
