# Day 6 interview questions: media formats

1. **Container vs codec?**
   The codec compresses a stream (H.264, AAC). The container packages one or more streams with
   timing and metadata (MP4, MKV, TS). An MKV and an MP4 can hold the exact same H.264 stream.

2. **A user says "the MKV won't play in the browser." What do you check?**
   `ffprobe` the codecs: browsers support MP4/WebM with H.264/VP9/AV1 + AAC/Opus. If the codecs are fine,
   remux to MP4 with `-c copy`; if not (e.g. AC-3 audio), transcode only that stream (`-c:v copy -c:a aac`).

3. **What is a keyframe / GOP, and why does it matter for streaming?**
   A keyframe (I-frame) decodes on its own; P/B-frames depend on others. A GOP runs from one keyframe to the
   next. Segments must start with a keyframe so players can switch quality or seek, so encoders use a fixed GOP aligned to the segment length.

4. **Remux vs transcode?**
   Remux copies the compressed streams into another container: fast and lossless. Transcode decodes and
   re-encodes: slow, lossy, but can change codec, resolution and bitrate.

5. **Why is MPEG-TS used for broadcast and HLS?**
   Fixed 188-byte packets with sync bytes and continuity counters: a receiver can join mid-stream and recover from lost data.

6. **What does 1080p25 at 5 Mb/s tell you?**
   1920x1080 progressive, 25 frames per second, average 5 megabits per second (about 37.5 MB per minute).

7. **How do you compute the size of uncompressed audio?**
   sample_rate x bit_depth x channels / 8 bytes per second: 48000 x 16 x 2 / 8 = 192 KB/s.

8. **H.264 vs H.265 vs AV1?**
   Each newer codec gets similar quality at lower bitrate (roughly 30-50% savings per generation) but costs
   more CPU to encode. H.264 is the compatibility baseline, HEVC has patent licensing issues, AV1 is royalty-free.

9. **PTS vs DTS?**
   Presentation vs decoding timestamp. With B-frames, frames are decoded in a different order than they are shown, so DTS and PTS differ.

10. **What is adaptive bitrate (ABR) and what's a bitrate ladder?**
    The same content encoded at several resolution/bitrate pairs (the ladder, e.g. 240p@400k ... 1080p@5M);
    the player picks one per segment based on bandwidth. Described by an HLS or DASH manifest.
