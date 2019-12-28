### Resources
# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "security_group" {
  name        = var.security_group_parameter["name"]
  vpc_id      = var.vpc_id
  description = var.security_group_parameter["description"]

  dynamic "ingress" {
    for_each = [for s in var.security_group_parameter["ingress"] : {
      from_port       = s.from_port
      to_port         = s.to_port
      protocol        = s.protocol
      security_groups = s.security_groups
      cidr_blocks     = s.cidr_blocks
      self            = s.self
      description     = s.description
    }]

    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      security_groups = ingress.value.security_groups
      cidr_blocks     = ingress.value.cidr_blocks
      self            = ingress.value.self
      description     = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = [for s in var.security_group_parameter["egress"] : {
      from_port       = s.from_port
      to_port         = s.to_port
      protocol        = s.protocol
      security_groups = s.security_groups
      cidr_blocks     = s.cidr_blocks
      self            = s.self
      description     = s.description
    }]

    content {
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      security_groups = egress.value.security_groups
      cidr_blocks     = egress.value.cidr_blocks
      self            = egress.value.self
      description     = egress.value.description
    }
  }

  tags = {
    Name    = var.security_group_parameter["name"]
    billing = var.common_tags["billing"]
  }
}


### Outputs
output "security_group_id" {
  value = aws_security_group.security_group.id
}
