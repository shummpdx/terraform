# NAT Practice
# This script will create a new VPC with three public subnets and one private one. 
# We'll then create a Guacamole instance that will be used as bastion to access
# an EC2 instance in one of the private subnets. 
# Various IAM settings will be configured to give the necessary permssions.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.4"
    }
    tls = {
      source = "hashicorp/tls"
      version = "3.1"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# Assign the private key that was created on my local computer
data "tls_public_key" "example" {
  private_key_pem = "${file("~/.ssh/ec2Key.pem")}"
}