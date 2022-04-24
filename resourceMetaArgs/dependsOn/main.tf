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

resource "aws_instance" "outputs_public" {
    ami = "ami-0359b3157f016ae46"
    instance_type = "t2.micro"
    key_name = "ec2Key"
}

output "public_ip" {
  value = aws_instance.outputs_public.public_ip
}