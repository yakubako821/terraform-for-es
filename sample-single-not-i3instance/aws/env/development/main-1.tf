### Modules
# CloudWatch
module "cpf-corp-search-es_cloudwatch_1" {
  source = "../../modules/cloudwatch"

  common_tags                    = local.common_tags
  cloudwatch_log_group_parameter = local.cloudwatch_log_group_parameter_1
}


# ELB
module "elasticsearch_lb_data_1" {
  source = "../../modules/elb/"

  common_tags   = local.common_tags_1
  elb_parameter = local.elb_parameter_data_1
}

module "elasticsearch_lb_listener_targetgroup_data_1" {
  source = "../../modules/elb/lb_listener_targetgroup"

  common_tags                        = local.common_tags_1
  lb                                 = module.elasticsearch_lb_data_1.lb
  vpc_id                             = var.vpc_id
  elb_listener_targetgroup_parameter = local.elb_listener_targetgroup_parameter_data_1
}

#module "elasticsearch_lb_coordinate_1" {
#  source = "../../modules/elb/"
#
#  common_tags   = local.common_tags_1
#  elb_parameter = local.elb_parameter_coordinate_1
#}

#module "elasticsearch_lb_listener_targetgroup_coordinate_1" {
#  source = "../../modules/elb/lb_listener_targetgroup"
#
#  common_tags                        = local.common_tags_1
#  lb                                 = module.elasticsearch_lb_coordinate_1.lb
#  vpc_id                             = var.vpc_id
#  elb_listener_targetgroup_parameter = local.elb_listener_targetgroup_parameter_coordinate_1
#}

module "elasticsearch_lb_kibana_1" {
  source = "../../modules/elb/"

  common_tags   = local.common_tags_1
  elb_parameter = local.elb_parameter_kibana_1
}

module "elasticsearch_lb_listener_targetgroup_kibana_1" {
  source = "../../modules/elb/lb_listener_targetgroup"

  common_tags                        = local.common_tags_1
  lb                                 = module.elasticsearch_lb_kibana_1.lb
  vpc_id                             = var.vpc_id
  elb_listener_targetgroup_parameter = local.elb_listener_targetgroup_parameter_kibana_1
}


# EC2 Master Node
# Elasticsearchは、初期起動時にMasterノードのIP確定が必要なため、単体で構築する。
# キーペアは事前に手動作成する。
#module "elasticsearch_instance_master_1" {
#  source = "../../modules/ec2/instance"
#
#  common_tags            = local.common_tags_1
#  ec2_instance_parameter = local.ec2_instance_parameter_master_1
#}


# EC2 DataNode - LaunchTemplate & Auto Scaling Group
# キーペアは事前に手動作成する。
module "elasticsearch_launch_template_data_1" {
  source = "../../modules/ec2/launch_template"

  common_tags               = local.common_tags_1
  launch_template_parameter = local.launch_template_parameter_data_1
}

module "elasticsearch_autoscaling_group_data_1" {
  source = "../../modules/ec2/autoscaling_group"

  common_tags                 = local.common_tags_1
  autoscaling_group_parameter = local.autoscaling_group_parameter_data_1
}

# EC2 Kibana & Coordinate Node - LaunchTemplate & Auto Scaling Group
# キーペアは事前に手動作成する。
#module "elasticsearch_launch_template_kibana-and-coordinate_1" {
#  source = "../../modules/ec2/launch_template"
#
#  common_tags               = local.common_tags_1
#  launch_template_parameter = local.launch_template_parameter_kibana-and-coordinate_1
#}

#module "elasticsearch_autoscaling_group_kibana-and-coordinate_1" {
#  source = "../../modules/ec2/autoscaling_group"
#
#  common_tags                 = local.common_tags_1
#  autoscaling_group_parameter = local.autoscaling_group_parameter_kibana-and-coordinate_1
#}


# ECS Cluster
#module "elasticsearch_ecs_cluster_master_1" {
#  source = "../../modules/ecs_cluster"
#
#  common_tags           = local.common_tags_1
#  ecs_cluster_parameter = local.ecs_cluster_parameter_master_1
#}

module "elasticsearch_ecs_cluster_data_1" {
  source = "../../modules/ecs_cluster"

  common_tags           = local.common_tags_1
  ecs_cluster_parameter = local.ecs_cluster_parameter_data_1
}

#module "elasticsearch_ecs_cluster_kibana-and-coordinate_1" {
#  source = "../../modules/ecs_cluster"
#
#  common_tags           = local.common_tags_1
#  ecs_cluster_parameter = local.ecs_cluster_parameter_kibana-and-coordinate_1
#}


# ECS Task & Service
#module "elasticsearch_ecs_cluster_taskservice_master_1" {
#  source = "../../modules/ecs_taskservice"
#
#  common_tags               = local.common_tags_1
#  ecs_cluster_parameter     = local.ecs_cluster_parameter_master_1
#  ecs_taskservice_parameter = local.ecs_taskservice_parameter_master_1
#}

module "elasticsearch_ecs_cluster_taskservice_data_1" {
  source = "../../modules/ecs_taskservice"

  common_tags               = local.common_tags_1
  ecs_cluster_parameter     = local.ecs_cluster_parameter_data_1
  ecs_taskservice_parameter = local.ecs_taskservice_parameter_data_1
}

#module "elasticsearch_ecs_cluster_taskservice_coordinate_1" {
#  source = "../../modules/ecs_taskservice"
#
#  common_tags               = local.common_tags_1
#  ecs_cluster_parameter     = local.ecs_cluster_parameter_kibana-and-coordinate_1
#  ecs_taskservice_parameter = local.ecs_taskservice_parameter_coordinate_1
#}

module "elasticsearch_ecs_cluster_taskservice_kibana_1" {
  source = "../../modules/ecs_taskservice"

  common_tags               = local.common_tags_1
  ecs_cluster_parameter     = local.ecs_cluster_parameter_data_1
  ecs_taskservice_parameter = local.ecs_taskservice_parameter_kibana_1
}


# ECS Service (Datadog)
# CoodinateNode用のdatadogは、必要に応じてモジュールを有効化し、datadog_enabled_coordinate_1変数を有効化する。
#module "elasticsearch_ecs_cluster_service_master_datadog_1" {
#  source = "../../modules/ecs_taskservice_datadog/ecs_service"
#
#  common_tags             = local.common_tags_1
#  ecs_cluster_parameter   = local.ecs_cluster_parameter_master_1
#  ecs_task_definition_arn = module.elasticsearch_ecs_task_elasticsearch-datadog-agent.ecs_task_definition.arn
#}

module "elasticsearch_ecs_cluster_service_data_datadog_1" {
  source = "../../modules/ecs_taskservice_datadog/ecs_service"

  common_tags             = local.common_tags_1
  ecs_cluster_parameter   = local.ecs_cluster_parameter_data_1
  ecs_task_definition_arn = module.elasticsearch_ecs_task_elasticsearch-datadog-agent.ecs_task_definition.arn
}

#module "elasticsearch_ecs_cluster_service_kibana-and-coordinate_datadog_1" {
#  source = "../../modules/ecs_taskservice_datadog/ecs_service"
#
#  common_tags             = local.common_tags_1
#  ecs_cluster_parameter   = local.ecs_cluster_parameter_kibana-and-coordinate_1
#  ecs_task_definition_arn = module.elasticsearch_ecs_task_elasticsearch-datadog-agent.ecs_task_definition.arn
#}
