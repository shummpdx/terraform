provider "aws" {
    region = "us-west-2"
}

resource "aws_vpc" "development_VPC" {
    cidr_block = "10.2.0.0/16"
}

module "instanceGenerator" {
    source = "../modules/instances"
    vpc_id = aws_vpc.development_VPC.id
    cidr_block = "10.2.0.0/16"
    name = "Development"
    instance_ami = "ami-0ee8244746ec5d6d4"
}