resource "aws_autoscaling_group" "ASG_webservers" {

  launch_configuration = aws_launch_configuration.lauch_cfg_asg.id
  min_size             = 2
  max_size             = 10
  desired_capacity     = 3
  load_balancers       = [aws_elb.ELB_Webservers.name]
  vpc_zone_identifier  = var.vpc_zone_identifier



  tag {
    key                 = "Name"
    value               = "webservers-asg"
    propagate_at_launch = true
  }

}
