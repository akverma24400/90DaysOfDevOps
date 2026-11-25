# Day 79 – Creating a Custom Helm Chart for AI-BankApp

## 📌 Overview

As part of the **90DaysOfDevOps Challenge**, Day 79 focuses on creating a custom Helm chart for the AI-BankApp project.

On Day 78, I explored Helm and deployed applications using existing community charts. Today, I took the next step by converting the Kubernetes manifests of AI-BankApp into a reusable and configurable custom Helm chart.

Instead of maintaining multiple Kubernetes YAML files, I created Helm templates that allow the entire application stack to be deployed and managed using a single Helm command.

## 🎯 Objectives

- Understand and analyze existing Kubernetes manifests.
- Create a custom Helm chart from scratch.
- Convert Kubernetes YAML files into reusable Helm templates.
- Configure deployments using `values.yaml`.
- Implement conditional deployments for MySQL and Ollama.
- Configure ConfigMaps, Secrets, Services, PVCs, and HPA.
- Preserve init containers, health probes, and lifecycle hooks.
- Validate the chart using Helm lint and template commands.
- Deploy and manage the application using Helm.

## 🏗️ Application Architecture

The AI-BankApp consists of three main components:

1. **BankApp:** Spring Boot-based banking application.
2. **MySQL:** Database for storing application data.
3. **Ollama:** AI chatbot service powered by a locally hosted language model.

Supporting Kubernetes resources include:

- ConfigMap for application configuration.
- Secret for database credentials.
- PersistentVolumeClaims for persistent storage.
- Services for internal communication.
- Horizontal Pod Autoscaler for application scaling.
- StorageClass for dynamic EBS provisioning.

## 📂 Project Structure

```text
helm-chart/
└── bankapp/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
        ├── _helpers.tpl
        ├── NOTES.txt
        ├── configmap.yaml
        ├── secrets.yaml
        ├── storage.yaml
        ├── bankapp-deployment.yaml
        ├── mysql-deployment.yaml
        ├── ollama-deployment.yaml
        ├── services.yaml
        └── hpa.yaml
```

## ⚙️ Implementation Steps

### 1. Clone the Repository

```bash
git clone -b feat/gitops https://github.com/TrainWithShubham/AI-BankApp-DevOps.git

cd AI-BankApp-DevOps
```

Explore the existing Kubernetes manifests:

```bash
ls k8s/
```

Studied the existing Deployment, Service, ConfigMap, Secret, PVC, HPA, Gateway, and other Kubernetes resources.

### 2. Scaffold the Custom Helm Chart

```bash
mkdir helm-chart
cd helm-chart

helm create bankapp
```

Remove the default Helm templates:

```bash
rm -rf bankapp/templates/*.yaml
rm -rf bankapp/templates/tests/
```

Retain `_helpers.tpl` and `NOTES.txt` for reusable template definitions and deployment information.

### 3. Configure Chart.yaml

Define the chart metadata, application version, description, maintainers, and keywords.

```yaml
apiVersion: v2
name: bankapp
description: AI-BankApp - Spring Boot banking application with MySQL and Ollama AI chatbot
type: application
version: 0.1.0
appVersion: "1.0.0"
```

### 4. Configure values.yaml

Created a centralized configuration file to manage application settings.

The configuration includes:

- BankApp image, replicas, resources, and autoscaling.
- MySQL image, resources, and persistent storage.
- Ollama image, model, resources, and persistent storage.
- Database credentials and application configuration.
- StorageClass configuration.
- Optional Gateway and TLS settings.

Example:

```yaml
bankapp:
  replicaCount: 4
  image:
    repository: trainwithshubham/ai-bankapp-eks
    tag: "latest"
    pullPolicy: Always

  service:
    type: ClusterIP
    port: 8080

  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 4
    targetCPUUtilization: 70

mysql:
  enabled: true
  image:
    repository: mysql
    tag: "8.0"
  persistence:
    size: 5Gi
    storageClass: gp3

ollama:
  enabled: true
  image:
    repository: ollama/ollama
    tag: "latest"
  model: tinyllama
  persistence:
    size: 10Gi
    storageClass: gp3
```

### 5. Create Helm Templates

Converted the original Kubernetes manifests into Helm templates using Go templating syntax.

**ConfigMap – configmap.yaml**

Stores database host, port, database name, and Ollama service URL.

**Secret – secrets.yaml**

Stores MySQL credentials using Helm's `b64enc` function to encode values automatically.

**Storage – storage.yaml**

Defines the StorageClass and PersistentVolumeClaims for MySQL and Ollama.

**BankApp Deployment – bankapp-deployment.yaml**

- Deploys the Spring Boot application.
- Uses init containers to wait for MySQL and Ollama.
- Configures environment variables using ConfigMap and Secret.
- Implements readiness and liveness probes.
- Supports configurable resource requests and limits.
- Allows HPA to manage replicas.

**MySQL Deployment – mysql-deployment.yaml**

- Deploys MySQL 8.0.
- Mounts persistent storage.
- Retrieves database credentials from Kubernetes Secrets.
- Implements database health checks.

**Ollama Deployment – ollama-deployment.yaml**

- Deploys the Ollama AI service.
- Mounts persistent storage.
- Uses a postStart lifecycle hook to pull the configured AI model.
- Implements readiness and liveness probes.

**Services – services.yaml**

Creates ClusterIP services for BankApp, MySQL, and Ollama.

**HPA – hpa.yaml**

Configures Horizontal Pod Autoscaling using CPU utilization.

The autoscaler supports:
- Minimum replicas: 2
- Maximum replicas: 4
- Target CPU utilization: 70%

### 6. Validate the Helm Chart

Check the chart for errors:

```bash
helm lint bankapp/
```

Render the Kubernetes manifests locally:

```bash
helm template my-bankapp bankapp/
```

Test configurable values:

```bash
helm template my-bankapp bankapp/ \
  --set bankapp.image.tag=abc1234 \
  --set bankapp.replicaCount=2 \
  --set ollama.enabled=false
```

This demonstrates how Helm allows environment-specific configuration without modifying the templates.

### 7. Dry Run Deployment

Validate the installation against the Kubernetes cluster:

```bash
helm install my-bankapp bankapp/ \
  --dry-run --debug \
  -n bankapp \
  --create-namespace
```

### 8. Deploy the Application on Kind

For a local Kind cluster, use its default StorageClass instead of the AWS EBS StorageClass.

```bash
helm install my-bankapp bankapp/ \
  -n bankapp \
  --create-namespace \
  --set storageClass.create=false \
  --set mysql.persistence.storageClass=standard \
  --set ollama.persistence.storageClass=standard
```

### 9. Verify the Deployment

Check Helm releases:

```bash
helm list -n bankapp
```

Check Kubernetes resources:

```bash
kubectl get all -n bankapp
```

Check persistent volume claims:

```bash
kubectl get pvc -n bankapp
```

Check ConfigMaps and Secrets:

```bash
kubectl get configmap,secret -n bankapp
```

Monitor pod status:

```bash
kubectl get pods -n bankapp -w
```

### 10. Access the Application

Forward the BankApp service to the local machine:

```bash
kubectl port-forward svc/my-bankapp-bankapp-service \
  -n bankapp 8080:8080
```

Open the application:

```text
http://localhost:8080
```

The AI-BankApp login page should be accessible once the application is ready.

### 11. Clean Up Resources

Uninstall the Helm release:

```bash
helm uninstall my-bankapp -n bankapp
```

## 💡 Key Learnings

Through this assignment, I learned:

- How to build custom Helm charts from existing Kubernetes manifests.
- How Helm templates use Go templating syntax.
- How to centralize application configuration using `values.yaml`.
- How to dynamically generate Kubernetes resource names.
- How to manage Secrets using Helm template functions.
- How to implement conditional resource creation.
- How to configure init containers and lifecycle hooks.
- How to integrate PersistentVolumeClaims with application deployments.
- How to configure Horizontal Pod Autoscaling.
- How to validate and deploy applications using Helm.

## 🔄 Helm vs Raw Kubernetes YAML

| Raw Kubernetes | Custom Helm Chart |
|---|---|
| Multiple YAML files | Reusable templates |
| Hardcoded values | Configurable values.yaml |
| Manual configuration changes | Environment-specific overrides |
| Manual resource management | Helm release management |
| Manual rollback process | Helm rollback support |

## 🚀 Final Outcome

Successfully worked on converting the AI-BankApp Kubernetes manifests into a custom Helm chart.

The chart brings together the Spring Boot application, MySQL database, and Ollama AI chatbot with configurable deployments, services, storage, secrets, and autoscaling.

**One Helm chart. One deployment command. A reusable application stack.**

## 📚 References

- [AI-BankApp DevOps Repository](https://github.com/TrainWithShubham/AI-BankApp-DevOps/tree/feat/gitops)
- [Helm Official Documentation](https://helm.sh/docs/)
- [90DaysOfDevOps Challenge](https://github.com/akverma24400/90DaysOfDevOps)

---

**Challenge:** #90DaysOfDevOps  
**Day:** 79  
**Topic:** Creating a Custom Helm Chart for AI-BankApp

#DevOps #Kubernetes #Helm #AWS #Docker #CloudNative #AI #90DaysOfDevOps