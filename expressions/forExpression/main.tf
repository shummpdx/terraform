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

variable "worlds" {
  type = list
}

variable "worlds_instance" {
  type = map
}