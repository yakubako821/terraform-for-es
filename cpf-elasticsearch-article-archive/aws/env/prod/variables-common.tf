### DataSources
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# Datadog Agent ECS Container Definitions
data "template_file" "container_definition_elasticsearch-datadog-agent" {
  template = file("../../modules/definitions/container_definitions/container_definition_elasticsearch-datadog-agent.json")

  vars = {
    parameterstore_dd_arn = "arn:aws:ssm:ap-northeast-1:${data.aws_caller_identity.current.account_id}:parameter/dd-agent"
  }
}


### Common Variable
variable "profile" {
  description = "Please enter the profile name of the AWS credential."
}

variable "region" {
  default = "ap-northeast-1"
}

variable "project_name" {
  default = "cpf"
}

variable "environment" {
  default = "prod"
}

variable "vpc_id" {
  default = "vpc-96f0b2f1"
}

variable "private_subnet_ids" {
  type    = "list"
  default = ["subnet-789b9031", "subnet-66eeab3d", "subnet-28edf000"]
}

variable "public_subnet_ids" {
  type    = "list"
  default = ["subnet-4a878c03", "subnet-cdeeab96", "subnet-41f0ed69"]
}

variable "privatesubnet_cidr_blocks" {
  type    = "list"
  default = ["172.24.8.0/22", "172.24.24.0/22", "172.24.40.0/22"]
}

#variable "vs_operationaccount_privatesubnet_cidr_blocks" {
#  type    = "list"
#  default = ["172.16.212.64/27", "172.16.213.64/27"]
#}


### Common Locals
locals {
  common_tags = {
    project = var.project_name
    env     = var.environment
    billing = var.project_name
  }
}

### Elasticsearch Locals
# TODO : EC2キーぺアをどう管理するか。
# TODO : env1/env2作ってBlue/Green環境作る。
# TODO : datadog-agentは、手動作成管理にしないとリビジョンがずれるので、その方針で構築するで良いか。
# TODO : ドメイン名の見直し。(ローカルドメインは使わなくて良いかも含めて)
locals {
  elasticsearch_name       = "${var.project_name}-elasticsearch-article-archive"
  elasticsearch_short_name = "${var.project_name}-es-aa"
}

### EC2 Locals
locals {
  security_group_parameter = {
    name        = "${local.elasticsearch_name}-${var.environment}-sg"
    description = "${local.elasticsearch_name}-${var.environment}-sg"

    ingress = [
      {
        from_port       = 9200
        to_port         = 9200
        protocol        = "tcp"
        description     = "from self"
        security_groups = null
        cidr_blocks     = null
        self            = true
      },
      {
        from_port       = 9300
        to_port         = 9300
        protocol        = "tcp"
        description     = "from self"
        security_groups = null
        cidr_blocks     = null
        self            = true
      },
      {
        from_port       = 9200
        to_port         = 9200
        protocol        = "tcp"
        description     = "from privatesubnet for nlb or private server"
        security_groups = null
        cidr_blocks     = var.privatesubnet_cidr_blocks
        self            = null
      },
      {
        from_port       = 9200
        to_port         = 9200
        protocol        = "tcp"
        description     = "from public subnet step server"
        security_groups = list("sg-06812c6bad600f53d")
        cidr_blocks     = null
        self            = null
      }
    ]

    egress = [
      {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        description     = "to internet"
        security_groups = null
        cidr_blocks     = list("0.0.0.0/0")
        self            = null
      },
      {
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        description     = "to internet"
        security_groups = null
        cidr_blocks     = list("0.0.0.0/0")
        self            = null
      },
      {
        from_port       = 9200
        to_port         = 9200
        protocol        = "tcp"
        description     = "to self"
        security_groups = null
        cidr_blocks     = null
        self            = true
      },
      {
        from_port       = 9200
        to_port         = 9200
        protocol        = "tcp"
        description     = "to self"
        security_groups = null
        cidr_blocks     = var.privatesubnet_cidr_blocks
        self            = null
      },
      {
        from_port       = 9300
        to_port         = 9300
        protocol        = "tcp"
        description     = "to self"
        security_groups = null
        cidr_blocks     = null
        self            = true
      },
      {
        from_port       = 10516
        to_port         = 10516
        protocol        = "tcp"
        description     = "to datadog(datadog)"
        security_groups = null
        cidr_blocks     = list("0.0.0.0/0")
        self            = null
      },
      {
        from_port       = 123
        to_port         = 123
        protocol        = "udp"
        description     = "to datadog(datadog)"
        security_groups = null
        cidr_blocks     = list("0.0.0.0/0")
        self            = null
      }
    ]
  }

#  security_group_parameter_from-batch = {
#    name        = "${local.elasticsearch_name}-from-batch-${var.environment}-sg"
#    description = "${local.elasticsearch_name}-from-batch-${var.environment}-sg"
#
#    ingress = [
#      {
#        # NitroインスタンスからNLBに直接接続する場合、接続元のSGIDだけでは接続できず、IPを指定しないと接続できないため、運用アカウントのVSサブネットIPレンジで開放する。
#        from_port       = 9200
#        to_port         = 9200
#        protocol        = "tcp"
#        description     = "from vs operationaccount privatesubnet"
#        security_groups = null
#        cidr_blocks     = var.vs_operationaccount_privatesubnet_cidr_blocks
#        self            = null
#      }
#    ]
#
#    egress = []
#  }

  security_group_parameter_elb-for-kibana = {
    name        = "${local.elasticsearch_name}-elb-for-kibana-${var.environment}-sg"
    description = "${local.elasticsearch_name}-elb-for-kibana-${var.environment}-sg"

    ingress = [
      {
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        description     = "from Nikkei Kuro LAN"
        security_groups = null
        cidr_blocks     = list("219.120.22.170/32")
        self            = null
      },
      {
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        description     = "from Nikkei Kuro LAN"
        security_groups = null
        cidr_blocks     = list("133.250.250.0/24")
        self            = null
      }
    ]

    egress = [
      {
        from_port       = 5601
        to_port         = 5601
        protocol        = "tcp"
        description     = "to privatesubnet"
        security_groups = null
        cidr_blocks     = var.privatesubnet_cidr_blocks
        self            = null
      }
    ]
  }

  security_group_parameter_kibana = {
    name        = "${local.elasticsearch_name}-kibana-${var.environment}-sg"
    description = "${local.elasticsearch_name}-kibana-${var.environment}-sg"

    ingress = [
      {
        from_port       = 5601
        to_port         = 5601
        protocol        = "tcp"
        description     = "from alb for kibana"
        security_groups = [module.elasticsearch_security_group_elb-for-kibana.security_group_id]
        cidr_blocks     = null
        self            = null
      }
    ]

    egress = []
  }
}


### Route 53 Record Locals
locals {
  route53_record_parameter_kibana = {
    zone_id = "ZF6R9CZC1BL0A"

    name = "${local.elasticsearch_name}-kibana"
    type = "A"

    alias_name                   = module.elasticsearch_lb_kibana_1.lb.dns_name
    alias_zone_id                = "Z14GRHDCWA56QT"
    alias_evaluate_target_health = true
  }

  route53_record_parameter_application = {
    zone_id = "ZF6R9CZC1BL0A"

    name = "${local.elasticsearch_name}-application"
    type = "A"

    alias_name                   = module.elasticsearch_lb_coordinate_1.lb.dns_name
    alias_zone_id                = "Z31USIVHYNEOWT"
    alias_evaluate_target_health = true
  }
}


### ECS Service & Task Locals
locals {
  # Elasticsearch用Datadogエージェント
  ecs_task_parameter_elasticsearch-datadog-agent = {
    ecs_task_name                     = "${local.elasticsearch_name}-datadog-agent-${var.environment}"
    ecs_task_execution_role_arn       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/cpf-datadog-agent-service-role"
    ecs_task_network_mode             = "host"
    ecs_task_requires_compatibilities = "EC2"
    ecs_task_container_definitions    = data.template_file.container_definition_elasticsearch-datadog-agent.rendered
    ecs_task_volumes = [
      {
        name      = "docker_sock"
        host_path = "/var/run/docker.sock"
      },
      {
        name      = "proc"
        host_path = "/proc/"
      },
      {
        # https://github.com/DataDog/datadog-agent/issues/2001 
        name      = "cgroup"
        host_path = "/sys/fs/cgroup/"
      },
      {
        name      = "datadog_agent_run"
        host_path = "/opt/datadog-agent/run"
      },
      {
        name      = "customized_d"
        host_path = "/etc/datadog-agent/conf.d/customized.d"
      },
      {
        name      = "elasticsearch-log-store"
        host_path = "/usr/share/elasticsearch/logs"
      }
    ]
  }
}