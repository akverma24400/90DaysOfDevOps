# Day 52 - Kubernetes Namespaces and Deployments

On Day 52, I organized resources with namespaces and used a Deployment to manage Nginx Pods. I tested self-healing, changed the replica count, rolled out a new image, and rolled back to the previous version.

## Goals

- Explore built-in and custom namespaces.
- Run a Deployment with multiple replicas.
- See how a Deployment replaces a deleted Pod.
- Scale Pods up and down.
- Perform and undo a rolling update.

## Namespaces I explored

```bash
kubectl get namespaces
kubectl get pods -n kube-system
```

| Namespace | Purpose |
| --- | --- |
| `default` | Resources without an explicitly selected namespace. |
| `kube-system` | Core Kubernetes components and system add-ons. |
| `kube-public` | Resources intended to be publicly readable in the cluster. |
| `kube-node-lease` | Lease objects used for node heartbeats. |

The `kube-system` output in my screenshot included CoreDNS, etcd, the API server, controller manager, scheduler, and networking components. I observed these system Pods without changing them.

## 1. Create namespaces

I created `dev` and `staging` with commands, then created `production` from a manifest:

```bash
kubectl create namespace dev
kubectl create namespace staging
```

```yaml
# namespace.yml
apiVersion: v1
kind: Namespace
metadata:
  name: production
```

```bash
kubectl apply -f namespace.yml
kubectl get namespaces
```

The screenshot shows all three custom namespaces as `Active`. A namespace scopes namespaced resources: the same Pod name can exist in two different namespaces.

To practice placing and finding resources in a namespace:

```bash
kubectl run nginx-dev --image=nginx:latest -n dev
kubectl run nginx-staging --image=nginx:latest -n staging
kubectl get pods -n dev
kubectl get pods -n staging
kubectl get pods -A
```

`kubectl get pods` without a namespace flag only checks the current context's namespace, usually `default`.

## 2. Create a Deployment

A Deployment expresses how many matching Pods should be available. It manages ReplicaSets, which create and replace the Pods.

```yaml
# nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: dev
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.24
          ports:
            - containerPort: 80
```

```bash
kubectl apply -f nginx-deployment.yaml
kubectl get deployments -n dev
kubectl get pods -n dev
```

My screenshot shows `nginx-deployment` with `3/3` ready and three running Pods in `dev`.

| Deployment column | Meaning |
| --- | --- |
| `READY` | Available replicas compared with desired replicas. |
| `UP-TO-DATE` | Replicas created from the current Pod template. |
| `AVAILABLE` | Replicas that have met the availability requirements. |

The selector `app: nginx` must match the label on the Pod template. The `template` contains the Pod blueprint, while `replicas: 3` defines the initial desired count.

## 3. Observe self-healing

```bash
kubectl get pods -n dev
kubectl delete pod <one-deployment-pod-name> -n dev
kubectl get pods -n dev
```

After I deleted one Deployment-managed Pod, a replacement appeared with a **different name**. The controller restored the desired replica count. A standalone Pod from Day 51 would not be recreated by a Deployment.

## 4. Scale the Deployment

```bash
kubectl scale deployment nginx-deployment --replicas=5 -n dev
kubectl get pods -n dev
kubectl scale deployment nginx-deployment --replicas=2 -n dev
kubectl get pods -n dev
```

The screenshot shows five running Deployment Pods after scaling up and two after scaling down. Kubernetes terminated the excess Pods to match the new desired count. I also edited the manifest and applied it again during practice; that can change the replica count back to the value in the YAML file. Keep the manifest and live configuration aligned to avoid surprises on a later `kubectl apply`.

## 5. Roll out and roll back an image

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.25 -n dev
kubectl rollout status deployment/nginx-deployment -n dev
kubectl rollout history deployment/nginx-deployment -n dev
kubectl rollout undo deployment/nginx-deployment -n dev
kubectl rollout status deployment/nginx-deployment -n dev
kubectl describe deployment nginx-deployment -n dev | grep Image
```

My rollout completed successfully. The history showed two revisions, and after the undo the Deployment image was back to **`nginx:1.24`**. During the rollback, `kubectl` warned that the Deployment had been managed by both `kubectl apply` and a rollout operation; I checked rollout status and the final image rather than relying on the warning alone.

A rolling update replaces Pods gradually according to the Deployment strategy. Whether clients experience downtime also depends on readiness, replica count, available capacity, and how traffic reaches the Pods; a rolling update alone does not guarantee zero downtime.

## 6. Clean up

```bash
kubectl delete deployment nginx-deployment -n dev
kubectl delete pod nginx-dev -n dev
kubectl delete pod nginx-staging -n staging
kubectl delete namespace dev staging production
kubectl get namespaces
kubectl get pods -A
```

Deleting a namespace also deletes its namespaced resources. Check which namespace each command targets before deleting anything.

## Screenshot evidence

1. Built-in namespaces and `kube-system` Pods.
2. Creating the `dev`, `staging`, and `production` namespaces.
3. First Nginx Deployment with three replicas.
4. Deleting a Pod and seeing a replacement.
5. Scaling to five replicas, then down to two.
6. Updating Nginx to `1.25` and rolling back to `1.24`.

## Key takeaway

Namespaces organize resources, while Deployments maintain a desired set of Pods. Deleting one Pod, changing the replica count, or updating the image gives Kubernetes a new state to reconcile.

---

Part of my [90DaysOfDevOps](https://github.com/akverma24400/90DaysOfDevOps/tree/master/2026/day-52) journey.
