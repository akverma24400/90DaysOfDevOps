# Day 51 - Kubernetes Manifests and My First Pods

On Day 51, I moved from exploring a kind cluster to creating Pods with YAML manifests. I deployed Nginx and BusyBox, checked the containers, generated a Pod imperatively, validated YAML with dry runs, and practiced selecting resources by label.

## Goals

- Understand the main fields of a Kubernetes manifest.
- Write and apply Pod manifests.
- Inspect running Pods with `kubectl`.
- Compare imperative and declarative commands.
- Validate manifests and filter Pods by labels.

## Pod manifest structure

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
  labels:
    app: my-app
spec:
  containers:
    - name: my-container
      image: nginx:latest
      ports:
        - containerPort: 80
```

| Field | Meaning |
| --- | --- |
| `apiVersion` | API version for the resource; a core Pod uses `v1`. |
| `kind` | Type of resource, here `Pod`. |
| `metadata` | Name, labels, namespace, and other identifying information. |
| `spec` | Desired configuration, including containers, images, and ports. |

A Pod is the smallest deployable unit in Kubernetes. A standalone Pod is useful for this exercise; Deployments manage replacement Pods in later tasks.

## 1. Create and verify an Nginx Pod

Write `nginx-pod.yml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
```

```bash
kubectl apply -f nginx-pod.yml
kubectl get pods
kubectl get pods -o wide
kubectl describe pod nginx-pod
kubectl logs nginx-pod
kubectl exec -it nginx-pod -- /bin/bash
# Inside the container:
curl localhost:80
exit
```

In my screenshots, `nginx-pod` reached `1/1 Running`. I entered the container, requested `localhost:80`, and received the Nginx welcome page. The `-o wide` output also showed the Pod IP and the worker node where it ran.

> Use the filename that actually exists. My practice file is `nginx-pod.yml`; `nginx-pod.yaml` is a different path.

## 2. Create a BusyBox Pod

Write `busybox-pod.yml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox-pod
  labels:
    app: busybox
    environment: dev
spec:
  containers:
    - name: busybox
      image: busybox:latest
      command: ["sh", "-c", "echo Hello from BusyBox && sleep 3600"]
```

```bash
kubectl apply -f busybox-pod.yml
kubectl get pods
kubectl logs busybox-pod
```

My screenshot shows `busybox-pod` running and the log line `Hello from BusyBox`. The `sleep` command keeps this example container alive so there is time to inspect it. With a Pod's default restart policy, a command that repeatedly exits immediately can eventually cause restart backoff.

## 3. Imperative and declarative approaches

The Nginx and BusyBox Pods used a **declarative** manifest and `kubectl apply`. I also practiced an **imperative** command to create a Redis Pod:

```bash
kubectl run redis-pod --image=redis:latest
kubectl get pods
kubectl get pod redis-pod -o yaml
```

Kubernetes adds runtime and server-managed fields to the YAML returned by `kubectl get`, such as `status`, `uid`, and `resourceVersion`. That output is useful for inspection but should not be copied wholesale into a new hand-written manifest.

To generate a starting manifest without creating a Pod:

```bash
kubectl run test-pod --image=nginx --dry-run=client -o yaml
```

## 4. Validate before applying

```bash
kubectl apply -f nginx-pod.yml --dry-run=client
kubectl apply -f nginx-pod.yml --dry-run=server
```

The client dry run prepares the request without persisting it. The server dry run sends a validation request to the API server without saving the resource, so it requires a reachable cluster. My screenshots show both dry runs completing after I corrected the `.yaml` versus `.yml` filename mismatch.

Experiment with an invalid field to see validation feedback. Removing an image can lead to a Pod that cannot start even if the object passes schema validation; a dry run does not prove the container will run.

## 5. Labels and filtering

```bash
kubectl get pods --show-labels
kubectl get pods -l app=nginx
kubectl get pods -l environment=dev
kubectl label pod nginx-pod environment=production
kubectl get pods -l environment=production
kubectl label pod nginx-pod environment-
```

I filtered Pods by `app` and `environment`, added the `environment=production` label to Nginx, verified the selector, and removed the label. Labels let commands and controllers select groups of resources without relying on Pod names.

For extra practice, create a third manifest with `app`, `environment`, and `team` labels, then filter by each label.

## 6. Clean up

```bash
kubectl delete pod nginx-pod
kubectl delete pod redis-pod
kubectl delete pod busybox-pod
kubectl get pods
```

Alternatively, delete a resource using its manifest if it still exists:

```bash
kubectl delete -f nginx-pod.yml
```

My cleanup screenshot ends with `No resources found in default namespace`. Deleting a Pod by name and then trying to delete the same Pod from its manifest may return `NotFound`; that simply means the resource is already gone.

## Screenshot evidence

1. Creating and inspecting an Nginx Pod.
2. Checking the Nginx welcome page from inside the Pod.
3. Creating BusyBox and reading its logs.
4. Generating YAML and validating a manifest with dry runs.
5. Listing, selecting, adding, and removing Pod labels.
6. Deleting the practice Pods.

## Key takeaway

YAML declares the desired resource, while `kubectl` lets me apply, inspect, and validate it. Checking Pod status, logs, and labels helped connect the manifest fields with what actually ran in the cluster.

---

Part of my [90DaysOfDevOps](https://github.com/akverma24400/90DaysOfDevOps/tree/master/2026/day-51) journey.
