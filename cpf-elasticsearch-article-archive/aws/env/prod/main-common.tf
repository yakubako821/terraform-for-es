### Provider
# AWS
# https://www.terraform.io/docs/providers/aws/
provider "aws" {
  version = ">=2.15"

  allowed_account_ids = [
    "556975058824"
  ]

  profile = var.profile
  region  = var.region
}

### Terraform Configuration
terraform {
  required_version = ">= 0.12.0"

  backend "s3" {
    bucket = "cpf-terraform-prod"
    key    = "cpf-elasitcsearch-article-archive/main/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

### Modules
# Security Group
module "elasticsearch_security_group" {
  source = "../../modules/security_group"

  common_tags              = local.common_tags
  vpc_id                   = var.vpc_id
  security_group_parameter = local.security_group_parameter
}

#module "elasticsearch_security_group_from-batch" {
#  source = "../../modules/security_group"
#
#  common_tags              = local.common_tags
#  vpc_id                   = var.vpc_id
#  security_group_parameter = local.security_group_parameter_from-batch
#}

module "elasticsearch_security_group_elb-for-kibana" {
  source = "../../modules/security_group"

  common_tags              = local.common_tags
  vpc_id                   = var.vpc_id
  security_group_parameter = local.security_group_parameter_elb-for-kibana
}

module "elasticsearch_security_group_kibana" {
  source = "../../modules/security_group"

  common_tags              = local.common_tags
  vpc_id                   = var.vpc_id
  security_group_parameter = local.security_group_parameter_kibana
}


# Route 53 Record
module "elasticsearch_route53_record_kibana" {
  source = "../../modules/route53_record"

  common_tags              = local.common_tags
  route53_record_parameter = local.route53_record_parameter_kibana
}

module "elasticsearch_route53_record_application" {
  source = "../../modules/route53_record"

  common_tags              = local.common_tags
  route53_record_parameter = local.route53_record_parameter_application
}

# ECS Task for Datadog Agent
module "elasticsearch_ecs_task_elasticsearch-datadog-agent" {
  source = "../../modules/ecs_taskservice_datadog/ecs_task_definition"

  common_tags        = local.common_tags
  ecs_task_parameter = local.ecs_task_parameter_elasticsearch-datadog-agent
}
