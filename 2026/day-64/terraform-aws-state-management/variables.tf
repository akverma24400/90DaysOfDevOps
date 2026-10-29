variable "ec2_instance_ami" {
    type = string
    default = "ami-03a23d9d58ea08615"
    description = "This is the ami id for reagon us-west-2"
}

variable "ec2_instance_type" {
    type = string
    default = "t3.micro"
    description = "This is a EC2 instance type variable"

}

variable "env" {
    type = string
    default = "dev"
    description = "This is a Dev environment for our infra"

}