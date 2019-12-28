### Resources
# https://www.terraform.io/docs/providers/aws/r/lb.html
resource "aws_lb" "lb" {
  name                             = var.elb_parameter["name"]
  subnets                          = var.elb_parameter["subnet_ids"]
  internal                         = var.elb_parameter["internal"]
  load_balancer_type               = var.elb_parameter["load_balancer_type"]
  security_groups                  = var.elb_parameter["security_groups"]
  enable_deletion_protection       = var.elb_parameter["enable_deletion_protection"]
  enable_cross_zone_load_balancing = var.elb_parameter["load_balancer_type"] == "network" ? var.elb_parameter["enable_cross_zone_load_balancing"] : null

  tags = {
    Name    = var.elb_parameter["name"]
    project = var.common_tags["project"]
    billing = var.common_tags["billing"]
    env     = var.common_tags["env"]
    app     = var.common_tags["app"]
  }
}


### Outputs
output "lb" {
  value = aws_lb.lb
}
