### Resources
# https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = var.ecs_task_parameter["ecs_task_name"]
  container_definitions    = var.ecs_task_parameter["ecs_task_container_definitions"]
  task_role_arn            = null
  execution_role_arn       = var.ecs_task_parameter["ecs_task_execution_role_arn"]
  network_mode             = var.ecs_task_parameter["ecs_task_network_mode"]
  requires_compatibilities = [var.ecs_task_parameter["ecs_task_requires_compatibilities"]]
  cpu                      = null
  memory                   = null

  dynamic "volume" {
    for_each = [for e in var.ecs_task_parameter["ecs_task_volumes"] : {
      name      = e.name
      host_path = e.host_path
    }]

    content {
      name      = volume.value.name
      host_path = volume.value.host_path
    }
  }

  tags = {
    Name    = var.ecs_task_parameter["ecs_task_name"]
    project = var.common_tags["project"]
    billing = var.common_tags["billing"]
  }
}


### Outputs
output "ecs_task_definition" {
  value = aws_ecs_task_definition.ecs_task_definition
}
