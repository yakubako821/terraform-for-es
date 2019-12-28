### Resources
# https://www.terraform.io/docs/providers/aws/r/instance.html
resource "aws_instance" "instance" {
  lifecycle {
    ignore_changes = ["user_data"]
  }

  count = length(var.ec2_instance_parameter["private_ips"])

  ami           = var.ec2_instance_parameter["ami"]
  instance_type = var.ec2_instance_parameter["instance_type"]
  user_data     = var.ec2_instance_parameter["user_data"]

  subnet_id              = element(var.ec2_instance_parameter["subnet_ids"], count.index % 3)
  private_ip             = element(var.ec2_instance_parameter["private_ips"], count.index % 3)
  vpc_security_group_ids = var.ec2_instance_parameter["vpc_security_group_ids"]

  iam_instance_profile = var.ec2_instance_parameter["iam_instance_profile"]
  key_name             = var.ec2_instance_parameter["key_name"]

  associate_public_ip_address          = var.ec2_instance_parameter["associate_public_ip_address"]
  instance_initiated_shutdown_behavior = var.ec2_instance_parameter["instance_initiated_shutdown_behavior"]
  disable_api_termination              = var.ec2_instance_parameter["disable_api_termination"]
  monitoring                           = var.ec2_instance_parameter["monitoring"]
  tenancy                              = var.ec2_instance_parameter["tenancy"]
  ebs_optimized                        = var.ec2_instance_parameter["ebs_optimized"]

  root_block_device {
    volume_type = var.ec2_instance_parameter["root_block_device_volume_type"]
    volume_size = var.ec2_instance_parameter["root_block_device_volume_size"]
  }

  credit_specification {
    cpu_credits = var.ec2_instance_parameter["cpu_credits"]
  }

  tags = {
    Name    = format("${var.ec2_instance_parameter["name"]}-%02d", count.index + 1)
    cluster = var.ec2_instance_parameter["cluster_name"]
    project = var.common_tags["project"]
    billing = var.common_tags["billing"]
    env     = var.common_tags["env"]
    datadog = var.common_tags["datadog"]
    app     = var.common_tags["app"]
  }

  volume_tags = {
    Name    = format("${var.ec2_instance_parameter["name"]}-%02d", count.index + 1)
    cluster = var.ec2_instance_parameter["cluster_name"]
    project = var.common_tags["project"]
    billing = var.common_tags["billing"]
    env     = var.common_tags["env"]
    datadog = var.common_tags["datadog"]
    app     = var.common_tags["app"]
  }
}


### Outputs
output "instance_ids_by_availability_zone" {
  value = {
    for instance in aws_instance.instance:
    instance.availability_zone => instance.id
  }
}

output "instance_private_ips_by_availability_zone" {
  value = {
    for instance in aws_instance.instance:
    instance.availability_zone => instance.private_ip
  }
}
