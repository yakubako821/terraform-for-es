# Provider datadog
provider "datadog" {
  version = ">=2.5"

  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}

terraform {
  required_version = ">=0.12"

  backend "s3" {
    bucket = "cpf-terraform-prod"
    key    = "cpf-elasticsearch-datadog/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

# Modules
module "dashboard" {
  source = "./modules/dashboard"

  project  = local.project
  resource = local.resource
}

module "monitor" {
  source = "./modules/monitor"

  project            = local.project
  resource           = local.resource
  notify_destination = local.notify_destination
}
