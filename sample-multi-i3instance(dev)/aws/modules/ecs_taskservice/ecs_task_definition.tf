### Resources
# https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = var.ecs_taskservice_parameter["ecs_task_name"]
  container_definitions    = var.ecs_taskservice_parameter["ecs_task_container_definitions"]
  task_role_arn            = var.ecs_taskservice_parameter["ecs_task_task_role_arn"]
  execution_role_arn       = var.ecs_taskservice_parameter["ecs_task_execution_role_arn"]
  network_mode             = var.ecs_taskservice_parameter["ecs_task_network_mode"]
  requires_compatibilities = [var.ecs_taskservice_parameter["ecs_task_compatibilities"]]
  cpu                      = var.ecs_taskservice_parameter["ecs_task_cpu"]
  memory                   = var.ecs_taskservice_parameter["ecs_task_memory"]

  dynamic "volume" {
    for_each = [for e in var.ecs_taskservice_parameter["ecs_task_volumes"] : {
      name      = e.name
      host_path = e.host_path
    }]

    content {
      name      = volume.value.name
      host_path = volume.value.host_path
    }
  }

  tags = {
    Name    = var.ecs_taskservice_parameter["ecs_task_name"]
    cluster = var.ecs_cluster_parameter["name"]
    project = var.common_tags["project"]
    billing = var.common_tags["billing"]
    env     = var.common_tags["env"]
    app     = var.common_tags["app"]
  }
}
