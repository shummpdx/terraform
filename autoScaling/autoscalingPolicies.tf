# Define Auto Scaling Up Policy
resource "aws_autoscaling_policy" "scale_up" {
  name = "CPU_Util"
  autoscaling_group_name = aws_autoscaling_group.myAutoScaler.name
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = 1
  cooldown = 60 # Seconds after a scale activity completes and another can start
  policy_type = "SimpleScaling"
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