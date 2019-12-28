# https://www.terraform.io/docs/providers/datadog/r/monitor.html#query-alert
resource "datadog_monitor" "query_alert_monitor" {
  for_each = {
    for monitors_by_cluster in local.query_alert_monitors : "${monitors_by_cluster.cluster_name}.${monitors_by_cluster.name}" => monitors_by_cluster
  }

  name = "[${var.project}][${var.resource}][${each.value["cluster_name"]}] ${each.value["name"]}"
  type = "query alert"

  message = templatefile("${path.module}/message_template.txt", {
    notify_destination = var.notify_destination
  })
  escalation_message = ""

  query = format(each.value["query"], each.value["cluster_name"])

  thresholds = each.value["thresholds"]

  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  no_data_timeframe   = null
  require_full_window = false
  new_host_delay      = 300
  notify_no_data      = false
  renotify_interval   = 0

  tags = [
    var.project,
    var.resource,
    each.value["cluster_name"],
  ]

  locked = false
  lifecycle {
    ignore_changes = ["silenced"]
  }
}

# https://www.terraform.io/docs/providers/datadog/r/monitor.html#service-check
resource "datadog_monitor" "service_check_monitor" {
  for_each = {
    for monitors_by_cluster in local.service_check_monitors : "${monitors_by_cluster.cluster_name}.${monitors_by_cluster.name}" => monitors_by_cluster
  }

  name = "[${var.project}][${var.resource}][${each.value["cluster_name"]}] ${each.value["name"]}"
  type = "service check"

  message = templatefile("${path.module}/message_template.txt", {
    notify_destination = var.notify_destination
  })

  query = format(each.value["query"], each.value["cluster_name"])

  thresholds = each.value["thresholds"]

  notify_audit      = false
  timeout_h         = 0
  include_tags      = true
  no_data_timeframe = 2
  new_host_delay    = 300
  notify_no_data    = false
  renotify_interval = 0

  tags = [
    var.project,
    var.resource,
    each.value["cluster_name"],
  ]

  locked = false
  lifecycle {
    ignore_changes = ["silenced"]
  }
}
