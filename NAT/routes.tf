# Ensure that the newly created route table is the main route table used
resource "aws_main_route_table_association" "main_route" {
  vpc_id = aws_vpc.zodiark.id
  route_table_id = aws_route_table.zodiarks_path.id
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

# Associate a seprate route table to private subnet so that 
# the subnet can't reach the internet
resource "aws_route_table" "zodiarks_private_path" {
  vpc_id = aws_vpc.zodiark.id

  tags = {
    Name = "zodiarks private path"
  } 
}

# Associate the private route table with the private subnet
resource "aws_route_table_association" "private_route" {
  subnet_id = aws_subnet.zodiarks_private_a.id
  route_table_id = aws_route_table.zodiarks_private_path.id
}

