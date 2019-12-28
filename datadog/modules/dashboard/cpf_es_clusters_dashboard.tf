resource "datadog_dashboard" "cpf_es_clusters_dashboard" {
  is_read_only = "false"
  layout_type  = "free"

  template_variable {
    default = "*"
    name    = "project"
    prefix  = "project"
  }

  template_variable {
    default = "*"
    name    = "env"
    prefix  = "env"
  }

  template_variable {
    default = "*"
    name    = "app"
    prefix  = "app"
  }

  template_variable {
    default = "*"
    name    = "host"
    prefix  = "host"
  }

  template_variable {
    default = "*"
    name    = "name"
    prefix  = "name"
  }

  template_variable {
    default = "*"
    name    = "functionname"
    prefix  = "functionname"
  }

  template_variable {
    default = "*"
    name    = "clustername"
    prefix  = "cluster_name"
  }

  title = "[${var.project}][${var.resource}] Elasticsearch Screenboard"

  widget {
    layout = {
      height = "12"
      width  = "15"
      x      = "16"
      y      = "31"
    }

    query_value_definition {
      autoscale = "true"
      precision = "0"

      request {
        aggregator = "max"

        conditional_formats {
          comparator = "<="
          hide_value = "false"
          palette    = "green_on_white"
          value      = "600"
        }

        conditional_formats {
          comparator = ">"
          hide_value = "false"
          palette    = "yellow_on_white"
          value      = "500"
        }

        conditional_formats {
          comparator = ">"
          hide_value = "false"
          palette    = "red_on_white"
          value      = "600"
        }

        q = "avg:elasticsearch.active_shards{$clustername,$project,$env,$app,$host,$name,$functionname}/avg:elasticsearch.number_of_data_nodes{$clustername,$project,$env,$app,$host,$name,$functionname}"
      }

      time = {
        live_span = "10m"
      }

      title       = "Active shards by Data Node"
      title_align = "left"
      title_size  = "16"
    }
  }

  widget {
    layout = {
      height = "12"
      width  = "15"
      x      = "0"
      y      = "31"
    }

    query_value_definition {
      autoscale = "true"
      precision = "0"

      request {
        aggregator = "max"

        conditional_formats {
          comparator = ">"
          hide_value = "false"
          palette    = "yellow_on_white"
          value      = "0"
        }

        conditional_formats {
          comparator = ">="
          hide_value = "false"
          palette    = "green_on_white"
          value      = "0"
        }

        q = "max:elasticsearch.unassigned_shards{$clustername,$project,$env,$app,$host,$name,$functionname}"
      }

      time = {
        live_span = "10m"
      }

      title       = "Unassigned shards"
      title_align = "left"
      title_size  = "16"
    }
  }

  widget {
    layout = {
      height = "14"
      width  = "67"
      x      = "92"
      y      = "72"
    }

    timeseries_definition {
      request {
        display_type = "bars"
        q            = "sum:elasticsearch.pending_tasks_total{$clustername,$project,$env,$app,$host,$name,$functionname} by {name}"

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "warm"
        }
      }

      show_legend = "false"

      time = {
        live_span = "4h"
      }

      title       = "Pending tasks by node"
      title_align = "left"
      title_size  = "16"
    }
  }

  widget {
    layout = {
      height = "18"
      width  = "29"
      x      = "62"
      y      = "6"
    }

    timeseries_definition {
      request {
        display_type = "line"
        q            = "(derivative(sum:elasticsearch.indexing.index.time{$clustername,$project,$env,$app,$host,$name,$functionname})*1000/derivative(sum:elasticsearch.indexing.index.total{*}))"

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "dog_classic"
        }
      }

      show_legend = "false"

      time = {
        live_span = "4h"
      }

      title       = "Indexing time (ms)"
      title_align = "left"
      title_size  = "16"
    }
  }

  widget {
    layout = {
      height = "18"
      width  = "29"
      x      = "32"
      y      = "6"
    }

    timeseries_definition {
      request {
        display_type = "line"
        q            = "(derivative(sum:elasticsearch.search.fetch.time{$clustername,$project,$env,$app,$host,$name,$functionname})+derivative(sum:elasticsearch.search.query.time{$clustername,$project,$env,$app,$host,$name,$functionname}))*1000/derivative(sum:elasticsearch.search.query.total{$clustername,$project,$env,$app,$host,$name,$functionname})"

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "dog_classic"
        }
      }

      show_legend = "false"

      time = {
        live_span = "4h"
      }

      title       = "Search latency (ms)"
      title_align = "left"
      title_size  = "16"
    }
  }

  widget {
    layout = {
      height = "14"
      width  = "33"
      x      = "126"
      y      = "57"
    }

    timeseries_definition {
      marker {
        display_type = "warning dashed"
        value        = "y = 75"
      }

      marker {
        display_type = "error dashed"
        value        = "y = 85"
      }

      request {
        display_type = "line"
        q            = "(1-(max:elasticsearch.fs.total.available_in_bytes{$clustername,$name,$project,$env,$app,$host,$functionname} by {name}/max:elasticsearch.fs.total.total_in_bytes{$clustername,$name,$project,$env,$app,$host,$functionname} by {name}))*100"

        style {
          line_type  = "solid"
          line_width = "thin"
          palette    = "cool"
        }
      }

      show_legend = "false"

      time = {
        live_span = "1h"
      }

      title       = "Disk space used by node (%)"
      title_align = "left"
      title_size  = "16"
    }
  }

  widget {
    layout = {
      height = "18"
      width  = "33"
      x      = "92"
      y      = "25"
    }

    timeseries_definition {
      marker {
        display_type = "warning dashed"
        value        = "y = 500"
      }

      marker {
        display_type = "error dashed"
        value        = "y = 1000"
      }

      request {
        display_type = "area"
        q            = "sum:elasticsearch.thread_pool.search.queue{$clustername,$project,$env,$app,$host,$name,$functionname} by {name}"

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "dog_classic"
        }
      }

      show_legend = "false"

      time = {
        live_span = "4h"
      }

      title       = "Search thread pool queue size by node"
      title_align = "left"
      title_size  = "16"
    }
  }

  widget {
    layout = {
      height = "18"
      width  = "33"
      x      = "126"
      y      = "25"
    }

    timeseries_definition {
      marker {
        display_type = "warning dashed"
        value        = "y = 100"
      }

      marker {
        display_type = "error dashed"
        value        = "y = 200"
      }

      request {
        display_type = "area"
        q            = "sum:elasticsearch.thread_pool.write.queue{$clustername,$project,$env,$app,$host,$name,$functionname} by {name}"

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "dog_classic"
        }
      }

      show_legend = "false"

      time = {
        live_span = "4h"
      }

      title       = "Write thread pool queue size by node"
      title_align = "left"
      title_size  = "16"
    }
  }

  widget {
    layout = {
      height = "18"
      width  = "45"
      x      = "46"
      y      = "68"
    }

    timeseries_definition {
      request {
        display_type = "line"
        q            = "per_second(avg:jvm.gc.collectors.old.count{$clustername,$project,$env,$app,$host,$name,$functionname} by {name})"

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "dog_classic"
        }
      }

      show_legend = "false"

      time = {
        live_span = "4h"
      }

      title       = "Old Garbage collections per sec"
      title_align = "left"
      title_size  = "16"
    }
  }

  widget {
    layout = {
      height = "18"
      width  = "45"
      x      = "0"
      y      = "68"
    }

    timeseries_definition {
      request {
        display_type = "line"
        q            = "per_second(avg:jvm.gc.collectors.young.count{$clustername,$project,$env,$app,$host,$name,$functionname} by {name})"

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "dog_classic"
        }
      }

      show_legend = "false"

      time = {
        live_span = "4h"
      }

      title       = "Young Garbage collections per sec"
      title_align = "left"
      title_size  = "16"
    }
  }

  widget {
    layout = {
      height = "17"
      width  = "91"
      x      = "0"
      y      = "50"
    }

    timeseries_definition {
      marker {
        display_type = "error dashed"
        value        = "y = 0"
      }

      request {
        display_type = "line"
        q            = "sum:jvm.mem.heap_in_use{$clustername,$project,$env,$app,$host,$name,$functionname} by {name}"

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "cool"
        }
      }

      show_legend = "false"

      time = {
        live_span = "4h"
      }

      title       = "JVM heap in use by node"
      title_align = "left"
      title_size  = "16"
    }
  }

  widget {
    layout = {
      height = "5"
      width  = "59"
      x      = "32"
      y      = "0"
    }

    note_definition {
      background_color = "blue"
      content          = "**[Search and indexing performance]**"
      font_size        = "18"
      show_tick        = "true"
      text_align       = "center"
      tick_edge        = "bottom"
      tick_pos         = "50%"
    }
  }

  widget {
    layout = {
      height = "5"
      width  = "31"
      x      = "0"
      y      = "0"
    }

    note_definition {
      background_color = "blue"
      content          = "**[Cluster health and node availability]**"
      font_size        = "16"
      show_tick        = "true"
      text_align       = "center"
      tick_edge        = "bottom"
      tick_pos         = "50%"
    }
  }

  widget {
    layout = {
      height = "5"
      width  = "67"
      x      = "92"
      y      = "0"
    }

    note_definition {
      background_color = "blue"
      content          = "**[Resource saturation]**"
      font_size        = "18"
      show_tick        = "true"
      text_align       = "center"
      tick_edge        = "bottom"
      tick_pos         = "50%"
    }
  }

  widget {
    layout = {
      height = "5"
      width  = "91"
      x      = "0"
      y      = "44"
    }

    note_definition {
      background_color = "blue"
      content          = "**[JVM heap and garbage collection]**"
      font_size        = "18"
      show_tick        = "true"
      text_align       = "center"
      tick_edge        = "bottom"
      tick_pos         = "50%"
    }
  }

  widget {
    layout = {
      height = "16"
      width  = "45"
      x      = "46"
      y      = "87"
    }

    timeseries_definition {
      request {
        display_type = "line"
        q            = "(avg:jvm.gc.collectors.old.collection_time{$clustername,$project,$env,$app,$host,$name,$functionname} by {name}/avg:jvm.gc.collectors.old.count{$clustername,$project,$env,$app,$host,$name,$functionname} by {name})"

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "cool"
        }
      }

      show_legend = "false"

      time = {
        live_span = "4h"
      }

      title       = "Old garbage collection time (sec)"
      title_align = "left"
      title_size  = "16"
    }
  }

  widget {
    layout = {
      height = "16"
      width  = "45"
      x      = "0"
      y      = "87"
    }

    timeseries_definition {
      request {
        display_type = "line"
        q            = "(sum:jvm.gc.collectors.young.collection_time{$clustername,$project,$env,$app,$host,$name,$functionname} by {name}/sum:jvm.gc.collectors.young.count{$clustername,$project,$env,$app,$host,$name,$functionname} by {name})"

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "cool"
        }
      }

      show_legend = "false"

      time = {
        live_span = "4h"
      }

      title       = "Young garbage collection time (sec)"
      title_align = "left"
      title_size  = "16"
    }
  }

  widget {
    layout = {
      height = "17"
      width  = "67"
      x      = "92"
      y      = "104"
    }

    timeseries_definition {
      request {
        display_type = "line"
        q            = "avg:system.load.1{$clustername,$project,$env,$app,$host,$name,$functionname} by {name}"

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "dog_classic"
        }
      }

      show_legend = "false"

      time = {
        live_span = "4h"
      }

      title       = "System load by node"
      title_align = "left"
      title_size  = "16"
    }
  }

  widget {
    layout = {
      height = "16"
      width  = "67"
      x      = "92"
      y      = "87"
    }

    timeseries_definition {
      request {
        display_type = "line"
        q            = "(1-(avg:system.cpu.idle{$clustername,$project,$env,$app,$host,$name,$functionname} by {name}/(avg:system.cpu.idle{$clustername,$project,$env,$app,$host,$name,$functionname} by {name}+avg:system.cpu.system{$clustername,$project,$env,$app,$host,$name,$functionname} by {name}+avg:system.cpu.iowait{$clustername,$project,$env,$app,$host,$name,$functionname} by {name}+avg:system.cpu.user{$clustername,$project,$env,$app,$host,$name,$functionname} by {name}+avg:system.cpu.stolen{$clustername,$project,$env,$app,$host,$name,$functionname} by {name}+avg:system.cpu.guest{$clustername,$project,$env,$app,$host,$name,$functionname} by {name})))*100"

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "dog_classic"
        }
      }

      show_legend = "false"

      time = {
        live_span = "4h"
      }

      title       = "CPU usage by node (%)"
      title_align = "left"
      title_size  = "16"
    }
  }

  widget {
    check_status_definition {
      check    = "elasticsearch.can_connect"
      grouping = "cluster"
      tags     = ["$clustername", "$project", "$env", "$app", "$host", "$name", "$functionname"]

      time = {
        live_span = "10m"
      }

      title       = "Available node"
      title_align = "left"
      title_size  = "16"
    }

    layout = {
      height = "13"
      width  = "15"
      x      = "16"
      y      = "6"
    }
  }

  widget {
    check_status_definition {
      check    = "elasticsearch.cluster_health"
      grouping = "cluster"
      tags     = ["$clustername", "$project", "$env", "$app", "$host", "$name", "$functionname"]

      time = {
        live_span = "10m"
      }

      title       = "Node by Cluster Status"
      title_align = "left"
      title_size  = "16"
    }

    layout = {
      height = "13"
      width  = "15"
      x      = "0"
      y      = "6"
    }
  }

  widget {
    layout = {
      height = "14"
      width  = "33"
      x      = "92"
      y      = "57"
    }

    timeseries_definition {
      marker {
        display_type = "warning dashed"
        value        = "y = 25"
      }

      marker {
        display_type = "error dashed"
        value        = "y = 33"
      }

      request {
        display_type = "line"
        q            = "(sum:elasticsearch.index.docs.deleted{$clustername,$project,$env,$app,$host,$name,$functionname} by {index_name}/sum:elasticsearch.index.docs.count{$clustername,$project,$env,$app,$host,$name,$functionname} by {index_name})*100"

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "dog_classic"
        }
      }

      show_legend = "false"

      time = {
        live_span = "4h"
      }

      title       = "Deleted Documents by index (%)"
      title_align = "left"
      title_size  = "16"
    }
  }

  widget {
    layout = {
      height = "18"
      width  = "29"
      x      = "32"
      y      = "25"
    }

    timeseries_definition {
      request {
        display_type = "line"
        q            = "derivative(sum:elasticsearch.search.query.total{$clustername,$project,$env,$app,$host,$name,$functionname})"

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "dog_classic"
        }
      }

      show_legend = "false"

      time = {
        live_span = "4h"
      }

      title       = "Search rate per sec"
      title_align = "left"
      title_size  = "16"
    }
  }

  widget {
    layout = {
      height = "18"
      width  = "29"
      x      = "62"
      y      = "25"
    }

    timeseries_definition {
      request {
        display_type = "line"
        q            = "derivative(sum:elasticsearch.indexing.index.total{$clustername,$project,$env,$app,$host,$name,$functionname})"

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "dog_classic"
        }
      }

      show_legend = "false"

      time = {
        live_span = "4h"
      }

      title       = "Indexing rate per sec"
      title_align = "left"
      title_size  = "16"
    }
  }

  widget {
    layout = {
      height = "10"
      width  = "31"
      x      = "0"
      y      = "20"
    }

    manage_status_definition {
      color_preference = "background"
      count            = "50"
      display_format   = "counts"
      hide_zero_counts = "true"
      query            = "acro_test status"
      sort             = "status,asc"
      start            = "0"
      title            = "Master eligible node alive monitoring"
      title_align      = "left"
      title_size       = "13"
    }
  }
}
