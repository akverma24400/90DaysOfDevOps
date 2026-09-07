# Day 40 – Your First GitHub Actions Workflow

## Overview

Today I moved from CI/CD concepts to running my first GitHub Actions workflow. I practiced triggering jobs on a push, reading step logs, using runner variables, and debugging an intentional failure.

## Task 1: Repository Setup

- Created a public repository named `github-actions-practice`.
- Cloned the repository locally.
- Created `.github/workflows/` at the repository root.
- Added the workflow file: `.github/workflows/hello.yml`.

## Task 2: Hello Workflow

Created a workflow with the following configuration:

| Component | Configuration |
| --- | --- |
| Trigger | Every `push` |
| Job ID | `greet` |
| Runner | `ubuntu-latest` |
| First step | Check out the repository using `actions/checkout` |
| Second step | Print `Hello from GitHub Actions!` |

After pushing the workflow, I opened the **Actions** tab, checked the successful run, and reviewed the output of each step.

**Learning:** Checking out the code makes repository files available on the runner for later steps.

## Task 3: Understanding Workflow Anatomy

| Key | Purpose |
| --- | --- |
| `on:` | Defines which events trigger the workflow |
| `jobs:` | Contains the jobs the workflow will execute |
| `runs-on:` | Selects the runner environment for a job |
| `steps:` | Lists the actions and commands within a job |
| `uses:` | Runs a reusable action, such as `actions/checkout` |
| `run:` | Executes shell commands on the runner |
| `name:` on a step | Gives the step a readable label in the Actions logs |

Steps in this job run in order on the same runner. Clear step names make the output easier to inspect.

## Task 4: Adding More Steps

Extended the workflow to display information about the run and checked the output after another push.

| Added output | Command or variable |
| --- | --- |
| Current date and time | `date` |
| Branch name for a branch push | `echo "$GITHUB_REF_NAME"` |
| Repository files, including hidden entries | `ls -la` |
| Runner operating system | `echo "$RUNNER_OS"` |

`GITHUB_REF_NAME` contains the short branch or tag name that triggered the push. `RUNNER_OS` reports the operating system; for this Ubuntu runner, it is `Linux`.

## Task 5: Breaking and Fixing the Workflow

Intentionally introduced a failing command, observed the failed run, then fixed the workflow and pushed again to restore a successful run.

### What does a failed pipeline look like?

- The run and failed job show a red failure indicator in the Actions tab.
- The failed step contains the command output and an error or nonzero exit code.
- Later normal steps in the same job are skipped by default. Cleanup or steps with suitable conditions can still run.

For example, `exit 1` deliberately returns a failure status. A typical log message is **Process completed with exit code 1**.

### How do I read the error?

1. Open the repository’s **Actions** tab.
2. Select the failed workflow run.
3. Open the `greet` job and expand the failed step.
4. Read the command output before the final exit-code message to find the cause.
5. Correct the command, commit the fix, and push again.
6. Confirm that the new run succeeds.


## Key Takeaways

- Workflow YAML files belong in `.github/workflows/` at the repository root.
- A push can trigger automated work on a cloud runner.
- `uses` runs an action; `run` executes shell commands.
- Step logs explain both successful output and failures.
- A green run confirms that the configured checks passed; this greeting workflow does not yet test or deploy an application.

## References

- [Understanding GitHub Actions](https://docs.github.com/en/actions/get-started/understand-github-actions)
- [GitHub Actions variables](https://docs.github.com/en/actions/reference/workflows-and-actions/variables)
- [Using workflow run logs](https://docs.github.com/en/actions/how-tos/monitor-workflows/use-workflow-run-logs)
