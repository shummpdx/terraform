# VPC Practice
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

# Allow SSH access
resource "aws_security_group" "sshSecurity" {
  name = "sshSecurity"
  description = "Allow SSH"
  
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

# Allow HTTP access
resource "aws_security_group" "httpSecurity" {
  name = "httpSecurity"
  description = "Zodiark Allows HTTP"

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "httpSecurity"
  }
}

# Allow traffic into the VPC
resource "aws_security_group" "outboundTraffic" {
  name = "outboundTraffic"
  description = "Allow for outbound traffic"

  egress {
    description = "outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "as_conf" {
  name = "web_config"
  image_id = "ami-04cb38c0c7b926017"
  instance_type = "t2.micro"
  security_groups = [
          "${aws_security_group.sshSecurity.id}",
          "${aws_security_group.httpSecurity.id}",
          "${aws_security_group.outboundTraffic.id}"
  ]
  key_name = "CAA"
  ebs_block_device {
    device_name = "Encrypted"
    snapshot_id = "snap-02912cea220ccc29d"
  }
}


resource "aws_placement_group" "myCluster" {
  name = "Custard the Clustar"
  strategy = "cluster"
}

resource "aws_autoscaling_group" "bar" {
  name = "My AutoBot"
  availability_zones = ["us-west-2a"]
  max_size = 4
  min_size = 2
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = 2 
  force_delete = true
  placement_group = aws_placement_group.myCluster.id
  launch_configuration = aws_launch_configuration.as_conf.id

}