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

# Begin creating new subnets
resource "aws_subnet" "zodiarks_public_a" {
  vpc_id = aws_vpc.zodiark.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public A"
  }
}

resource "aws_subnet" "zodiarks_public_c" {
  vpc_id = aws_vpc.zodiark.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2c"
  map_public_ip_on_launch = true
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

# Allow SSH access
resource "aws_security_group" "sshSecurity" {
  name = "sshSecurity"
  description = "Allow SSH"
  vpc_id = aws_vpc.zodiark.id
  
  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sshSecurity"
  }
}

# Allow HTTP access
resource "aws_security_group" "httpSecurity" {
  name = "httpSecurity"
  description = "Zodiark Allows HTTP"
  vpc_id = aws_vpc.zodiark.id
  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "httpSecurity"
  }
}

resource "aws_security_group" "httpsSecurity" {
  name = "httpsSecurity"
  description = "Zodiark Allows HTTPS"
  vpc_id = aws_vpc.zodiark.id

  ingress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "httpsSecurity"
  }
}

# Allow traffic into the VPC
resource "aws_security_group" "outboundTraffic" {
  name = "outboundTraffic"
  description = "Allow for outbound traffic"
  vpc_id = aws_vpc.zodiark.id

  egress {
    description = "outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Assign the private key that was created on my local computer
data "tls_public_key" "example" {
  private_key_pem = "${file("~/.ssh/ec2Key.pem")}"
}

# Deploy(?) the key pay
resource "aws_key_pair" "deployer" {
  key_name = "ec2Key"
  public_key = "${file("~/.ssh/ec2Key.pub")}" 
}

# Build our Configured EC2 Instance
resource "aws_instance" "zodiark_public" {
    ami = "ami-0359b3157f016ae46"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.zodiarks_public_a.id

    key_name = "ec2Key" 

    /*
    # Typically, post-configuration should be left to tools such
    # ansible, but essential bootstrap commands or custom routes
    # for instances in private subnets are reasons why you might
    # need to use this hook.
    user_data = <<EOF
        #! /usr/bin/env bash
        sudo ec2-user
        sudo yum install httpd -y
        sudo service httpd start
    EOF*/
    security_groups = [
        "${aws_security_group.sshSecurity.id}",
        "${aws_security_group.httpSecurity.id}",
        "${aws_security_group.httpsSecurity.id}",
        "${aws_security_group.outboundTraffic.id}"
    ]
    
    tags = {
        Name = "Public"
    }
}

data "aws_iam_policy_document" "guacamoleIAM" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PupLogEvents",
      "logs:DescribeLogStreams"
    ]
    effect = "Allow"
    resources = ["*"]
  }
}

# Assume Role Policy 
data "aws_iam_policy_document" "guacamole-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    //resources = ["arn:aws:iam::*:role/EC32ReadOnlyAccessRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "zodiarksGuac" {
    name = "zodiarkGuac"
    assume_role_policy = data.aws_iam_policy_document.guacamole-assume-role-policy.json
    inline_policy {
        name = "guacRole"
        policy = data.aws_iam_policy_document.guacamoleIAM.json
    }
}

resource "aws_iam_instance_profile" "guacProfile" {
    name = "guacProfile"
    role = aws_iam_role.zodiarksGuac.name
}

resource "aws_instance" "guacamole" {
    ami = "ami-05764e7636cb4a33d"
    instance_type = "t2.small"
    subnet_id = aws_subnet.zodiarks_public_a.id

    iam_instance_profile = aws_iam_instance_profile.guacProfile.name

    security_groups = [
        "${aws_security_group.sshSecurity.id}",
        "${aws_security_group.httpSecurity.id}",
        "${aws_security_group.httpsSecurity.id}",
        "${aws_security_group.outboundTraffic.id}"
    ]
 
    tags = {
        Name = "Guaca!"
    }
}