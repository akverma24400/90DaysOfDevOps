# Day 46 – Reusable Workflows & Composite Actions

## Goal

Learn how to reuse GitHub Actions automation instead of repeating the same configuration in every workflow. This practice covers reusable workflows, inputs, secrets, outputs, and a custom composite action.

## Tools Used

GitHub Actions, YAML, Bash, Git, and GitHub Secrets.

## 1. Understanding Reusable Workflows

A **reusable workflow** is a workflow that another workflow can call. It can contain one or more jobs, each with its own steps and runner configuration.

The **`workflow_call` trigger** makes a workflow callable and defines the inputs, secrets, and outputs it exposes.

A reusable workflow is called through `jobs.<job_id>.uses`. A regular action is called inside a job through `steps[].uses`.

Reusable workflow files must live directly in `.github/workflows/` with a `.yml` or `.yaml` extension. Nested folders inside that directory are not supported.

Reference: [GitHub — Reuse workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows).

## 2. Reusable Build Workflow

**File:** `.github/workflows/reusable-build.yml`

The practice workflow checks out the repository, prints the application name and target environment, and checks whether a Docker token was supplied.

| Parameter | Kind | Configuration | Purpose |
| --- | --- | --- | --- |
| `app_name` | String input | Required | Identifies the application |
| `environment` | String input | Default: `staging` | Identifies the intended deployment target |
| `docker_token` | Secret | Required | Supplies the Docker token without hardcoding it |

The task specifies `required: true` alongside the environment default. The earlier practice version used `required: false` so callers could omit it. The caller in this exercise explicitly supplies `production`.

Expected messages for the supplied caller:

- `Building my-web-app for production`
- `Docker token is set: true`

The token check only confirms that the value is nonempty. It does not authenticate with Docker Hub. The actual secret must never be printed.

The `environment` input is a string in this exercise; it does not automatically configure a GitHub deployment environment.

With only `workflow_call` configured, this workflow needs a caller to run. This practice does not build an image, push to Docker Hub, or deploy an application.

## 3. Caller Workflow

**File:** `.github/workflows/call-build.yml`

The caller starts on pushes to `main`. Its `build` job references the reusable workflow and passes:

- Application name: `my-web-app`
- Environment: `production`
- Secret: the repository's `DOCKER_TOKEN`, mapped to `docker_token`

Create `DOCKER_TOKEN` under **Repository Settings → Secrets and variables → Actions** before running the workflow.

The job that calls the reusable workflow uses `uses` at job level. The called workflow defines its own runner and steps.

## 4. Returning a Build Version

The reusable workflow can generate a version such as `v1.0-abc1234`, using the first seven characters of the commit SHA.

The value must be connected across each output layer:

| Layer | What it does |
| --- | --- |
| Step output | The `set-version` step writes `build_version` to `$GITHUB_OUTPUT` |
| Job output | The build job maps `steps.set-version.outputs.build_version` |
| Workflow output | `on.workflow_call.outputs` maps `jobs.build.outputs.build_version` |
| Caller job | A second job declares `needs: build` and reads `needs.build.outputs.build_version` |

All mappings and the generating step must be enabled. Leaving the `set-version` step commented out means it cannot produce the version.

The caller's second job should print the same generated version. This demonstrates passing data between workflows; the version is a label, not a build artifact.

Reference: [GitHub — Using outputs from a reusable workflow](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows#using-outputs-from-a-reusable-workflow).

## 5. Custom Composite Action

**File:** `.github/actions/setup-and-greet/action.yml`

A **composite action** packages several steps into one action. Its metadata declares `runs.using: composite`.

For this exercise, the action should:

1. Accept a `name` input and a `language` input with the default `en`.
2. Print a greeting using the selected language.
3. Print the current date and runner operating system.
4. Write `greeted=true` to `$GITHUB_OUTPUT` from a step with an ID.
5. Map the action's `greeted` output to that step output.

Example greeting behavior:

| Language | Example |
| --- | --- |
| `en` | Hello, Akash! |
| `hi` | Namaste, Akash! |
| Unsupported language | Fall back to English |

Each `run` step inside a composite action must specify a shell, such as `bash`.

### Calling the Local Action

Create a workflow such as `.github/workflows/composite-action-practice.yml` with a job that:

1. Checks out the repository so the local action files are available.
2. Calls `./.github/actions/setup-and-greet` from a step.
3. Passes the name and language through `with`.
4. Assigns an ID to the calling step and reads its `greeted` output in a later step.

The expected output value is the string `true`.

## 6. Reusable Workflow vs Composite Action

| Feature | Reusable Workflow | Composite Action |
| --- | --- | --- |
| Invoked by | A job-level `uses` call; enabled by `workflow_call` | `uses` inside a job step |
| Can contain jobs? | Yes | No |
| Can contain multiple steps? | Yes, inside its jobs | Yes |
| Location | Directly in `.github/workflows/` | An action directory containing `action.yml` or `action.yaml` |
| Runner | Defined by its jobs | Uses the caller job's runner |
| Inputs | Defined under `workflow_call.inputs` | Defined in action metadata |
| Secrets directly? | Supports `workflow_call.secrets` | No dedicated secrets declaration or direct secrets context; caller passes values through inputs or environment variables |
| Outputs | Step → job → workflow → caller | Internal step → action → caller step |
| Best for | Reusing whole workflows, including multiple jobs | Reusing a group of steps inside jobs |

Reference: [GitHub — Reusing workflow configurations](https://docs.github.com/en/actions/concepts/workflows-and-actions/reusing-workflow-configurations).

## Troubleshooting From This Practice

| Issue | Correction |
| --- | --- |
| `Unexpected value 'inputes'` | Change `inputes` to `inputs` |
| Secret declared as `docker_tocken` but passed as `docker_token` | Use `docker_token` consistently |
| Checkout referenced as `actions/checkout@v4x` | Use the valid `actions/checkout@v4` reference |
| Output references a commented-out step | Enable the generating step and every required output mapping, or remove the unused output |
| Local composite action cannot be found | Check out the repository before calling the action and confirm its path |

## Verification Checklist

These checks should be completed in GitHub Actions after committing the files. They are not claims of a successful run.

- [ ] Add the `DOCKER_TOKEN` repository secret.
- [ ] Push the caller and reusable workflow to `main`.
- [ ] Confirm the caller starts and runs the reusable build job.
- [ ] Confirm the application name and `production` appear in the logs.
- [ ] Confirm token presence is reported without revealing the secret.
- [ ] Enable version generation and all output mappings.
- [ ] Confirm the dependent caller job prints the generated version.
- [ ] Add and run the composite action workflow.
- [ ] Confirm the greeting, date, runner OS, and `greeted` output.

## Key Takeaways

- Reusable workflows let multiple callers share job definitions.
- Inputs customize behavior, secrets carry sensitive values, and outputs return results.
- Composite actions package repeated steps into a single action.
- Consistent names and complete output mappings are essential.
- Reuse reduces duplicated configuration and makes changes easier to maintain.

**Author:** Akash Verma  
**Challenge:** #90DaysOfDevOps — Day 46
