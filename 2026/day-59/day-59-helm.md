# Day 59 – Helm: Kubernetes Package Manager

Day 59 covers packaging Kubernetes resources into reusable charts and managing their lifecycle through installation, customization, upgrades, rollbacks, and cleanup.

This README explains the solutions and expected verification results. Commands and YAML implementations can stay in the dedicated practice files.

## Goal

Manage an application as a Helm release instead of maintaining each Kubernetes resource independently. The lab uses a Bitnami NGINX chart and a custom chart named `my-app`.

**Tools:** Helm, Kubernetes, kubectl, NGINX, and the Bitnami chart repository.

## Core Concepts

| Concept | Meaning | Example in this lab |
|---|---|---|
| Chart | A package containing Kubernetes templates, default values, and metadata | `bitnami/nginx` or `my-app` |
| Release | A named installation of a chart in a Kubernetes namespace | `my-nginx` or `my-release` |
| Repository | A location from which Helm discovers and downloads charts | Bitnami |
| Values | Configuration supplied to a chart's templates | Replica count, image tag, and Service type |
| Revision | A numbered record of a release operation | Initial install, upgrade, and rollback |

The same chart can be installed as multiple releases with different names and configuration.

## Task 1 – Install and Verify Helm

Install Helm using the method appropriate for the operating system. Verify that the CLI is available, record its installed version, and inspect its environment settings, including repository configuration and cache locations.

Confirm that the Kubernetes context points to the practice cluster before performing release operations. Checking the Helm version alone does not confirm cluster connectivity.

**Verification:** Record the version reported by the local installation. This value depends on the environment and should come from the actual terminal output.

## Task 2 – Add the Bitnami Repository and Search

Register the Bitnami chart repository, refresh its local index, and search for NGINX and other available charts. Updating the index refreshes discovery information; it does not upgrade installed releases.

Search results help identify the chart name, chart version, application version, and description. The chart version describes the package, while the application version describes the software it deploys.

**Verification:** Count distinct Bitnami chart names after updating the index. Exclude the table header and avoid counting historical chart versions as separate charts. The catalogue changes, so record the count from the practice session.

Reference: [Helm repository search](https://helm.sh/docs/helm/helm_search_repo/).

## Task 3 – Install and Inspect a Chart

Install the Bitnami NGINX chart as the `my-nginx` release. Helm renders its templates with the selected values and submits the resulting resources to Kubernetes.

Inspect the release status and generated manifest, then inspect the actual workloads and Services. A chart can create a Deployment, Service, and additional resources; the exact set depends on its version and enabled options.

**Verification:** Record the number of ready application Pods and the Service type from the live resources. Check the selected chart's defaults instead of assuming they match the custom chart created later.

Release metadata and workload readiness answer different questions: confirm both that Helm recorded the installation and that Kubernetes made the application ready.

## Task 4 – Customize with Values

Start by reviewing the chart's default values and supported configuration keys. Create one customized release using command-line overrides, then another with a separate `custom-values.yaml` file. Use distinct release names within the namespace.

The target configuration is:

| Setting | Intended value |
|---|---|
| Replica count | 3 |
| Service type | `NodePort` |
| CPU request | `100m`, equivalent to 0.1 CPU |
| Memory request | `128Mi` |
| CPU limit | `250m`, equivalent to 0.25 CPU |
| Memory limit | `256Mi` |

Requests guide Kubernetes scheduling. CPU limits constrain CPU usage through throttling, while exceeding a memory limit can lead to the container being killed. These values apply to the container resources exposed by the chart.

A values file makes configuration easier to review, reuse, and track in version control. For this standalone chart, user-supplied values override chart defaults, and command-line overrides take precedence over conflicting values supplied in a file.

Inspect the release's supplied overrides and the live resources. To inspect the complete effective configuration, include the chart defaults as well.

**Verification:** The values-file release should have three ready replicas, a NodePort Service, and the requested container resource settings. A configuration key only affects the workload when the chart uses it.

References: [Helm values files](https://helm.sh/docs/chart_template_guide/values_files/) and [Kubernetes resource management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/).

## Task 5 – Upgrade and Roll Back

Upgrade `my-nginx` to five replicas and inspect its release history. Retain the other intended settings when applying the replica change.

Roll back to the initial revision and inspect both the history and the restored workload. A rollback creates a new revision containing the selected earlier configuration.

For one successful installation, one upgrade, and one rollback, the expected sequence is:

| Revision | Operation | Configuration |
|---|---|---|
| 1 | Initial installation | Original chart values and overrides |
| 2 | Upgrade | Replica count changed to 5 |
| 3 | Rollback to revision 1 | Original configuration restored |

**Verification:** This sequence produces three revisions. The rollback restores the original replica count, which must be checked against revision 1. Extra attempts or release operations can change the revision numbers.

Helm rollback manages the release's Kubernetes configuration; it does not restore application data or reverse database migrations.

References: [Helm upgrade](https://helm.sh/docs/helm/helm_upgrade/), [rollback](https://helm.sh/docs/helm/helm_rollback/), and [release history](https://helm.sh/docs/helm/helm_history/).

## Task 6 – Create a Custom Chart

Scaffold `my-app` and inspect the generated files before editing its configuration.

| File or directory | Purpose |
|---|---|
| `Chart.yaml` | Chart metadata, including name and version |
| `values.yaml` | Default configuration consumed by templates |
| `templates/deployment.yaml` | Template for the application's Deployment |
| `templates/service.yaml` | Template for its Service |
| `templates/_helpers.tpl` | Shared naming and label helpers |
| `charts/` | Packaged or unpacked chart dependencies |

Go template expressions insert configuration and metadata into the generated manifests:

| Expression | Value it reads |
|---|---|
| `{{ .Values.replicaCount }}` | The effective replica count |
| `{{ .Chart.Name }}` | The chart name from `Chart.yaml` |
| `{{ .Release.Name }}` | The installation's release name |

For the custom chart, set the initial replica count to **3** and the image to **nginx:1.25**, as required by the exercise. The generated image configuration uses separate repository and tag fields. Keep the tag as a quoted string and keep autoscaling disabled for this manual scaling exercise.

Update existing configuration sections while preserving the remaining generated defaults. Duplicate keys or a partially replaced values file can cause parsing or template errors.

Validate the chart with linting, then preview its rendered manifests. Confirm the image and replica count before installing it as `my-release`. Linting and rendering help detect chart problems; live readiness still needs verification after installation.

| Stage | Expected Deployment readiness | Expected ready application Pods |
|---|---|---|
| Install with 3 replicas | `3/3` | 3 |
| Upgrade to 5 replicas | `5/5` | 5 |

Allow the workload to reach readiness before recording the results. A command-line replica override changes the release configuration without editing the local `values.yaml` file.

References: [Helm chart fundamentals](https://helm.sh/docs/chart_template_guide/getting_started/), [chart linting](https://helm.sh/docs/helm/helm_lint/), and [Deployment readiness](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).

## Task 7 – Clean Up

Uninstall each release created for this lab from its namespace. Once the exercise is complete, remove the temporary chart directory and values file if they are no longer needed; preserve any copies intended for the practice repository.

The `--keep-history` option retains release records while uninstalling the release's resources. It does not keep the application running.

**Verification:** With normal uninstallation and no unrelated releases in the checked namespace, the release list should be empty. If history was retained, uninstalled entries may remain visible; Helm 4 lists all statuses by default. In that case, confirm that no lab releases remain deployed and that their workloads are gone. A namespace-scoped listing does not prove that every namespace is empty.

References: [Helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) and [release listing](https://helm.sh/docs/helm/helm_list/).

## Troubleshooting from This Lab

| Message or issue | Explanation and correction |
|---|---|
| `--set: command not found` | `--set` is an option attached to a Helm operation. Enter the complete operation together; use line continuation correctly when splitting it across lines. |
| `my-app/Chart.yaml: no such file or directory` | The chart path is relative to the current directory. From inside `my-app`, target the current directory; from its parent, target `my-app`. |
| `mapping values are not allowed in this context` | Inspect the reported line and the lines above it for malformed YAML. Check indentation, tabs, colon spacing, and nested fields beneath an inline empty map. |
| Adding requests and limits beneath `resources: {}` | Convert the empty inline map into a normal nested mapping before adding resource settings. |
| `Chart.yaml: icon is recommended` | This informational recommendation does not itself cause linting to fail. |

The YAML error reported near line 10 requires inspecting the saved file to identify its exact cause. A valid snippet in a message does not confirm that the file on disk has the same content.

## Verification Checklist

These are checks to complete against the practice cluster, not a record of results already confirmed.

- [ ] Record the installed Helm version and review environment settings.
- [ ] Refresh the Bitnami index and record its distinct chart count.
- [ ] Confirm the initial NGINX release's ready Pod count and Service type.
- [ ] Confirm three replicas, NodePort, and resource settings for the values-file release.
- [ ] Confirm five replicas after upgrading `my-nginx`.
- [ ] Confirm rollback restores revision 1's configuration and creates a new revision.
- [ ] Confirm custom-chart linting passes and rendered values match the exercise.
- [ ] Confirm `my-release` changes from three ready replicas to five.
- [ ] Confirm cleanup removes the lab workloads and leaves no deployed lab releases.

## Key Takeaways

- Charts package related Kubernetes resources for reuse.
- Releases give each installation its own configuration and lifecycle.
- Values separate application configuration from manifest templates.
- Upgrades and rollbacks are tracked through release revisions.
- Linting, manifest previews, and live workload checks validate different stages.
- Correct chart paths and YAML formatting are essential for reliable Helm operations.
