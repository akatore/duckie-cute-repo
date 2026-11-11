# Day 5 problem: DASH manifest to a web page

Two parts: a Perl XML parser and a small HTML/JS viewer.

## Part 1: `starter/mpd2json.pl`

```bash
perl starter/mpd2json.pl starter/manifest.mpd > starter/representations.json
```

Print a JSON array with one object per `Representation`, in document order:

| key | from | notes |
|-----|------|-------|
| `id` | `Representation/@id` | string |
| `type` | `AdaptationSet/@contentType`, else the part before `/` of `@mimeType` | `video` / `audio` |
| `codecs` | `Representation/@codecs`, else inherited from `AdaptationSet/@codecs` | string |
| `bandwidth` | `Representation/@bandwidth` | **number** |
| `width`, `height` | `Representation` | numbers, **video only** |
| `sample_rate` | `Representation/@audioSamplingRate` | number, **audio only** |

Example element of the output:
```json
{ "id": "v1080", "type": "video", "codecs": "avc1.640028", "bandwidth": 5000000, "width": 1920, "height": 1080 }
```

Requirements: use `XML::LibXML` with XPath (handle the default namespace!), use `JSON::PP`, and die
with a clear message if the file is missing or not well-formed XML.

## Part 2: `starter/index.html`

A page that:
1. `fetch`es `representations.json` (same folder) and renders a table: ID, type, codecs, bandwidth (shown in kbps), resolution (`1920x1080`, or the sample rate for audio).
2. Has a `<select>` to filter by type: all / video / audio.
3. Sorts by a column when its header is clicked (numeric columns numerically).
4. Shows a readable error message in the page if the fetch fails.
5. Uses `textContent` (not `innerHTML`) for data values.

View it: `cd starter && python3 -m http.server 8000`, then open the playground URL for port 8000
(or copy `index.html` + `representations.json` to Windows and serve them the same way).

## Acceptance criteria
`bash check.sh` passes (it checks Part 1 exactly and Part 2 for the required building blocks).
Then check Part 2 by hand in a browser: filter, sort, and rename the JSON file to see the error message.

## Stretch goals
- Show the total duration from `MPD/@mediaPresentationDuration` (`PT10M34.6S` is ISO 8601).
- Print an HLS master playlist (`#EXT-X-STREAM-INF:BANDWIDTH=...,RESOLUTION=...,CODECS="..."`) from the same data.
- Validate the manifest with `xmllint --noout`.
