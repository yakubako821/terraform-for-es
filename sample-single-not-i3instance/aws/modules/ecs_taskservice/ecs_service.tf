### Resources
# https://www.terraform.io/docs/providers/aws/r/ecs_service.html
resource "aws_ecs_service" "ecs_service" {
  name                    = var.ecs_taskservice_parameter["ecs_service_name"]
  task_definition         = aws_ecs_task_definition.ecs_task_definition.arn
  cluster                 = var.ecs_cluster_parameter["name"]
  launch_type             = var.ecs_taskservice_parameter["ecs_task_compatibilities"]
  scheduling_strategy     = var.ecs_taskservice_parameter["ecs_service_schedule_strategy"]
  enable_ecs_managed_tags = var.ecs_taskservice_parameter["ecs_service_enable_ecs_managed_tags"]
  propagate_tags          = var.ecs_taskservice_parameter["ecs_service_propagate_tags"]
  desired_count           = var.ecs_taskservice_parameter["ecs_service_desired_count"]

  dynamic "load_balancer" {
    for_each = [for e in var.ecs_taskservice_parameter["load_balancer"] : {
      target_group_arn = e.target_group_arn
      container_name   = e.container_name
      container_port   = e.container_port
    }]

    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  #deployment_controller = null
  health_check_grace_period_seconds = var.ecs_taskservice_parameter["ecs_service_health_check_grace_period_seconds"]

  tags = {
    Name    = var.ecs_taskservice_parameter["ecs_service_name"]
    cluster = var.ecs_cluster_parameter["name"]
    project = var.common_tags["project"]
    billing = var.common_tags["billing"]
    env     = var.common_tags["env"]
    app     = var.common_tags["app"]
  }
}
