# Day 47 – Advanced Triggers: PR Events, Cron Schedules & Event-Driven Pipelines

**90DaysOfDevOps | Akash Verma | TrainWithShubham**

## Goal

Practice PR validation, scheduled health checks, selective triggers, and workflows driven by other workflows or external systems.

Workflow code is maintained in a separate folder. This document explains the behavior, key concepts, and troubleshooting for each task. Live results still need to be verified; the deployment exercise is a demonstration only.

## 1. Pull request lifecycle

File: `.github/workflows/pr-lifecycle.yml`

`opened` means a new PR, `synchronize` means its head branch received an update, `reopened` means a closed PR was opened again, and `closed` covers both merged and unmerged closures. The merged flag distinguishes these outcomes.

PR text is passed through environment variables instead of inserted directly into shell code.

## 2. PR validation

File: `.github/workflows/pr-checks.yml`

The jobs run independently. The file-size rule defines 1 MB as **1,000,000 bytes** and inspects added or modified files in the PR, including renamed destinations. Deleted files are excluded. The size check reads Git blobs without executing PR code.

`edited` also reruns validation when the description is updated. A missing description creates a warning but leaves the job successful. To enforce validation before merging, configure the required checks in a branch ruleset; a workflow failure alone is not a merge restriction.

**Observed troubleshooting:** The shared run showed `file-size-check` and `pr-body-check` passing, while `branch-name-check` rejected `dev`. A name such as `feature/pr-validation` satisfies this rule. A passing body check alone does not prove the body was nonempty, because an empty body only warns.

**Screenshot evidence:** Add the supplied PR-check screenshot to `2026/day-47/screenshots/pr-checks.png` and link it from this document.

The screenshot is not embedded in this standalone document.

## 3. Scheduled health checks

File: `.github/workflows/scheduled-tasks.yml`

Replace `HEALTH_URL` with your application's health endpoint. This example expects exactly HTTP 200 and follows redirects.

### Cron notes

Field order: `minute hour day-of-month month day-of-week`. These examples use UTC.

| Requirement | Cron | Explanation |
| --- | --- | --- |
| Monday at 02:30 UTC | `30 2 * * 1` | Monday at 08:00 IST |
| Every six hours | `0 */6 * * *` | 00:00, 06:00, 12:00, 18:00 UTC |
| Every weekday at 09:00 IST | `30 3 * * 1-5` | 03:30 UTC, Monday–Friday |
| First day of month at midnight UTC | `0 0 1 * *` | 05:30 IST on day 1 |

IST is UTC +05:30. If monthly midnight means **IST**, the UTC time is 18:30 on the previous month's final day. A simple fixed day-of-month cron cannot represent every month's last day. Use a daily `30 18 * * *` schedule and a date guard checking whether the current date in `Asia/Kolkata` is day 1.

Schedules run from the default branch. High load can delay scheduled jobs or cause queued jobs to be dropped; the top of the hour is especially busy. In public repositories, 60 days without repository activity automatically disables scheduled workflows. A manual run tests the job but does not prove the cron trigger fired. [GitHub schedule documentation](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule)

## 4. Path and branch filters

File: `.github/workflows/smart-triggers.yml`

File: `.github/workflows/path-ignore.yml`

Use `paths` to include selected areas, and `paths-ignore` to exclude documentation-only changes. Branch and path conditions must both match. Do not combine `paths` and `paths-ignore` on the same event. Here, `**/*.md` covers Markdown at any depth; `*.md` would cover the repository root only. `release/*` matches a single level such as `release/v1`; use `release/**` for deeper branch names. [GitHub filter syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#onpushpull_requestpull_request_targetpathspaths-ignore)

Try a root README-only change on `main`: both examples should skip. A change to `src/index.js` on `main` should trigger both.

## 5. Run deployment steps after tests

File: `.github/workflows/tests.yml`

This example assumes `package.json` and `test.js` are committed at the repository root and the package has `"test": "node test.js"` in its scripts. Use your actual test suite. If a consistent `package-lock.json` is committed, use `npm ci` for installation.

File: `.github/workflows/deploy-after-tests.yml`

The completion event fires for failed runs too. The job condition controls whether deployment proceeds. `exit 0` ends only its step; the separate deployment job's condition is what enforces the gate.

`Run Tests` must match the upstream workflow's `name`, not its filename. The downstream file must exist on the default branch. When adding real deployment, restrict trusted branches and explicitly select the tested commit (`github.event.workflow_run.head_sha`) or its verified artifact. A default checkout would otherwise select the default branch for this event. [GitHub workflow_run documentation](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#workflow_run)

### workflow_run vs workflow_call

| Event | My explanation | Example |
| --- | --- | --- |
| `workflow_run` | Start a separate workflow in response to another workflow's activity. Inspect its result to decide what to do next. | Test completion starts a deployment decision. |
| `workflow_call` | Let a caller invoke a reusable workflow as a job and supply declared inputs and secrets. | Several projects reuse the same build workflow. |

See [GitHub reusable workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows).

## 6. External event triggers

File: `.github/workflows/external-trigger.yml`

Send the `deploy-request` event from an authenticated terminal with `environment` set to `production` in the client payload. The client payload must be a JSON object, not a string. A successful request returns **204 No Content**, which confirms acceptance rather than a completed deployment. [GitHub CLI API manual](https://cli.github.com/manual/gh_api)

The workflow must be on the default branch. An external monitoring service might request a diagnostic workflow after an alert; a Slack bot might submit an approved deployment request; another repository might notify this repository that a new build is ready.

Classic PATs need `repo` scope for this endpoint. Fine-grained tokens need access to this repository and **Contents: write**. Token permissions are separate from the workflow's `permissions` block. [GitHub dispatch API](https://docs.github.com/en/rest/repos/repos#create-a-repository-dispatch-event)

## Troubleshooting from this exercise

| Symptom | Meaning and correction |
| --- | --- |
| Branch `dev` rejected | The naming rule accepts `feature/`, `fix/`, or `docs/` followed by a name. |
| npm cannot find package.json | Check out the repository and run npm in the folder containing the committed package file. |
| npm cannot find test.js | The npm script resolves to a missing file. Check spelling, casing, Git tracking, and the run's commit. |
| Old failure persists after pushing a fix | Inspect the new commit's run. Rerunning an old run still uses its original commit. |
| Dispatch gives 404 with token scopes: none | The shown classic token lacks the required scope. Correct permissions, then verify owner/repository spelling if 404 persists. |
| Dispatch accepted but no workflow appears | Check the default-branch workflow file and exact event type. |

## Verification checklist

These remain unchecked until verified in the repository; this document does not claim successful live runs.

- [ ] Open, update, close/reopen, and merge a PR; inspect each action value.
- [ ] Confirm `dev` fails and `feature/pr-validation` passes the branch rule.
- [ ] Confirm a changed file above 1,000,000 bytes fails the size job.
- [ ] Confirm an empty PR description produces only a warning.
- [ ] Run the health check manually and capture a separate schedule-triggered run.
- [ ] Compare README-only and source-file pushes on allowed branches.
- [ ] Observe successful tests enabling the deployment demonstration.
- [ ] Observe failed tests skipping the deployment job.
- [ ] Receive HTTP 204 and confirm the external event prints `production`.
- [ ] Add the PR-check screenshot beside this document.

## Submission

Keep runnable workflows in the practice repository's root `.github/workflows/` directory. YAML stored only inside `2026/day-47/` will not be discovered as workflows.

Save this document and any screenshots under `2026/day-47/`, then commit and push them to your learning repository.

**Key takeaway:** Choose the event, narrow its scope, and explicitly gate actions on the result you need.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
