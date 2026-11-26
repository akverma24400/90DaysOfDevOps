# Day 80 --- Helm Multi-Environment Deployment and CI/CD

This README documents the Day 80 Helm work for the **AI-BankApp**
project: environment-specific configuration, Helm hooks and tests, chart
packaging, Helm diff, and the GitOps deployment workflow.

> Reference project:
> [TrainWithShubham/AI-BankApp-DevOps](https://github.com/TrainWithShubham/AI-BankApp-DevOps)
> --- `feat/gitops` branch.

## Objectives

-   Maintain one Helm chart for development, staging, and production.
-   Configure database-readiness validation with a Helm
    pre-install/pre-upgrade hook.
-   Add a Helm test to check the application's health endpoint.
-   Lint, version, and package the chart.
-   Understand how Helm values can be updated by CI and synchronized by
    Argo CD.
-   Troubleshoot Helm releases that remain in `pending-install`.

## 1. Environment-specific values

The chart uses a shared set of templates and separate values files. This
avoids maintaining three copies of the Kubernetes manifests.

  Setting                   Development                 Staging   Production
  ----------------------- ------------- ----------------------- ------------
  BankApp replicas                    1              2--3 (HPA)   2--4 (HPA)
  Image tag                    `latest`                `v1.2.0`     `v1.2.0`
  MySQL storage                     2Gi                     5Gi         20Gi
  MySQL memory request            128Mi                   256Mi        512Mi
  Ollama memory request             1Gi   Not specified in task          2Gi
  Gateway                      Disabled   Not specified in task      Enabled

### Development --- `bankapp/values-dev.yaml`

Key configuration:

-   One BankApp replica; autoscaling disabled.
-   Image tag `latest` and pull policy `Always`.
-   MySQL and Ollama enabled.
-   MySQL persistence: 2Gi.
-   Ollama model: `tinyllama`; persistence: 5Gi.
-   Uses the `standard` storage class.
-   StorageClass creation disabled.

### Staging --- `bankapp/values-staging.yaml`

Key configuration:

-   Two BankApp replicas, with HPA between two and three replicas.
-   Image tag `v1.2.0`.
-   MySQL and Ollama enabled.
-   MySQL persistence: 5Gi; Ollama persistence: 10Gi.
-   Uses the `gp3` storage class.
-   StorageClass creation enabled.
-   The task provides staging MySQL credentials as example values. Do
    not use those literal credentials in a real environment.

### Production --- `bankapp/values-prod.yaml`

Key configuration:

-   Four BankApp replicas, with HPA between two and four replicas.
-   Image tag `v1.2.0`.
-   MySQL and Ollama enabled, with larger resource requests and limits.
-   MySQL persistence: 20Gi; Ollama persistence: 10Gi.
-   Uses the `gp3` storage class.
-   Gateway enabled.
-   StorageClass creation enabled.
-   Production credentials must be supplied securely, not committed to
    Git.

> **Security:** Do not commit real passwords or credentials in
> `values.yaml`, `values-dev.yaml`, `values-staging.yaml`, or
> `values-prod.yaml`. Use External Secrets Operator with AWS Secrets
> Manager, Sealed Secrets, or Vault. Replace any example credentials
> from the exercise before publishing the repository.

## 2. Helm hooks and application test

### Database readiness hook

File: `bankapp/templates/pre-install-job.yaml`

The Job uses the annotations:

``` yaml
annotations:
  "helm.sh/hook": pre-install,pre-upgrade
  "helm.sh/hook-weight": "0"
  "helm.sh/hook-delete-policy": before-hook-creation
```

It runs a BusyBox container that checks the MySQL service on port `3306`
until it becomes reachable. The Job is configured with
`backoffLimit: 10` and a `Never` restart policy.

This hook runs before installation and upgrades. It complements the
application's init-container readiness checks; it does not replace them.

### Helm connection test

File: `bankapp/templates/tests/test-connection.yaml`

The test Pod is annotated with:

``` yaml
annotations:
  "helm.sh/hook": test
```

It uses BusyBox and requests the Spring Boot health endpoint:

``` bash
wget -qO- http://<release-fullname>-service:8080/actuator/health
```

Run the test after deploying:

``` bash
helm test bankapp-dev -n dev
```

The service name in the test command must match the Service rendered by
the chart. If the test fails, inspect the test Pod and its logs:

``` bash
kubectl get pods -n dev
kubectl describe pod <test-pod-name> -n dev
kubectl logs <test-pod-name> -n dev
```

## 3. Lint and package the chart

Run lint before packaging:

``` bash
helm lint bankapp/
```

Package the chart:

``` bash
helm package bankapp/
```

The chart's `Chart.yaml` version is the chart package version. For this
exercise, it was updated to:

``` yaml
version: 0.2.0
appVersion: "1.1.0"
```

Package again after changing the version:

``` bash
helm package bankapp/
```

This creates `bankapp-0.2.0.tgz` when the chart version is `0.2.0`.

Check the package:

``` bash
helm show chart bankapp-0.2.0.tgz
```

Optional: create a simple chart repository directory:

``` bash
mkdir -p chart-repo
cp bankapp-*.tgz chart-repo/
helm repo index chart-repo/ --url https://<your-username>.github.io/helm-charts
```

Replace the example URL with the actual chart repository URL before
publishing.

## 4. Render and deploy each environment

### Development deployment

For a new release:

``` bash
helm install bankapp-dev bankapp/ \
  -f bankapp/values-dev.yaml \
  -n dev --create-namespace
```

To deploy the packaged chart to a new release:

``` bash
helm install my-bankapp bankapp-0.2.0.tgz \
  -f bankapp/values-dev.yaml \
  -n bankapp --create-namespace
```

Use a release name only once per namespace. If the release already
exists, upgrade it instead of installing it again.

### Staging render check

``` bash
helm template bankapp-staging bankapp/ \
  -f bankapp/values-staging.yaml \
  -n staging | grep "replicas:"
```

### Production render check

``` bash
helm template bankapp-prod bankapp/ \
  -f bankapp/values-prod.yaml \
  -n prod | grep "replicas:"
```

These `helm template` commands render manifests locally; they do **not**
deploy the staging or production environments.

### Upgrade an existing release

For an existing development release, use:

``` bash
helm upgrade bankapp-dev bankapp-0.2.0.tgz \
  -f bankapp/values-dev.yaml \
  -n dev
```

For a repeatable install-or-upgrade workflow:

``` bash
helm upgrade --install bankapp-dev bankapp/ \
  -f bankapp/values-dev.yaml \
  -n dev --create-namespace \
  --wait --timeout 300s --atomic
```

For production, use the production values file and inject the image tag
and secrets from a trusted CI/CD secret source:

``` bash
helm upgrade --install bankapp bankapp/ \
  -f bankapp/values-prod.yaml \
  --set bankapp.image.tag="$GIT_SHA" \
  -n bankapp --create-namespace \
  --wait --timeout 300s --atomic
```

## 5. Helm diff

Install the plugin once:

``` bash
helm plugin install https://github.com/databus23/helm-diff
```

Preview changes to an existing release:

``` bash
helm diff upgrade bankapp-dev bankapp/ \
  -f bankapp/values-dev.yaml \
  -n dev
```

For a release that does not exist yet, use `--allow-unreleased`:

``` bash
helm diff upgrade bankapp-prod bankapp/ \
  -f bankapp/values-prod.yaml \
  -n prod --allow-unreleased
```

`helm diff` compares the proposed rendered chart with the currently
installed release. The release name and namespace must identify the
release you intend to compare.

## 6. GitOps and CI/CD integration

### Existing raw-manifest flow

1.  A developer pushes application code.
2.  GitHub Actions builds the Docker image.
3.  The image is tagged with the Git commit SHA.
4.  The workflow updates the image tag in `k8s/bankapp-deployment.yml`.
5.  The workflow commits the change.
6.  Argo CD detects the Git change and synchronizes the Kubernetes
    manifests.

### Helm-based flow

1.  A developer pushes application code.
2.  GitHub Actions builds the Docker image.
3.  The image is tagged with the Git commit SHA.
4.  The workflow updates `bankapp.image.tag` in the relevant Helm values
    file.
5.  The workflow commits the values change.
6.  Argo CD detects the Git change, renders the Helm chart, and
    synchronizes the resulting Kubernetes resources.

Example CI step from the exercise:

``` yaml
- name: Update Helm values with new image tag
  run: |
    TAG=${{ steps.tag.outputs.sha_short }}
    yq -i '.bankapp.image.tag = "'$TAG'"' helm-chart/bankapp/values-prod.yaml

- name: Commit updated Helm values
  run: |
    git config user.name "github-actions[bot]"
    git config user.email "github-actions[bot]@users.noreply.github.com"
    git add helm-chart/bankapp/values-prod.yaml
    git diff --staged --quiet || git commit -m "ci: update bankapp image to $TAG [skip ci]"
    git push
```

The workflow assumes that the repository path and the
`steps.tag.outputs.sha_short` output are configured in the actual GitHub
Actions workflow.

### Argo CD source configuration

For raw Kubernetes manifests, the Application source points to the `k8s`
directory:

``` yaml
source:
  path: k8s
```

For a Helm chart, it points to the chart directory and selects the
environment values file:

``` yaml
source:
  path: helm-chart/bankapp
  helm:
    valueFiles:
      - values-prod.yaml
```

Argo CD supports Helm natively. It renders the chart and manages the
resulting Kubernetes resources through its GitOps synchronization
process.

### Why use Helm with Argo CD?

-   One reusable chart can describe multiple environments.
-   Environment-specific values reduce duplicated manifests.
-   Chart versions provide a clear packaging and release mechanism.
-   Templates make repeated Kubernetes configuration easier to maintain.
-   Argo CD can render Helm charts directly from Git and track the
    desired state.

## 7. Production best practices

### Use install-or-upgrade

``` bash
helm upgrade --install bankapp bankapp/ \
  -f bankapp/values-prod.yaml \
  --set bankapp.image.tag="$GIT_SHA" \
  -n bankapp --create-namespace \
  --wait --timeout 300s \
  --atomic
```

-   `--install`: install if the release does not exist.
-   `--set`: pins the image to the supplied Git commit tag.
-   `--wait`: waits for supported resources to become ready.
-   `--timeout`: sets the maximum wait duration.
-   `--atomic`: rolls back an unsuccessful upgrade and enables cleanup
    on failed installation.

### Review changes before applying

Use `helm diff upgrade` to inspect the proposed changes before upgrading
an existing release.

### Apply namespace resource quotas

The exercise proposes a `ResourceQuota` template with CPU and memory
request/limit ceilings. Add it only after checking that the quota is
appropriate for the workloads in that namespace.

### Protect secrets

Never store real production secrets in Git or plain Helm values files.
Use a dedicated secrets-management solution and pass credentials
securely at deployment time.

## 8. Troubleshooting encountered during the exercise

### A. `cannot re-use a name that is still in use`

Example:

``` text
INSTALLATION FAILED: cannot re-use a name that is still in use
```

A release with that name is already recorded in the target namespace. A
normal `helm list -A` may hide releases in pending or failed states.

Inspect all release states:

``` bash
helm list -A --all
helm list -n bankapp --all
helm history my-bankapp -n bankapp
```

If the release is an incomplete installation and you no longer need it,
uninstall it:

``` bash
helm uninstall my-bankapp -n bankapp
```

Then retry the installation only after confirming the release is gone:

``` bash
helm list -n bankapp --all
```

Do not remove a release that contains workloads or data you need to
retain.

### B. `pending-install` releases

During this exercise, `helm list -A --all` showed `bankapp` and
`my-bankapp` in `pending-install`.

Inspect the release and namespace before cleanup:

``` bash
helm status bankapp -n bankapp
helm status my-bankapp -n bankapp
kubectl get all -n bankapp
kubectl get events -n bankapp --sort-by=.metadata.creationTimestamp
```

If an installation was interrupted and the release is confirmed to be
disposable, remove the incomplete release:

``` bash
helm uninstall my-bankapp -n bankapp
helm uninstall bankapp -n bankapp
```

Only run the uninstall commands for releases you have verified are safe
to remove. The existing `bankapp-dev` release in namespace `dev` is
separate and should not be deleted as part of this cleanup.

### C. `Ctrl+Z` suspends rather than terminates

Pressing `Ctrl+Z` suspends the foreground process. It does not clean up
the Helm release or necessarily stop the install operation.

Check shell jobs:

``` bash
jobs
```

If the suspended job is the unwanted Helm install, terminate the
matching job using its displayed job number, for example:

``` bash
kill %3
```

Use the actual job number shown by `jobs`; do not assume it is always
`%3`.

### D. Helm diff says `release: not found`

Example:

``` text
Release was not present in Helm.
Error: release: not found
```

This happens when the release name or namespace does not identify an
installed release. For an existing development release, use its actual
name and namespace:

``` bash
helm diff upgrade bankapp-dev bankapp/ \
  -f bankapp/values-dev.yaml \
  -n dev
```

For a first-time preview, use a new release name and
`--allow-unreleased`:

``` bash
helm diff upgrade bankapp-prod bankapp/ \
  -f bankapp/values-prod.yaml \
  -n prod --allow-unreleased
```

The plugin only needs to be installed once. If Helm reports
`plugin already exists`, do not reinstall it.

### E. Choose install or upgrade correctly

-   New release: `helm install RELEASE CHART ...`
-   Existing release: `helm upgrade RELEASE CHART ...`
-   Either case: `helm upgrade --install RELEASE CHART ...`

For the existing `bankapp-dev` release in namespace `dev`, upgrading to
the new packaged chart is the appropriate operation:

``` bash
helm upgrade bankapp-dev bankapp-0.2.0.tgz \
  -f bankapp/values-dev.yaml \
  -n dev
```

## 9. Verification checklist

Run the checks relevant to the environment you actually deployed:

``` bash
# Chart validation
helm lint bankapp/

# Inspect package metadata
helm show chart bankapp-0.2.0.tgz

# List releases, including pending/failed states
helm list -A --all

# Inspect the development release
helm status bankapp-dev -n dev

# Inspect Kubernetes resources
kubectl get pods -n dev
kubectl get svc -n dev

# Run the Helm test
helm test bankapp-dev -n dev
```

For staging and production, the `helm template` commands above validate
rendered output without creating resources. A successful render is not
proof of a successful live deployment.

## 10. Helm, raw manifests, and Kustomize

  -----------------------------------------------------------------------
  Approach                Best suited for         AI-BankApp example
  ----------------------- ----------------------- -----------------------
  Raw manifests           Simple deployments with Existing `k8s/`
                          limited environment     directory
                          variation               

  Helm                    Reusable charts,        Custom chart with
                          configurable            environment values and
                          environments, and       hooks
                          dependencies            

  Kustomize               Patching and overlaying Environment overlays
                          existing manifests      for the existing `k8s/`
                          without a templating    resources
                          language                
  -----------------------------------------------------------------------

## 11. Three-day Helm learning summary

  -----------------------------------------------------------------------
  Day                     Concept                 AI-BankApp connection
  ----------------------- ----------------------- -----------------------
  78                      Helm install,           Deployed MySQL for the
                          repositories, values,   BankApp using a Helm
                          upgrade, and rollback   chart

  79                      Custom charts and Go    Converted the
                          templates               Kubernetes manifests
                                                  into a reusable Helm
                                                  chart

  80                      Multi-environment       Added environment
                          values, hooks,          configurations, hooks,
                          packaging, and CI/CD    chart packaging, and a
                                                  Helm-based GitOps
                                                  workflow
  -----------------------------------------------------------------------

## 12. Cleanup

Only clean up resources created for this exercise and after confirming
that they are no longer needed.

``` bash
helm uninstall bankapp-dev -n dev
kubectl delete namespace dev
kind delete cluster --name tws-cluster
```

> **Warning:** Deleting a namespace or Kind cluster removes its
> workloads and may remove access to associated development data.
> Confirm that anything important has been backed up before cleanup.

------------------------------------------------------------------------

## Key takeaways

-   Helm values allow one chart to serve development, staging, and
    production.
-   Hooks can run validation jobs before installation or upgrades.
-   Helm tests can verify an application's health endpoint after
    deployment.
-   Chart versioning and packaging make charts easier to distribute.
-   `helm diff` helps review changes before an upgrade.
-   Argo CD can render and synchronize Helm charts as part of a GitOps
    workflow.
-   `helm upgrade --install` is useful for repeatable deployment
    automation.
-   Always inspect release name, namespace, and status before retrying
    an installation.
