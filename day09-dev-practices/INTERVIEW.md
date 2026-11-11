# Day 9 interview questions: professional practices

1. **What is CI/CD and why do teams use it?**
   CI builds and tests every change automatically, so integration problems show up within minutes, not at release time.
   CD makes every green build deployable (or deploys it), in small, low-risk steps with quick rollback.

2. **What do you look for when reviewing code?**
   Correctness and edge cases, error handling, security (injection, validation, secrets), tests, readability, and
   operational concerns (logging, performance, config). I keep comments specific and kind and mark nits as nits.

3. **How do you handle a review comment you disagree with?**
   Explain my reasoning with facts (benchmarks, docs, tests), ask questions to understand theirs, and if it's still open,
   pick the team convention or ask a third person. It's about the code, not about me.

4. **How do you resolve a merge conflict?**
   Read both sides to understand each change's intent, write the combined correct version, remove the markers,
   run the tests, then `git add` and commit (or `rebase --continue`).

5. **A production service is down at 3am. What do you do?**
   Acknowledge the alert, check the health/monitoring dashboard and recent deploys, look at logs (`journalctl`),
   restore service first (restart, roll back, fail over), communicate status, and find the root cause afterwards in a blameless post-mortem.

6. **What does 99.99% uptime mean in practice?**
   About 53 minutes of downtime per year. It requires redundancy (several instances, load balancer with health checks),
   rolling deploys, monitoring and alerting, and on-call people; it's not achievable with a single server.

7. **What does systemd's `Restart=on-failure` do, and is it enough?**
   systemd restarts the process if it exits with an error or is killed. It doesn't detect a process that hangs while still
   running; for that you need health checks (or a watchdog) and monitoring.

8. **What makes a good commit?**
   One logical change, builds and passes tests on its own, short subject in imperative mood, a body explaining why,
   and a reference to the issue.

9. **How would you find which commit introduced a bug?**
   `git bisect`: mark a known good and a known bad commit; git checks out the midpoint and you test, in O(log n) steps.
   `git bisect run ./test.sh` automates it.

10. **Unit vs integration vs end-to-end tests?**
    Unit tests check one function in isolation, quickly. Integration tests check that components work together (loader + DB).
    End-to-end tests drive the whole system through its real interface (HTTP). Many unit, fewer integration, few end-to-end.
