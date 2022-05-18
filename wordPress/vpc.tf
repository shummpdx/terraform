# Create new VPC
resource "aws_vpc" "production" {
  cidr_block = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "Production Test"
  }
}

resource "aws_internet_gateway" "defaultIG" {
  vpc_id = aws_vpc.production.id
  tags = {
    Name = "Practice IG"
  }
}

resource "aws_route_table" "productionRoutes" {
  vpc_id = aws_vpc.production.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.defaultIG.id
  }

  tags = {
    Name = "Practice Route Table"
  }
}

resource "aws_route_table_association" "associateMe" {
  subnet_id = aws_subnet.wordpress_public_a.id
  route_table_id = aws_route_table.productionRoutes.id
}

# Create private subnets for the RDS subnet group
# Two private subnets are requried for db subnet group
resource "aws_subnet" "rds_private_a" {
  vpc_id = aws_vpc.production.id
  cidr_block = var.subnet1_cidr 
  availability_zone = var.west2a_AZ
  tags = {
    Name = "RDS Private A Test"
  }
}

resource "aws_subnet" "rds_private_b" {
  vpc_id = aws_vpc.production.id
  cidr_block = var.subnet2_cidr 
  availability_zone = var.west2b_AZ
  tags = {
    Name = "RDS Private B Test"
  }
}

resource "aws_db_subnet_group" "privateSubnets" {
  name = "private_subnet_group"
  subnet_ids = [aws_subnet.rds_private_a.id, aws_subnet.rds_private_b.id]

  tags = {
    Name = "Private Subnet Group Test"
  }
}

resource "aws_subnet" "wordpress_public_a" {
  vpc_id = aws_vpc.production.id
  cidr_block = var.subnet3_cidr 
  availability_zone = var.west2c_AZ 
  map_public_ip_on_launch = true
  tags = {
    Name = "WordPress Public A Test"
  }
}