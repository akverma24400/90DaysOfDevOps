# Day 44 – Secrets, Artifacts & Running Real Tests in CI

Simple solutions for Day 44 of #90DaysOfDevOps.

## Goal

Use GitHub Secrets, share files between jobs, run real tests, and cache dependencies.

The workflow and script code is maintained separately. This README contains the task summaries and learning notes.

## Task 1: GitHub Secrets

Go to **Settings → Secrets and variables → Actions → New repository secret**.
Create `MY_SECRET_MESSAGE` with a harmless practice value.

## Task 2: Use Secrets as Environment Variables

Pass the secret to a workflow step as an environment variable.

Check whether the environment variable is non-empty and print only whether the secret is set, without exposing its value.

**What happens if a secret is printed?** GitHub normally replaces recognized secret values with `***`. For the masking experiment, use only a harmless practice value and remove the temporary print step afterward.

**Why should secrets never be printed?** Logs can be read or shared. Masking is not guaranteed for transformed values, so avoid logging real passwords or tokens.

Also add these repository secrets for Day 45:

| Secret | Value to store |
| --- | --- |
| `DOCKER_USERNAME` | Your Docker Hub username |
| `DOCKER_TOKEN` | Your Docker Hub access token |

## Task 3: Upload Artifacts

Generate a report file in a workflow and save it using `actions/upload-artifact`.

After a successful run, open its summary and download **day-44-report** from **Artifacts**.

## Task 4: Download Artifacts Between Jobs

To share a report between jobs:

1. The `upload` job creates and uploads the report.
2. `needs: upload` makes the `download` job wait for it.
3. The second job downloads the named artifact and prints its contents.

**When are artifacts useful?** Use them for test reports, logs, compiled applications, and build outputs needed by another job. Separate hosted jobs have separate runners, so local files do not automatically carry over.

## Task 5: Run Real Tests in CI

Add a script from earlier Shell or Python practice to the repository. The workflow should check out the code, install any required dependencies, and run the script. A non-zero exit code should fail the job.

Bash is already installed on the Ubuntu runner; no additional dependencies are needed.

**Make it fail:** Intentionally break the script’s logic, then commit and push. Check that a failing test returns a non-zero exit code and the job turns red.

**Fix it:** Correct the script, then commit and push. Check that all tests pass and the job turns green. Save screenshots of both runs.

**Troubleshooting:** `npm install` needs a `package.json`. This Shell example does not use npm. Use `run:` for shell commands and `uses:` for actions.

## Task 6: Cache Dependencies

Use `actions/cache` in a workflow that installs Python dependencies. Cache pip downloads and include the dependency file hash in the cache key.

Run it twice on the same branch without changing the files. Wait for the first run to finish successfully before starting the second.

| Run | Expected cache result | Installation time (`real`) |
| --- | --- | --- |
| First run with a new key | Miss; cache saved after successful job | Fill in: ___ seconds |
| Second run | Hit; cache restored | Fill in: ___ seconds |

**What is cached?** Pip's downloaded package data and wheel cache in `~/.cache/pip`. Installed packages are not cached by this workflow, so the install step must still run.

**Where is it stored?** In GitHub Actions cache storage on GitHub-owned cloud infrastructure. A matching run restores it into the runner's `~/.cache/pip` directory.

**Why use a hash?** Changing `requirements.txt` changes the cache key.

**Will it always be faster?** No. For small dependencies, downloading and restoring the cache may take similar time. Record actual results rather than assuming a speed improvement.

View saved caches under **Actions → Caches**.

## Artifacts vs Cache

| Feature | Purpose | Example |
| --- | --- | --- |
| Artifact | Save outputs for download or another job | Test report |
| Cache | Reuse files to reduce repeated work | pip package downloads |

## Verification Checklist

Mark these after checking your own GitHub Actions runs:

- [ ] Secret check prints `The secret is set: true`.
- [ ] Dummy-secret masking observed; temporary print step removed.
- [ ] Docker Hub secrets added.
- [ ] Report artifact downloaded from the run summary.
- [ ] Second job downloads and prints the report.
- [ ] Broken test produces a red run.
- [ ] Fixed test produces a green run.
- [ ] Cache workflow run twice and actual timings recorded.

## References

- [GitHub Secrets](https://docs.github.com/en/actions/concepts/security/secrets)
- [Workflow artifacts](https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
- [Dependency caching](https://docs.github.com/en/actions/concepts/workflows-and-actions/dependency-caching)

**Author:** Akash Verma | **Challenge:** #90DaysOfDevOps
