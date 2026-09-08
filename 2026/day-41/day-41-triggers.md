# Day 41 – Triggers & Matrix Builds

## Overview

Expanded my GitHub Actions practice by working with pull-request, scheduled, and manual triggers. I also explored matrix jobs, excluded combinations, and tested how failures affect other jobs.

**Practice repository:** `github-actions-practice`  
**Workflow location:** `.github/workflows/` at the repository root.

## Task 1: Pull-Request Trigger

Created `pr-check.yml` to check pull requests targeting `main`.

| Setting | Meaning |
| --- | --- |
| `pull_request` | Runs for selected PR events |
| `types: [opened, synchronize]` | Runs when a PR opens or its source commits change |
| `branches: [main]` | Filters the target branch |
| `GITHUB_HEAD_REF` | Provides the PR’s source branch name |

The step prints **PR check running for branch: <branch name>**. I tested it by pushing a branch and opening a PR, then checked the result on the PR page.

**Learning:** `synchronize` covers code updates; changing a PR’s title or description is an `edited` event.

## Task 2: Scheduled Trigger

Added a cron schedule for a daily run.

| Schedule | Cron expression |
| --- | --- |
| Every day at midnight UTC | `0 0 * * *` |
| Every Monday at 9 AM UTC | `0 9 * * 1` |

The five fields are **minute, hour, day of month, month, day of week**.

Scheduled workflows run from the default branch. Execution can be delayed, so the scheduled time is not an exact start-time guarantee.

## Task 3: Manual Trigger

Created `manual.yml` with `workflow_dispatch` and an `environment` input for `staging` or `production`.

Launched it through **Actions → select workflow → Run workflow** and checked the printed input. Its value is available through `inputs.environment`.

**Learning:** The workflow file must exist on the default branch to enable manual triggering. Printing an environment name does not deploy anything.

## Task 4: Matrix Builds

Created `matrix.yml` to install Python and print its version across multiple environments.

| Matrix configuration | Job executions |
| --- | --- |
| Three Python versions on one OS | **3** |
| Three Python versions × two operating systems | **6** |
| Six combinations minus one excluded combination | **5** |

Example using Ubuntu and Windows:

| Python version | Ubuntu | Windows |
| --- | --- | --- |
| `3.10` | Run | Excluded in Task 5 |
| `3.11` | Run | Run |
| `3.12` | Run | Run |

Jobs can run in parallel, subject to runner availability and concurrency limits.

**YAML lesson:** Quote version strings as `"3.10"`, `"3.11"`, and `"3.12"`. An unquoted `3.10` can be interpreted as the number `3.1`.

## Task 5: Exclude & Fail-Fast

Practiced excluding one OS/version combination and intentionally failing one matrix job.

| Setting | Effect |
| --- | --- |
| `matrix.exclude` | Removes matching combinations |
| `strategy.fail-fast: true` — default | A non-tolerated failure cancels queued and running jobs in that matrix |
| `strategy.fail-fast: false` | Other matrix jobs continue despite one failing |

**Learning:** `fail-fast: false` provides results for the remaining combinations. It does not turn the failed job green or ignore its error. `continue-on-error` is a separate setting.

## Completion Summary

- Practiced checks on PRs targeting `main`.
- Added a daily schedule and learned cron expressions.
- Ran a manual workflow with an input.
- Expanded Python jobs across operating systems.
- Practiced exclusions and compared failure behavior.


## References

- [GitHub Actions workflow triggers](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows)
- [Running job variations with a matrix](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/run-job-variations)
