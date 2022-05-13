# AutoScaling Practice
# Scale Up && Scale Down based on CPU Util

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