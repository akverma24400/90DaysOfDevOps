variable "ami_id" {
  description = "AMI ID for Ec2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs"
  type        = list(string)
}

variable "instance_name" {
  description = "Name of the instance"
  type        = string
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}