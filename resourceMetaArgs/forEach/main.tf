# VPC Practice
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.4"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "my_server" {
  for_each = {
    nano = "t2.nano"
    micro = "t2.micro"
    small = "t2.small"
  }

  ami = "ami-0359b3157f016ae46"
  instance_type = each.value
  
  tags = {
    Name = "Server-${each.key}"
  }
}

output "public_ips" {
  value = values(aws_instance.my_server)[*].public_ip
}