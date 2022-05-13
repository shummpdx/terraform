# Create a new VPC 
resource "aws_vpc" "zodiark" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  
  tags = {
    Name = "zodiark"
  }
}

resource "aws_vpc_endpoint" "zodiarksEndpoint"{
  vpc_id = aws_vpc.zodiark.id
  service_name = "com.amazonaws.us-west-2.s3"
  route_table_ids = ["${aws_route_table.zodiarks_private_path.id}"]
  tags = {
    Name = "Zodiarks Endpoint"
  }
}

# Create a new gateway for the VPC so it can connect to the internet
resource "aws_internet_gateway" "ig-zodiark" {
  vpc_id = aws_vpc.zodiark.id
  
  tags = {
    Name = "Zodiarks Gateway"
  }
}