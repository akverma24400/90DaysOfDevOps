# Day 57 – Kubernetes Resource Requests, Limits, and Probes

## Goal

Give Kubernetes enough information to place Pods on nodes, control their resource usage, and detect unhealthy containers. This lab uses a local `kind` cluster and six small Pods to explore scheduling, out-of-memory (OOM) kills, and health probes.

> Keep the Pod manifests in a separate `manifests/` folder. This README records what each manifest should do, how to verify it, and what the result means.

## Prerequisites

- A running `kind` cluster and a working `kubectl` context.
- Confirm that the nodes are ready with `kubectl get nodes`.
- Enough free resources for the small Pods in this lab. The oversized Pod is intentionally unschedulable.

## Requests, limits, and QoS

| Setting | What it does | Value for the first Pod |
| --- | --- | --- |
| CPU request | Used by the scheduler when choosing a node | `100m` (0.1 CPU core) |
| CPU limit | Caps CPU use through throttling | `250m` (0.25 CPU core) |
| Memory request | Used by the scheduler when choosing a node | `128Mi` (128 mebibytes) |
| Memory limit | Caps memory use; exceeding it can cause an OOM kill | `256Mi` (256 mebibytes) |

Requests reserve *scheduling capacity*; they do not mean a container always consumes that much. Limits constrain runtime usage. Memory limits are enforced reactively, so an OOM kill is possible when usage crosses the limit, but its exact timing can vary.

Kubernetes assigns a Pod a **QoS class** based on the requests and limits of its containers:

| QoS class | Basic condition |
| --- | --- |
| `Guaranteed` | Every container has CPU **and** memory requests and limits, with each request equal to its corresponding limit. |
| `Burstable` | At least one CPU or memory request or limit is set, but the Pod does not meet the `Guaranteed` rules. |
| `BestEffort` | No container has CPU or memory requests or limits. |

## Probes at a glance

| Probe | Question Kubernetes asks | What happens on failure? |
| --- | --- | --- |
| Liveness | Is the application still functioning? | The container is restarted after the configured number of consecutive failures. |
| Readiness | Can the application receive traffic now? | The Pod becomes unready and is removed from ready Service endpoints; the container keeps running. |
| Startup | Has the application finished starting? | Liveness and readiness checks wait until it succeeds. Repeated startup failures restart the container. |

## Suggested files

```text
day-57/
├── README.md
└── manifests/
    ├── resource-pod.yaml
    ├── stress-pod.yaml
    ├── pending-pod.yaml
    ├── liveness-pod.yaml
    ├── readiness-pod.yaml
    └── startup-pod.yaml
```

Use the Pod names in the sections below, or substitute the names you chose in your manifests. Run the commands from the `day-57/` directory.

## Task 1 – Set resource requests and limits

Create `manifests/resource-pod.yaml` with one container. Under its `resources` field, set requests to **100m CPU / 128Mi memory** and limits to **250m CPU / 256Mi memory**.

```bash
kubectl apply -f manifests/resource-pod.yaml
kubectl describe pod resource-demo
```

Look for the container's **Requests** and **Limits**, then the Pod's **QoS Class**. Because the requests are lower than the limits, the expected class is **`Burstable`**.

## Task 2 – Observe an OOM kill

Create `manifests/stress-pod.yaml` using `polinux/stress`. Set a **100Mi** memory limit and run `stress` with `--vm 1 --vm-bytes 200M --vm-hang 1` to allocate more memory than the limit permits.

```bash
kubectl apply -f manifests/stress-pod.yaml
kubectl get pod stress-demo -w
kubectl describe pod stress-demo
```

In `kubectl describe`, inspect **Last State → Terminated** for `Reason: OOMKilled` and typically `Exit Code: 137`. With the default Pod restart policy, the container may restart repeatedly and show `CrashLoopBackOff`. If an OOM kill does not appear immediately, give it time and inspect the container's last state; memory enforcement is reactive.

**Answer:** An OOM-killed container typically exits with code **137**. Confirm `OOMKilled` as the reason too, because exit code 137 alone only shows that the process received `SIGKILL`.

## Task 3 – See why a Pod stays Pending

Create `manifests/pending-pod.yaml` with requests for **100 CPU cores** and **128Gi memory**. A normal local `kind` cluster cannot fit that request on any node.

```bash
kubectl apply -f manifests/pending-pod.yaml
kubectl get pod pending-demo
kubectl describe pod pending-demo
```

The Pod should remain **Pending**. In **Events**, look for a `FailedScheduling` message such as `0/3 nodes are available: 3 Insufficient cpu, 3 Insufficient memory`. The node count and exact wording depend on your cluster. Record the event you actually see:

> My `FailedScheduling` event: _paste your event here_

The scheduler compares **requests** with available node capacity. Changing a limit alone would not solve this scheduling failure.

## Task 4 – Test a liveness probe

Create `manifests/liveness-pod.yaml` with BusyBox. At container startup, create `/tmp/healthy`; after 30 seconds, remove it and keep the main process running. Configure an `exec` liveness probe that runs `cat /tmp/healthy` every **5 seconds**, with `failureThreshold: 3`.

```bash
kubectl apply -f manifests/liveness-pod.yaml
kubectl get pod liveness-demo -w
kubectl describe pod liveness-demo
```

After the file disappears, three consecutive failed checks cause a container restart. The startup command creates the file again, so the cycle can repeat. Keep the main process alive after removing the file; otherwise, its normal exit would also cause a restart and make the probe test unclear.

> My observed `RESTARTS` count: _record the value from `kubectl get pod`_

The count depends on how long you watch, so there is no fixed number for this question.

## Task 5 – Test a readiness probe

Create `manifests/readiness-pod.yaml` with `nginx` and an HTTP readiness probe for **`/` on port `80`**. Name the Pod `readiness-demo`.

```bash
kubectl apply -f manifests/readiness-pod.yaml
kubectl expose pod readiness-demo --port=80 --name=readiness-svc
kubectl get pod readiness-demo
kubectl get endpoints readiness-svc
```

Once the Pod is ready, the Service should list its Pod IP as an endpoint. Remove the default page to make the default Nginx response for `/` fail the HTTP probe:

```bash
kubectl exec readiness-demo -- rm /usr/share/nginx/html/index.html
kubectl get pod readiness-demo -w
kubectl get endpoints readiness-svc
```

Wait until the readiness failure threshold is reached. **15 seconds may not be enough** if you leave the probe settings at their defaults. The Pod should show **`0/1` READY**, and the Service should have no ready endpoint for it. Compare the `RESTARTS` column before and after.

**Answer:** A failed readiness probe **does not restart** the container; it stops routing Service traffic to that Pod. This test assumes the standard Nginx image and its default page/configuration.

## Task 6 – Give a slow container time to start

Create `manifests/startup-pod.yaml` with a container that waits **20 seconds**, creates `/tmp/started`, and then keeps running. Add an `exec` startup probe for that file with `periodSeconds: 5` and `failureThreshold: 12`. Add a liveness probe that checks the same file.

```bash
kubectl apply -f manifests/startup-pod.yaml
kubectl get pod startup-demo -w
kubectl describe pod startup-demo
```

The startup configuration allows roughly **60 seconds** (`5 × 12`) for the file to appear. Until the startup probe succeeds, Kubernetes does not run the liveness probe. Once it succeeds, liveness checks can begin.

**What if `failureThreshold` were 2?** The available startup window would be roughly **10 seconds**, shorter than the 20-second startup. The startup probe would repeatedly fail and restart the container before it could become healthy. Actual probe timing can vary slightly.

## Task 7 – Clean up

```bash
kubectl delete service readiness-svc --ignore-not-found
kubectl delete -f manifests/ --ignore-not-found
kubectl get pods,services
```

Check that the lab Pods and `readiness-svc` have been removed. The built-in `kubernetes` Service may still be listed.

## Results to record

| Check | Expected result | My observation |
| --- | --- | --- |
| Resource Pod QoS | `Burstable` | _Add result_ |
| Stress Pod | `OOMKilled`, commonly exit code `137` | _Add result_ |
| Oversized Pod | `Pending` with `FailedScheduling` / insufficient resources | _Add exact event_ |
| Liveness Pod | Restart count increases after failed checks | _Add count_ |
| Readiness Pod | `0/1` ready, no Service endpoint, no probe-triggered restart | _Add result_ |
| Startup Pod | Becomes healthy after about 20 seconds with the larger startup budget | _Add result_ |

## Key takeaways

1. Requests affect **where** a Pod can run; limits affect **how much** CPU and memory its containers may use.
2. CPU over a limit is throttled. Memory over a limit can result in an OOM kill.
3. Liveness restarts an unhealthy container; readiness controls traffic without restarting it.
4. A startup probe protects a slow-starting application from premature liveness checks.

## References

- [Kubernetes: Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Kubernetes: Pod Quality of Service Classes](https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/)
- [Kubernetes: Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
