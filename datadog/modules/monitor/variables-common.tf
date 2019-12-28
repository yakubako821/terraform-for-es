variable "project" {}
variable "resource" {}
variable "notify_destination" {}

locals {
  query_alert_monitors = concat(
    local.cpf_es_article_archive_clusters_x_query_alert_monitors,
    local.cpf_es_article_recent_clusters_x_query_alert_monitors,
    local.cpf_es_company_people_clusters_x_query_alert_monitors,
  )

  service_check_monitors = concat(
    local.cpf_es_article_archive_clusters_x_service_check_monitors,
    local.cpf_es_article_recent_clusters_x_service_check_monitors,
    local.cpf_es_company_people_clusters_x_service_check_monitors,
  )
}
