# VPC Practice
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.4"
    }
  }
}

variable "instance_type" {
  type = string
}

locals {
    project_name = "Rhain"
}

resource "aws_instance" "variable_instance" {
  ami           = "ami-00ee4df451840fa9d"
  instance_type = var.instance_type

  tags = {
    Name = "Variable Server"
  }
}

output "instance_ip" {
    value = aws_instance.variable_instance.public_ip 
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}