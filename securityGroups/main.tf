# Security Groups
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

resource "aws_security_group" "sshSecurity" {
  name = "sshSecurity"
  description = "Allow SSH"
  
  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Name = "sshSecurity"
  }
}

resource "aws_instance" "zodiark_public" {
  ami = "ami-0359b3157f016ae46"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
      "${aws_security_group.sshSecurity.id}"
  ]

  tags = {
    Name = "Zodiark's Revenge!"
  }
}