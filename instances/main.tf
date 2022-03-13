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

data "tls_public_key" "example" {
  private_key_pem = "${file("~/.ssh/ec2Key.pem")}"
}

resource "aws_key_pair" "deployer" {
  key_name = "ec2Key"
  public_key = "${file("~/.ssh/ec2Key.pub")}" 
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

resource "aws_security_group" "outboundSecurity" {
    name = "outboundSecurity"
    description = "Allow outbound traffic"

    egress  {
        from_port = 0 
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "zodiark_public" {
    ami = "ami-0359b3157f016ae46"
    instance_type = "t2.micro"
    key_name = "ec2Key"
    subnet_id = "subnet-026b45caf7654b5a3"
    vpc_security_group_ids = [
        aws_security_group.sshSecurity.id,
        aws_security_group.outboundSecurity.id
    ]
    tags = {
        Name = "Zodiark's Revenge!"
    }
}