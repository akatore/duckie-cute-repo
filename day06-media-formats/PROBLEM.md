# Day 6 problem: `probe_report.pl`

## Step 1: generate test media
```bash
bash starter/gen_clips.sh starter/clips
ls -la starter/clips
```
Read `gen_clips.sh` and explain to yourself (out loud) what every option does.
Then look at each file with `ffprobe -hide_banner <file>`.

## Step 2: write `starter/probe_report.pl`

```bash
perl starter/probe_report.pl starter/clips/*
```

For each file, run `ffprobe` (JSON output, list-form `open`, no shell) and print **one line**:

```
<basename> | container=<format_name> | video=<codec> <w>x<h> <fps>fps | audio=<codec> <rate>Hz <ch>ch | duration=<secs>s | bitrate=<kbps> kb/s
```

- Use the **first** video stream and the **first** audio stream. If there is none, print `video=none` / `audio=none`.
- `fps` is computed from `r_frame_rate` (`"25/1"`, `"30000/1001"`) and printed with 2 decimals: `25.00fps`.
- `duration` with 2 decimals; `bitrate` = `format.bit_rate / 1000`, as an integer.
- If a file can't be probed, print a warning to stderr, continue with the next file, and exit with status 1 at the end.

Example (your bitrates will differ a bit):
```
clip_h264.mp4 | container=mov,mp4,m4a,3gp,3g2,mj2 | video=h264 1280x720 25.00fps | audio=aac 44100Hz 1ch | duration=5.00s | bitrate=412 kb/s
tone.wav | container=wav | video=none | audio=pcm_s16le 48000Hz 2ch | duration=3.00s | bitrate=1536 kb/s
```

## Step 3: answer in `starter/ANSWERS.md` (short answers, your own words)
1. Why is `tone.wav` so much bigger per second than `clip_h264.mp4`, even though the MP4 also has video?
2. Remux `clip_h264.mp4` to MKV with `-c copy`. How long did it take compared with a transcode, and did the codec change?
3. Run `ffprobe -show_frames` on `clip_h264.mp4`: how many I-frames are there and why? Re-encode with `-g 25` and count again.
4. Try `ffmpeg -i clip_vp9.webm -c copy out.mp4` and then the same into `out.ts` and `out.wav`. Which work, which fail, and what does that tell you about containers and the codecs they can carry?

## Acceptance criteria
`bash check.sh` passes (it generates fresh clips, runs your script and checks every field it can check exactly).

## Stretch goals
- Add `--json` to print the same information as a JSON array (you'll need this in the capstone).
- Flag "problems": no audio, odd resolution (not divisible by 2), fps above 60, video not in `yuv420p`.
- Write the HLS command from NOTES.md and inspect the `.m3u8` it produces.
