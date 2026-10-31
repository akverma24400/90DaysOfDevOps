# Day 65 – Terraform Modules: Build Reusable Infrastructure

## Overview

Today I learned how to use Terraform Modules to build reusable, scalable, and maintainable infrastructure.

Instead of writing all infrastructure resources in a single file, Terraform Modules allow us to organize configurations into smaller, reusable components.

Modules work like functions in programming: define infrastructure once and reuse it across multiple environments or projects.

## Task 1 – Understanding Module Structure

Created a structured Terraform project with a root module and two custom child modules:

- **Root Module:** The main working directory that manages the overall infrastructure and calls other modules.
- **Child Modules:** Reusable Terraform configurations stored in separate directories. They handle specific infrastructure components.

Organized the project into EC2 Instance and Security Group modules, each containing separate configuration, variable, and output files.

## Task 2 – Building a Custom EC2 Module

Created a reusable EC2 module from scratch.

**Implementation:**
- Defined input variables for AMI ID, instance type, subnet ID, security group IDs, instance name, and tags.
- Created an EC2 instance resource using the supplied variables.
- Used merged tags to combine the instance Name tag with additional custom tags.
- Exposed instance ID, public IP, and private IP through module outputs.

This module can be reused to launch multiple EC2 instances with different configurations.

## Task 3 – Building a Custom Security Group Module

Created a custom Security Group module to manage network access rules.

**Implementation:**
- Accepted VPC ID, security group name, ingress ports, and tags as input variables.
- Used a dynamic ingress block to generate multiple inbound rules from a list of ports.
- Configured outbound traffic to allow all egress.
- Exposed the Security Group ID as a module output.

**Key Learning:** Dynamic blocks help generate repeated nested configuration blocks without manually writing each rule.

## Task 4 – Calling Custom Modules from the Root Module

Integrated both custom modules into the root Terraform configuration.

**Implementation:**
- Created and configured the VPC and public subnet.
- Called the Security Group module to create a reusable security group.
- Called the EC2 module twice to launch two separate instances.
- Connected both EC2 instances to the same security group.
- Assigned different names to the web server and API server.
- Configured root outputs to display both instances' public IP addresses.

Validated the configuration and reviewed the execution plan before deployment.

## Task 5 – Using a Public Registry Module

Explored the official Terraform Registry and replaced manually managed VPC resources with the community-maintained AWS VPC module.

**Module Used:** terraform-aws-modules/vpc/aws

**Implementation:**
- Created a VPC with CIDR block 10.0.0.0/16.
- Configured two public and two private subnets.
- Disabled NAT Gateway to avoid unnecessary costs.
- Enabled DNS hostnames.
- Connected the custom EC2 and Security Group modules to the VPC module outputs.

**Key Learning:** Public registry modules save development time by providing reusable, tested infrastructure configurations.

Terraform downloads registry modules into the local .terraform/modules directory.

## Task 6 – Module Versioning and Best Practices

Learned how to manage module versions and maintain consistent infrastructure deployments.

Explored different version constraints:
- Exact version pinning for predictable deployments.
- Pessimistic version constraints for compatible updates.
- Version ranges for controlled flexibility.

Used Terraform initialization with upgrade to check for newer module versions.

Also explored Terraform state to understand how resources are organized under module-specific addresses.

### Five Terraform Module Best Practices

1. Always pin versions for public registry modules.
2. Keep modules focused on a single responsibility.
3. Use input variables instead of unnecessary hardcoded values.
4. Define outputs so other modules can reference resources.
5. Add a README.md file to every custom module.

## Key Learnings

- Understanding root modules and child modules.
- Building reusable EC2 and Security Group modules.
- Using dynamic blocks for repeated configuration.
- Passing variables and outputs between modules.
- Reusing public Terraform Registry modules.
- Managing module versions and dependencies.
- Understanding module resource addresses in Terraform state.
- Organizing infrastructure using a modular approach.

## Final Outcome

Successfully explored Terraform's modular architecture by building custom EC2 and Security Group modules and integrating them with the official AWS VPC registry module.

This exercise demonstrated how modular infrastructure improves reusability, consistency, scalability, and maintainability.

**Learning Track:** TrainWithShubham – 90DaysOfDevOps

**Day 65 Completed – Terraform Modules: Build Reusable Infrastructure.**