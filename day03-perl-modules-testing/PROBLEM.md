# Day 3 problem: `MediaName.pm` + unit tests

The media team names files by convention. Write a module that understands those names.

Files: `starter/lib/MediaName.pm` (implement) and `starter/t/media_name.t` (add tests).

## Naming convention

```
<Title>_S<season>E<episode>_<height>p_<codec>.<ext>     episode, e.g. Breaking_News_S01E02_1080p_h264.mkv
<Title>_<year>_<height>p_<codec>.<ext>                  movie,   e.g. Big.Buck.Bunny_2008_720p_hevc.mp4
```

- Title words are separated by `_` or `.`. Output title uses single spaces: `Breaking News`, `Big Buck Bunny`.
- Season: 1-2 digits, episode: 1-3 digits, year: 19xx or 20xx, height: 3-4 digits followed by `p`.
- Codec is one of `h264 h265 hevc av1 vp9`. `hevc` is reported as `h265`.
- Extension is one of `mkv mp4 ts webm mov`.
- Matching is case-insensitive; output codec, resolution and container are lowercase.
- A leading directory is ignored: `/media/tv/News_S01E01_720p_h264.ts` works.

## API

### `parse($filename)` returns a hash ref, or `undef` if the name doesn't match

```perl
parse('Breaking_News_S01E02_1080p_h264.mkv') ==
{ title => 'Breaking News', type => 'episode', season => 1, episode => 2,
  resolution => '1080p', height => 1080, codec => 'h264', container => 'mkv' }

parse('Big.Buck.Bunny_2008_720p_hevc.MP4') ==
{ title => 'Big Buck Bunny', type => 'movie', year => 2008,
  resolution => '720p', height => 720, codec => 'h265', container => 'mp4' }
```
Numbers must be numbers (`1`, not `"01"`).

### `group_by_show(@filenames)` returns a hash ref

Keys are episode titles; values are array refs of `parse` results sorted by season, then episode.
Movies and non-matching names are ignored.

Both functions must be importable: `use MediaName qw(parse group_by_show);`

## Acceptance criteria
- `bash check.sh` passes. It runs **your** tests (`t/*.t`, at least **10** passing assertions)
  and then a hidden grader test against the spec above.
- Run your own tests while you work with `cd starter && prove -lv t`.

## Stretch goals
- Add `format_name(\%info)`, the inverse of `parse`, and a round-trip test.
- Add a `t/00-compile.t` that only checks `use_ok('MediaName')`.
- Run `perlcritic lib/MediaName.pm` (`apt install libperl-critic-perl`) and fix what it reports.
