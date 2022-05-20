
variable "vpc_id" {}
variable "cidr_block" {}

variable "instance_ami" {}

variable "instance_type" {
    default = "t2.micro"
}

variable "name" {}