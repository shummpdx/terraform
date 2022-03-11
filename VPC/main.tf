# S3 Practice
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

resource "aws_vpc" "zodiark" {
    cidr_block = "10.0.0.0/16"
    tenancy = "default"
}