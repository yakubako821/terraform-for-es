### DataSources
# Datadog Agent Configuration file
data "template_file" "elasticsearch_log_conf_1" {
  template = file("../../modules/definitions/datadog_customized_log_definition/elasticsearch_log_conf.yaml")

  vars = {
    datadog_service_tag                               = local.elasticsearch_parameter_1["elasticsearch_cluster_name"]
    elasticsearch_logfile_path                        = "/usr/share/elasticsearch/logs/${local.elasticsearch_parameter_1["elasticsearch_cluster_name"]}.log"
    elasticsearch_index_search_slowlog_logfile_path   = "/usr/share/elasticsearch/logs/${local.elasticsearch_parameter_1["elasticsearch_cluster_name"]}_index_search_slowlog.log"
    elasticsearch_index_indexing_slowlog_logfile_path = "/usr/share/elasticsearch/logs/${local.elasticsearch_parameter_1["elasticsearch_cluster_name"]}_index_indexing_slowlog.log"
    elasticsearch_deprecation_logfile_path            = "/usr/share/elasticsearch/logs/${local.elasticsearch_parameter_1["elasticsearch_cluster_name"]}_deprecation.log"
  }
}


# EC2 User data
data "template_file" "ec2_user_data_elasticsearch-master_1" {
  template = file("../../modules/definitions/ec2_user_data_definitions/ec2_user_data_elasticsearch-master.sh")

  vars = {
    ecs_cluster_name         = local.ecs_cluster_parameter_master_1["name"]
    datadog_agent_log_config = data.template_file.elasticsearch_log_conf_1.rendered
  }
}

data "template_file" "ec2_user_data_elasticsearch-data_1" {
  template = file("../../modules/definitions/ec2_user_data_definitions/ec2_user_data_elasticsearch-data.sh")

  vars = {
    ecs_cluster_name         = local.ecs_cluster_parameter_data_1["name"]
    datadog_agent_log_config = data.template_file.elasticsearch_log_conf_1.rendered
  }
}

data "template_file" "ec2_user_data_elasticsearch-kibana-and-coordinate_1" {
  template = file("../../modules/definitions/ec2_user_data_definitions/ec2_user_data_elasticsearch-kibana-and-coordinate.sh")

  vars = {
    ecs_cluster_name         = local.ecs_cluster_parameter_kibana-and-coordinate_1["name"]
    datadog_agent_log_config = data.template_file.elasticsearch_log_conf_1.rendered
  }
}


# ECS Container Definitions
data "template_file" "container_definition_elasticsearch-master_1" {
  template = file("../../modules/definitions/container_definitions/container_definition_elasticsearch.json")

  vars = {
    node_type         = "master"
    container_name    = local.elasticsearch_parameter_1["elasticsearch_master_node_name"]
    ecr_name          = local.elasticsearch_parameter_1["ecr_name_elasticsearch"]
    ecr_version       = local.elasticsearch_parameter_1["ecr_version"]
    account_id        = data.aws_caller_identity.current.account_id
    awslogs_log_group = local.cloudwatch_log_group_parameter_1["name"]

    cluster_name                                                            = local.elasticsearch_parameter_1["elasticsearch_cluster_name"]
    discovery_type                                                          = local.elasticsearch_parameter_1["discovery_type_single"] ? "-E discovery.type=single-node" : ""
    cluster_initial_master_nodes                                            = local.elasticsearch_parameter_1["discovery_type_single"] ? "" : "-E cluster.initial_master_nodes=${local.elasticsearch_parameter_1["master_node_ips"][0]},${local.elasticsearch_parameter_1["master_node_ips"][1]},${local.elasticsearch_parameter_1["master_node_ips"][2]}"
    memory_reservation                                                      = local.elasticsearch_parameter_1["master_memory_reservation"]
    es_java_opts                                                            = local.elasticsearch_parameter_1["master_es_java_opts"]
    cluster_routing_allocation_awareness_force_aws_availability_zone_values = local.elasticsearch_parameter_1["cluster_routing_allocation_awareness_force_aws_availability_zone_values"]
    xpack_monitoring_collection_enabled                                     = local.elasticsearch_parameter_1["xpack_monitoring_collection_enabled"]
    xpack_monitoring_exporters_my_remote_host                               = local.elasticsearch_parameter_1["xpack_monitoring_exporters_my_remote_host"]
    xpack_monitoring_history_duration                                       = local.elasticsearch_parameter_1["xpack_monitoring_history_duration"]
    indices_query_bool_max_clause_count                                     = local.elasticsearch_parameter_1["indices_query_bool_max_clause_count"]
  }
}

data "template_file" "container_definition_elasticsearch-data_1" {
  template = file("../../modules/definitions/container_definitions/container_definition_elasticsearch.json")

  vars = {
    node_type         = "data"
    container_name    = local.elasticsearch_parameter_1["elasticsearch_data_node_name"]
    ecr_name          = local.elasticsearch_parameter_1["ecr_name_elasticsearch"]
    ecr_version       = local.elasticsearch_parameter_1["ecr_version"]
    account_id        = data.aws_caller_identity.current.account_id
    awslogs_log_group = local.cloudwatch_log_group_parameter_1["name"]

    cluster_name                                                            = local.elasticsearch_parameter_1["elasticsearch_cluster_name"]
    discovery_type                                                          = local.elasticsearch_parameter_1["discovery_type_single"] ? "-E discovery.type=single-node" : ""
    cluster_initial_master_nodes                                            = local.elasticsearch_parameter_1["discovery_type_single"] ? "" : "-E cluster.initial_master_nodes=${local.elasticsearch_parameter_1["master_node_ips"][0]},${local.elasticsearch_parameter_1["master_node_ips"][1]},${local.elasticsearch_parameter_1["master_node_ips"][2]}"
    memory_reservation                                                      = local.elasticsearch_parameter_1["data_memory_reservation"]
    es_java_opts                                                            = local.elasticsearch_parameter_1["data_es_java_opts"]
    cluster_routing_allocation_awareness_force_aws_availability_zone_values = local.elasticsearch_parameter_1["cluster_routing_allocation_awareness_force_aws_availability_zone_values"]
    xpack_monitoring_collection_enabled                                     = local.elasticsearch_parameter_1["xpack_monitoring_collection_enabled"]
    xpack_monitoring_exporters_my_remote_host                               = local.elasticsearch_parameter_1["xpack_monitoring_exporters_my_remote_host"]
    xpack_monitoring_history_duration                                       = local.elasticsearch_parameter_1["xpack_monitoring_history_duration"]
    indices_query_bool_max_clause_count                                     = local.elasticsearch_parameter_1["indices_query_bool_max_clause_count"]
  }
}

data "template_file" "container_definition_elasticsearch-coordinate_1" {
  template = file("../../modules/definitions/container_definitions/container_definition_elasticsearch.json")

  vars = {
    node_type         = "coordinate"
    container_name    = local.elasticsearch_parameter_1["elasticsearch_coordinate_node_name"]
    ecr_name          = local.elasticsearch_parameter_1["ecr_name_elasticsearch"]
    ecr_version       = local.elasticsearch_parameter_1["ecr_version"]
    account_id        = data.aws_caller_identity.current.account_id
    awslogs_log_group = local.cloudwatch_log_group_parameter_1["name"]

    cluster_name                                                            = local.elasticsearch_parameter_1["elasticsearch_cluster_name"]
    discovery_type                                                          = local.elasticsearch_parameter_1["discovery_type_single"] ? "-E discovery.type=single-node" : ""
    cluster_initial_master_nodes                                            = local.elasticsearch_parameter_1["discovery_type_single"] ? "" : "-E cluster.initial_master_nodes=${local.elasticsearch_parameter_1["master_node_ips"][0]},${local.elasticsearch_parameter_1["master_node_ips"][1]},${local.elasticsearch_parameter_1["master_node_ips"][2]}"
    memory_reservation                                                      = local.elasticsearch_parameter_1["coordinate_memory_reservation"]
    es_java_opts                                                            = local.elasticsearch_parameter_1["coordinate_es_java_opts"]
    cluster_routing_allocation_awareness_force_aws_availability_zone_values = local.elasticsearch_parameter_1["cluster_routing_allocation_awareness_force_aws_availability_zone_values"]
    xpack_monitoring_collection_enabled                                     = local.elasticsearch_parameter_1["xpack_monitoring_collection_enabled"]
    xpack_monitoring_exporters_my_remote_host                               = local.elasticsearch_parameter_1["xpack_monitoring_exporters_my_remote_host"]
    xpack_monitoring_history_duration                                       = local.elasticsearch_parameter_1["xpack_monitoring_history_duration"]
    indices_query_bool_max_clause_count                                     = local.elasticsearch_parameter_1["indices_query_bool_max_clause_count"]
  }
}

data "template_file" "container_definition_elasticsearch-kibana_1" {
  template = file("../../modules/definitions/container_definitions/container_definition_elasticsearch-kibana.json")

  vars = {
    container_name    = local.elasticsearch_parameter_1["elasticsearch_kibana_node_name"]
    ecr_name          = local.elasticsearch_parameter_1["ecr_name_kibana"]
    ecr_version       = local.elasticsearch_parameter_1["ecr_version"]
    account_id        = data.aws_caller_identity.current.account_id
    awslogs_log_group = local.cloudwatch_log_group_parameter_1["name"]

    memory_reservation = local.elasticsearch_parameter_1["kibana_memory_reservation"]
  }
}

### Common Variable
variable "datadog_enabled_1" {
  default = "true"
}

variable "datadog_enabled_coordinate_1" {
  default = "false"
}


### Common Locals
locals {
  common_tags_1 = {
    project = var.project_name
    env     = var.environment
    billing = var.project_name
    app     = local.elasticsearch_parameter_1["elasticsearch_cluster_name"]
    datadog = var.datadog_enabled_1
  }
}

### Elasticsearch Locals
# TODO : EC2キーぺアをどう管理するか。
# TODO : env1/env2のドメイン接続先切り替えによるBlue/Greenデプロイメントを検証。
locals {
  elasticsearch_parameter_1 = {
    elasticsearch_cluster_name                    = "${local.elasticsearch_name}-${var.environment}-1"
    elasticsearch_master_node_name                = "${local.elasticsearch_name}-master-${var.environment}-1"
    elasticsearch_data_node_name                  = "${local.elasticsearch_name}-data-${var.environment}-1"
    elasticsearch_kibana-and-coordinate_node_name = "${local.elasticsearch_name}-kibana-and-coord-${var.environment}-1"
    elasticsearch_kibana_node_name                = "${local.elasticsearch_name}-kibana-${var.environment}-1"
    elasticsearch_coordinate_node_name            = "${local.elasticsearch_name}-coord-${var.environment}-1"

    elasticsearch_cluster_short_name                    = "${local.elasticsearch_short_name}-${var.environment}-1"
    elasticsearch_master_node_short_name                = "${local.elasticsearch_short_name}-ma-${var.environment}-1"
    elasticsearch_data_node_short_name                  = "${local.elasticsearch_short_name}-da-${var.environment}-1"
    elasticsearch_kibana-and-coordinate_node_short_name = "${local.elasticsearch_short_name}-kc-${var.environment}-1"
    elasticsearch_kibana_node_short_name                = "${local.elasticsearch_short_name}-ki-${var.environment}-1"
    elasticsearch_coordinate_node_short_name            = "${local.elasticsearch_short_name}-co-${var.environment}-1"

    ecr_name_elasticsearch = "cpf-elasticsearch-article"
    ecr_name_kibana        = "cpf-kibana"
    ecr_version            = "v680"

    # single-nodeで起動する場合は、マスターノードのみmaster_node_ipsを1つにして作成し、他ノードの定義を削除して作成する。
    discovery_type_single = false

    # 公式見解 : i3.2xlarge以降は、32766mにヒープメモリを充てるのが最大性能が発揮できる。
    # memory_reservation : インスタンスタイプメモリ - 1024MB
    # -XX:ActiveProcessorCount : インスタンスタイプのvCPU数
    # Xms/Xmx : (memory_reservation - 1G)の70%
    # Xmn : Xms(Xmx) / 2
    master_instance_type      = "m5.large"
    master_node_ips           = list("172.24.8.101", "172.24.24.101", "172.24.40.101")
    master_memory_reservation = 7168
    master_es_java_opts       = "-XX:ActiveProcessorCount=2 -Xms4096m -Xmx4096m -XX:HeapDumpPath=/usr/share/elasticsearch/data -Xlog:gc*:file=/usr/share/elasticsearch/logs/gc_%p_%t.log::filecount=32,filesize=64m:time"

    data_instance_type      = "i3.2xlarge"
    data_autoscaling_size   = 6
    data_memory_reservation = 50000
    data_es_java_opts       = "-XX:ActiveProcessorCount=8 -Xms32766m -Xmx32766m -XX:HeapDumpPath=/usr/share/elasticsearch/data -Xlog:gc*:file=/usr/share/elasticsearch/logs/gc_%p_%t.log::filecount=32,filesize=64m:time"

    kibana-and-coordinate_instance_type    = "m5.large"
    kibana-and-coordinate_autoscaling_size = 1
    coordinate_memory_reservation          = 5120
    kibana_memory_reservation              = 2048
    coordinate_es_java_opts                = "-XX:ActiveProcessorCount=2 -Xms4096m -Xmx4096m -XX:HeapDumpPath=/usr/share/elasticsearch/data -Xlog:gc*:file=/usr/share/elasticsearch/logs/gc_%p_%t.log::filecount=32,filesize=64m:time"

    cluster_routing_allocation_awareness_force_aws_availability_zone_values = "ap-northeast-1a,ap-northeast-1c,ap-northeast-1d"
    xpack_monitoring_collection_enabled                                     = "true"
    xpack_monitoring_exporters_my_remote_host                               = "cpf-elasticsearch-km-article-archive-monitoring-indexing-1.cpf.b12s.jp:9200"
    xpack_monitoring_history_duration                                       = "40d"
    indices_query_bool_max_clause_count                                     = "8192"
  }
}

### CloudWatch Locals
locals {
  cloudwatch_log_group_parameter_1 = {
    name              = "/aws/ecs/${local.elasticsearch_parameter_1["elasticsearch_cluster_name"]}"
    retention_in_days = 30
  }
}

### EC2 Locals
locals {
  # Master Node
  ec2_instance_parameter_master_1 = {
    name         = local.elasticsearch_parameter_1["elasticsearch_master_node_name"]
    cluster_name = local.elasticsearch_parameter_1["elasticsearch_cluster_name"]

    ami                                  = "ami-0e37e42dff65024ae"
    instance_type                        = local.elasticsearch_parameter_1["master_instance_type"]
    iam_instance_profile                 = "cpf-elasticsearch-instance-profile"
    key_name                             = "aws_nikkei_b2b_prod"
    associate_public_ip_address          = "false"
    instance_initiated_shutdown_behavior = "stop"
    disable_api_termination              = "false"
    monitoring                           = "false"
    tenancy                              = "default"
    ebs_optimized                        = "true"
    user_data                            = data.template_file.ec2_user_data_elasticsearch-master_1.rendered
    cpu_credits                          = "standard"
    vpc_security_group_ids               = [module.elasticsearch_security_group.security_group_id]

    # Modifying any of the root_block_device settings requires resource replacement.
    root_block_device_volume_type = "gp2"
    root_block_device_volume_size = "50"

    subnet_ids  = var.private_subnet_ids
    private_ips = local.elasticsearch_parameter_1["master_node_ips"]
  }

  # Data Node
  launch_template_parameter_data_1 = {
    name          = local.ecs_cluster_parameter_data_1["name"]
    ebs_optimized = true

    image_id      = "ami-0e37e42dff65024ae"
    instance_type = local.elasticsearch_parameter_1["data_instance_type"]
    user_data     = data.template_file.ec2_user_data_elasticsearch-data_1.rendered
    key_name      = "aws_nikkei_b2b_prod"

    iam_instance_profile_name = "cpf-elasticsearch-instance-profile"
    monitoring_enabled        = false

    block_device_mappings = []

    network_interfaces = [
      {
        device_index                = 0
        associate_public_ip_address = false
        security_groups             = [module.elasticsearch_security_group.security_group_id]
      }
    ]

    tag_specifications = [
      {
        resource_type     = "instance"
        tag_Name_value    = local.ecs_cluster_parameter_data_1["name"]
        tag_cluster_value = local.elasticsearch_parameter_1["elasticsearch_cluster_name"]
        tag_project_value = local.common_tags_1["project"]
        tag_env_value     = local.common_tags_1["env"]
        tag_app_value     = local.common_tags_1["app"]
      },
      {
        resource_type     = "volume"
        tag_Name_value    = local.ecs_cluster_parameter_data_1["name"]
        tag_cluster_value = local.elasticsearch_parameter_1["elasticsearch_cluster_name"]
        tag_project_value = local.common_tags_1["project"]
        tag_env_value     = local.common_tags_1["env"]
        tag_app_value     = local.common_tags_1["app"]
      }
    ]
  }

  autoscaling_group_parameter_data_1 = {
    name                    = local.ecs_cluster_parameter_data_1["name"]
    launch_template_id      = module.elasticsearch_launch_template_data_1.launch_template.id
    launch_template_version = module.elasticsearch_launch_template_data_1.launch_template.latest_version
    max_size                = local.elasticsearch_parameter_1["data_autoscaling_size"]
    min_size                = local.elasticsearch_parameter_1["data_autoscaling_size"]
    desired_capacity        = local.elasticsearch_parameter_1["data_autoscaling_size"]

    health_check_grace_period = 300
    health_check_type         = "EC2"

    vpc_zone_identifier = var.private_subnet_ids

    target_group_arns = null

    tags = [
      {
        key                 = "Name"
        value               = local.ecs_cluster_parameter_data_1["name"]
        propagate_at_launch = true
      },
      {
        key                 = "cluster"
        value               = local.elasticsearch_parameter_1["elasticsearch_cluster_name"]
        propagate_at_launch = true
      },
      {
        key                 = "project"
        value               = local.common_tags_1["project"]
        propagate_at_launch = true
      },
      {
        key                 = "billing"
        value               = local.common_tags_1["billing"]
        propagate_at_launch = true
      },
      {
        key                 = "env"
        value               = local.common_tags_1["env"]
        propagate_at_launch = true
      },
      {
        key                 = "app"
        value               = local.common_tags_1["app"]
        propagate_at_launch = true
      },
      {
        key                 = "datadog"
        value               = local.common_tags_1["datadog"]
        propagate_at_launch = true
      }
    ]
  }

  # Kibana & Coordinate Node
  launch_template_parameter_kibana-and-coordinate_1 = {
    name          = local.ecs_cluster_parameter_kibana-and-coordinate_1["name"]
    ebs_optimized = true

    image_id      = "ami-0e37e42dff65024ae"
    instance_type = local.elasticsearch_parameter_1["kibana-and-coordinate_instance_type"]
    user_data     = data.template_file.ec2_user_data_elasticsearch-kibana-and-coordinate_1.rendered
    key_name      = "aws_nikkei_b2b_prod"

    iam_instance_profile_name = "cpf-elasticsearch-instance-profile"
    monitoring_enabled        = false

    block_device_mappings = []

    network_interfaces = [
      {
        device_index                = 0
        associate_public_ip_address = false
        security_groups             = [module.elasticsearch_security_group.security_group_id, module.elasticsearch_security_group_kibana.security_group_id]
      }
    ]

    tag_specifications = [
      {
        resource_type     = "instance"
        tag_Name_value    = local.ecs_cluster_parameter_kibana-and-coordinate_1["name"]
        tag_cluster_value = local.elasticsearch_parameter_1["elasticsearch_cluster_name"]
        tag_project_value = local.common_tags_1["project"]
        tag_env_value     = local.common_tags_1["env"]
        tag_app_value     = local.common_tags_1["app"]
      },
      {
        resource_type     = "volume"
        tag_Name_value    = local.ecs_cluster_parameter_kibana-and-coordinate_1["name"]
        tag_cluster_value = local.elasticsearch_parameter_1["elasticsearch_cluster_name"]
        tag_project_value = local.common_tags_1["project"]
        tag_env_value     = local.common_tags_1["env"]
        tag_app_value     = local.common_tags_1["app"]
      }
    ]
  }

  autoscaling_group_parameter_kibana-and-coordinate_1 = {
    name                    = local.ecs_cluster_parameter_kibana-and-coordinate_1["name"]
    launch_template_id      = module.elasticsearch_launch_template_kibana-and-coordinate_1.launch_template.id
    launch_template_version = module.elasticsearch_launch_template_kibana-and-coordinate_1.launch_template.latest_version
    max_size                = local.elasticsearch_parameter_1["kibana-and-coordinate_autoscaling_size"]
    min_size                = local.elasticsearch_parameter_1["kibana-and-coordinate_autoscaling_size"]
    desired_capacity        = local.elasticsearch_parameter_1["kibana-and-coordinate_autoscaling_size"]

    health_check_grace_period = 300
    health_check_type         = "EC2"

    vpc_zone_identifier = var.private_subnet_ids

    target_group_arns = null

    tags = [
      {
        key                 = "Name"
        value               = local.ecs_cluster_parameter_kibana-and-coordinate_1["name"]
        propagate_at_launch = true
      },
      {
        key                 = "cluster"
        value               = local.elasticsearch_parameter_1["elasticsearch_cluster_name"]
        propagate_at_launch = true
      },
      {
        key                 = "project"
        value               = local.common_tags_1["project"]
        propagate_at_launch = true
      },
      {
        key                 = "billing"
        value               = local.common_tags_1["billing"]
        propagate_at_launch = true
      },
      {
        key                 = "env"
        value               = local.common_tags_1["env"]
        propagate_at_launch = true
      },
      {
        key                 = "app"
        value               = local.common_tags_1["app"]
        propagate_at_launch = true
      },
      {
        key                 = "datadog"
        value               = var.datadog_enabled_coordinate_1
        propagate_at_launch = true
      }
    ]
  }
}

### ELB Locals
locals {
  elb_parameter_data_1 = {
    name                             = local.elasticsearch_parameter_1["elasticsearch_data_node_short_name"]
    internal                         = "true"
    load_balancer_type               = "network"
    security_groups                  = null
    enable_deletion_protection       = "false"
    enable_cross_zone_load_balancing = "true"
    subnet_ids                       = var.private_subnet_ids
  }

  elb_listener_targetgroup_parameter_data_1 = {
    name                                          = local.elasticsearch_parameter_1["elasticsearch_data_node_short_name"]
    default_action_type                           = "forward"
    listener_port                                 = "9200"
    listener_protocol                             = "TCP"
    listener_ssl_policy                           = null
    listener_certificate_arn                      = null
    target_type                                   = "instance"
    target_group_port                             = "9200"
    target_group_protocol                         = "TCP"
    target_group_deregistration_delay             = "300"
    target_group_health_check_interval            = "30"
    target_group_health_check_path                = null
    target_group_health_check_healthy_threshold   = "3"
    target_group_health_check_unhealthy_threshold = "3"
    target_group_health_check_matcher             = null
  }

  elb_parameter_coordinate_1 = {
    name                             = local.elasticsearch_parameter_1["elasticsearch_coordinate_node_short_name"]
    internal                         = "true"
    load_balancer_type               = "network"
    security_groups                  = null
    enable_deletion_protection       = "false"
    enable_cross_zone_load_balancing = "true"
    subnet_ids                       = var.private_subnet_ids
  }

  elb_listener_targetgroup_parameter_coordinate_1 = {
    name                                          = local.elasticsearch_parameter_1["elasticsearch_coordinate_node_short_name"]
    default_action_type                           = "forward"
    listener_port                                 = "9200"
    listener_protocol                             = "TCP"
    listener_ssl_policy                           = null
    listener_certificate_arn                      = null
    target_type                                   = "instance"
    target_group_port                             = "9200"
    target_group_protocol                         = "TCP"
    target_group_deregistration_delay             = "300"
    target_group_health_check_interval            = "30"
    target_group_health_check_path                = null
    target_group_health_check_healthy_threshold   = "3"
    target_group_health_check_unhealthy_threshold = "3"
    target_group_health_check_matcher             = null
  }

  elb_parameter_kibana_1 = {
    name                             = local.elasticsearch_parameter_1["elasticsearch_kibana_node_short_name"]
    internal                         = "false"
    load_balancer_type               = "application"
    security_groups                  = [module.elasticsearch_security_group_elb-for-kibana.security_group_id]
    enable_deletion_protection       = "false"
    enable_cross_zone_load_balancing = "true"
    subnet_ids                       = var.public_subnet_ids
  }

  elb_listener_targetgroup_parameter_kibana_1 = {
    name                                          = local.elasticsearch_parameter_1["elasticsearch_kibana_node_short_name"]
    default_action_type                           = "forward"
    listener_port                                 = "443"
    listener_protocol                             = "HTTPS"
    listener_ssl_policy                           = "ELBSecurityPolicy-2016-08"
    listener_certificate_arn                      = "arn:aws:acm:ap-northeast-1:${data.aws_caller_identity.current.account_id}:certificate/d7a5e373-cf82-4235-a069-d9578cc54a5f"
    target_type                                   = "instance"
    target_group_port                             = "5601"
    target_group_protocol                         = "HTTP"
    target_group_deregistration_delay             = "300"
    target_group_health_check_interval            = "30"
    target_group_health_check_path                = "/app/kibana"
    target_group_health_check_healthy_threshold   = "3"
    target_group_health_check_unhealthy_threshold = "3"
    target_group_health_check_matcher             = "200"
  }
}


### ECS Locals
locals {
  # ECS Cluster
  ecs_cluster_parameter_master_1 = {
    name = local.elasticsearch_parameter_1["elasticsearch_master_node_name"]
  }

  ecs_cluster_parameter_data_1 = {
    name = local.elasticsearch_parameter_1["elasticsearch_data_node_name"]
  }

  ecs_cluster_parameter_kibana-and-coordinate_1 = {
    name = local.elasticsearch_parameter_1["elasticsearch_kibana-and-coordinate_node_name"]
  }

  # Master Node
  ecs_taskservice_parameter_master_1 = {
    ecs_task_name                  = "${local.ecs_cluster_parameter_master_1["name"]}_${replace(local.elasticsearch_parameter_1["ecr_version"], ".", "")}"
    ecs_task_task_role_arn         = null
    ecs_task_execution_role_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/cpf-elasticsearch-service-role"
    ecs_task_network_mode          = "host"
    ecs_task_compatibilities       = "EC2"
    ecs_task_cpu                   = null
    ecs_task_memory                = null
    ecs_task_container_definitions = data.template_file.container_definition_elasticsearch-master_1.rendered
    ecs_task_volumes = [
      {
        name      = "elasticsearch-data-instance-store"
        host_path = "/usr/share/elasticsearch/data"
      },
      {
        name      = "elasticsearch-log-store"
        host_path = "/usr/share/elasticsearch/logs"
      }
    ]

    ecs_service_name                              = local.ecs_cluster_parameter_master_1["name"]
    ecs_service_schedule_strategy                 = "DAEMON"
    ecs_service_enable_ecs_managed_tags           = "false"
    ecs_service_propagate_tags                    = "SERVICE"
    ecs_service_desired_count                     = null
    ecs_service_health_check_grace_period_seconds = null

    network_configuration = []

    load_balancer = []
  }

  # Data Node
  ecs_taskservice_parameter_data_1 = {
    ecs_task_name                  = "${local.ecs_cluster_parameter_data_1["name"]}_${replace(local.elasticsearch_parameter_1["ecr_version"], ".", "")}"
    ecs_task_task_role_arn         = null
    ecs_task_execution_role_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/cpf-elasticsearch-service-role"
    ecs_task_network_mode          = "host"
    ecs_task_compatibilities       = "EC2"
    ecs_task_cpu                   = null
    ecs_task_memory                = null
    ecs_task_container_definitions = data.template_file.container_definition_elasticsearch-data_1.rendered
    ecs_task_volumes = [
      {
        name      = "elasticsearch-data-instance-store-1"
        host_path = "/usr/share/elasticsearch/data/data1"
      },
      {
        name      = "elasticsearch-data-instance-store-2"
        host_path = "/usr/share/elasticsearch/data/data2"
      },
      {
        name      = "elasticsearch-log-store"
        host_path = "/usr/share/elasticsearch/logs"
      }
    ]

    ecs_service_name                              = local.ecs_cluster_parameter_data_1["name"]
    ecs_service_schedule_strategy                 = "DAEMON"
    ecs_service_enable_ecs_managed_tags           = "false"
    ecs_service_propagate_tags                    = "SERVICE"
    ecs_service_desired_count                     = null
    ecs_service_health_check_grace_period_seconds = 300

    network_configuration = []

    load_balancer = [
      {
        target_group_arn = module.elasticsearch_lb_listener_targetgroup_data_1.lb_target_group.arn
        container_name   = local.elasticsearch_parameter_1["elasticsearch_data_node_name"]
        container_port   = 9200
      }
    ]
  }

  # Coordinate Node
  ecs_taskservice_parameter_coordinate_1 = {
    ecs_task_name                  = "${local.elasticsearch_parameter_1["elasticsearch_coordinate_node_name"]}_${replace(local.elasticsearch_parameter_1["ecr_version"], ".", "")}"
    ecs_task_task_role_arn         = null
    ecs_task_execution_role_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/cpf-elasticsearch-service-role"
    ecs_task_network_mode          = "host"
    ecs_task_compatibilities       = "EC2"
    ecs_task_cpu                   = null
    ecs_task_memory                = null
    ecs_task_container_definitions = data.template_file.container_definition_elasticsearch-coordinate_1.rendered
    ecs_task_volumes = [
      {
        name      = "elasticsearch-data-instance-store"
        host_path = "/usr/share/elasticsearch/data"
      },
      {
        name      = "elasticsearch-log-store"
        host_path = "/usr/share/elasticsearch/logs"
      }
    ]

    ecs_service_name                              = local.elasticsearch_parameter_1["elasticsearch_coordinate_node_name"]
    ecs_service_schedule_strategy                 = "DAEMON"
    ecs_service_enable_ecs_managed_tags           = "false"
    ecs_service_propagate_tags                    = "SERVICE"
    ecs_service_desired_count                     = null
    ecs_service_health_check_grace_period_seconds = 300

    network_configuration = []

    load_balancer = [
      {
        target_group_arn = module.elasticsearch_lb_listener_targetgroup_coordinate_1.lb_target_group.arn
        container_name   = local.elasticsearch_parameter_1["elasticsearch_coordinate_node_name"]
        container_port   = 9200
      }
    ]
  }

  route53_record_parameter_indexing_1 = {
    zone_id = "ZF6R9CZC1BL0A"

    name = "${local.elasticsearch_name}-indexing-1"
    type = "A"

    alias_name                   = module.elasticsearch_lb_data_1.lb.dns_name
    alias_zone_id                = "Z31USIVHYNEOWT"
    alias_evaluate_target_health = true
  }

  # Kibana Node
  ecs_taskservice_parameter_kibana_1 = {
    ecs_task_name                  = "${local.elasticsearch_parameter_1["elasticsearch_kibana_node_name"]}_${replace(local.elasticsearch_parameter_1["ecr_version"], ".", "")}"
    ecs_task_task_role_arn         = null
    ecs_task_execution_role_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/cpf-elasticsearch-service-role"
    ecs_task_network_mode          = "host"
    ecs_task_compatibilities       = "EC2"
    ecs_task_cpu                   = null
    ecs_task_memory                = null
    ecs_task_container_definitions = data.template_file.container_definition_elasticsearch-kibana_1.rendered
    ecs_task_volumes               = []

    ecs_service_name                              = local.elasticsearch_parameter_1["elasticsearch_kibana_node_name"]
    ecs_service_schedule_strategy                 = "DAEMON"
    ecs_service_enable_ecs_managed_tags           = "false"
    ecs_service_propagate_tags                    = "SERVICE"
    ecs_service_desired_count                     = null
    ecs_service_health_check_grace_period_seconds = 300

    network_configuration = []

    load_balancer = [
      {
        target_group_arn = module.elasticsearch_lb_listener_targetgroup_kibana_1.lb_target_group.arn
        container_name   = local.elasticsearch_parameter_1["elasticsearch_kibana_node_name"]
        container_port   = 5601
      }
    ]
  }
}
