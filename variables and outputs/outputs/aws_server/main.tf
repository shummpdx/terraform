# VPC Practice
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

# Allow SSH access
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

# Allow traffic into the VPC
resource "aws_security_group" "outboundTraffic" {
  name = "outboundTraffic"
  description = "Allow for outbound traffic"

  egress {
    description = "outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Assign the private key that was created on my local computer
data "tls_public_key" "example" {
  private_key_pem = "${file("~/.ssh/ec2Key.pem")}"
}

# Deploy(?) the key pay
resource "aws_key_pair" "deployer" {
  key_name = "ec2Key"
  public_key = "${file("~/.ssh/ec2Key.pub")}" 
}

resource "aws_instance" "outputs_public" {
    ami = "ami-0359b3157f016ae46"
    instance_type = "t2.micro"
    key_name = "ec2Key"

    vpc_security_group_ids = [
        aws_security_group.sshSecurity.id,
        aws_security_group.outboundTraffic.id
    ]
}

output "public_ip" {
  value = aws_instance.outputs_public.public_ip
}