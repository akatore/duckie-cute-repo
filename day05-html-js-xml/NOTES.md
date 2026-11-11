# Day 5: HTML, JavaScript and XML

## Why it matters for this job
Internal dashboards and players are HTML + JavaScript. Streaming manifests (MPEG-DASH `.mpd`),
RSS/podcast feeds, and many config files are XML. You'll parse XML in Perl and show data in a page.

## HTML essentials

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Renditions</title>
  <style> table { border-collapse: collapse } td, th { border: 1px solid #999; padding: 4px } </style>
</head>
<body>
  <h1>Renditions</h1>
  <select id="type-filter"><option value="">all</option><option>video</option></select>
  <table id="reps"><thead><tr><th data-key="id">ID</th></tr></thead><tbody></tbody></table>
  <video src="clip.mp4" controls width="640"></video>
  <script src="app.js"></script>      <!-- scripts at the end: the DOM above already exists -->
</body>
</html>
```

Semantic tags: `header nav main section article footer`. Forms: `form input label button select`.
Always escape user data before inserting it as HTML (`&` -> `&amp;`, `<` -> `&lt;`), or use `textContent`.

## JavaScript for a C programmer

```js
const xs = [3, 1, 2];               // const = can't rebind; let = block-scoped variable; avoid var
xs.sort((a, b) => a - b);           // arrow function; sort() without a comparator sorts as STRINGS
const big = xs.filter(x => x > 1).map(x => x * 10);
const rep = { id: "v1", bandwidth: 5000000 };      // object = hash
console.log(`id=${rep.id}`);        // template string
1 == "1"   // true  (type coercion)  -> always use === and !==
```

### DOM and events
```js
const tbody = document.querySelector("#reps tbody");
const tr = document.createElement("tr");
const td = document.createElement("td");
td.textContent = rep.id;            // textContent never interprets HTML: safe
tr.appendChild(td); tbody.appendChild(tr);

document.querySelector("#type-filter").addEventListener("change", ev => render(ev.target.value));
document.querySelectorAll("th").forEach(th => th.addEventListener("click", () => sortBy(th.dataset.key)));
```

### fetch and async/await
```js
async function load() {
  const res = await fetch("representations.json");   // HTTP GET, relative to the page URL
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return await res.json();
}
load().then(data => render(data)).catch(err => console.error(err));
```
JavaScript in the browser is single-threaded with an event loop: `await` gives control back
instead of blocking. `fetch` of a `file://` URL is blocked by browsers, so **serve the folder over HTTP**:
`python3 -m http.server 8000` (or `php -S 0.0.0.0:8000`) and open `http://<host>:8000/`.

Debugging: browser DevTools (F12): Console for errors, Network tab for requests/status codes.

## XML essentials

```xml
<?xml version="1.0" encoding="UTF-8"?>
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011" type="static">
  <Period>
    <AdaptationSet contentType="video" mimeType="video/mp4">
      <Representation id="v720" bandwidth="2800000" width="1280" height="720"/>
    </AdaptationSet>
  </Period>
</MPD>
```

- Elements, attributes, text; exactly one root; must be well-formed (every tag closed, case-sensitive).
- **Namespaces**: `xmlns="..."` puts all elements in that namespace. XPath `//Representation`
  then finds **nothing**; you must register a prefix. (This trips up everyone, so expect it.)
- XML vs JSON: XML has attributes, namespaces, schemas (XSD), mixed content; JSON is simpler and maps
  directly to arrays/hashes.
- Check well-formedness: `xmllint --noout file.xml` (`apt install libxml2-utils`).

### XPath cheat sheet
`/MPD/Period` (absolute path), `//Representation` (anywhere), `@bandwidth` (attribute),
`Representation[@height > 700]` (predicate), `..` (parent), `count(//Representation)`.

### XML::LibXML in Perl
```perl
use XML::LibXML;
my $doc = XML::LibXML->load_xml(location => 'manifest.mpd');
my $xc  = XML::LibXML::XPathContext->new($doc);
$xc->registerNs(d => 'urn:mpeg:dash:schema:mpd:2011');     # the namespace fix
for my $set ($xc->findnodes('//d:AdaptationSet')) {
    for my $rep ($xc->findnodes('d:Representation', $set)) {  # relative to $set
        print $rep->getAttribute('id'), "\n";
    }
}
```

## DASH in one paragraph
A video is encoded at several qualities (**representations**: e.g. 240p/400 kbps ... 1080p/5 Mbps)
and cut into short segments. The manifest (`.mpd`, XML) lists them, grouped in **adaptation sets**
(video, audio per language, subtitles). The player measures bandwidth and switches representation
per segment: **adaptive bitrate streaming (ABR)**. HLS is Apple's equivalent with `.m3u8` text playlists.
