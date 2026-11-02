# Day 67 --- TerraWeek Capstone: Multi-Environment Infrastructure with Terraform

A reusable, workspace-driven AWS infrastructure project that provisions
isolated **development**, **staging**, and **production** environments
from one Terraform codebase.

This capstone brings together the Terraform concepts covered during
TerraWeek: HCL, providers, resources, variables, outputs, data sources,
state management, remote backends, custom modules, registry modules, and
Terraform workspaces.

> **Project status:** Update the deployment and cleanup sections with
> your actual verification results. Do not mark an environment as
> deployed or destroyed until you have confirmed it in Terraform and the
> AWS Console.

------------------------------------------------------------------------

## Table of contents

-   [Overview](#overview)
-   [Architecture](#architecture)
-   [Project structure](#project-structure)
-   [Environments](#environments)
-   [Custom modules](#custom-modules)
-   [Workspace-based configuration](#workspace-based-configuration)
-   [Prerequisites](#prerequisites)
-   [Getting started](#getting-started)
-   [Deploy the environments](#deploy-the-environments)
-   [Verify the deployment](#verify-the-deployment)
-   [Terraform workspaces explained](#terraform-workspaces-explained)
-   [Terraform best practices](#terraform-best-practices)
-   [Cleanup](#cleanup)
-   [TerraWeek learning recap](#terraweek-learning-recap)
-   [Troubleshooting](#troubleshooting)
-   [Documentation and evidence](#documentation-and-evidence)

## Overview

The goal is to manage three AWS environments using:

-   **One Terraform root module** for shared infrastructure logic.
-   **Three custom child modules** for the VPC, security group, and EC2
    instance.
-   **Three Terraform workspaces** (`dev`, `staging`, and `prod`) to
    maintain separate state.
-   **Separate `.tfvars` files** to supply environment-specific
    configuration.
-   **An S3 remote backend** to store Terraform state centrally and
    support state locking.

Each environment receives its own VPC, public subnet, internet gateway,
route table, security group, and EC2 instance.

## Architecture

``` text
                         One Terraform codebase
                                  |
                       Terraform root module
                                  |
                   terraform.workspace selects env
                                  |
             +--------------------+--------------------+
             |                    |                    |
            dev                staging                prod
             |                    |                    |
        dev.tfvars          staging.tfvars          prod.tfvars
             |                    |                    |
             +--------------------+--------------------+
                                  |
                         Custom child modules
                                  |
             +--------------------+--------------------+
             |                    |                    |
          VPC module        Security Group module   EC2 module
             |                    |                    |
        VPC + subnet        Ingress / egress rules   EC2 instance
        Internet gateway
        Route table
                                  |
                              AWS account
```

### Resource layout per environment

``` text
Environment
   |
   +-- VPC
   |    +-- Public subnet
   |    +-- Internet gateway
   |    +-- Route table
   |    +-- Route table association
   |
   +-- Security group
   |    +-- Environment-specific ingress ports
   |    +-- Allow-all egress
   |
   +-- EC2 instance
        +-- Environment-specific instance type
        +-- Public IP
        +-- Project and environment tags
```

The environments use different VPC CIDR ranges to avoid address-space
overlap.

## Project structure

``` text
terraweek-capstone/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── locals.tf
├── dev.tfvars
├── staging.tfvars
├── prod.tfvars
├── .gitignore
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security-group/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── ec2-instance/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### Why this structure?

-   Root files separate provider/backend configuration, inputs, outputs,
    locals, and module composition.
-   Each child module owns one responsibility, making it easier to test,
    reuse, and maintain.
-   Environment-specific values stay outside the reusable module code.
-   The same root configuration can be used for all three environments.
-   Module inputs and outputs make dependencies explicit.

Keep credentials and sensitive values out of source control. The example
`.gitignore` below excludes local Terraform state, provider data, and
variable files; commit `.terraform.lock.hcl` in a real project so
provider selections remain reproducible.

Example `.gitignore`:

``` gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
crash.log
crash.*.log
```

> **Note:** If you use a remote backend, state is stored remotely, but
> local state-related files and plans should still be protected. Do not
> commit secrets or generated plan files.

## Environments

  Setting         Development     Staging         Production
  --------------- --------------- --------------- ---------------
  Workspace       `dev`           `staging`       `prod`
  VPC CIDR        `10.0.0.0/16`   `10.1.0.0/16`   `10.2.0.0/16`
  Public subnet   `10.0.1.0/24`   `10.1.1.0/24`   `10.2.1.0/24`
  EC2 type        `t2.micro`      `t2.small`      `t3.small`
  Ingress ports   `22, 80`        `22, 80, 443`   `80, 443`
  SSH ingress     Allowed         Allowed         Not allowed

The production security group intentionally does not expose SSH. For
production access, prefer a controlled approach such as AWS Systems
Manager Session Manager rather than opening SSH to the internet.

### Environment variable files

`dev.tfvars`:

``` hcl
vpc_cidr      = "10.0.0.0/16"
subnet_cidr   = "10.0.1.0/24"
instance_type = "t2.micro"
ingress_ports = [22, 80]
```

`staging.tfvars`:

``` hcl
vpc_cidr      = "10.1.0.0/16"
subnet_cidr   = "10.1.1.0/24"
instance_type = "t2.small"
ingress_ports = [22, 80, 443]
```

`prod.tfvars`:

``` hcl
vpc_cidr      = "10.2.0.0/16"
subnet_cidr   = "10.2.1.0/24"
instance_type = "t3.small"
ingress_ports = [80, 443]
```

These files contain configuration, not credentials. If your deployment
requires secrets, inject them through a secure mechanism such as
environment variables or a secrets manager.

## Custom modules

The root module composes three focused modules.

### 1. VPC module --- `modules/vpc/`

**Inputs**

-   `cidr`
-   `public_subnet_cidr`
-   `environment`
-   `project_name`

**Resources**

-   AWS VPC
-   Public subnet
-   Internet gateway
-   Route table
-   Route table association

**Outputs**

-   `vpc_id`
-   `subnet_id`

The module creates the network foundation for an environment. Resources
should carry consistent project and environment tags.

### 2. Security group module --- `modules/security-group/`

**Inputs**

-   `vpc_id`
-   `ingress_ports`
-   `environment`
-   `project_name`

**Resources**

-   Security group
-   Dynamic ingress rules based on the supplied port list
-   Egress rule allowing outbound traffic

**Output**

-   `sg_id`

The ingress rules are configurable, so each workspace can use a
different set of allowed ports without duplicating module code. Restrict
ingress source CIDRs appropriately for your own deployment; do not
assume that opening a port makes it safe.

### 3. EC2 instance module --- `modules/ec2-instance/`

**Inputs**

-   `ami_id`
-   `instance_type`
-   `subnet_id`
-   `security_group_ids`
-   `environment`
-   `project_name`

**Resources**

-   AWS EC2 instance

**Outputs**

-   `instance_id`
-   `public_ip`

The module receives the subnet and security group IDs from the other
modules and launches an instance using the selected environment's
sizing.

## Workspace-based configuration

Terraform exposes the active workspace through the built-in expression:

``` hcl
terraform.workspace
```

A typical `locals.tf`:

``` hcl
locals {
  environment = terraform.workspace
  name_prefix = "${var.project_name}-${local.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
    Workspace   = terraform.workspace
  }
}
```

The root module uses the active workspace to name and tag resources and
passes the appropriate values into the child modules.

Example module composition (adapt input names to the exact variables
declared in your modules):

``` hcl
module "vpc" {
  source             = "./modules/vpc"
  cidr               = var.vpc_cidr
  public_subnet_cidr = var.subnet_cidr
  environment        = local.environment
  project_name       = var.project_name
}

module "security_group" {
  source       = "./modules/security-group"
  vpc_id       = module.vpc.vpc_id
  ingress_ports = var.ingress_ports
  environment  = local.environment
  project_name = var.project_name
}

module "ec2_instance" {
  source             = "./modules/ec2-instance"
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  subnet_id          = module.vpc.subnet_id
  security_group_ids = [module.security_group.sg_id]
  environment        = local.environment
  project_name       = var.project_name
}
```

Root outputs should expose the module outputs, for example:

``` hcl
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "instance_id" {
  value = module.ec2_instance.instance_id
}

output "public_ip" {
  value = module.ec2_instance.public_ip
}
```

Make sure the root variables include every value referenced by the root
module, including `ami_id` if your EC2 module requires it. Select an AMI
that is valid for the AWS region and architecture you are using.

## Prerequisites

-   An AWS account and an IAM identity with permissions to create and
    manage the required VPC, EC2, security group, and backend resources.
-   AWS CLI configured with the intended credentials and region.
-   Terraform installed.
-   An S3 bucket created for the remote state backend.
-   Backend bucket versioning enabled; configure encryption and tightly
    scoped access.
-   A valid AMI ID for the selected AWS region.

Check your tools and AWS identity:

``` bash
terraform version
aws --version
aws sts get-caller-identity
aws configure get region
```

The S3 backend bucket must exist before `terraform init`. Keep the
backend configuration consistent with your actual bucket, key, and
region.

## Getting started

Clone the repository and enter the project directory:

``` bash
git clone <your-repository-url>
cd terraweek-capstone
```

Format and initialize Terraform:

``` bash
terraform fmt -recursive
terraform init
terraform validate
```

Create the workspaces:

``` bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
```

List and inspect workspaces:

``` bash
terraform workspace list
terraform workspace show
```

If a workspace already exists, use
`terraform workspace select <workspace>` instead of creating it again.

## Deploy the environments

Always select the intended workspace and review the plan before
applying.

### Development

``` bash
terraform workspace select dev
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

### Staging

``` bash
terraform workspace select staging
terraform plan -var-file="staging.tfvars"
terraform apply -var-file="staging.tfvars"
```

### Production

``` bash
terraform workspace select prod
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

The `-var-file` option explicitly selects the environment configuration.
When using it, make sure all required variables are provided by that
file, defaults, or another approved input method.

## Verify the deployment

Inspect outputs in each workspace:

``` bash
terraform workspace select dev
terraform output

terraform workspace select staging
terraform output

terraform workspace select prod
terraform output
```

Check the AWS Console or CLI to verify:

-   Three VPCs exist with the expected, distinct CIDR ranges.
-   Each VPC has its own subnet, internet gateway, route table, and
    route association.
-   Three EC2 instances exist with the expected instance types.
-   Security group ingress differs by environment.
-   Resource names and tags identify the project and environment.

Expected instance naming pattern:

-   `terraweek-dev-server`
-   `terraweek-staging-server`
-   `terraweek-prod-server`

Example CLI checks:

``` bash
aws ec2 describe-vpcs \
  --query 'Vpcs[].{VpcId:VpcId,CidrBlock:CidrBlock,Tags:Tags}'

aws ec2 describe-instances \
  --query 'Reservations[].Instances[].{InstanceId:InstanceId,Type:InstanceType,State:State.Name,PublicIp:PublicIpAddress,Tags:Tags}'
```

### Are the environments completely isolated?

They have separate Terraform workspace states and separate VPCs, but
that alone does **not** guarantee complete security or account-level
isolation. They may still share an AWS account, IAM identities, quotas,
backend bucket, and other account-wide services. Network isolation
depends on routing, peering, gateways, security groups, network ACLs,
and any shared connectivity you configure. For stronger production
isolation, consider separate AWS accounts and organizational controls.

## Terraform workspaces explained

### What does `terraform.workspace` return?

It returns the name of the currently selected Terraform workspace. In
this project, it returns `dev`, `staging`, or `prod`.

### Where is each workspace's state stored?

With the local backend, non-default workspace state is stored under:

``` text
terraform.tfstate.d/<workspace>/terraform.tfstate
```

With an S3 backend, Terraform uses a workspace-specific state key. For a
configured key such as `terraweek-capstone/terraform.tfstate`, a
non-default workspace commonly uses a path in this form:

``` text
env:/<workspace>/<configured-key>
```

The exact object path depends on the backend's configured `key` and
workspace key prefix. For this project, inspect the actual S3 object
path rather than assuming it.

### Workspaces versus separate directories

Workspaces let multiple state instances share the same Terraform
configuration and module code. This is convenient when environments are
structurally similar and differ mainly in variable values.

Separate directories or separate root configurations can be more
appropriate when environments need substantially different
infrastructure, providers, permissions, deployment lifecycles, or
independent configuration changes. Workspaces are separate state, not a
security boundary.

## Terraform best practices

  --------------------------------------------------------------------------
  Area                                Recommended practice
  ----------------------------------- --------------------------------------
  File structure                      Separate providers, backend,
                                      variables, outputs, locals, and
                                      resource/module composition

  State management                    Use a remote backend, enable locking,
                                      and enable state versioning

  Variables                           Parameterize configuration; use
                                      environment-specific variable files
                                      and validation rules

  Modules                             Keep modules focused; define clear
                                      inputs and outputs

  Registry modules                    Pin module versions and review changes
                                      before upgrading

  Workspaces                          Use workspace-aware configuration when
                                      environments share the same
                                      architecture

  Security                            Never commit credentials or state;
                                      encrypt remote state and restrict
                                      backend access

  Workflow                            Run `terraform fmt`,
                                      `terraform validate`, and
                                      `terraform plan` before applying

  Tagging                             Tag resources with project,
                                      environment, and management metadata

  Naming                              Use a consistent
                                      `<project>-<environment>-<resource>`
                                      pattern

  Cleanup                             Destroy temporary/non-production
                                      infrastructure when it is no longer
                                      needed

  Production safety                   Review plans carefully and use
                                      stronger account and access separation
                                      where appropriate
  --------------------------------------------------------------------------

A useful day-to-day workflow:

``` bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

## Cleanup

Destroy resources in reverse environment order. Review each plan and
confirm the selected workspace before approving destruction.

``` bash
terraform workspace select prod
terraform destroy -var-file="prod.tfvars"

terraform workspace select staging
terraform destroy -var-file="staging.tfvars"

terraform workspace select dev
terraform destroy -var-file="dev.tfvars"
```

Verify in AWS that the instances, VPCs, subnets, security groups,
internet gateways, and route tables created by this project have been
removed.

Then return to the default workspace and delete the non-default
workspaces:

``` bash
terraform workspace select default
terraform workspace delete prod
terraform workspace delete staging
terraform workspace delete dev
```

Do not delete a workspace until its managed resources have been
destroyed and its state is no longer needed. Confirm that the AWS
account is clean of this project's resources; do not assume that
deleting a workspace deletes cloud resources.

## TerraWeek learning recap

  -----------------------------------------------------------------------
  Day                                 Concepts
  ----------------------------------- -----------------------------------
  61                                  Infrastructure as Code, HCL,
                                      `init`, `plan`, `apply`, `destroy`,
                                      state basics

  62                                  Providers, resources, dependencies,
                                      lifecycle rules

  63                                  Variables, outputs, data sources,
                                      locals, functions

  64                                  Remote backend, state locking,
                                      import, drift detection

  65                                  Custom modules, registry modules,
                                      versioning

  66                                  EKS with Terraform modules,
                                      real-world cluster provisioning

  67                                  Workspaces, multi-environment
                                      infrastructure, capstone project
  -----------------------------------------------------------------------

## Troubleshooting

### S3 state lock error (HTTP 412 / `PreconditionFailed`)

An S3 `PutObject` HTTP 412 while acquiring a Terraform state lock can
indicate that the lock object already exists or that a previous
operation did not release it.

1.  Check whether another Terraform process or teammate is currently
    running an operation.
2.  Do not remove the lock while an apply, plan, or destroy is active.
3.  If the operation is definitely no longer running, use the lock ID
    reported by Terraform:

``` bash
terraform force-unlock <LOCK_ID>
```

4.  Confirm the workspace and inspect state:

``` bash
terraform workspace show
terraform state list
```

5.  Retry with a fresh plan before applying.

Avoid `-lock=false` as a workaround. Disabling locking can allow
concurrent state writes and risk state corruption or infrastructure
inconsistencies. Never manually delete a lock object from S3 unless you
fully understand the backend locking mechanism and have verified no
operation is active.

### No outputs found

If `terraform output` reports that no outputs are found:

-   Confirm that you selected the workspace where resources were
    applied.
-   Confirm that root-level `output` blocks are declared.
-   Confirm that apply completed successfully.
-   Check that the output values reference the correct module outputs.

### Workspace or variable-file mismatch

Before applying, run:

``` bash
terraform workspace show
```

Then explicitly select the intended workspace and use its matching
variable file. A workspace name does not automatically load a matching
`.tfvars` file.

## Documentation and evidence

For the Day 67 learning submission, add the following evidence to your
project documentation:

1.  Screenshot of all three environments running in AWS.
2.  Screenshot or terminal output showing `terraform output` for `dev`,
    `staging`, and `prod`.
3.  Directory tree showing the root files and three custom modules.
4.  Relevant module and root configuration snippets.
5.  The three variable files with environment differences highlighted.
6.  Verification that all resources were destroyed after testing.

Suggested companion documentation filename:

``` text
day-67-terraweek-capstone.md
```

------------------------------------------------------------------------

## Key takeaway

Terraform workspaces make it possible to manage multiple state instances
from one reusable codebase. Combined with focused modules,
environment-specific variable files, remote state, and consistent
tagging, they provide a practical foundation for repeatable
infrastructure management.

**One codebase. Three environments. Reusable modules. Independent
state.**
