# AutoScaling Practice
# Scale Up && Scale Down based on CPU Util

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31"
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