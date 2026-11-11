# Day 10: Capstone, presenting your work, and interview communication

The job asks for "proficiency in English, excellent communication skills and strong work ethic"
and "proof of experience in scientific work". Today you finish the project **and** practise talking about it.

## Building the capstone: suggested order (about 3 hours)
1. `lib/MediaProbe.pm` until `make test` is green (30 min). Copy `probe` from Day 6.
2. `bin/scan.pl` and run it on Day 6's clips: `perl bin/scan.pl ../../day06-media-formats/starter/clips` (20 min).
3. Copy Day 8's schema and loader; load the scan output by hand with `sqlite3` + `load_catalog.pl` (15 min).
4. Server: copy Day 4, add DBI and `/catalog`, test with `curl` (45 min).
5. `run_all.sh`: automate exactly what you did by hand in steps 2-4 (30 min).
6. README and CI (30 min). Push to a new GitHub repo and get a green Actions run.

## The 2-minute project pitch (template)

1. **Problem** (1 sentence): "Media teams need to know what's inside thousands of files: codecs, resolutions, durations."
2. **What I built** (2 sentences): "A Perl pipeline that probes files with ffprobe, stores the metadata in SQLite, and serves it over an HTTP JSON API, with a C tool for WAV analysis."
3. **How it works** (walk the diagram in your README, 30 seconds).
4. **One hard part and how you solved it** (the most valuable 30 seconds): e.g. "XPath returned nothing on the DASH manifest because of the default namespace; I registered a prefix" or "My WAV parser broke on files with an odd-sized LIST chunk; I found it with a unit test and handled the pad byte."
5. **Quality**: "Unit tests with Test::More, an end-to-end script, CI on GitHub Actions, placeholders against SQL injection."
6. **What I'd do next** (1 sentence).

Practise until you can do it without notes. Then do a 30-second version.

## Answering behavioural questions: STAR

**S**ituation, **T**ask, **A**ction (most of the time goes here, say "I", not "we"), **R**esult (with a number if possible, plus what you learned).

Prepare 5 stories from university, projects, or this prep week, and reuse them:
- A difficult bug you tracked down.
- Learning something new fast (this whole kit: Perl and ffmpeg in 10 days!).
- Working in a team / a disagreement you resolved.
- A mistake you made and what you changed afterwards.
- Your scientific work: thesis, lab project, paper. How you formed a hypothesis, measured, and drew conclusions.

## Technical interview communication
- **Think out loud.** Silence is the worst signal. "I'm thinking about whether a hash or a sorted array fits better..."
- **Clarify first.** "Can the log be bigger than memory? Should ties be broken?" Good engineers ask.
- **Brute force, then improve.** Say the simple solution and its complexity, then optimise.
- **Test your own answer** with a small example and an edge case before saying "done".
- **Don't know something?** Say so, then reason: "I haven't used HEVC in TS, but I'd check it with ffprobe and the muxer docs." Honesty plus a method beats guessing.
- **Ask good questions at the end:** "What does a typical first month look like for an intern?", "How are code reviews done in the team?",
  "What does on-call look like for the 24x7 services?", "Which parts of the stack are in Perl vs C?"

## English tips for technical talk
- Short sentences. One idea per sentence.
- Signpost: "There are two parts to this. First... Second..."
- Useful phrases: "Let me make sure I understand the question...", "My assumption is...", "The trade-off here is...",
  "Could you repeat the last part?", "To summarise..."
- Practise saying key terms aloud: *idempotent, latency, throughput, concurrency, codec, container, transaction, regression*.

## Work ethic signals interviewers notice
Showing a finished project with tests and a README; a git history with sensible commits; being on time;
following up on what you said you'd check; admitting what you don't know and how you'd learn it.
