### Resources
# https://www.terraform.io/docs/providers/aws/r/ecs_service.html
resource "aws_ecs_service" "ecs_service" {
  name                    = "datadog-agent"
  task_definition         = var.ecs_task_definition_arn
  cluster                 = var.ecs_cluster_parameter["name"]
  launch_type             = "EC2"
  scheduling_strategy     = "DAEMON"
  enable_ecs_managed_tags = "false"
  propagate_tags          = "SERVICE"

  health_check_grace_period_seconds = null

  tags = {
    Name    = "datadog-agent"
    project = var.common_tags["project"]
    billing = var.common_tags["billing"]
    env     = var.common_tags["env"]
    app     = var.common_tags["app"]
  }
}
