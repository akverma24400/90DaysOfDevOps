variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "sg_name" {
  description = "Security grop name"
  type        = string
}


variable "ingress_ports" {
  description = "VPC ID"
  type        = list(number)
  default     = [22, 80]
}

variable "tags" {
  description = "Some tags"
  type        = map(string)
  default     = {}
}