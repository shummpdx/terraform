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

#VPC Creation
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "main"
    }
}

#Gateway Creation
resource "aws_internet_gateway" "practiceGW" {
    vpc_id = aws_vpc.main.id
}

#Subnet Creation
resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-west-2b"
    map_public_ip_on_launch = true
    tags = {
        Name = "Sandbox"
    }
}

#Create Route Table
resource "aws_route_table" "routeTable" {
    vpc_id = aws_vpc.main.id 
}

#Associate route table with subnet
resource "aws_route_table_association" "routeTableAssociation" {
    subnet_id = aws_subnet.main.id
    route_table_id = aws_route_table.routeTable.id
}

#Add Route to route table pointing to the gateway
resource "aws_route" "addingRoute" {
    route_table_id = aws_route_table.routeTable.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.practiceGW.id
}

#SSH 
resource "aws_security_group" "sshSecurity" {
  name = "sshSecurity"
  description = "Allow SSH"
  vpc_id = aws_vpc.main.id

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

#Instance creation
resource "aws_instance" "subnetTest" {
    ami = "ami-0359b3157f016ae46"
    instance_type = "t2.micro"
    key_name = "windows_keypair"
    subnet_id = aws_subnet.main.id
    vpc_security_group_ids = [
        aws_security_group.sshSecurity.id,
        #aws_security_group.outboundSecurity.id
    ]
    tags = {
        Name = "Subnet Test"
    }
}