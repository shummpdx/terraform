# VPC Practice
terraform {
  required_version = ">= 1.1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31"
    }
  }
}

resource "aws_subnet" "development_subnet" {
  vpc_id = var.vpc_id
  cidr_block = var.cidr_block
}

resource "aws_instance" "production_instance" {
  ami =  var.instance_ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.development_subnet.id

  tags = {
    Name = "${var.name} Instance"
  }
}