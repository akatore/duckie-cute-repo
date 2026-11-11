# Day 4 interview questions: networking and HTTP

1. **TCP vs UDP?**
   TCP: connection-oriented, reliable, ordered, flow and congestion control (HTTP/1.1, HTTP/2, SSH).
   UDP: connectionless, no delivery guarantee, low latency (DNS, RTP live streaming, QUIC/HTTP/3 builds reliability on top).

2. **What happens when you open `https://example.com`?**
   DNS resolves the name; TCP handshake to port 443; TLS handshake (certificate check, key exchange);
   HTTP GET; server responds; browser parses HTML and fetches sub-resources.

3. **401 vs 403?**
   401: not authenticated (who are you?). 403: authenticated but not allowed.

4. **502 vs 503 vs 504?**
   502: the proxy got an invalid response from the upstream. 503: the service is unavailable (overloaded,
   maintenance). 504: the proxy timed out waiting for the upstream.

5. **What is idempotent? Which methods are?**
   Doing it twice has the same effect as once. GET, HEAD, PUT, DELETE, OPTIONS are; POST is not.

6. **How does a video player seek in an MP4 over HTTP?**
   It sends `Range: bytes=START-END` and the server replies `206 Partial Content` with `Content-Range`.

7. **Why does `Content-Length` need to be exact, and what if you don't know it?**
   The client uses it to know where the body ends on a kept-alive connection. If unknown, use
   `Transfer-Encoding: chunked` or close the connection after the body.

8. **What does `Listen => 10` / `listen(fd, 10)` mean?**
   The size of the queue of connections that completed the handshake but haven't been `accept()`ed yet.

9. **What is `SO_REUSEADDR` for?**
   Lets the server bind to a port that still has connections in TIME_WAIT, so a restart doesn't fail with "Address already in use".

10. **How would you debug "the API is slow"?**
    Reproduce with `curl -w '%{time_namelookup} %{time_connect} %{time_starttransfer} %{time_total}\n'`
    to split DNS / connect / server time; check server logs and metrics (CPU, memory, DB query time); then profile the slow part.
