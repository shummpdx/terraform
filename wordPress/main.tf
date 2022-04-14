# Script taken from: https://github.com/devbhusal/terraform-ec2-RDS-wordpress
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.4"
    }
    tls = {
      source = "hashicorp/tls"
      version = "3.1"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# Create a new VPC 
resource "aws_vpc" "wordpress-VPC" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  
  tags = {
    Name = "Production"
  }
}

# Begin creating new subnets
resource "aws_subnet" "wordpress_public_a" {
  vpc_id = aws_vpc.wordpress-VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Wordpress Public A"
  }
}

resource "aws_subnet" "wordpress_private_a" {
  vpc_id = aws_vpc.wordpress-VPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "Wordpress Private A"
  }
}

resource "aws_subnet" "wordpress_private_b" {
  vpc_id = aws_vpc.wordpress-VPC.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2c"
  tags = {
    Name = "Wordpress Private B"
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

# HTTP(S)/MYSQL/SSH
resource "aws_security_group" "wordpress_security" {
  name = "Wordpress Security"
  description = "HTTP(S)/MYSQL/SSH Permissions for Wordpress Instance"
  vpc_id = aws_vpc.wordpress-VPC.id

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MYSQL"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Wordpress Security"
  }
}

resource "aws_security_group" "RDS_allow" {
  name = "RDS Security"
  description = "MYSQL Security for RDS"
  vpc_id = aws_vpc.wordpress-VPC.id

  ingress {
    description = "MYSQL"
    from_port = 3306 
    to_port = 3306 
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = ["${aws_security_group.wordpress_security.id}"]
  }

  egress {
    description = "outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS Security"
  }
}

# Create RDS Subnet Group
resource "aws_db_subnet_group" "RDS_subnet_group" {
  subnet_ids = ["${aws_subnet.wordpress_private_a.id}", "${aws_subnet.wordpress_private_b.id}"]
}

resource "aws_db_instance" "wordpressDB" {
  allocated_storage = 10
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  db_subnet_group_name = aws_db_subnet_group.RDS_subnet_group.id
  vpc_security_group_ids = ["${aws_security_group.RDS_allow.id}"]
  db_name = "wordpress_db"
  username = "wordpress_user" 
  password = "wordpress"
  skip_final_snapshot = true
}
data "template_file" "user_data" {
  template = file("./user_data.tpl")

  vars = {
    db_username = "wordpress_user"
    db_user_password = "wordpress"
    db_name = "wordpress_db"
    db_RDS = aws_db_instance.wordpressDB.endpoint 
  }
}

# Assign the private key that was created on my local computer
data "tls_public_key" "example" {
  private_key_pem = "${file("~/.ssh/ec2Key.pem")}"
}


# Deploy(?) the key pay
resource "aws_key_pair" "deployer" {
  key_name = "ec2Key"
  public_key = "${file("~/.ssh/ec2Key.pub")}" 
}

# Build our Configured EC2 Instance
resource "aws_instance" "Wordpress" {
    ami = "ami-0359b3157f016ae46"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.wordpress_public_a.id
    security_groups = ["${aws_security_group.wordpress_security.id}"]
    user_data = data.template_file.user_data.rendered
    key_name = "ec2Key" 
    
    tags = {
        Name = "Public"
    }

    depends_on = [aws_db_instance.wordpressDB]
}

resource "aws_eip" "eip" {
  instance = aws_instance.Wordpress.id
}