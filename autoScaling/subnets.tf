# Create VPC
resource "aws_vpc" "autoscaling_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "autoscaling" 
    }
}

# Gateway Creation
resource "aws_internet_gateway" "autoscaling_gateway" {
    vpc_id = aws_vpc.autoscaling_vpc.id
}

# Create subnet
resource "aws_subnet" "autoscaling_subnet" {
    vpc_id = aws_vpc.autoscaling_vpc.id
    cidr_block = "10.0.1.0/24"

    availability_zone = "us-west-2a"
    tags = {
        Name = "Sandbox"
    }

    map_public_ip_on_launch = true
} 

# Create route table
resource "aws_route_table" "autoscaling_route_table" {
    vpc_id = aws_vpc.autoscaling_vpc.id
}

# Associate route table with subnet
resource "aws_route_table_association" "autoscaling_route_ass" {
    subnet_id = aws_subnet.autoscaling_subnet.id
    route_table_id = aws_route_table.autoscaling_route_table.id
}

# Add route to route table
resource "aws_route" "addRoute" {
    route_table_id = aws_route_table.autoscaling_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.autoscaling_gateway.id
}