resource "aws_launch_template" "autoScaling" {
  image_id = "ami-0944e91aed79c721c"
  instance_type = "t2.micro"
  key_name = "windows_keypair"

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.sshSecurity.id]
    subnet_id = aws_subnet.autoscaling_subnet.id
  }

  placement {
    availability_zone = aws_subnet.autoscaling_subnet.availability_zone
  }

  # vpc_security_group_ids = [aws_security_group.sshSecurity.id]

  tags = {
    Name = "Terraform Test"
  }
}

resource "aws_autoscaling_group" "myAutoScaler" {
  depends_on = [ aws_subnet.autoscaling_subnet ]
  name = "My AutoBot"
  vpc_zone_identifier = [aws_subnet.autoscaling_subnet.id]
  max_size = 3 
  min_size = 2
  health_check_grace_period = 100
  health_check_type = "EC2"
  desired_capacity = 2 
  force_delete = true
  # launch_configuration = aws_launch_configuration.as_conf.id
  launch_template {
    id = aws_launch_template.autoScaling.id
    # version - (optional): template version.
    # can be version #, $Latest, or $Default
    #version = "$Latest"
  }
}