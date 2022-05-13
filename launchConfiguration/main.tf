# Launch Configuration Practice
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

resource "aws_launch_configuration" "as_conf" {
  name = "WordPress Config"
  image_id = "ami-0b1c009f2b7452446" # Amazon Linux AMI
  instance_type = "t2.micro"
  security_groups = [
          "${aws_security_group.sshSecurity.id}",
          "${aws_security_group.httpSecurity.id}",
          "${aws_security_group.outboundTraffic.id}"
  ]
  key_name = "ec2Key"
}