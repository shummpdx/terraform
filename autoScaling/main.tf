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
  image_id = "ami-0ca285d4c2cda3300"
  instance_type = "t2.micro"
  security_groups = [
          "${aws_security_group.sshSecurity.id}",
          "${aws_security_group.outboundTraffic.id}"
  ]
  key_name = "ec2Key"
}

/*resource "aws_placement_group" "myCluster" {
  name = "Custard the Clustar"
  strategy = "cluster"
}*/

resource "aws_autoscaling_group" "bar" {
  name = "My AutoBot"
  availability_zones = ["us-west-2a"]
  max_size = 3 
  min_size = 2
  health_check_grace_period = 300
  health_check_type = "EC2"
  desired_capacity = 2 
  force_delete = true
  //placement_group = aws_placement_group.myCluster.id
  launch_configuration = aws_launch_configuration.as_conf.id
}

resource "aws_autoscaling_policy" "CPU_util" {
  name = "CPU_Util"
  autoscaling_group_name = aws_autoscaling_group.bar.name
  adjustment_type = "ChangeInCapacity"
  policy_type = "PredictiveScaling"
  predictive_scaling_configuration {
    metric_specification {
      target_value = 10

      predefined_load_metric_specification {
        predefined_metric_type = "ASGTotalCPUUtilization"
        resource_label = "testLabel"
      }
    }
  }
}