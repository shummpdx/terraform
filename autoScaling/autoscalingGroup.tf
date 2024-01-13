resource "aws_autoscaling_group" "myAutoScaler" {
  depends_on = [ aws_subnet.main ]
  name = "My AutoBot"
  vpc_zone_identifier = [aws_subnet.main.id]
  max_size = 3 
  min_size = 2
  health_check_grace_period = 100
  health_check_type = "EC2"
  desired_capacity = 2 
  force_delete = true
  launch_configuration = aws_launch_configuration.as_conf.id
}