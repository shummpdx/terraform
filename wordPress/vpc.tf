# Create a new VPC 
resource "aws_vpc" "wordpress-VPC" {
  cidr_block = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true
  
  tags = {
    Name = "Production"
  }
}

# Begin creating new subnets
resource "aws_subnet" "wordpress_public_a" {
  vpc_id = aws_vpc.wordpress-VPC.id
  cidr_block = var.subnet1_cidr
  availability_zone = var.AZ1
  map_public_ip_on_launch = true
  tags = {
    Name = "Wordpress Public A"
  }
}

# Create a new gateway for the VPC so it can connect to the internet
resource "aws_internet_gateway" "wordpress-ig" {
  vpc_id = aws_vpc.wordpress-VPC.id
  
  tags = {
    Name = "Wordpress Gateway"
  }
}

# Create a new route table to allow our subnets to reach the internet
resource "aws_route_table" "wordpress_route_table" {
  vpc_id = aws_vpc.wordpress-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wordpress-ig.id
  }
  tags = {
    Name = "Wordpress Route Table"
  } 
}

# Ensure that the newly created route table is the main route table used
resource "aws_main_route_table_association" "wordpress_public_route" {
  vpc_id = aws_vpc.wordpress-VPC.id
  route_table_id = aws_route_table.wordpress_route_table.id
}