### Resources
# https://www.terraform.io/docs/providers/aws/r/launch_template.html
resource "aws_launch_template" "launch_template" {
  name = var.launch_template_parameter["name"]
  ebs_optimized = var.launch_template_parameter["ebs_optimized"]
  
  image_id = var.launch_template_parameter["image_id"]
  instance_type = var.launch_template_parameter["instance_type"]
  user_data = base64encode(var.launch_template_parameter["user_data"])
  key_name = var.launch_template_parameter["key_name"]
  
  dynamic "block_device_mappings" {
    for_each = [for b in var.launch_template_parameter["block_device_mappings"] : {
      device_name = b.device_name
      ebs_encrypted = b.ebs_encrypted
      ebs_kms_key_id =b.ebs_kms_key_id
      ebs_iops = b.ebs_iops
      ebs_volume_size = b.ebs_volume_size
      ebs_volume_type = b.ebs_volume_type
    }]

    content {
      device_name = block_device_mappings.value.device_name

      ebs {
        encrypted = block_device_mappings.value.ebs_encrypted
        kms_key_id = block_device_mappings.value.ebs_kms_key_id
        iops = block_device_mappings.value.ebs_iops
        volume_size = block_device_mappings.value.ebs_volume_size
        volume_type = block_device_mappings.value.ebs_volume_type
      }
    }
  }

  iam_instance_profile {
    name = var.launch_template_parameter["iam_instance_profile_name"]
  }

  monitoring {
    enabled = var.launch_template_parameter["monitoring_enabled"]
  }

  dynamic "network_interfaces" {
    for_each = [for n in var.launch_template_parameter["network_interfaces"] : {
      device_index = n.device_index
      associate_public_ip_address = n.associate_public_ip_address
      security_groups = n.security_groups
    }]

    content {
      device_index = network_interfaces.value.device_index
      associate_public_ip_address = network_interfaces.value.associate_public_ip_address
      security_groups = network_interfaces.value.security_groups
    }
  }

  dynamic "tag_specifications" {
    for_each = [for t in var.launch_template_parameter["tag_specifications"] : {
      resource_type = t.resource_type
      tag_Name_value = t.tag_Name_value
      tag_cluster_value = t.tag_cluster_value
      tag_project_value = t.tag_project_value
      tag_env_value = t.tag_env_value
      tag_app_value = t.tag_app_value
    }]

    content {
      resource_type = tag_specifications.value.resource_type

      tags = {
        Name    = tag_specifications.value.tag_Name_value
        cluster = tag_specifications.value.tag_cluster_value
        project = tag_specifications.value.tag_project_value
        billing = var.common_tags["billing"]
        env     = tag_specifications.value.tag_env_value
        app     = tag_specifications.value.tag_app_value
      }
    }
  }

  tags = {
    Name    = var.launch_template_parameter["name"]
    billing = var.common_tags["billing"]
  }
}


### Outputs
output "launch_template" {
  value = aws_launch_template.launch_template
}
