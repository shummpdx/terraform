terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31"
    }
  }
}

resource "aws_vpc" "ltVPC" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "ltVPC"
    }
}

resource "aws_subnet" "ltSub" {
    vpc_id = aws_vpc.ltVPC.id
    cidr_block = "10.0.1.0/24"

    tags = {
        Name = "ltSub"
    }
}

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

resource "aws_vpc_endpoint" "ec2" {
  vpc_id = aws_vpc.ltVPC.id
  
}

resource "aws_vpc_endpoint_subnet_association" "endpointSubnet" {
  vpc_endpoint_id = aws_vpc.ltVPC.id
  subnet_id = aws_subnet.ltSub.id
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