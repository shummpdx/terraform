# VPC Practice
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "summons"

    workspaces {
      name = "getting-started"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.4"
    }
  }
}

locals {
  project_name = "Rhain"
}