terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31"
    }
  }
}

resource "aws_launch_template" "test" {
    image_id = "ami-0944e91aed79c721c"
    instance_type = "t2.micro"
    key_name = "windows_keypair"

    network_interfaces {
        associate_public_ip_address = true
    }

    placement {
      availability_zone = "us-west-2a"
    }

    tags = {
      Name = "Terraform Test"
    }
}