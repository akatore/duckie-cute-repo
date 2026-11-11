# Day 5 interview questions: HTML, JavaScript, XML

1. **`==` vs `===` in JavaScript?**
   `==` converts types before comparing (`0 == ""` is true); `===` compares value and type. Use `===`.

2. **`let`, `const`, `var`?**
   `let`/`const` are block-scoped; `const` can't be reassigned (the object can still change); `var` is
   function-scoped and hoisted. Prefer `const`, then `let`.

3. **What is the DOM?**
   The browser's tree of objects built from the HTML. JavaScript reads and changes it
   (`querySelector`, `createElement`, `appendChild`) and the page updates.

4. **What is XSS and how do you prevent it?**
   Cross-site scripting: attacker-controlled text ends up executed as HTML/JS in a victim's page.
   Escape output (`htmlspecialchars` in PHP), use `textContent` instead of `innerHTML`, and set a Content-Security-Policy.

5. **What does `async/await` do?**
   Syntax over Promises: `await` pauses the async function until the Promise settles without
   blocking the single JS thread (the event loop keeps handling other events).

6. **What is CORS?**
   Browsers block a page from reading responses from another origin unless the server allows it
   with `Access-Control-Allow-Origin`. It protects users, not servers.

7. **XML vs JSON: when would you pick XML?**
   When you need namespaces, schemas/validation (XSD), attributes, mixed text content, or a standard
   requires it (DASH MPD, RSS, SOAP, SVG). JSON for simple APIs.

8. **Why does `//Representation` return nothing on a DASH manifest?**
   The document has a default namespace. Element names are namespace-qualified, so register a prefix
   (`d`) and query `//d:Representation`.

9. **DOM parser vs SAX/streaming parser?**
   DOM loads the whole tree in memory (easy XPath, fine for manifests). SAX/pull parsers stream events
   with constant memory (for huge files, e.g. multi-GB XML dumps).

10. **What is adaptive bitrate streaming?**
    The same content in several bitrates/resolutions, cut into segments and described in a manifest
    (DASH `.mpd` or HLS `.m3u8`); the player switches quality per segment based on measured bandwidth and buffer.
