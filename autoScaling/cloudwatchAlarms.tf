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

  # If our CPU utilization is greater than or equal to 20% 
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

# Define Descaling CloudWatch
resource "aws_cloudwatch_metric_alarm" "myScalingDownAlarm" {
  alarm_name = "myScalingDownAlarm"
  alarm_description = "Alarm Once CPU Usage Decreases"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  statistic = "Average"

  # If our CPU utilization is Less Than Or Equal To 10% 
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