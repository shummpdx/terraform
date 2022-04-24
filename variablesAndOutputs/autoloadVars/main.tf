# VPC Practice
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.4"
    }
  }
}

variable "instance_type" {
  type = string
  description = "The size of the instance"
  #sensitive = true
  validation {
    condition = can(regex("^t3.", var.instance_type))
    error_message = "Instance must be a t3. type EC2 instance."
  }
}

locals {
    project_name = "Rhain"
}

resource "aws_instance" "variable_instance" {
  ami           = "ami-00ee4df451840fa9d"
  instance_type = var.instance_type

  tags = {
    Name = "Variable Server"
  }
}

output "instance_ip" {
    value = aws_instance.variable_instance.public_ip 
}