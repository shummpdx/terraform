terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31"
    }
  }
}

#VPC Creation
resource "aws_vpc" "ltVPC" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "ltVPC"
    }
}

#Gateway Creation
resource "aws_internet_gateway" "launchTemplateGateway" {
  vpc_id = aws_vpc.ltVPC.id
}

#Subnet Creation
resource "aws_subnet" "ltSub" {
    vpc_id = aws_vpc.ltVPC.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-west-2b"
    map_public_ip_on_launch = true
    tags = {
        Name = "ltSub"
    }
}

#Create Route Table
resource "aws_route_table" "launchTempRouteTable" {
  vpc_id = aws_vpc.ltVPC.id
}

#Associate route table with subnet
resource "aws_route_table_association" "routeTableAssociation" {
    subnet_id = aws_subnet.ltSub.id
    route_table_id = aws_route_table.launchTempRouteTable.id
}

#Add Route to route table pointing to the gateway
resource "aws_route" "addingRoute" {
    route_table_id = aws_route_table.launchTempRouteTable.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.launchTemplateGateway.id
}

#SSH
resource "aws_security_group" "sshSecurity" {
  name = "sshSecurity"
  description = "Allow SSH"
  vpc_id = aws_vpc.ltVPC.id

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

resource "aws_launch_template" "test" {
  image_id = "ami-0944e91aed79c721c"
  instance_type = "t2.micro"
  key_name = "windows_keypair"

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.sshSecurity.id]
    subnet_id = aws_subnet.ltSub.id
  }

  placement {
    availability_zone = aws_subnet.ltSub.availability_zone
  }

  #vpc_security_group_ids = [aws_security_group.sshSecurity.id]

  tags = {
    Name = "Terraform Test"
  }
}