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

resource "aws_autoscaling_group" "myAutoScaler" {
  name = "My AutoBot"
  vpc_zone_identifier = ["subnet-03884456ae66871c8"]
  //availability_zones = ["us-west-2a"]
  max_size = 3 
  min_size = 2
  health_check_grace_period = 100
  health_check_type = "EC2"
  desired_capacity = 2 
  force_delete = true
  //placement_group = aws_placement_group.myCluster.id
  launch_configuration = aws_launch_configuration.as_conf.id
}

resource "aws_autoscaling_policy" "scale_up" {
  name = "CPU_Util"
  autoscaling_group_name = aws_autoscaling_group.myAutoScaler.name
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = 1
  cooldown = 60 # Seconds after a scale activity completes and another can start
  policy_type = "SimpleScaling"
}

# Define CloudWatch Monitoring
# We are gonna pick the CPU metrics within CloudWatch and set a threshold to trigger the action
resource "aws_cloudwatch_metric_alarm" "myScalingAlarm" {
  alarm_name = "myScalingAlarm"
  alarm_description = "Alarm Once CPU Usage Increases"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  statistic = "Average"

  # If our CPU utilization is over 20% 
  threshold = 20 

  # The period of time used to calculate the average. If the average execeeds the threshold
  # it will trigger this alarm_action
  period = 120 

  # The Scope -
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.myAutoScaler.name
  }
  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
}

# Define Auto Descaling Policy
resource "aws_autoscaling_policy" "scaledown_policy" {
  name = "scaledown_policy"
  autoscaling_group_name = aws_autoscaling_group.myAutoScaler.name
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = -1
  cooldown = 60
  policy_type = "SimpleScaling"
}

# Define Descaling CloudWatch
resource "aws_cloudwatch_metric_alarm" "myScalingDownAlarm" {
  alarm_name = "myScalingDownAlarm"
  alarm_description = "Alarm Once CPU Usage Decreases"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  statistic = "Average"

  # If our CPU utilization is over 20% 
  threshold = 10 

  # The period of time used to calculate the average. If the average execeeds the threshold
  # it will trigger this alarm_action
  period = 120 

  # The Scope -
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.myAutoScaler.name
  }
  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.scaledown_policy.arn]
}