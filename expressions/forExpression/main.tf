terraform {
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

variable "worlds" {
  type = list
}

variable "worlds_instance" {
  type = map
}