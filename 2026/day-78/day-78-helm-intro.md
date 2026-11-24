# Day 78 – Introduction to Helm and Chart Basics

## Overview

As part of the **90DaysOfDevOps Challenge**, Day 78 focuses on learning Helm, the package manager for Kubernetes.

Before deploying applications using Helm, I prepared a fresh AWS EC2 instance and configured Docker as the container runtime for my Kubernetes lab environment.

## Objectives

- Understand the fundamentals of Helm.
- Learn about Helm Charts, Releases, Repositories, and Values.
- Prepare an AWS EC2 environment for Kubernetes.
- Install and configure Docker.
- Set up Kind and kubectl.
- Deploy and manage applications using Helm.
- Practice Helm upgrades, rollbacks, and release management.

## Infrastructure Setup

| Component | Configuration |
|---|---|
| Cloud Provider | AWS |
| Compute | Amazon EC2 |
| Operating System | Ubuntu 24.04 LTS |
| Container Runtime | Docker |
| Kubernetes Tool | Kind (planned) |
| Kubernetes CLI | kubectl (planned) |
| Package Manager | Helm (planned) |

## Step 1 – Update the System

Updated Ubuntu package repositories and installed essential dependencies.

```bash
sudo apt update
sudo apt upgrade -y
```

Installed required packages:

```bash
sudo apt install -y curl wget git unzip \
apt-transport-https ca-certificates \
gnupg lsb-release conntrack socat
```

## Step 2 – Install Docker

Installed Docker using Ubuntu's package manager.

```bash
sudo apt install -y docker.io
```

## Step 3 – Configure Docker Service

Enabled Docker to start automatically during system boot and started the service.

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

## Step 4 – Configure Docker Permissions

Added the current Ubuntu user to the Docker group to execute Docker commands without using `sudo`.

```bash
sudo usermod -aG docker $USER
```

Applied the updated group membership:

```bash
newgrp docker
```

## Step 5 – Verify Docker Installation

Checked the Docker client and server versions:

```bash
docker version
```

Verified running containers:

```bash
docker ps
```

Checked Docker service status:

```bash
sudo systemctl status docker
```

**Expected Result:** Docker service should be active and running, and Docker commands should execute without permission errors.

## Next Steps

The following tasks will be completed as part of the Day 78 lab:

- [ ] Install kubectl.
- [ ] Install Kind.
- [ ] Create a Kubernetes cluster with one control-plane node and two worker nodes.
- [ ] Install Helm.
- [ ] Add and explore Helm repositories.
- [ ] Deploy MySQL using a Helm Chart.
- [ ] Create a custom `mysql-values.yaml` file.
- [ ] Deploy a second MySQL release using custom values.
- [ ] Practice Helm upgrade, history, and rollback.
- [ ] Explore Helm Chart structure.
- [ ] Document practical learnings and screenshots.

## Key Learnings

- Docker is used to run and manage containers.
- `systemctl enable` configures a service to start automatically at boot.
- `systemctl start` starts a service immediately.
- Adding a user to the Docker group allows Docker commands without `sudo`.
- A properly configured container runtime is an important prerequisite for this Kubernetes lab.

## Challenge

Part of the **90DaysOfDevOps Challenge** by TrainWithShubham.

**Author:** Akash Verma  
**GitHub:** [akverma24400](https://github.com/akverma24400)

#90DaysOfDevOps #DevOps #AWS #EC2 #Docker #Kubernetes #Helm #LearningInPublic