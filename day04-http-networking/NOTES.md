# Day 4: Networking and HTTP

## Why it matters for this job
Media is delivered over HTTP (progressive download, HLS, DASH). Services expose HTTP APIs and
health checks, and a 24x7 platform needs people who can debug "why is this request failing?".

## The layers you need to know

| Layer | Examples | What to remember |
|-------|----------|------------------|
| Application | HTTP, DNS, SSH, SMTP | Text or binary protocol on top of a transport |
| Transport | TCP, UDP | TCP = reliable ordered byte stream with a handshake; UDP = datagrams, no guarantee (used for RTP/live, DNS) |
| Network | IP (v4/v6), ICMP | Addresses and routing; `ping` uses ICMP |
| Link | Ethernet, Wi-Fi | MAC addresses |

**TCP 3-way handshake**: SYN, SYN-ACK, ACK. Then data flows. Closing: FIN/ACK on both sides.

**Ports**: 22 ssh, 53 dns, 80 http, 443 https, 3306 mysql, 5432 postgres. Ports < 1024 need root.

**What happens when you type a URL**: DNS lookup -> TCP connect to IP:443 -> TLS handshake ->
HTTP request -> server response -> browser parses HTML, fetches CSS/JS/images (more requests).

## Sockets (you know these from C)

C: `socket()`, `bind()`, `listen()`, `accept()`, `read()/write()`, `close()`.
Perl wraps them in `IO::Socket::INET`:

```perl
use IO::Socket::INET;
my $server = IO::Socket::INET->new(
    LocalPort => 8080, Listen => 10, Proto => 'tcp', ReuseAddr => 1,
) or die "listen failed: $!";
while (my $client = $server->accept) {     # blocks until a client connects
    my $request_line = <$client>;          # "GET /health HTTP/1.1\r\n"
    print $client "HTTP/1.1 200 OK\r\n...";
    close $client;
}
```

## HTTP in one page

Request:
```
GET /files?type=video HTTP/1.1\r\n
Host: localhost:8080\r\n
User-Agent: curl/8.5\r\n
Accept: */*\r\n
\r\n                                 <- blank line ends the headers
```

Response:
```
HTTP/1.1 200 OK\r\n
Content-Type: application/json\r\n
Content-Length: 15\r\n              <- exact number of BYTES in the body
Connection: close\r\n
\r\n
{"status":"ok"}
```

**Methods**: GET (read, safe, idempotent), POST (create/action), PUT (replace, idempotent),
PATCH (partial update), DELETE (idempotent), HEAD (headers only), OPTIONS.

**Status codes**:
- 2xx success: 200 OK, 201 Created, 204 No Content, 206 Partial Content (video seeking with `Range:`)
- 3xx redirect: 301 Moved Permanently, 302 Found, 304 Not Modified (cache)
- 4xx client error: 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 405 Method Not Allowed, 429 Too Many Requests
- 5xx server error: 500 Internal Server Error, 502 Bad Gateway, 503 Service Unavailable, 504 Gateway Timeout

**Important headers**: `Host`, `Content-Type`, `Content-Length`, `Range`/`Content-Range`,
`Cache-Control`, `ETag`/`If-None-Match`, `Location`, `Authorization`, `Set-Cookie`.

**HTTP versions**: 1.1 keep-alive connections; 2 multiplexes many requests over one TCP connection
(binary framing); 3 runs over QUIC (UDP). HTTPS = HTTP inside TLS.

**REST**: resources as URLs (`/files/42`), HTTP methods as verbs, JSON bodies, stateless requests.

## Cheat sheet

```bash
curl -v http://localhost:8080/health          # show request and response headers
curl -i URL                                   # response headers + body
curl -s -o /dev/null -w '%{http_code}\n' URL  # just the status code
curl -X POST -H 'Content-Type: application/json' -d '{"a":1}' URL
curl -r 0-1023 URL -o first_kb.bin            # Range request (how video seeking works)
printf 'GET /health HTTP/1.1\r\nHost: x\r\n\r\n' | nc localhost 8080   # raw HTTP by hand
dig example.com; host example.com             # DNS
ss -tlnp                                      # who is listening
sudo tcpdump -i lo -A port 8080               # watch the bytes on the wire
```

## JSON in Perl
`JSON::PP` is in core Perl: `encode_json($ref)` / `decode_json($text)`.
`JSON::PP->new->canonical->pretty` sorts keys and indents (stable output for tests and diffs).
