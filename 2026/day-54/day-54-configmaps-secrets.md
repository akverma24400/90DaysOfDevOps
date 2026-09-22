# Day 54 - Kubernetes ConfigMaps and Secrets

On Day 54, I practiced supplying configuration to Pods without baking settings into container images. I created ConfigMaps from literals and an Nginx file, injected configuration into Pods, created a Secret, and mounted Secret values as files.

## Goals

- Store ordinary settings in ConfigMaps and sensitive settings in Secrets.
- Supply key-value settings as environment variables and configuration files as mounted volumes.
- Inspect how mounted Secret values appear inside a Pod.
- Observe how updates to a mounted ConfigMap can reach a running Pod.

## ConfigMaps and Secrets at a glance

| Resource | Suitable for | In a Pod |
| --- | --- | --- |
| ConfigMap | Non-sensitive settings and configuration files | Environment variables or mounted files |
| Secret | Credentials and other sensitive values | Selected environment variables or mounted files |

Kubernetes Secret data appears base64-encoded in resource YAML. Base64 can be decoded and is not encryption. Access control and encryption at rest require appropriate cluster configuration.

## 1. Create a ConfigMap from literals

```bash
kubectl create configmap app-config \
  --from-literal=APP_ENV=production \
  --from-literal=APP_DEBUG=false \
  --from-literal=APP_PORT=8080

kubectl describe configmap app-config
kubectl get configmap app-config -o yaml
```

My screenshot shows `app-config` with three readable values: `APP_ENV=production`, `APP_DEBUG=false`, and `APP_PORT=8080`. A ConfigMap holds ordinary configuration, so these values are visible to users permitted to read the object.

## 2. Create an Nginx configuration ConfigMap

My `default.conf` contains a default response and a health endpoint:

```nginx
server {
    listen 80;

    location / {
        return 200 "Hello from ConfigMap!\n";
    }

    location /health {
        return 200 "healthy\n";
    }
}
```

```bash
kubectl create configmap nginx-config --from-file=default.conf=default.conf
kubectl describe configmap nginx-config
kubectl get configmap nginx-config -o yaml
```

The screenshot of `kubectl get configmap nginx-config -o yaml` shows the `default.conf` key and the file contents. When mounted as a ConfigMap volume, that key becomes a file named `default.conf`.

## 3. Supply ConfigMaps to Pods

For simple key-value settings, use `envFrom`:

```yaml
# app-config-pod.yml
apiVersion: v1
kind: Pod
metadata:
  name: app-config-pod
spec:
  containers:
    - name: busybox
      image: busybox:1.36
      command: ["/bin/sh", "-c"]
      args:
        - 'echo "ENV=$APP_ENV DEBUG=$APP_DEBUG PORT=$APP_PORT"; sleep 3600'
      envFrom:
        - configMapRef:
            name: app-config
```

For a full Nginx file, mount the ConfigMap at the directory Nginx reads:

```yaml
# nginx-config-pod.yml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-config-pod
spec:
  containers:
    - name: nginx
      image: nginx:stable
      volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/conf.d
          readOnly: true
  volumes:
    - name: nginx-config
      configMap:
        name: nginx-config
```

```bash
kubectl apply -f app-config-pod.yml -f nginx-config-pod.yml
kubectl wait --for=condition=Ready pod/app-config-pod pod/nginx-config-pod --timeout=120s
kubectl logs app-config-pod
kubectl exec nginx-config-pod -- cat /etc/nginx/conf.d/default.conf
```

My screenshot confirms both Pods became Ready, BusyBox printed `ENV=production DEBUG=false PORT=8080`, and the Nginx file was present inside its container. The screenshot does not show an HTTP request to `/health`. To verify the endpoint, forward the Pod's port and test from another terminal:

```bash
kubectl port-forward pod/nginx-config-pod 8080:80
# In another terminal:
curl -s http://localhost:8080/health
```

Expected response: `healthy`. Port forwarding avoids relying on `curl` being installed in the Nginx image.

## 4. Create and inspect a Secret

Use a **throwaway example password** for this exercise. Do not put real credentials in a README, a screenshot, or a command committed to Git:

```bash
kubectl create secret generic db-credentials \
  --from-literal=DB_USER=admin \
  --from-literal='DB_PASSWORD=<demo-password>'

kubectl get secret db-credentials -o yaml
kubectl get secret db-credentials -o jsonpath='{.data.DB_PASSWORD}' | base64 --decode
echo
```

My practice screenshot shows that the Secret was created, the YAML stored base64-encoded values, and decoding returned plaintext. The public PDF version covers the demo password. Anyone allowed to read and decode Secret data can recover its value, so Kubernetes RBAC and Secret handling matter.

## 5. Use the Secret inside a Pod

```yaml
# secret-pod.yml
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
spec:
  containers:
    - name: busybox
      image: busybox:1.36
      command: ["/bin/sh", "-c", "sleep 3600"]
      env:
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: DB_USER
      volumeMounts:
        - name: db-credentials
          mountPath: /etc/db-credentials
          readOnly: true
  volumes:
    - name: db-credentials
      secret:
        secretName: db-credentials
```

```bash
kubectl apply -f secret-pod.yml
kubectl wait --for=condition=Ready pod/secret-pod --timeout=120s
kubectl exec secret-pod -- printenv DB_USER
kubectl exec secret-pod -- ls /etc/db-credentials
kubectl exec secret-pod -- cat /etc/db-credentials/DB_USER
```

My screenshot shows `DB_USER` available as an environment variable and both `DB_USER` and `DB_PASSWORD` present as filenames under `/etc/db-credentials`. The mounted files contain plaintext values, not base64 strings. Avoid printing a password into public logs or documentation.

## 6. Observe ConfigMap update propagation

Create a small ConfigMap and a Pod that repeatedly reads its mounted file:

```bash
kubectl create configmap live-config --from-literal=message=hello
```

```yaml
# live-config-pod.yml
apiVersion: v1
kind: Pod
metadata:
  name: live-config-pod
spec:
  containers:
    - name: busybox
      image: busybox:1.36
      command: ["/bin/sh", "-c"]
      args:
        - 'while true; do cat /config/message; sleep 5; done'
      volumeMounts:
        - name: live-config
          mountPath: /config
          readOnly: true
  volumes:
    - name: live-config
      configMap:
        name: live-config
```

```bash
kubectl apply -f live-config-pod.yml
kubectl wait --for=condition=Ready pod/live-config-pod --timeout=120s
kubectl logs -f live-config-pod
# In another terminal:
kubectl patch configmap live-config --type merge -p '{"data":{"message":"world"}}'
```

The screenshot shows the Pod becoming Ready and logging the initial value `hello`. It does **not** show the patch or `world` appearing afterward, so I would capture that output before claiming the update was verified. Mounted ConfigMap files normally refresh after kubelet notices a change; this is not instantaneous, and `subPath` mounts do not receive these updates. Environment variables set from ConfigMaps remain unchanged in an existing Pod.

## 7. Clean up

```bash
kubectl delete pod app-config-pod nginx-config-pod secret-pod live-config-pod
kubectl delete configmap app-config nginx-config live-config
kubectl delete secret db-credentials
```

Check that the example resources have been removed. The screenshots provided for Day 54 do not include a final cleanup result.

## Screenshot evidence

1. `app-config` created from three literals.
2. `nginx-config` created from `default.conf`.
3. ConfigMap YAML displaying the `default.conf` contents.
4. BusyBox environment variables and Nginx volume mount inside Pods.
5. Secret creation, base64 storage, and a decode demonstration.
6. Secret environment variable and mounted files in a Pod.
7. The initial `hello` message from a mounted ConfigMap.

## Key takeaway

ConfigMaps and Secrets let a Pod consume configuration without rebuilding the application image. Environment variables are fixed when a Pod starts; ordinary mounted ConfigMap files can reflect later changes. Secret values must still be protected because their base64 representation is easy to decode.

---

Part of my [90DaysOfDevOps](https://github.com/akverma24400/90DaysOfDevOps/tree/master/2026/day-54) journey.
