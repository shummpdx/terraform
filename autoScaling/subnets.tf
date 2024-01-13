resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "project1"
    }
}

resource "aws_internet_gateway" "test" {}

resource "aws_internet_gateway_attachment" "name" {
    internet_gateway_id = aws_internet_gateway.test.id
    vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"

    availability_zone = "us-west-2a"
    tags = {
        Name = "Sandbox"
    }

    map_public_ip_on_launch = true
}