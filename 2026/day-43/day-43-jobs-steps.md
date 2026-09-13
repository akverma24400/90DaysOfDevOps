# Day 43 – Jobs, Steps, Env Vars & Conditionals

## Goal

Learn how to control a GitHub Actions pipeline using job dependencies, environment variables, job outputs, and conditions.

This README explains the solutions. Keep the workflow YAML files separately in the practice repository's `.github/workflows` directory.

## Key Concepts

| Concept | Meaning |
| --- | --- |
| Workflow | An automated process triggered by an event |
| Job | A group of steps executed on a runner |
| Step | An individual command or action within a job |
| Environment variable | A named value available within its configured scope |
| Job output | A value passed from one job to another |
| Conditional | A rule that decides whether a job or step runs |

Steps within a job run in order. Independent jobs can run in parallel, depending on runner availability.

## Task 1 – Multi-Job Workflow

**Workflow file:** `multi-job.yml`

### Solution

Create three jobs and connect them using `needs`:

| Job | Action | Dependency |
| --- | --- | --- |
| build | Prints “Building the app” | None |
| test | Prints “Running tests” | build |
| deploy | Prints “Deploying” | test |

The test job waits for a successful build. The deploy job waits for successful tests. With the default conditions, a failed job causes its dependent jobs to be skipped.

These messages demonstrate execution order; they do not actually build, test, or deploy an application.

**Verify:** Open the run in the Actions tab. The graph should show build, followed by test, followed by deploy.

## Task 2 – Environment Variables

### Solution

Define variables at three levels and print them together in the step where VERSION is defined.

| Level | Variable | Value | Available to |
| --- | --- | --- | --- |
| Workflow | APP_NAME | myapp | Steps across all jobs in the workflow |
| Job | ENVIRONMENT | staging | Steps in that job |
| Step | VERSION | 1.0.0 | That step only |

When the same name is defined at multiple levels, the more specific level takes priority: step overrides job, and job overrides workflow.

Also print the commit SHA using `github.sha` and the triggering user using `github.actor`.

**Verify:** The logs should contain myapp, staging, 1.0.0, the commit SHA, and the actor's username.

## Task 3 – Pass Outputs Between Jobs

### Solution

1. In the first job, give the date-producing step an ID.
2. Generate today's date and write a named value to `GITHUB_OUTPUT`.
3. Expose the step's output through the job's `outputs` mapping.
4. Make the second job depend on the first using `needs`.
5. Read and print the value through `needs.<job>.outputs.<name>`.

**Why pass outputs between jobs?** A later job may need a value calculated earlier, such as a build version, image tag, or deployment URL. Outputs let it reuse that value instead of calculating it again.

Environment variables do not automatically carry over between separate jobs. Use job outputs for small values and artifacts for files.

**Verify:** Both jobs should show the same generated date.

## Task 4 – Conditionals

### Solution

| Requirement | Approach |
| --- | --- |
| Run a step only on main | Check that `github.ref` equals `refs/heads/main` for a branch push |
| Run a step after a failure | Use `failure()` to handle an earlier unhandled failure |
| Run a job only on push | Check that `github.event_name` equals `push` |
| Allow a step to fail without failing the job by itself | Enable step-level `continue-on-error` |

To compare push and pull-request behavior, configure the workflow to receive both events. On a pull request, the head branch is available through `github.head_ref`; `github.ref` normally represents the pull-request merge ref.

### Checking the previous step

`failure()` detects any earlier failure, not specifically the immediately previous step. Give the target step an ID and also inspect its result when that distinction matters.

### What does continue-on-error do?

It allows the job to continue after that step fails. It does not fix the error, and other steps can still fail the job.

For a failed step with this setting, its raw `outcome` is failure while its final `conclusion` is success. Inspect `steps.<id>.outcome` to detect that tolerated failure; do not rely on `failure()` alone.

**Verify:** Compare main and feature-branch runs, trigger a pull request, and inspect logs from deliberately failing steps.

## Task 5 – Smart Pipeline

**Workflow file:** `smart-pipeline.yml`

### Solution

1. Configure push events for every branch. An explicit branch pattern of `**` includes branch names containing slashes and excludes tag pushes.
2. Create independent lint and test jobs so they can run in parallel.
3. Make summary depend on both jobs using `needs`.
4. In summary, identify main using `github.ref`. Label other branch pushes as feature-branch pushes for this exercise.
5. Print the pushed head commit's message from `github.event.head_commit.message`.

Pass the commit message into a step environment variable and print it as quoted text. This keeps quotes and special characters in the message from becoming shell commands.

### When does summary run?

With only dependencies configured, summary runs after both jobs succeed. To report after failures too, add a job condition using `!cancelled()`. This allows reporting after dependencies finish unless the workflow was cancelled.

**Verify:** Push to main and another branch. Confirm lint and test have no dependency on each other, summary waits for both, and the branch message and commit message are correct.

## Verification Checklist

Mark each item after checking the workflow runs:

- [ ] Build, test, and deploy follow the dependency chain.
- [ ] All three environment variables print correctly.
- [ ] Commit SHA and actor appear in the logs.
- [ ] The second job reads the first job's output.
- [ ] Branch and event conditions work as expected.
- [ ] Failure handling and continue-on-error behavior are checked.
- [ ] Lint and test can run in parallel.
- [ ] Summary waits for both jobs and prints the correct details.

## References

- [Workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax)
- [Contexts reference](https://docs.github.com/en/actions/reference/workflows-and-actions/contexts)
- [Conditions and status checks](https://docs.github.com/en/actions/reference/workflows-and-actions/expressions)
- [Passing job outputs](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/pass-job-outputs)

---

**Akash Verma | 90DaysOfDevOps**
