# Day 66 – Provision an EKS Cluster with Terraform Modules

## Overview

In Day 66 of the 90DaysOfDevOps challenge, I worked on provisioning an Amazon Elastic Kubernetes Service (EKS) cluster using Terraform Registry modules.

Instead of manually creating Kubernetes infrastructure through the AWS Console, I used Infrastructure as Code (IaC) to automate the provisioning process.

The project uses Terraform modules to create an AWS VPC, public and private subnets, NAT Gateway, EKS cluster, IAM roles, and managed worker nodes.

After provisioning the infrastructure, the next objective is to connect the cluster using kubectl, deploy an Nginx application, expose it through an AWS LoadBalancer, and finally destroy all resources to avoid unnecessary AWS costs.

## Project Objectives

- Provision an AWS VPC using Terraform Registry modules.
- Create public and private subnets across multiple Availability Zones.
- Configure a NAT Gateway for private subnet connectivity.
- Provision an Amazon EKS cluster using Terraform modules.
- Create an EKS managed node group.
- Configure kubectl to communicate with the EKS cluster.
- Deploy an Nginx application with three replicas.
- Expose the application using a Kubernetes LoadBalancer Service.
- Destroy all AWS resources after completing the exercise.

## Architecture

```text
                   AWS CLOUD
                       |
                 Ubuntu EC2
                       |
              Terraform Modules
                       |
                 AWS VPC
                 10.0.0.0/16
                       |
             +---------+---------+
             |                   |
        Public Subnets      Private Subnets
             |                   |
        NAT Gateway          EKS Cluster
             |                   |
        Internet GW         Managed Node Group
                                 |
                         +-------+-------+
                         |       |       |
                       Node 1  Node 2  Node 3
                         |       |       |
                         +-------+-------+
                                 |
                          Kubernetes Pods
                                 |
                          Nginx Deployment
                          (3 Replicas)
                                 |
                        LoadBalancer Service
                                 |
                           Internet Users
```

## Technology Stack

| Technology | Purpose |
|---|---|
| AWS EC2 | Terraform administration machine |
| AWS VPC | Network infrastructure |
| Amazon EKS | Managed Kubernetes service |
| Terraform | Infrastructure as Code |
| Terraform Registry | Reusable infrastructure modules |
| AWS CLI v2 | AWS authentication and management |
| kubectl | Kubernetes cluster management |
| Kubernetes | Container orchestration |
| Nginx | Sample application |
| Helm | Kubernetes package management |

## Project Structure

```text
terraform-eks/
│
├── providers.tf
├── vpc.tf
├── eks.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
│
├── k8s/
│   └── nginx-deployment.yaml
│
└── README.md
```

## Task 1 – Project Setup

Create the project directory:

```bash
mkdir terraform-eks
cd terraform-eks
```

Create the Terraform configuration files:

```bash
touch providers.tf
touch vpc.tf
touch eks.tf
touch variables.tf
touch outputs.tf
touch terraform.tfvars
```

Create the Kubernetes directory:

```bash
mkdir k8s
```

### Configure Terraform Providers

In `providers.tf`, configure the AWS and Kubernetes providers.

The AWS provider is pinned to the 5.x version series, while the Kubernetes provider is included for future Kubernetes resource management through Terraform.

The AWS region is configured using an input variable.

### Define Input Variables

In `variables.tf`, define:

| Variable | Default Value | Description |
|---|---|---|
| region | us-east-1 | AWS region |
| cluster_name | terraweek-eks | EKS cluster name |
| cluster_version | 1.31 | Kubernetes version specified in the original exercise |
| node_instance_type | t3.medium | Worker node instance type |
| node_desired_count | 2 | Desired worker node count |
| vpc_cidr | 10.0.0.0/16 | VPC IP address range |

The `terraform.tfvars` file contains the actual values supplied to Terraform.

**Version note:** Kubernetes 1.31 is now approaching the end of its EKS extended-support period. For a new deployment, check currently supported EKS versions and compatible AMI types. Amazon Linux 2023 is preferable to the older Amazon Linux 2 for new node groups.

## Task 2 – Create VPC Using Terraform Registry Module

For networking infrastructure, I used the `terraform-aws-modules/vpc/aws` module.

The VPC configuration includes:

- Two public subnets.
- Two private subnets.
- Multiple Availability Zones.
- One NAT Gateway to reduce networking costs.
- DNS hostnames enabled.
- Internet Gateway connectivity.

### Why does EKS need public and private subnets?

**Public Subnets:**

Public subnets provide internet-facing networking infrastructure. They can host internet-facing load balancers and other resources that need direct public connectivity.

**Private Subnets:**

Private subnets are used for EKS worker nodes and internal workloads. They provide network isolation while allowing outbound internet access through the NAT Gateway.

### Kubernetes Subnet Tags

Public subnet tags:

```hcl
public_subnet_tags = {
  "kubernetes.io/role/elb" = 1
}
```

Private subnet tags:

```hcl
private_subnet_tags = {
  "kubernetes.io/role/internal-elb" = 1
}
```

These tags help Kubernetes AWS load-balancer integrations identify suitable subnets when provisioning external and internal load balancers.

Initialize Terraform:

```bash
terraform init
```

Validate the configuration:

```bash
terraform validate
```

Review the execution plan:

```bash
terraform plan
```

## Task 3 – Create EKS Cluster Using Terraform Module

For EKS provisioning, I used the official community Terraform Registry module:

`terraform-aws-modules/eks/aws`

Module version:

```hcl
version = "~> 20.0"
```

The module provisions:

- Amazon EKS control plane.
- IAM roles and policies.
- EKS security groups.
- Managed node groups.
- Cluster access configuration.
- Kubernetes networking integration.

### EKS Managed Node Group

The managed node group is configured with:

| Configuration | Value |
|---|---|
| Node group name | terraweek_nodes |
| Instance type | t3.medium |
| Minimum nodes | 1 |
| Maximum nodes | 3 |
| Desired nodes | 2 |

The managed node group allows AWS to manage the underlying EC2 worker node lifecycle and integrate the nodes with the EKS control plane.

Initialize and download the modules:

```bash
terraform init
```

Validate:

```bash
terraform validate
```

Review infrastructure changes:

```bash
terraform plan
```

Apply the infrastructure:

```bash
terraform apply
```

Terraform provisions the required AWS infrastructure.

**Important:** Review the plan before applying because EKS, NAT Gateway, EC2 instances, and LoadBalancers can generate AWS charges.

## Task 4 – Connect kubectl to EKS

After successful infrastructure provisioning, Terraform provides the following outputs:

| Output | Value |
|---|---|
| Cluster Name | terraweek-eks |
| Cluster Region | us-east-1 |
| Cluster Endpoint | EKS API endpoint |

Update the kubeconfig file:

```bash
aws eks update-kubeconfig \
  --name terraweek-eks \
  --region us-east-1
```

Verify the current Kubernetes context:

```bash
kubectl config current-context
```

Check worker nodes:

```bash
kubectl get nodes
```

Check all pods:

```bash
kubectl get pods -A
```

Check cluster information:

```bash
kubectl cluster-info
```

### Authentication Troubleshooting

During the connection process, I encountered this error:

```text
You must be logged in to the server
The server has asked for the client to provide credentials
```

This error indicates that Kubernetes authentication or EKS authorization needs to be checked.

Troubleshooting commands:

```bash
aws sts get-caller-identity
```

```bash
aws eks get-token \
  --cluster-name terraweek-eks \
  --region us-east-1
```

```bash
aws eks list-access-entries \
  --cluster-name terraweek-eks \
  --region us-east-1
```

The IAM identity used by the EC2 instance must have the appropriate EKS access entry and authorization.

Updating kubeconfig alone does not grant Kubernetes permissions.

## Task 5 – Deploy Nginx Application

After connecting to the EKS cluster, the next step is deploying a sample Nginx application.

Create the Kubernetes manifest:

```bash
nano k8s/nginx-deployment.yaml
```

The manifest defines two Kubernetes resources:

**1. Deployment**

- Application: Nginx
- Replicas: 3
- Container image: nginx:latest
- Container port: 80

**2. Service**

- Service name: nginx-service
- Type: LoadBalancer
- Service port: 80
- Target port: 80

Apply the manifest:

```bash
kubectl apply -f k8s/nginx-deployment.yaml
```

Verify the deployment:

```bash
kubectl get deployments
```

Check pods:

```bash
kubectl get pods
```

Check the service:

```bash
kubectl get svc
```

Wait for the AWS LoadBalancer:

```bash
kubectl get svc nginx-service -w
```

Once the LoadBalancer has been provisioned, copy its external hostname.

Open the hostname in a browser:

```text
http://LOADBALANCER_HOSTNAME
```

Expected result:

```text
Welcome to nginx!
```

This confirms that the application is running inside the Kubernetes cluster and is accessible through the AWS LoadBalancer.

## Task 6 – Destroy AWS Infrastructure

Infrastructure cleanup is an important part of DevOps.

EKS clusters, NAT Gateways, EC2 instances, and LoadBalancers can continue generating charges even when they are not actively being used.

First, delete Kubernetes resources:

```bash
kubectl delete -f k8s/nginx-deployment.yaml
```

Wait until the AWS LoadBalancer has been fully deleted.

Verify that no Nginx resources remain:

```bash
kubectl get deployments
kubectl get pods
kubectl get svc
```

Next, destroy the Terraform-managed infrastructure:

```bash
terraform destroy
```

Confirm the operation when prompted.

Verify the cleanup in the AWS Console:

- EKS: No remaining exercise cluster.
- EC2: No remaining EKS worker instances.
- VPC: Terraform-created VPC deleted.
- NAT Gateway: Deleted.
- Elastic IP: Released.
- LoadBalancer: Deleted.

**Note:** Check for any separately created resources or retained dependencies that Terraform does not manage before considering the account clean.

## Important Terraform Commands

| Command | Purpose |
|---|---|
| `terraform init` | Initialize Terraform and download modules |
| `terraform validate` | Validate configuration |
| `terraform plan` | Preview infrastructure changes |
| `terraform apply` | Provision AWS resources |
| `terraform output` | Display Terraform outputs |
| `terraform state list` | List managed resources |
| `terraform destroy` | Destroy managed infrastructure |

## Key Learnings

Through this exercise, I explored:

1. Provisioning AWS infrastructure using reusable Terraform Registry modules.
2. Creating a multi-AZ VPC with public and private subnets.
3. Understanding NAT Gateway and subnet routing.
4. Deploying Amazon EKS using Terraform.
5. Configuring EKS managed node groups.
6. Connecting kubectl with AWS IAM authentication.
7. Deploying Kubernetes workloads.
8. Exposing applications using AWS LoadBalancer Services.
9. Managing infrastructure lifecycle using Terraform.
10. Cleaning up cloud resources to prevent unnecessary costs.

## Conclusion

Day 66 demonstrated how Infrastructure as Code can simplify Kubernetes infrastructure provisioning.

Instead of manually creating networking resources, IAM roles, EKS clusters, and worker nodes, Terraform modules make infrastructure repeatable, reusable, and easier to maintain.

The exercise also highlighted the importance of Kubernetes networking, IAM authentication, workload deployment, and cloud resource cleanup.

**Next Step:** Explore Terraform-based Kubernetes resource management, Helm deployments, and automated EKS application delivery through CI/CD pipelines.

---

**Challenge:** 90DaysOfDevOps – Day 66  
**Project:** EKS Cluster Provisioning with Terraform Modules  
**Author:** Akash Verma  
**Technologies:** AWS | Terraform | EKS | Kubernetes | Docker | Nginx