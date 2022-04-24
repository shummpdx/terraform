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
  count = 2
  ami = "ami-0359b3157f016ae46"
  instance_type = "t2.micro"
  
  tags = {
    Name = "Server-${count.index}"
  }
}

output "public_ips" {
  value = aws_instance.my_server.*.public_ip
}