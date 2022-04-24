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
  ami = "ami-0359b3157f016ae46"
  instance_type = "t2.micro"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "bucket1" {
    bucket = "seans-bucket-of-runes"

    tags = {
        Name = "Runes"
        Environment = "Dev"
    }
}

output "public_ips" {
  value = aws_instance.my_server.public_ip
}