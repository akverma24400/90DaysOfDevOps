# Day 56 – Kubernetes StatefulSets

> **90 Days of DevOps** | Stable pod identity, predictable scaling, and persistent storage.

## Overview

Deployments are useful for applications whose replicas can be replaced interchangeably. Stateful applications, such as databases, often need a predictable identity and storage associated with a particular replica.

This exercise uses Nginx to demonstrate StatefulSet behavior: stable pod names, individual DNS records, dedicated Persistent Volume Claims (PVCs), and data persistence after pod replacement.

**Scope:** This README explains the solution and expected verification results. YAML manifests and command scripts can be maintained separately. The results below are expected outcomes, not recorded cluster test results.

## Learning Goals

- Understand the difference between Deployments and StatefulSets.
- Connect a StatefulSet to a Headless Service.
- Create three replicas with stable names and separate PVCs.
- Resolve each pod through its individual DNS name.
- Verify that stored data survives pod deletion.
- Observe ordered scaling and PVC retention.

## Prerequisites

- A running Kubernetes cluster and a configured kubectl client.
- Working cluster DNS.
- A suitable StorageClass with dynamic provisioning, or matching pre-provisioned Persistent Volumes.
- Enough resources and storage for up to five replicas.

## Deployment vs StatefulSet

| Feature | Deployment | StatefulSet |
| --- | --- | --- |
| Pod names | Generated names that change when pods are replaced | Stable ordinal names, such as `web-0` and `web-1` |
| Startup | No per-replica ordering guarantee | Ordered by default, waiting for each pod to become Ready |
| Storage | PVC use is configured in the pod template; it does not automatically create a claim per replica | `volumeClaimTemplates` provides a dedicated claim for each replica |
| Network identity | Usually accessed through a shared Service | Individual pod DNS names through a governing Headless Service |
| Typical use | Interchangeable application replicas | Applications needing stable identity or per-replica storage |

## Lab Configuration

The following names keep all examples consistent. Substitute your own names if your manifests differ.

| Setting | Value |
| --- | --- |
| StatefulSet | `web` |
| Headless Service | `web-headless` |
| Namespace | `default` |
| Pod label | `app: web` |
| Container image | `nginx` |
| Initial replicas | `3` |
| Volume claim template | `web-data` |
| Storage request per replica | `100Mi` |
| Access mode | `ReadWriteOnce` |
| Container mount path | `/usr/share/nginx/html` |
| Pod management policy | `OrderedReady` (default) |
| PVC retention | `Retain` for deletion and scale-down (default) |

## Task 1 – Understand the Problem

Create an Nginx Deployment with three replicas and inspect their names. Delete one pod and compare its name with the replacement pod's name. The replacement has a different generated name.

This behavior works well when any replica can handle the same request. A database cluster may need to identify a particular member consistently for peer discovery and association with its data.

Delete the demonstration Deployment before starting the StatefulSet exercise.

**Verification answer:** Changing pod names can break configurations that depend on a member's stable hostname. StatefulSets provide predictable identities that remain associated with replica ordinals.

## Task 2 – Create a Headless Service

Configure the Service with `clusterIP: None` and a selector matching the StatefulSet pod label. The StatefulSet's `serviceName` must reference this Service.

The Headless Service supports direct discovery of the selected pods without assigning a shared virtual ClusterIP.

**Expected result:** The Service's `CLUSTER-IP` column displays `None`.

## Task 3 – Create the StatefulSet

Configure three Nginx replicas and a `web-data` volume claim template requesting `100Mi` with `ReadWriteOnce` access. Mount that volume at `/usr/share/nginx/html` so the test file is written to persistent storage.

Watch the pods start. With the default ordered policy, `web-0` becomes Ready before `web-1` is created, followed by `web-2`.

| Pod | Dedicated PVC |
| --- | --- |
| `web-0` | `web-data-web-0` |
| `web-1` | `web-data-web-1` |
| `web-2` | `web-data-web-2` |

**Verification answer:** Expect three Ready pods with the names above and three Bound PVCs. Claim names follow `<template-name>-<pod-name>`.

## Task 4 – Verify Stable Network Identity

From a temporary BusyBox pod inside the cluster, resolve each pod's fully qualified DNS name and compare the returned address with that pod's current IP.

| Pod | DNS name |
| --- | --- |
| `web-0` | `web-0.web-headless.default.svc.cluster.local` |
| `web-1` | `web-1.web-headless.default.svc.cluster.local` |
| `web-2` | `web-2.web-headless.default.svc.cluster.local` |

**Verification answer:** Each lookup should resolve to the corresponding pod's IP. The DNS name stays stable after replacement, although the IP can change. These names assume the cluster DNS domain is `cluster.local`.

## Task 5 – Verify Persistent Storage

Write a different message into each pod's mounted `index.html` file.

| Pod | File content |
| --- | --- |
| `web-0` | `Data from web-0` |
| `web-1` | `Data from web-1` |
| `web-2` | `Data from web-2` |

Delete `web-0`, wait for its replacement to become Ready, and read its file again.

**Expected result:** The replacement is still named `web-0`, reuses `web-data-web-0`, and returns `Data from web-0`.

**Verification answer:** The content should be identical because it was stored on the mounted persistent volume. A file written only to the container filesystem would not demonstrate persistence.

## Task 6 – Observe Ordered Scaling

Scale from three replicas to five. Observe `web-3` starting before `web-4`. Each new replica receives its own PVC.

Scale back to three. Observe `web-4` terminating before `web-3`.

| Stage | Desired pods | Expected PVC count |
| --- | --- | --- |
| Initial deployment | `web-0` through `web-2` | 3 |
| Scale up to five | `web-0` through `web-4` | 5 |
| Scale down to three | `web-0` through `web-2` | 5 |

**Verification answer:** Five PVCs remain under the default retention policy. The retained claims for `web-3` and `web-4` can be reused when scaling up again.

## Task 7 – Clean Up

Delete the StatefulSet and Headless Service, then inspect the remaining PVCs. Remove the lab's PVCs manually when their data is no longer needed. Remove the temporary DNS test pod if it still exists.

**Verification answer:** With the default `Retain` policy, the PVCs are not automatically deleted with the StatefulSet. An explicitly configured `Delete` retention policy changes this behavior.

Deleting a PVC can also delete its backing storage, depending on the Persistent Volume's reclaim policy.

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| PVC stays Pending | StorageClass, provisioner, available capacity, and claim events |
| Only `web-0` appears | Its scheduling, volume binding, container logs, and readiness; ordered startup waits for it |
| Pod DNS lookup fails | Service selector, `serviceName`, namespace, pod readiness, and cluster DNS; retry after DNS cache expiry |
| Data disappears after replacement | Ensure the test path is mounted from `web-data` and the original PVC remains |
| PVC count differs after scale-down | Check the StatefulSet's PVC retention policy |

## Key Takeaways

- A StatefulSet keeps a replica's name and storage association predictable.
- The Headless Service enables individual pod DNS names.
- Volume claim templates give replicas separate persistent storage.
- Default ordered management makes scale-up and scale-down predictable.
- Persistent storage survives pod replacement, but it is not a backup.
- A StatefulSet does not configure database replication, failover, or backups by itself.

## Reference

- [Kubernetes documentation: StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
