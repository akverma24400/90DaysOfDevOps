# Day 58 – Metrics Server and Horizontal Pod Autoscaler

## Goal

Learn how Kubernetes measures resource usage and automatically changes the number of application Pods when CPU demand rises or falls.

## What I Covered

### 1. Metrics Server

Metrics Server collects CPU and memory usage from the nodes and Pods in a cluster. Once it is running, Kubernetes can report current resource usage. On a local Kind cluster, kubelet certificate settings may need an adjustment for Metrics Server to work; that adjustment should not be used in production.

### 2. Reading Resource Usage

Node and Pod metrics help identify which workloads are using the most CPU. These numbers show **actual usage**. Resource requests are used for scheduling, while limits cap how much a container may use. They are different from the usage shown by Metrics Server.

### 3. Preparing an Application for Autoscaling

The PHP-Apache example application needs a Deployment and a Service for this exercise. Its CPU request is **200 millicores (200m)**. The request gives the HPA a baseline for calculating CPU utilization. Without a CPU request, a CPU utilization target cannot be calculated for the workload.

### 4. Creating an HPA

The Horizontal Pod Autoscaler aims to keep average CPU utilization near **50% of the requested CPU**, with at least **1** and at most **10** replicas. For a 200m CPU request, 50% represents an average of about **100m CPU per Pod**. The target can initially appear as unknown while the first metrics are collected.

### 5. Testing Scale Up and Scale Down

Continuous requests to the application increase CPU usage and give the HPA a reason to add replicas. After the load stops, the HPA can reduce the replica count. Scale down normally takes longer because Kubernetes waits through a stabilization window to avoid repeatedly adding and removing Pods.

### 6. Managing the HPA with a Manifest

The HPA can also be managed with a declarative manifest using the **autoscaling/v2** API. Its behavior settings control how quickly replicas may be added or removed. In this exercise, scale up has no stabilization delay, while scale down uses a **300-second window**.

### 7. Cleanup

After testing, remove the practice HPA, Service, Deployment, and load generator. Leave Metrics Server installed for future exercises.



## Key Takeaway

Metrics Server provides usage data, CPU requests give the HPA a baseline, and the HPA adjusts replicas in response to demand. The 50% target is measured against the **CPU request**, not the CPU limit.
