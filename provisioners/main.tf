# Deploy a server that's open on port 80/22
# that only allows me to SSH into it
# copy over key pair
# run script so we can create an apache server
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "summons"

    workspaces {
      name = "provisioner"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_key_pair" "deployer" {
  key_name = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCt7zp3QDlGw9Ne+KlHG1Vo63hwl5W8VCQc7goadRPaRmcm0ci8cnOTewvFEq8kuSU78xfyeZEwrcdzeUs6kgQTWtSRS1L8FTfEj9Re/GcLgw7gAcmowwO2ltREsvmKOOxVqSR/a20B6RMhVWh7jAXLrb7drkVR8y9jHDvskHwuojwTSi3hcWEz9z09T0MD4CGLcmZHmbq/tb4J5dwZb38ZUQoKLk7cEeFDNB/2rTAaqyQVzbDDLQtNbDIDmJXFvQu0QpyUeH5VKlWvK0BbXRKkFqPZbQA42tstWG5/rlr3ZglQ+LielVV7qX3xdPjNF2p8xdqYGl1Eo08FrSoP6AmFvmF/KzTpuQXzw4go9/cX3T0hYZ2b5yE6fThfHNZl9dfVKkHAgs3Jefb5JA1YPhLGCgT9/rSnAGrWuHttF/XWMklh9LMXBO8hDqgYYAvaVdyv5OMdjsN3k+mCbEXHMIH4Bywf8r/jbk58wUClXxC3hsh4ZYFa2S8pMxds5kO2Q2M= sean@LabBox"
}

#data sources allow us to reference external resources
data "aws_vpc" "main" {
  id = "vpc-0e8b7c87a34be9dda"
}

resource "aws_security_group" "sg_my_server" {
  name = "sg_my_server"
  description = "My Server Security Group"
  vpc_id = data.aws_vpc.main.id

  ingress = [
    {
      description = "HTTP"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    },
    {
      description = "SHH"
      from_port = 22 
      to_port = 22 
      protocol = "tcp"
      cidr_blocks = ["98.232.206.61/32"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]

  egress = [
    {
      description = "outgoing traffic"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]
}

data "template_file" "user_data" {
  template = file("./userdata.yaml")
}

resource "aws_instance" "myInstance" {
  ami           = "ami-00ee4df451840fa9d"
  instance_type = "t2.micro"

  key_name = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = [ aws_security_group.sg_my_server.id ]

  user_data = data.template_file.user_data.rendered

  tags = {
    Name = "Provisioners Instance"
  }
}

output "public_ip" {
  value = aws_instance.myInstance.public_ip
}