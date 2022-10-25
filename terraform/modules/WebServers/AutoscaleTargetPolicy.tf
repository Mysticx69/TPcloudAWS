resource "aws_autoscaling_policy" "asg_policy_webservers" {

  name                   = "webservers_autoscale_policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.ASG_webservers.name

  target_tracking_configuration {

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = "60"
  }

}
