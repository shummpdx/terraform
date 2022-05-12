# Network Access Control Example
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

# Block/Allow my IP on public A
resource "aws_network_acl" "denyMyself" {
  vpc_id = aws_vpc.zodiark.id
  subnet_ids = ["${aws_subnet.zodiarks_public_a.id}"]

  ingress {
    rule_no = 10
    protocol =  "tcp"
    to_port = 80
    from_port = 80
    cidr_block = "98.232.206.61/32"
    //action = "allow"
    action = "deny"
  }

  ingress {
    rule_no = 100
    protocol = "-1"
    to_port = 0
    from_port = 0
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  egress {
    rule_no = 10
    protocol = "-1"
    to_port = 0
    from_port = 0
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  tags = {
    Name = "Deny Myself"
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


# Build our Configured EC2 Instance
resource "aws_instance" "zodiark_public" {
    ami = "ami-0359b3157f016ae46"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.zodiarks_public_a.id
    key_name = "ec2Key" 

    # Typically, post-configuration should be left to tools such
    # ansible, but essential bootstrap commands or custom routes
    # for instances in private subnets are reasons why you might
    # need to use this hook.
    user_data = <<EOF
      #! /usr/bin/env bash
      sudo ec2-user
      sudo yum install httpd -y
      sudo service httpd start
    EOF

    security_groups = [
        "${aws_security_group.httpSecurity.id}",
        "${aws_security_group.outboundTraffic.id}"
    ]
    
    tags = {
        Name = "Public"
    }
}