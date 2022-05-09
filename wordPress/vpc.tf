resource "aws_vpc" "production" {
  cidr_block = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "Production"
  }
}

# Create private subnets for the RDS subnet group
resource "aws_subnet" "rds_private_a" {
  vpc_id = aws_vpc.production.id
  cidr_block = var.subnet1_cidr 
  availability_zone = var.west2a_AZ
  tags = {
    Name = "RDS Private A"
  }
}

resource "aws_subnet" "rds_private_b" {
  vpc_id = aws_vpc.production.id
  cidr_block = var.subnet2_cidr 
  availability_zone = var.west2b_AZ
  tags = {
    Name = "RDS Private B"
  }
}

resource "aws_db_subnet_group" "privateSubnets" {
  name = "private_subnet_group"
  subnet_ids = [aws_subnet.rds_private_a.id, aws_subnet.rds_private_b.id]

  tags = {
    Name = "Private Subnet Group"
  }
}

resource "aws_eip" "example" {
}

resource "aws_nat_gateway" "PrivateNat" {
  subnet_id = aws_subnet.rds_private_a.id
  allocation_id = aws_eip.example.id
}

resource "aws_subnet" "wordpress_public_a" {
  vpc_id = aws_vpc.production.id
  cidr_block = var.subnet3_cidr 
  availability_zone = var.west2c_AZ 
  map_public_ip_on_launch = true
  tags = {
    Name = "WordPress Public A"
  }
}