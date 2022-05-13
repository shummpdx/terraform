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

resource "aws_subnet" "zodiarks_public_b" {
  vpc_id = aws_vpc.zodiark.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public B"
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