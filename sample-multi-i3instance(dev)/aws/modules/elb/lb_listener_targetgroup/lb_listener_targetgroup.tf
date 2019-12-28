### Resources
# https://www.terraform.io/docs/providers/aws/r/lb_listener.html
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = var.lb.arn
  port              = var.elb_listener_targetgroup_parameter["listener_port"]
  protocol          = var.elb_listener_targetgroup_parameter["listener_protocol"]
  ssl_policy        = var.elb_listener_targetgroup_parameter["listener_ssl_policy"]
  certificate_arn   = var.elb_listener_targetgroup_parameter["listener_certificate_arn"]

  default_action {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    type             = var.elb_listener_targetgroup_parameter["default_action_type"]
  }
}

# https://www.terraform.io/docs/providers/aws/r/lb_target_group.html
resource "aws_lb_target_group" "lb_target_group" {
  name                 = var.elb_listener_targetgroup_parameter["name"]
  port                 = var.elb_listener_targetgroup_parameter["target_group_port"]
  protocol             = var.elb_listener_targetgroup_parameter["target_group_protocol"]
  target_type          = var.elb_listener_targetgroup_parameter["target_type"]
  vpc_id               = var.vpc_id
  deregistration_delay = var.elb_listener_targetgroup_parameter["target_group_deregistration_delay"]

  health_check {
    interval            = var.elb_listener_targetgroup_parameter["target_group_health_check_interval"]
    path                = var.elb_listener_targetgroup_parameter["target_group_health_check_path"]
    port                = "traffic-port"
    protocol            = var.elb_listener_targetgroup_parameter["target_group_protocol"]
    healthy_threshold   = var.elb_listener_targetgroup_parameter["target_group_health_check_healthy_threshold"]
    unhealthy_threshold = var.elb_listener_targetgroup_parameter["target_group_health_check_unhealthy_threshold"]
    matcher             = var.elb_listener_targetgroup_parameter["target_group_health_check_matcher"]
  }

  tags = {
    Name    = var.elb_listener_targetgroup_parameter["name"]
    project = var.common_tags["project"]
    billing = var.common_tags["billing"]
    env     = var.common_tags["env"]
    app     = var.common_tags["app"]
  }
}


### Outputs
output "lb_target_group" {
  value = aws_lb_target_group.lb_target_group
}
