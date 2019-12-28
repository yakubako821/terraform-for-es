### Resources
# https://www.terraform.io/docs/providers/aws/r/cloudwatch_log_group.html
resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name              = var.cloudwatch_log_group_parameter["name"]
  retention_in_days = var.cloudwatch_log_group_parameter["retention_in_days"]

  tags = {
    Name    = var.cloudwatch_log_group_parameter["name"]
    billing = var.common_tags["billing"]
  }
}
