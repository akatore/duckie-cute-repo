# Day 9 problem: the professional workflow, hands on

Four small tasks. Put the files in `starter/`.

## 1. Merge conflict lab
```bash
bash starter/conflict_lab.sh ~/conflict-lab
cd ~/conflict-lab
git log --oneline --graph --all
git merge feature/welcome          # conflict!
```
Resolve it so that `greet.pl`:
- keeps the usage check from `feature/welcome`, and
- prints exactly `Hello, <name>! Welcome to the media team.` (formal greeting from `main` + welcome text from the feature).

Then run `perl greet.pl Asha`, `git add`, and `git commit` to finish the merge. Look at the graph again.

## 2. CI workflow: `starter/.github/workflows/ci.yml`
A GitHub Actions workflow for your prep repository that:
- runs on `push` to `main` and on every `pull_request`,
- uses `ubuntu-latest`, checks out the code, installs the needed packages with `apt-get`,
- builds and runs the C tests with `make ... test` (Day 7) and the Perl tests with `prove` (Day 3).

Push it to your GitHub repo, open the **Actions** tab and get a green run. Then break a test on a branch, open a pull request, and watch it go red.

## 3. Operations: `starter/mediacatalog.service` and `starter/healthcheck.sh`
- A systemd unit that runs the Day 4 server as a non-root user, restarts it on failure, and starts on boot.
- `healthcheck.sh URL [TIMEOUT]`: requests the URL with a timeout. Exit `0` and print `OK ...` if it answers
  HTTP 2xx with a body containing `"ok"`; exit `2` and print `CRITICAL ...` to stderr if it can't connect or gets a non-2xx;
  exit `1` (`WARNING ...`) if the body is unexpected.

If your playground VM runs systemd (`ps -p 1 -o comm=` prints `systemd`), install the unit for real:
copy your server to `/opt/mediacatalog/`, `sudo cp mediacatalog.service /etc/systemd/system/`,
`sudo systemctl enable --now mediacatalog`, then `kill -9` the server process and watch systemd restart it.

## 4. Code review: `starter/review/upload_handler.pl`
A teammate opened a pull request with this file. Review it as if for real: write `starter/REVIEW.md` with
**at least 6 findings**, each as a bullet: line number, the problem, why it matters, and a suggested fix.
Rank them: blocking issues first, nits last. (Don't fix the file; reviewing is the exercise.)

## Acceptance criteria
`bash check.sh` passes (`LAB=/path/to/conflict-lab bash check.sh` if you used another folder).
Compare your review with `solutions/day09/REVIEW.md` afterwards: did you find the security issues?
