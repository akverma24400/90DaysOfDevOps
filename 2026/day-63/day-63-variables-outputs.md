# Day 63 — Variables, Outputs, Data Sources and Expressions

## Overview

Day 63 focuses on making Terraform configurations dynamic, reusable, and environment-aware using variables, outputs, data sources, locals, and built-in functions.

## Objectives

- Replace hardcoded values with variables.
- Manage development and production environments.
- Export infrastructure details using outputs.
- Discover AWS resources dynamically.
- Use locals for naming and tagging.
- Practice Terraform functions and conditional expressions.

---

## Task 1: Input Variables

Input variables allow configuration values to be customized without modifying the main Terraform configuration.

Variables were defined for the AWS region, VPC CIDR, subnet CIDR, instance type, project name, environment, allowed ports, and extra tags.

### Five Variable Types

- **String:** Text values, such as a project name.
- **Number:** Numeric values, such as port numbers.
- **Bool:** True or false values.
- **List:** An ordered collection of values.
- **Map:** Key-value pairs, such as resource tags.

**Key learning:** Variables reduce hardcoded values and make configurations reusable.

## Task 2: Variable Files and Precedence

Separate variable files were created for development and production environments.

- **Development:** Uses the default network configuration and a smaller instance type.
- **Production:** Uses separate CIDR ranges and a production-appropriate instance type.

### Variable Precedence

From lowest to highest priority:

1. Variable defaults.
2. Environment variables (`TF_VAR_`).
3. Automatically loaded variable files.
4. Explicitly supplied variable files.
5. Command-line variable assignments.

**Key learning:** Variable files make environment management easier without duplicating Terraform configurations.

## Task 3: Outputs

Outputs expose important infrastructure details after deployment.

The following outputs were configured:

- VPC ID
- Subnet ID
- EC2 instance ID
- EC2 public IP
- EC2 public DNS
- Security group ID

The public IP output can be compared with the EC2 instance's public IPv4 address in the AWS console.

**Key learning:** Outputs simplify infrastructure verification and automation.

## Task 4: Data Sources

Data sources retrieve information about existing resources or resources discoverable through a provider.

- **AMI data source:** Dynamically discovers a matching Amazon Linux 2 image.
- **Availability Zones data source:** Retrieves available zones in the selected AWS region.

### Resource vs. Data Source

A **resource** creates or manages infrastructure, while a **data source** reads information about existing or discoverable infrastructure.

**Key learning:** Data sources reduce reliance on hardcoded resource IDs and region-specific values.

## Task 5: Locals and Dynamic Tags

Local values simplify repeated expressions and establish consistent resource naming.

A common name prefix combines the project name and environment. Common tags include the project, environment, and management tool.

Resource-specific tags can be merged with common tags to maintain consistent metadata across the infrastructure.

**Key learning:** Locals improve readability, reduce repetition, and simplify resource tagging.

## Task 6: Functions and Conditional Expressions

Five useful Terraform functions explored:

| Function       | Purpose                                       |
| -------------- | --------------------------------------------- |
| `upper()`      | Converts text to uppercase.                   |
| `join()`       | Combines strings using a separator.           |
| `lookup()`     | Retrieves a value from a map.                 |
| `length()`     | Returns the length of a string or collection. |
| `cidrsubnet()` | Calculates subnet CIDR ranges.                |

Other useful functions include `format()`, `toset()`, and `merge()`.

Conditional expressions select values based on a condition, such as choosing different EC2 instance types for development and production.

**Key learning:** Functions and expressions make infrastructure configuration flexible and environment-aware.

## Verification Checklist

- [x] Variables defined and hardcoded values reduced.
- [x] Development and production variable files created.
- [x] Variable precedence tested.
- [x] Outputs verified after deployment.
- [x] AMI and Availability Zones discovered dynamically.
- [x] Locals and common tags configured.
- [x] Functions tested in Terraform console.
- [x] Conditional expression verified.
- [x] Terraform plan reviewed and unnecessary resources cleaned up.

## Conclusion

Day 63 demonstrates how variables, outputs, data sources, locals, and expressions make Terraform configurations more reusable, maintainable, and suitable for multiple environments.

**Day 63 completed — continuing the journey toward Infrastructure as Code and Cloud Automation.**

\#Terraform #AWS #InfrastructureAsCode #DevOps #CloudComputing #90DaysOfDevOps
