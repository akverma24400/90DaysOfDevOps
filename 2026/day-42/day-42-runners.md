# Day 42 – Runners: GitHub-Hosted & Self-Hosted

## Goal

Understand where GitHub Actions jobs run, explore the tools available on hosted runners, and run a workflow on a Linux machine or AWS EC2 instance.

## What Is a Runner?

A **runner** is a machine that executes jobs in a GitHub Actions workflow. The `runs-on` setting tells GitHub which runner to use.

| Feature | GitHub-hosted runner | Self-hosted runner |
| --- | --- | --- |
| Machine | Provided by GitHub | Your local machine or cloud VM |
| Management | GitHub manages the environment | You manage the machine and tools |
| Tools | Many tools are already installed | You install the tools your jobs need |
| Files after a job | Standard hosted jobs use fresh environments | Files may remain until cleaned up |

## Task 1 – Run Jobs on Three Operating Systems

The workflow code is uploaded separately. It contains three jobs, using **ubuntu-latest**, **windows-latest**, and **macos-latest**. Each job prints the operating system, hostname, and current user.

Push the workflow and open the repository's **Actions** tab. These three jobs can run in parallel because none uses `needs` to wait for another job. Available capacity and concurrency limits can affect when they start.

**Notes:** GitHub provides and maintains GitHub-hosted runners, including their operating systems and runner images.

## Task 2 – Explore Pre-installed Tools

The Ubuntu job prints the installed versions of:

- Docker
- Python
- Node.js
- Git

**Why does this matter?** Pre-installed tools reduce setup work and let a workflow start building or testing sooner. Versions can change as runner images are updated.

For the full software list, open the official [runner images repository](https://github.com/actions/runner-images) and follow the **Included Software** link for the Ubuntu image used by your job.

To identify the exact image used in a run, expand **Set up job → Runner Image** in its logs.

## Task 3 – Set Up a Self-Hosted Runner

Use a Linux machine or an AWS EC2 instance that you can access.

1. Open your GitHub repository.
2. Go to **Settings → Actions → Runners → New self-hosted runner**.
3. Select **Linux** and the architecture matching your machine.
4. On your machine, run the download, extraction, and configuration commands shown by GitHub.
5. Start the runner from its installation directory using the instructions provided by GitHub.

6. Check that the terminal says **Listening for Jobs** and GitHub shows the runner as **Idle**.

Use GitHub's current commands because the download version and registration token change. Run configuration as your normal Linux user and keep the registration token private.

Keep the machine running and the runner process active while testing. Closing the terminal may stop a runner started interactively.

## Task 4 – Run a Job on Your Machine

The self-hosted workflow code is uploaded separately. It prints the hostname, current user, and working directory, then creates and verifies a test file.

This workflow uses the Linux runner registered in Task 3.

### Trigger the workflow

1. Commit and push the workflow to the repository's default branch.
2. Open **Actions → Test Self-Hosted Runner → Run workflow**.
3. Check the logs. The hostname should match your machine or EC2 instance.

### Verify the file on your machine

Find the absolute file location in the job logs. Open that file on your runner machine and check that its contents match the message written by your workflow.

The file remains after the run if the job does not remove it. Future workflows or cleanup commands may delete it.

## Task 5 – Select a Runner Using Labels

1. Open **Settings → Actions → Runners** and select your runner.
2. Edit its labels and add `my-linux-runner`.
3. Update the workflow to require both the **self-hosted** and **my-linux-runner** labels.

4. Commit, push, and run the workflow again.
5. Confirm that the job runs on your labeled machine.

**Why are labels useful?** Labels help send jobs to suitable machines when several runners are available. For example, you might label machines by operating system, installed tools, or hardware.

A runner must match **every label** in the `runs-on` list. If no matching runner is online and available, the job waits in the queue.

## Quick Troubleshooting

| Problem | What to check |
| --- | --- |
| Runner shows Offline | Confirm the machine is on and the runner process is active |
| Job stays queued | Check runner availability and matching labels |
| Command not found | Install the required tool on the self-hosted machine |
| Cannot find the test file | Use the exact absolute path printed in the job logs |
| Run workflow button missing | Confirm `workflow_dispatch` is present on the default branch |

## Verification Checklist

Mark each item after verifying it:

- [ ] Ubuntu, Windows, and macOS jobs ran successfully.
- [ ] Each job printed its OS, hostname, and current user.
- [ ] Ubuntu printed Docker, Python, Node.js, and Git versions.
- [ ] The self-hosted runner appeared as Idle.
- [ ] The workflow ran on my Linux machine or EC2 instance.
- [ ] I found `day-42-test.txt` on the machine after the run.
- [ ] The workflow ran successfully with `my-linux-runner`.

## References

- [GitHub-hosted runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners)
- [Pre-installed runner software](https://github.com/actions/runner-images)
- [Add a self-hosted runner](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/add-runners)
- [Use self-hosted runners and labels](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/use-in-a-workflow)

---

Part of my **90DaysOfDevOps** learning journey.
