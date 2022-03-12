# VPC Practice
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

# Create a new VPC 
resource "aws_vpc" "zodiark" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  
  tags = {
    Name = "zodiark"
  }
}

# Create a new gateway for the VPC so it can connect to the internet
resource "aws_internet_gateway" "ig-zodiark" {
  vpc_id = aws_vpc.zodiark.id
  
  tags = {
    Name = "Zodiarks Gateway"
  }
}

# Create a new route table to allow our subnets to reach the internet
resource "aws_route_table" "zodiarks_path" {
  vpc_id = aws_vpc.zodiark.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig-zodiark.id
  }
  tags = {
    Name = "zodiarks path"
  } 
}
# Ensure that the newly created route table is the main route table used
resource "aws_main_route_table_association" "main_route" {
  vpc_id = aws_vpc.zodiark.id
  route_table_id = aws_route_table.zodiarks_path.id
}

resource "aws_subnet" "zodiarks_public_a" {
  vpc_id = aws_vpc.zodiark.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Public A"
  }
}
resource "aws_subnet" "zodiarks_public_b" {
  vpc_id = aws_vpc.zodiark.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "Public B"
  }
}
resource "aws_subnet" "zodiarks_public_c" {
  vpc_id = aws_vpc.zodiark.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2c"
  tags = {
    Name = "Public C"
  }
}
resource "aws_subnet" "zodiarks_private_a" {
  vpc_id = aws_vpc.zodiark.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-west-2c"
  tags = {
    Name = "Private A"
  }
}

resource "aws_route_table" "zodiarks_private_path" {
  vpc_id = aws_vpc.zodiark.id
  tags = {
    Name = "zodiarks private path"
  } 
}

resource "aws_route_table_association" "private_route" {
  subnet_id = aws_subnet.zodiarks_private_a.id
  route_table_id = aws_route_table.zodiarks_private_path.id
}

# Create Security Group
resource "aws_security_group" "sshSecurity" {
  name = "Zodiarks Allows SSH"
  description = "Allow SSH"
  vpc_id = aws_vpc.zodiark.id
  
  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  tags = {
    Name = "Allow SSH"
  }
}

resource "aws_security_group" "httpSecurity" {
  name = "Zodiark Allows HTTP"
  description = "Zodiarks Allow HTTP"
  vpc_id = aws_vpc.zodiark.id
  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }
  tags = {
    Name = "Allow HTTP"
  }
}

resource "aws_network_interface" "zodiarkNetwork" {
  subnet_id = aws_subnet.zodiarks_public_a.id
  /*security_groups = [
    aws_security_group.sshSecurity.id,
    aws_security_group.httpSecurity.id
  ]*/
}

data "aws_iam_policy_document" "test" {
  statement {
    actions = [
      "cloudwatch:PutMetricData",
      "ds:CreateComputer",
      "ds:DescribeDirectories",
      "ec2:DescribeInstanceStatus",
      "logs:*",
      "ssm:*",
      "ec2messages:*"
    ]
    effect = "Allow"
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["iam:CreateServiceLinkedRole"]
    resources = ["arn:aws:iam::*:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM*"]
    condition {
      test = "StringLike"
      variable = "iam:AWSServiceName" 
      values = ["ssm.amazonaws.com"]
      }
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:DeleteServiceLinkedRole",
      "iam:GetServiceLinkedRoleDeletionStatus"
    ]
    resources = ["arn:aws:iam::*:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
# Create role that will give access to SSM for session manager and S3
resource "aws_iam_role" "zodiarksEC2" {
  name = "zodiarkEC2"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  inline_policy {
    name = "policy-1234"
    policy = data.aws_iam_policy_document.test.json
  }
}

# Create new EC3 key pair
resource "tls_private_key" "newKey" {
  algorithm = "RSA"
}
resource "aws_key_pair" "deployer" {
  key_name = "deployer-one"
  public_key = tls_private_key.newKey.public_key_openssh
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.zodiarksEC2.name
}
# Build our Configured EC2 Instance
resource "aws_instance" "zodiark_public" {
  ami = "ami-0359b3157f016ae46"
  instance_type = "t2.micro"
  network_interface {
    network_interface_id = aws_network_interface.zodiarkNetwork.id
    device_index = 0
  }
  key_name = aws_key_pair.deployer.id
  iam_instance_profile = aws_iam_instance_profile.test_profile.name

  # Typically, post-configuration should be left to tools such
  # ansible, but essential bootstrap commands or custom routes
  # for instances in private subnets are reasons why you might
  # need to use this hook .
  user_data = <<-EOF
    #!/bin/bash
    sudo yum install httpd -y
    sudo service httpd start
  EOF
}