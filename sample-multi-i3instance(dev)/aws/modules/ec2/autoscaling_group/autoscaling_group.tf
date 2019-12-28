### Resources
# https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html
resource "aws_autoscaling_group" "autoscaling_group" {
  name            = var.autoscaling_group_parameter["name"]
  launch_template {
    id      = var.autoscaling_group_parameter["launch_template_id"]
    version = var.autoscaling_group_parameter["launch_template_version"]
  }
  
  max_size                  = var.autoscaling_group_parameter["max_size"]
  min_size                  = var.autoscaling_group_parameter["min_size"]
  desired_capacity          = var.autoscaling_group_parameter["desired_capacity"]
  
  health_check_grace_period = var.autoscaling_group_parameter["health_check_grace_period"]
  health_check_type         = var.autoscaling_group_parameter["health_check_type"]
  
  vpc_zone_identifier       = var.autoscaling_group_parameter["vpc_zone_identifier"]
  
  target_group_arns = var.autoscaling_group_parameter["target_group_arns"]
  
  tags = var.autoscaling_group_parameter["tags"]
}
