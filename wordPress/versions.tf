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