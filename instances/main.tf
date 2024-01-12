# Instance Practice
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

data "tls_public_key" "example" {
  private_key_pem = "${file("~/.ssh/ec2Key.pem")}"
}

resource "aws_instance" "zodiark_public" {
    ami = "ami-0359b3157f016ae46"
    instance_type = "t2.micro"
    key_name = "ec2Key"
    subnet_id = "subnet-03884456ae66871c8"
    vpc_security_group_ids = [
        aws_security_group.sshSecurity.id,
        aws_security_group.outboundSecurity.id
    ]
    tags = {
        Name = "Zodiark's Revenge!"
    }
}