# Day 64 — Terraform State Management and Remote Backends

## Overview

This exercise focuses on managing Terraform state safely and consistently. Terraform state maps configuration resources to real infrastructure, allowing Terraform to determine what exists and what needs to change.

## Objectives

- Inspect Terraform state and understand the attributes it records.
- Migrate state from local storage to an S3 remote backend.
- Enable S3 versioning and DynamoDB-based state locking.
- Import an existing AWS resource into Terraform management.
- Rename and remove resource addresses from state without unintentionally destroying infrastructure.
- Simulate infrastructure drift, reconcile it, and verify the final plan.

## Task 1: Inspect the Current State

After applying the configuration, the state was inspected in human-readable form and the tracked resource addresses were listed. The state details for the EC2 instance and VPC were also reviewed.

### Findings

- **Resources tracked:** The exact count depends on the resources created by the configuration. Use the resource list from the actual run to record this number.
- **EC2 instance attributes:** State records the values Terraform needs to manage the resource, including its resource ID, AMI, instance type, availability zone, subnet and VPC details, network settings, tags, metadata options, and other provider-computed attributes. The exact fields depend on the AWS provider and resource configuration.
- **State serial:** The serial is a monotonically increasing state revision number. It increments when Terraform writes a new state snapshot, helping Terraform identify newer state versions.

## Task 2: Configure an S3 Remote Backend

The backend infrastructure was prepared separately from the configuration whose state it stores.

### Backend setup

- Created an S3 bucket dedicated to Terraform state.
- Enabled S3 bucket versioning to support recovery of earlier state versions.
- Created a DynamoDB table with `LockID` as its partition key for state locking.
- Configured the S3 backend to store the state at the `dev/terraform.tfstate` key in `ap-south-1`.
- Enabled encryption for the remote state.
- Reinitialized Terraform and approved migration of the existing local state to S3.

### Verification

- Confirmed that the state object was present in the configured S3 bucket.
- Ran a Terraform plan after migration and checked that it reported no unexpected infrastructure changes.
- Verified the active backend configuration before continuing.

**Result:** Terraform state is stored remotely, making it easier for authorized team members and automation to use a shared state location.

## Task 3: Test State Locking

State locking helps prevent concurrent Terraform operations from writing conflicting updates to the same state.

### Observation

When another Terraform operation attempts to access a state that is already locked, Terraform reports that it cannot acquire the lock. The message includes lock details such as the lock ID and information about the operation holding the lock. The exact wording depends on the Terraform version and backend response.

### Why locking matters

Without locking, simultaneous operations could overwrite state updates or make Terraform's view of infrastructure inconsistent. In a team environment, locking reduces this risk by allowing only one state-modifying operation at a time.

A lock should only be forcibly released after confirming that the operation holding it has stopped and that the lock is genuinely stale. Forcing an unlock while another operation is still running can cause state conflicts.

**Result:** State-locking behavior was reviewed and its role in safe collaboration was documented.

## Task 4: Import an Existing S3 Bucket

An S3 bucket created outside Terraform was declared in the Terraform configuration and imported into state using its existing bucket name.

### Findings

Importing associates an existing real-world resource with a Terraform resource address. It does not create the resource, and it does not automatically generate a complete matching configuration in older import workflows. The configuration must describe the resource's intended settings.

After import, the configuration and actual resource settings were compared using a Terraform plan. Any proposed changes were reviewed and the configuration was adjusted where appropriate.

**Difference from creating a resource from scratch:** Creating a resource through Terraform asks Terraform to provision new infrastructure. Importing instead brings an already-existing resource under Terraform's management without creating a second copy.

**Result:** The imported bucket appears in Terraform state alongside the other managed resources.

## Task 5: State Operations — Rename and Remove

### Rename with `state mv`

The imported bucket's Terraform address was changed from `aws_s3_bucket.imported` to `aws_s3_bucket.logs_bucket`, and the configuration was updated to use the new address.

**When to use it:** Use a state move when refactoring configuration, renaming resources, moving resources into modules, or changing resource addresses while keeping the same underlying infrastructure. A correct move prevents Terraform from interpreting the change as a resource deletion followed by creation.

### Remove with `state rm`

The bucket's address was removed from Terraform state without deleting the bucket in AWS. As a result, Terraform no longer manages that resource through the removed address.

**When to use it:** Use state removal when Terraform should stop managing a resource but the real infrastructure should remain, for example when transferring management to another state or tool. Update the configuration as needed; otherwise, a later plan may attempt to create a replacement resource.

The bucket was subsequently imported again under the intended address.

**Result:** The resource address was changed, removed from state without destroying the AWS resource, and re-imported successfully.

## Task 6: Simulate and Reconcile State Drift

State drift occurs when the real infrastructure changes outside the Terraform workflow, such as through the AWS console, CLI, or another automation system.

### Procedure and outcome

- Applied the configuration to establish the intended baseline.
- Made a manual change to an EC2 tag in the AWS console.
- Ran a Terraform plan to compare the real infrastructure with the declared configuration.
- Chose to restore the desired configuration by applying the reviewed plan.
- Verified that the intended tag value was restored.
- Ran a final plan and confirmed that no further changes were proposed.

**Result:** The manual change was detected and reconciled so that the real resource matched the Terraform configuration again.

## Preventing Drift in Production

Teams can reduce unplanned drift by:

- Restricting direct production changes through the AWS console and limiting permissions using IAM.
- Routing infrastructure changes through reviewed Terraform pull requests and CI/CD pipelines.
- Using remote state, state locking, and versioning.
- Running regular plans or scheduled drift-detection checks.
- Monitoring AWS configuration changes and retaining audit logs.
- Defining clear ownership for each resource and avoiding multiple tools managing the same resource without an explicit design.
- Reviewing plans before applying changes and maintaining a documented recovery procedure.

Emergency console changes may still be necessary, but they should be documented and followed by an update to Terraform configuration or a controlled reconciliation.

## Key Learnings

- Terraform state stores the mapping and attributes needed to manage real infrastructure.
- Remote state provides a shared storage location, while versioning supports recovery.
- State locking helps prevent concurrent operations from corrupting or overwriting state.
- Importing brings existing infrastructure under Terraform management; it does not provision that infrastructure.
- State moves change Terraform addresses without replacing the underlying resource when performed correctly.
- Removing a resource from state does not delete it from AWS.
- Drift is identified by comparing configuration, state, and real infrastructure; a reviewed plan helps teams reconcile it safely.

## Cleanup and Cost Awareness

Before finishing the lab, review the AWS resources created specifically for this exercise. Keep the state bucket and locking table if they will be reused. If removing them, first ensure that no Terraform configuration still depends on them and preserve any state versions needed for recovery. Delete test infrastructure only when it is safe to do so.

> **Note:** Record the actual resource count, observed lock-error details, and verification results from your own terminal and AWS account. These values can differ depending on the configuration and Terraform/provider versions.
