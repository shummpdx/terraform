# VPC Practice
terraform {
}

module "aws_server" {
  source = "./aws_server"
}

output "public_ip" {
  value = module.aws_server.public_ip
}