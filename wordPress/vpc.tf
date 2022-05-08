resource "aws_subnet" "rds_private_a" {
  vpc_id = "vpc-017a3eb77ea7a4a56"
  cidr_block = "10.0.2.0/24" 
  availability_zone = "us-west-2a"
  tags = {
    Name = "RDS Private A"
  }
}

resource "aws_subnet" "rds_private_b" {
  vpc_id = "vpc-017a3eb77ea7a4a56"
  cidr_block = "10.0.3.0/24" 
  availability_zone = "us-west-2b"
  tags = {
    Name = "RDS Private B"
  }
}

resource "aws_eip" "example" {
}

resource "aws_nat_gateway" "PrivateNat" {
  subnet_id = aws_subnet.rds_private_a.id
  allocation_id = aws_eip.example.id
}

resource "aws_subnet" "wordpress_public_a" {
  vpc_id = "vpc-017a3eb77ea7a4a56"
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-west-2c"
  map_public_ip_on_launch = true
  tags = {
    Name = "WordPress Public A"
  }
}