# Day 61 — Introduction to Terraform and Your First AWS Infrastructure

A practical guide for creating an S3 bucket, adding an EC2 instance, inspecting state, updating a tag, and removing the lab.

**Environment:** Ubuntu or Ubuntu on WSL; AWS Region `ap-south-1` (Mumbai). Run these commands on your own machine or practice server.

**Status:** This is a walkthrough. Example plans below are expected results, not evidence that resources have already been deployed. Add your actual outputs and screenshots after completing the lab.

> **AMI update:** Amazon Linux 2 reached end of support on June 30, 2026. This guide uses Amazon Linux 2023 instead of the assignment's older AMI. AWS publishes regional AMI IDs through Systems Manager public parameters. [AWS notice](https://aws.amazon.com/amazon-linux-2/) · [AMI lookup documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami-parameter-store.html)

## 1. Understand Infrastructure as Code

### What is IaC, and why does it matter?

Infrastructure as Code means describing infrastructure in files that a tool can use to create and manage it. For example, a Terraform resource block can describe an EC2 instance's image, size, and tags.

In DevOps, this makes infrastructure repeatable and reviewable alongside application changes. It reduces repeated console work, inconsistent settings, and reliance on someone remembering every setup step. Configuration in Git also provides a history of changes.

### Declarative and cloud-agnostic

**Declarative:** You describe the result you want. Terraform calculates the operations needed to reach that result.

**Cloud-agnostic:** Terraform supports many platforms through providers, including AWS, Azure, and Google Cloud. The workflow is shared, but resource definitions remain provider-specific; an AWS EC2 block does not automatically become an Azure VM.

Source: [HashiCorp — Infrastructure as Code](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/infrastructure-as-code)

### How the tools differ

| Tool | Typical use | How infrastructure is described |
| --- | --- | --- |
| Terraform | Provisioning and managing resources across providers | Declarative Terraform configuration, commonly HCL; tracks resource mappings in state |
| AWS CloudFormation | AWS-native infrastructure management through stacks | YAML or JSON templates; AWS manages stack state |
| Ansible | Configuring systems, installing software, deploying applications; can also provision infrastructure | YAML playbooks that run tasks; many modules express a desired state |
| Pulumi | Infrastructure management using familiar programming languages | Python, TypeScript, Go, and other supported languages, plus YAML; its engine manages resource state |

Sources: [CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/) · [Ansible](https://docs.ansible.com/projects/ansible/latest/getting_started/introduction.html) · [Pulumi](https://www.pulumi.com/docs/iac/concepts/)

## 2. Install Terraform and configure AWS

Skip installation if `terraform -version` and `aws --version` already work.

### Terraform on Ubuntu / WSL Ubuntu

Run each command separately:

```bash
sudo apt-get update
sudo apt-get install -y curl gnupg lsb-release unzip

curl -fsSL https://apt.releases.hashicorp.com/gpg |
  gpg --dearmor |
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
  sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update
sudo apt-get install -y terraform
terraform -version
```

For macOS with Homebrew:

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform -version
```

For Windows with Chocolatey, in an Administrator terminal:

```powershell
choco install terraform
terraform -version
```

Source: [HashiCorp installation instructions](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

### AWS CLI on Ubuntu / WSL Ubuntu

Check the architecture of the machine where you are installing the CLI:

```bash
uname -m
```

For `x86_64`:

```bash
curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

For `aarch64` / ARM64, use this download command instead, then run the same unzip and installation commands:

```bash
curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -o awscliv2.zip
```

Source: [AWS CLI installation instructions](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

### Authenticate

If your practice EC2 server already has an appropriate IAM role attached, Terraform can use that role. For a local lab using IAM user credentials:

```bash
aws configure
```

Enter your own access key and secret key locally, region `ap-south-1`, and output format `json`. Use a lab IAM identity, not root account keys. Do not put credentials into `main.tf` or Git.

For an organization using IAM Identity Center, use its SSO configuration and login instead.

Check which identity is active:

```bash
aws sts get-caller-identity
```

It returns `Account`, `Arn`, and `UserId`. Authentication success does not prove that the identity can create resources. It also needs permissions for this lab's S3 and EC2 operations and `ssm:GetParameter` for the public AMI lookup.

Source: [Terraform AWS provider authentication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

**Cost:** These are real AWS resources. Check your account's eligibility and available credits, and complete the cleanup step.

## 3. Create the S3 bucket

Create an isolated directory:

```bash
mkdir terraform-basics
cd terraform-basics
```

Create `main.tf` with:

```hcl
terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "day61" {
  bucket_prefix = "akash-day61-"

  tags = {
    Name    = "Terraform-Day61"
    Project = "90DaysOfDevOps"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.day61.bucket
}
```

`bucket_prefix` lets Terraform append a unique suffix, avoiding a manually chosen bucket-name collision. Use either `bucket_prefix` or `bucket`, not both.

The address `aws_s3_bucket.day61` consists of the resource type and its local Terraform label. The actual AWS bucket name is shown by the output.

Initialize and check the configuration:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
```

Expected summary for a fresh directory:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

Create the bucket:

```bash
terraform apply
```

Review the plan and enter `yes`. Then obtain its actual name:

```bash
terraform output -raw bucket_name
```

Verify that bucket in the S3 console. Keep it empty for this exercise.

### What did init download?

It installed a compatible AWS provider plugin. It also initialized the backend used to store state. It does not create the bucket.

| File or directory | Purpose |
| --- | --- |
| `.terraform/` | Working-directory data such as installed provider plugins, downloaded modules when used, and backend metadata |
| `.terraform.lock.hcl` | Selected provider versions and checksums; commit this file |
| `terraform.tfstate` | Local resource state, normally created after applying this lab; keep private |

Sources: [S3 bucket resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) · [terraform init](https://developer.hashicorp.com/terraform/cli/commands/init)

## 4. Add an EC2 instance

This minimal configuration relies on an existing default VPC and default subnet in Mumbai. Check them first:

```bash
aws ec2 describe-vpcs \
  --region ap-south-1 \
  --filters Name=is-default,Values=true \
  --query 'Vpcs[].VpcId' \
  --output table

aws ec2 describe-subnets \
  --region ap-south-1 \
  --filters Name=default-for-az,Values=true \
  --query 'Subnets[].[SubnetId,VpcId,AvailabilityZone]' \
  --output table
```

If none exist, select an existing suitable subnet in this region and add its real ID as `subnet_id` inside the instance resource below. Its VPC must also provide a suitable security group; you can explicitly supply one with `vpc_security_group_ids`.

Append these blocks to the existing `main.tf`. Keep the S3 configuration:

```hcl
data "aws_ssm_parameter" "al2023" {
  name            = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  with_decryption = false
}

resource "aws_instance" "day61" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = "t2.micro"
  associate_public_ip_address = false

  tags = {
    Name    = "TerraWeek-Day1"
    Project = "90DaysOfDevOps"
  }
}

output "instance_id" {
  value = aws_instance.day61.id
}
```

The data source reads an AWS-maintained public parameter; it does not create a parameter. Its x86_64 AMI matches `t2.micro`, regardless of the architecture of the laptop running Terraform.

This lab provisions an instance without assigning a public IPv4 address. SSH and a web application are outside the assignment.

Run:

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
```

With the bucket unchanged, expect **1 to add, 0 to change, 0 to destroy**. Reading a data source is separate from creating a managed resource.

In EC2, select Mumbai and check the returned instance ID, its running state, and the `TerraWeek-Day1` name.

**Why is the bucket not recreated?** Terraform's state maps `aws_s3_bucket.day61` to the existing AWS bucket. During a normal plan, Terraform refreshes tracked objects through AWS APIs and compares them with the configuration. An unchanged bucket needs no action.

**AMI behavior:** The public parameter follows new Amazon Linux releases. A later plan can propose replacing EC2 if its AMI changes. For a fixed, repeatable lab, copy the resolved AMI ID into the `ami` argument after the first apply. Always inspect replacement actions.

Sources: [AWS public AMI parameters](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami-parameter-store.html) · [EC2 resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) · [State purpose](https://developer.hashicorp.com/terraform/language/state/purpose)

## 5. Inspect and understand state

Open `terraform.tfstate` in your editor and read it without modifying it.

Look for top-level metadata such as `terraform_version`, `serial`, `lineage`, `outputs`, and `resources`. Resource entries include type, local name, provider reference, and instance attributes such as the real AWS ID, ARN, AMI, or tags. State also records dependency information.

| Command | What it returns |
| --- | --- |
| `terraform show` | A human-readable view of the current stored state |
| `terraform state list` | Resource and data-source addresses tracked in state |
| `terraform state show aws_s3_bucket.day61` | Stored attributes for the bucket |
| `terraform state show aws_instance.day61` | Stored attributes for EC2 |

With this example, the list should include:

```text
data.aws_ssm_parameter.al2023
aws_instance.day61
aws_s3_bucket.day61
```

These inspection commands do not themselves perform a full refresh against AWS.

**Why avoid manual editing?** State connects configuration addresses to real objects. Breaking those mappings or metadata can cause incorrect plans. Use supported Terraform state commands or import workflows when maintenance is necessary.

**Why keep state out of Git?** It can hold plaintext secrets and private infrastructure details. Marking a value `sensitive` hides normal display output; it does not encrypt that value in state. Local state is adequate for this isolated lab; teams should use a protected remote backend with locking.

Create `.gitignore` before committing:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
crash.log
crash.*.log
*.tfvars
*.tfvars.json
.env
.env.*
!.env.example
```

Commit `main.tf`, `.gitignore`, `.terraform.lock.hcl`, and this Markdown file. Do not commit saved plans under another filename either: plans can contain sensitive values. An ignore rule does not untrack files already committed.

Sources: [Terraform state](https://developer.hashicorp.com/terraform/language/state/purpose) · [Sensitive data](https://developer.hashicorp.com/terraform/language/manage-sensitive-data) · [State CLI tutorial](https://developer.hashicorp.com/terraform/tutorials/state/state-cli)

## 6. Modify, plan, apply, and destroy

Change only the instance's `Name` tag:

```hcl
Name = "TerraWeek-Modified"
```

Then run:

```bash
terraform fmt
terraform plan
```

| Symbol | Meaning |
| --- | --- |
| `+` | Create |
| `~` | Update in place |
| `-` | Destroy |
| `-/+` | Replace: destroy, then create |
| `+/-` | Replace: create, then destroy |

For the tag-only change, with no other drift or AMI change, expect:

```text
Plan: 0 to add, 1 to change, 0 to destroy.
```

The instance should be updated in place and retain its instance ID.

```bash
terraform apply
```

Verify the new name in EC2.

### Clean up the lab

Run from the same `terraform-basics` directory:

```bash
terraform plan -destroy
terraform destroy
```

Check that the plan targets this lab's bucket and instance, then enter `yes`.

Expected result after a successful cleanup:

```text
Destroy complete! Resources: 2 destroyed.
```

The SSM parameter is read-only input and is not deleted. The pre-existing VPC, subnet, and security group are also not managed or deleted by this configuration.

Verify:

- S3: the lab bucket no longer appears.
- EC2: the instance is terminated; its entry may remain visible temporarily.
- State: `terraform state list` contains no managed bucket or EC2 instance.
- Storage: confirm the instance's root EBS volume was deleted with termination.

If S3 reports `BucketNotEmpty`, inspect and remove only this lab bucket's contents, including object versions if versioning was enabled, then retry. Keep the Terraform files and state until cleanup succeeds.

Sources: [Terraform plans](https://developer.hashicorp.com/terraform/tutorials/cli/plan) · [Destroy infrastructure](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-destroy)

## Evidence to add after completing the lab

- [ ] Terraform version and AWS CLI version recorded.
- [ ] AWS identity verified; credentials excluded from screenshots.
- [ ] S3 creation verified in the console.
- [ ] EC2 running with the original tag verified.
- [ ] State commands run and observations recorded.
- [ ] Tag update verified with the same instance ID.
- [ ] Destroy completed and AWS cleanup checked.

| Observation | Your result |
| --- | --- |
| Terraform version | Fill in after running |
| AWS CLI version | Fill in after running |
| Bucket name | Fill in after applying |
| EC2 instance ID | Fill in after applying |
| Tag-change plan | Fill in after planning |
| Cleanup result | Fill in after destroying |

## Common errors

| Error or symptom | Check |
| --- | --- |
| `No valid credential sources found` | Verify the active role, profile, or credentials with `aws sts get-caller-identity` |
| `AccessDenied` / `UnauthorizedOperation` | Inspect the denied action and request the needed permission; authentication and authorization are separate |
| No default VPC or subnet | Supply a real subnet ID and appropriate security group from the selected region |
| AMI not found | Check the region and architecture; use the regional public parameter above |
| Instance type unavailable or not eligible | Check account restrictions and regional availability before choosing another compatible x86_64 type |
| Unexpected EC2 replacement | Inspect which attribute forces replacement; a changed latest AMI is one possible cause |
| `BucketNotEmpty` during destroy | Empty only the lab bucket, then rerun destroy |

