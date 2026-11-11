# Day 10: Mock interview (60 minutes)

Ask a friend to play the interviewer with this script, or do it alone, timing yourself and answering out loud.
Questions come from `QUESTION_BANK.md`; the interviewer can pick others.

| Time | Part | What to do |
|------|------|------------|
| 0-5 | Intro | "Tell me about yourself" in 90 seconds: studies, scientific work, what you built this week, why this role. |
| 5-10 | Project | The 2-minute capstone pitch, then the interviewer asks two follow-up "why" questions. |
| 10-25 | Rapid fire | 10 questions from the bank, about 90 seconds each, mixed topics. |
| 25-45 | Live problem | One of the problems below, thinking out loud, on paper or in a terminal. |
| 45-55 | Behavioural | Two STAR questions. |
| 55-60 | Your questions | Ask two questions to the interviewer. |

## Live problems (pick one)

1. **Log analysis (Perl or shell).** "Given an access log, print the 3 slowest endpoints by average response time;
   the response time in ms is the last field." Talk about parsing, hashes of sums and counts, sorting, and what happens with a 50 GB file.
2. **Media sanity check (Perl).** "Given ffprobe JSON for a file, list problems: no audio, resolution not divisible by 2,
   frame rate above 60, duration under one second." Talk about structure, tests, and how it would run on 1 million files.
3. **C.** "Write `int count_keyframes(const uint8_t *buf, size_t len)` that counts H.264 IDR NAL units in an Annex B stream
   (start code `00 00 01` or `00 00 00 01`, NAL type = `byte & 0x1F`, IDR = 5)." Talk about bounds checks and testing.
4. **SQL.** "Using the Day 8 schema: for each container, the average duration and the share of files that have more than one audio stream."

## Self-assessment after the mock
- Did I clarify the question before answering?
- Did I talk while thinking?
- Were my answers under 2 minutes?
- Did I give at least one concrete example from my own work?
- What 3 things do I review tomorrow?
