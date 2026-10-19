# Day 62 — Providers, Resources and Dependencies

## Overview

Day 62 focuses on understanding Terraform providers, AWS resources, implicit and explicit dependencies, lifecycle rules, and infrastructure cleanup.

The objective is to build a complete AWS networking stack using Terraform and understand how Terraform manages resource creation, updates, and destruction.

## Objectives

- Understand AWS provider configuration and version constraints.
- Create a VPC and its networking components.
- Understand implicit and explicit dependencies.
- Deploy an EC2 instance in a public subnet.
- Explore Terraform lifecycle arguments.
- Visualize dependencies using `terraform graph`.
- Destroy infrastructure safely to avoid unnecessary AWS charges.

---

## Task 1: Exploring the AWS Provider

The AWS provider allows Terraform to communicate with AWS APIs and manage infrastructure resources.

The provider configuration specifies the AWS region and the permitted provider versions. Running `terraform init` downloads the required provider plugin and initializes the project.

### Provider Version Constraints

| Constraint | Description                                                                        |
| ---------- | ---------------------------------------------------------------------------------- |
| `~> 5.0`   | Allows compatible versions within the 5.x series, excluding version 6.0 and later. |
| `>= 5.0`   | Allows version 5.0 and any later version, including newer major versions.          |
| `= 5.0.0`  | Requires exactly version 5.0.0.                                                    |

### Purpose of `.terraform.lock.hcl`

The Terraform dependency lock file records the selected provider versions and their checksums.

It helps maintain consistent provider installations across different environments and team members.

**Key learning:** Version constraints define which provider versions are acceptable, while the lock file records the selected version and verifies the provider package.

---

## Task 2: Building a VPC from Scratch

A Virtual Private Cloud (VPC) provides an isolated networking environment for AWS resources.

The infrastructure consists of five core networking resources.

| Resource                | Purpose                                                           |
| ----------------------- | ----------------------------------------------------------------- |
| VPC                     | Creates an isolated network with CIDR block `10.0.0.0/16`.        |
| Public Subnet           | Creates a subnet with CIDR block `10.0.1.0/24`.                   |
| Internet Gateway        | Enables internet connectivity for appropriately routed resources. |
| Route Table             | Defines how network traffic is directed.                          |
| Route Table Association | Associates the route table with the public subnet.                |

The route table contains a default route directing internet-bound traffic to the Internet Gateway.

Public IP assignment is enabled for instances launched in the subnet.

### Verification

After applying the configuration, verify the following resources in the AWS console:

- VPC
- Public subnet
- Internet Gateway
- Route table and default route
- Route table association

Confirm that all five resources are connected correctly.

**Key learning:** A public subnet requires a suitable route to an Internet Gateway. Assigning a public IP alone does not guarantee internet connectivity.

---

## Task 3: Understanding Implicit Dependencies

Terraform automatically identifies dependencies when one resource references another resource's attributes.

### Dependencies in the Configuration

- **Subnet → VPC:** The subnet references the VPC ID.
- **Internet Gateway → VPC:** The Internet Gateway references the VPC ID.
- **Route Table → VPC:** The route table references the VPC ID.
- **Default Route → Internet Gateway:** The route references the Internet Gateway ID.
- **Route Table Association → Subnet and Route Table:** The association references both resources.
- **Security Group → VPC:** The security group references the VPC ID.
- **EC2 Instance → Subnet and Security Group:** The instance references the subnet and security group.

### How Terraform Handles Dependencies

Terraform builds a dependency graph from resource references and dependency declarations. It uses this graph to determine the correct execution order.

For example, Terraform creates the VPC before the subnet because the subnet requires the VPC ID.

If a subnet references a VPC that does not exist, AWS cannot create the subnet successfully.

**Key learning:** Resource references provide Terraform with the information needed to determine the correct creation order.

---

## Task 4: Adding a Security Group and EC2 Instance

### Security Group

The security group controls inbound and outbound traffic for the EC2 instance.

The configured rules include:

- SSH access on port 22.
- HTTP access on port 80.
- Outbound traffic allowed to all destinations.

The security group is associated with the VPC and attached to the EC2 instance.

**Security consideration:** Allowing SSH from `0.0.0.0/0` exposes port 22 to the entire internet. For production environments, restrict SSH access to trusted IP addresses or use a more secure management method.

### EC2 Instance

The EC2 instance is configured with the following properties:

- Amazon Linux 2 AMI compatible with the selected AWS region.
- Instance type: `t2.micro`.
- Public IPv4 address association enabled.
- Security group attached.
- Resource tag: `TerraWeek-Server`.
- SSH key pair configured for secure access.

### Verification

After applying the configuration, verify the instance state, subnet, security group, and public IPv4 address in the AWS console.

For SSH connectivity, ensure that the key pair exists in the same AWS region, the private key is available, and the security group permits access from your IP address.

**Key learning:** Successful EC2 connectivity depends on correct networking, security rules, public IP configuration, and valid SSH credentials.

---

## Task 5: Explicit Dependencies with `depends_on`

Terraform normally infers dependencies through resource references. However, some relationships cannot be inferred automatically.

An explicit dependency can be used to ensure that an S3 bucket for application logs is created only after the EC2 instance.

This demonstrates how Terraform handles dependencies even when there is no direct resource attribute reference.

### Visualizing the Dependency Graph

Terraform can generate a dependency graph in DOT format. The graph can be inspected directly or converted into an image using Graphviz.

The graph helps identify:

- Resource relationships.
- Creation and destruction order.
- Dependencies between networking components.
- Relationships between compute and storage resources.

### Real-World Uses of `depends_on`

1. **Infrastructure prerequisites:** Ensure a prerequisite resource or configuration operation is processed before a dependent resource when no direct reference expresses the relationship.
2. **Service configuration:** Establish ordering between resources that depend on another resource's configuration but do not reference its attributes directly.

An explicit dependency guarantees Terraform ordering, not application readiness. For example, creating an EC2 instance does not guarantee that the application running on it is healthy.

**Key learning:** Prefer implicit dependencies through resource references whenever possible, and use `depends_on` when a genuine dependency cannot otherwise be expressed.

---

## Task 6: Lifecycle Rules and Destroy

Terraform lifecycle arguments control how resources are created, replaced, protected, and updated.

### Three Important Lifecycle Arguments

| Argument                | Description                                                                          |
| ----------------------- | ------------------------------------------------------------------------------------ |
| `create_before_destroy` | Attempts to create a replacement before destroying the existing resource.            |
| `prevent_destroy`       | Rejects plans that would destroy a resource while the protection remains configured. |
| `ignore_changes`        | Ignores changes to selected attributes during normal Terraform update planning.      |

### When to Use Lifecycle Rules

**Create Before Destroy**

Useful when replacing resources with minimal downtime, provided the old and new resources can coexist.

**Prevent Destroy**

Useful for protecting critical infrastructure, such as production databases, against accidental destruction through Terraform.

**Ignore Changes**

Useful when selected attributes are intentionally managed outside Terraform or are expected to change independently.

### Understanding Terraform Destroy

Terraform destroys resources in reverse dependency order, removing dependent resources before the resources they rely on.

For example, the EC2 instance should be removed before its security group. Networking resources must also be destroyed in an order that respects their dependencies.

Before cleanup, review the destruction plan carefully. Afterward, verify in the AWS console that the resources have been removed.

**Key learning:** Lifecycle rules control resource replacement and update behavior, while the dependency graph determines a valid destruction order.

---

## Final Verification Checklist

- [x] AWS provider configured with a version constraint.
- [x] Terraform initialized successfully.
- [x] Provider lock file reviewed.
- [x] VPC and public subnet created.
- [x] Internet Gateway attached to the VPC.
- [x] Route table and default route configured.
- [x] Route table associated with the public subnet.
- [x] Security group configured.
- [x] EC2 instance deployed and public IP verified.
- [x] SSH key pair configured correctly.
- [x] S3 bucket dependency configured.
- [x] Dependency graph generated and inspected.
- [x] Lifecycle arguments understood and tested.
- [x] Resources destroyed successfully.
- [x] AWS console checked for leftover resources.

---

## Key Takeaways

1. Provider version constraints help control infrastructure tooling versions.
2. Terraform automatically detects dependencies through resource references.
3. Explicit dependencies handle relationships Terraform cannot infer.
4. Dependency graphs help explain resource creation and destruction order.
5. Lifecycle rules influence resource replacement, protection, and change detection.
6. Public cloud infrastructure requires appropriate networking and security configuration.
7. Terraform cleanup helps prevent unnecessary AWS charges.

## Conclusion

Day 62 demonstrates how Terraform manages connected AWS infrastructure rather than isolated resources.

Understanding providers, resources, dependencies, and lifecycle rules provides a strong foundation for building maintainable, reproducible, and scalable cloud infrastructure.

**Day 62 completed — continuing the journey toward Infrastructure as Code and Cloud Automation.**

\#Terraform #AWS #InfrastructureAsCode #DevOps #CloudComputing #90DaysOfDevOps
