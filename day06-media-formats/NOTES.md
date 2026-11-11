# Day 6: Video and audio formats, encodings and containers

## Why it matters for this job
This is probably the team's core domain. You should be able to say what's inside a file, why it
won't play, and how to convert it, using `ffprobe` and `ffmpeg`.

## The one distinction everyone tests: container vs codec

- **Codec** (coder/decoder): *how* the audio or video is compressed. H.264, H.265/HEVC, AV1, VP9, MPEG-2 (video); AAC, MP3, Opus, AC-3, FLAC, PCM (audio).
- **Container** (format): the *box* that holds one or more encoded streams plus timing, metadata,
  subtitles, chapters. MP4, MKV, WebM, MPEG-TS, MOV, WAV, Ogg.

Analogy for a C programmer: the codec is the compression algorithm (like zlib); the container is
the archive format (like tar) that interleaves several compressed streams and adds an index.

| Container | Typical codecs | Used for |
|-----------|----------------|----------|
| MP4 (`.mp4`, `.m4a`) | H.264/H.265/AV1 + AAC | Web, mobile, downloads; `moov` atom = index |
| MKV (`.mkv`) | almost anything | Archiving, many tracks/subtitles |
| WebM (`.webm`) | VP8/VP9/AV1 + Vorbis/Opus | Royalty-free web video (a Matroska subset) |
| MPEG-TS (`.ts`) | H.264/MPEG-2 + AAC/MP2/AC-3 | Broadcast, HLS segments; 188-byte packets, survives data loss |
| WAV (`.wav`) | PCM (uncompressed) | Audio production; RIFF chunks |

## Key concepts

- **Resolution**: width x height (1920x1080 = "1080p"; `p` = progressive, `i` = interlaced).
- **Frame rate**: frames per second (24, 25, 29.97 = 30000/1001, 50, 60). ffprobe shows it as a fraction.
- **Bitrate**: bits per second. Quality depends on bitrate *and* codec: HEVC needs roughly half the bitrate of H.264 for similar quality.
  CBR (constant) vs VBR (variable); CRF in x264 = constant quality mode.
- **Frame types**: I-frame (keyframe, self-contained), P-frame (predicted from previous), B-frame (bidirectional).
  **GOP** = group of pictures from one keyframe to the next. You can only start decoding/seeking/cutting at a keyframe.
  Streaming uses fixed GOPs (e.g. 2 s) so every segment starts with a keyframe.
- **Chroma subsampling**: `yuv420p` stores colour at a quarter of the resolution; required by most players.
- **Audio**: sample rate (44.1 kHz CD, 48 kHz video), bit depth (16/24-bit), channels (mono, stereo, 5.1).
  PCM bitrate = sample_rate x bits x channels: 48000 x 16 x 2 = 1536 kb/s. AAC at 128 kb/s sounds about as good.
- **Lossy vs lossless**: AAC/MP3/Opus/H.264 throw information away; FLAC/PCM/FFV1 don't.
- **Transcoding** = decode + re-encode (slow, quality loss). **Remuxing** = copy streams into a new container (`-c copy`, fast, lossless).
- **Timestamps**: PTS (presentation) vs DTS (decoding) differ when B-frames exist. A/V sync issues are often timestamp problems.
- **Streaming**: HLS (`.m3u8` + TS/fMP4 segments, Apple) and DASH (`.mpd` + fMP4 segments). Both are adaptive bitrate over plain HTTP.

## ffprobe

```bash
ffprobe -hide_banner clip.mp4                                         # human summary
ffprobe -v error -print_format json -show_format -show_streams clip.mp4   # machine-readable (use this from scripts)
ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height,r_frame_rate -of csv=p=0 clip.mp4
ffprobe -v error -select_streams v:0 -show_frames -show_entries frame=pict_type -of csv clip.mp4 | head   # I/P/B frames
```

Relevant JSON fields: `format.format_name`, `format.duration`, `format.bit_rate`,
`streams[].codec_type` (`video`/`audio`), `codec_name`, `width`, `height`, `r_frame_rate` (`"25/1"`),
`sample_rate`, `channels`. Note that numbers like `duration` and `sample_rate` come as **strings**.

## ffmpeg

```bash
# generate synthetic test media (no downloads needed)
ffmpeg -f lavfi -i testsrc2=size=1280x720:rate=25:duration=5 -f lavfi -i sine=frequency=440:duration=5 \
       -c:v libx264 -pix_fmt yuv420p -c:a aac -shortest test.mp4

ffmpeg -i in.mkv -c copy out.mp4                         # remux (no re-encode)
ffmpeg -i in.mp4 -c:v libx264 -crf 23 -preset fast -c:a aac -b:a 128k out.mp4   # transcode
ffmpeg -i in.mp4 -vf scale=-2:480 small.mp4               # resize, keep aspect ratio
ffmpeg -ss 00:00:10 -i in.mp4 -t 5 -c copy cut.mp4        # cut (snaps to keyframes with -c copy)
ffmpeg -i in.mp4 -vn -c:a copy audio.m4a                  # extract audio
ffmpeg -i in.mp4 -ss 2 -frames:v 1 thumb.jpg              # thumbnail
ffmpeg -i in.mp4 -c:v libx264 -g 50 -keyint_min 50 -hls_time 2 -f hls out.m3u8   # HLS with 2s GOPs at 25fps
```

`-i` input, `-c:v`/`-c:a` codec for video/audio, `-b:v` bitrate, `-vf` video filter, `-y` overwrite.

## Running external programs safely from Perl

```perl
# list form: no shell, so spaces and ; in filenames can't inject commands
open my $fh, '-|', 'ffprobe', '-v', 'error', '-print_format', 'json', '-show_format', '-show_streams', $file
    or die "cannot run ffprobe: $!";
my $json = do { local $/; <$fh> };      # slurp all output
close $fh or die "ffprobe failed (exit " . ($? >> 8) . ")\n";   # close on a pipe reports the exit status
my $info = decode_json($json);
```
Avoid `` `ffprobe $file` `` and `system("ffprobe $file")` with interpolated strings.
