terraform {
  required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "5.31"
        }
    }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "main"
    }
}

resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"

    tags = {
        Name = "Sandbox"
    }
}