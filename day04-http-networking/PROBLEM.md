# Day 4 problem: a minimal HTTP/JSON server in Perl

Write `starter/server.pl` using only `IO::Socket::INET` and `JSON::PP` (no web framework).

```bash
perl starter/server.pl 8080 /path/to/media     # args: PORT (default 8080), MEDIA_DIR (default ./media)
curl -i http://localhost:8080/health
```

## Routes

| Request | Status | Body |
|---------|--------|------|
| `GET /health` | 200 | `{"status":"ok"}` |
| `GET /files` | 200 | JSON array of the regular file names in MEDIA_DIR, sorted, hidden files (starting with `.`) excluded |
| any other path | 404 | `{"error":"not found"}` |
| non-GET method on any path | 405 | `{"error":"method not allowed"}` plus header `Allow: GET` |

## Rules
- Ignore a query string: `/files?x=1` behaves like `/files`.
- Every response has `Content-Type: application/json`, a correct `Content-Length` and `Connection: close`.
- Use `\r\n` line endings in the status line and headers.
- Read the request line **and** the headers (up to the blank line) before responding.
- The server keeps running after each request (handle one client at a time; that is fine today).
- Log one line per request to STDOUT, e.g. `GET /files 200`.

## Acceptance criteria
`bash check.sh` passes. It starts your server on port 18084 with a temporary media folder and uses `curl`.

## Stretch goals
- `GET /files/<name>` streams the file with the right `Content-Type` (`video/mp4`, `video/x-matroska`, ...).
- Support `Range: bytes=0-1023` and reply `206 Partial Content`.
- Handle several clients at once with `fork` (remember to reap children: `$SIG{CHLD} = 'IGNORE'`).
- Watch your own traffic with `sudo tcpdump -i lo -A port 8080`.
