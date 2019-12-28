### Resources
# https://www.terraform.io/docs/providers/aws/r/ecs_cluster.html
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_parameter["name"]

  tags = {
    Name    = var.ecs_cluster_parameter["name"]
    cluster = var.ecs_cluster_parameter["name"]
    project = var.common_tags["project"]
    billing = var.common_tags["billing"]
    env     = var.common_tags["env"]
    app     = var.common_tags["app"]
  }
}
