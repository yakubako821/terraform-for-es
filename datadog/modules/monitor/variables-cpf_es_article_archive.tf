locals {
  cpf_es_article_archive_clusters = [
    "cpf-elasticsearch-article-archive-prod-1",
    # "cpf-elasticsearch-article-archive-prod-2",
  ]

  cpf_es_article_archive_query_alert_monitors = [
    {
      name = "active shards"

      query = "max(last_1m):avg:elasticsearch.active_shards{cluster_name:%[1]s} by {cluster_name} > 600"

      thresholds = {
        critical = 600
        warning  = 500
      }
    },
    {
      name = "breakers field data tripped"

      query = "change(max(last_5m),last_1m):avg:elasticsearch.breakers.fielddata.tripped{cluster_name:%[1]s} by {node_name} > 10"

      thresholds = {
        critical = 10
        warning  = 0
      }
    },
    {
      name = "breakers inflight requests tripped"

      query = "change(max(last_5m),last_1m):avg:elasticsearch.breakers.inflight_requests.tripped{cluster_name:%[1]s} by {node_name} > 10"

      thresholds = {
        critical = 10
        warning  = 0
      }
    },
    {
      name = "breakers parent tripped"

      query = "change(max(last_5m),last_1m):avg:elasticsearch.breakers.parent.tripped{cluster_name:%[1]s} by {node_name} > 10"

      thresholds = {
        critical = 10
        warning  = 0
      }
    },
    {
      name = "breakers request tripped"

      query = "change(max(last_5m),last_1m):avg:elasticsearch.breakers.request.tripped{cluster_name:%[1]s} by {node_name} > 10"

      thresholds = {
        critical = 10
        warning  = 0
      }
    },
    {
      name = "docs deleted ratio"

      query = "max(last_1m):avg:elasticsearch.docs.deleted{cluster_name:%[1]s} by {cluster_name} / avg:elasticsearch.docs.count{cluster_name:%[1]s} by {cluster_name} * 100 > 33"

      thresholds = {
        critical = 33
        warning  = 25
      }
    },
    {
      name = "gc old collection count"

      query = "change(max(last_5m),last_1m):avg:jvm.gc.collectors.old.count{cluster_name:%[1]s} by {node_name} > 3"

      thresholds = {
        critical = 3
      }
    },
    {
      name = "gc old collection time"

      query = "max(last_1m):avg:jvm.gc.collectors.old.collection_time{cluster_name:%[1]s} by {node_name} > 30"

      thresholds = {
        critical = 30
      }
    },
    {
      name = "gc young collection count"

      query = "change(max(last_5m),last_1m):avg:jvm.gc.collectors.young.count{cluster_name:%[1]s} by {node_name} > 100"

      thresholds = {
        critical = 100
      }
    },
    {
      name = "gc young collection time"

      query = "max(last_1m):avg:jvm.gc.collectors.young.collection_time{cluster_name:%[1]s} by {node_name} > 30000"

      thresholds = {
        critical = 30000
      }
    },
    {
      name = "index docs deleted ratio"

      query = "max(last_1m):avg:elasticsearch.index.docs.deleted{cluster_name:%[1]s} by {index_name} / avg:elasticsearch.index.docs.count{cluster_name:%[1]s} by {index_name} * 100 > 33"

      thresholds = {
        critical = 33
        warning  = 25
      }
    },
    {
      name = "index status"

      query = "max(last_1m):avg:elasticsearch.index.health{cluster_name:%[1]s} by {index_name} > 1"

      thresholds = {
        critical = 1
        warning  = 0
      }
    },
    {
      name = "indexing index time"

      query = "avg(last_1m):avg:elasticsearch.indexing.index.time{cluster_name:%[1]s} by {node_name} > 500000"

      thresholds = {
        critical = 500000
      }
    },
    {
      name = "indexing index total"

      query = "avg(last_1m):avg:elasticsearch.indexing.index.total{cluster_name:%[1]s} by {node_name} > 100000000"

      thresholds = {
        critical = 100000000
      }
    },
    {
      name = "jvm heap used"

      query = "min(last_5m):avg:jvm.mem.heap_used{cluster_name:%[1]s} by {node_name} / avg:jvm.mem.heap_max{cluster_name:%[1]s} by {node_name} * 100 > 90"

      thresholds = {
        critical = 90
      }
    },
    {
      name = "pending task total"

      query = "max(last_1m):avg:elasticsearch.pending_tasks_total{cluster_name:%[1]s} by {task_name,task_version} > 1"

      thresholds = {
        critical = 1
      }
    },
    {
      name = "search fetch time"

      query = "avg(last_1m):avg:elasticsearch.search.fetch.time{cluster_name:%[1]s} by {node_name} > 300"

      thresholds = {
        critical = 300
      }
    },
    {
      name = "search fetch total"

      query = "avg(last_1m):avg:elasticsearch.search.fetch.total{cluster_name:%[1]s} by {node_name} > 5000000"

      thresholds = {
        critical = 5000000
      }
    },
    {
      name = "search query time"

      query = "avg(last_1m):avg:elasticsearch.search.query.time{cluster_name:%[1]s} by {node_name} > 600"

      thresholds = {
        critical = 600
      }
    },
    {
      name = "search query total"

      query = "avg(last_1m):avg:elasticsearch.search.query.total{cluster_name:%[1]s} by {node_name} > 5000000"

      thresholds = {
        critical = 5000000
      }
    },
    {
      name = "thread search queue"

      query = "max(last_1m):avg:elasticsearch.thread_pool.search.queue{cluster_name:%[1]s} by {node_name} > 10000"

      thresholds = {
        critical = 10000
        warning  = 1000
      }
    },
    {
      name = "thread search rejected"

      query = "change(max(last_5m),last_1m):avg:elasticsearch.thread_pool.search.rejected{cluster_name:%[1]s} by {node_name} > 0"

      thresholds = {
        critical = 0
      }
    },
    {
      name = "thread write queue"

      query = "max(last_1m):avg:elasticsearch.thread_pool.write.queue{cluster_name:%[1]s} by {node_name} > 10000"

      thresholds = {
        critical = 10000
        warning  = 1000
      }
    },
    {
      name = "thread write rejected"

      query = "change(max(last_5m),last_1m):avg:elasticsearch.thread_pool.write.rejected{cluster_name:%[1]s} by {node_name} > 0"

      thresholds = {
        critical = 0
      }
    },
    {
      name = "unassigned shards"

      query = "max(last_1m):avg:elasticsearch.unassigned_shards{cluster_name:%[1]s} by {cluster_name} > 10"

      thresholds = {
        critical = 10
        warning  = 1
      }
    },
    {
      name = "JVM Heap"

      query = "max(last_1m):max:jvm.mem.heap_used{cluster_name:%[1]s} by {node_name} / max:jvm.mem.heap_max{cluster_name:%[1]s} by {node_name} >= 0.9"

      thresholds = {
        critical = 0.9
        warning  = 0.8
      }
    },
    {
      name = "Young GC Duration"

      query = "max(last_1m):max:jvm.gc.collectors.young.collection_time{cluster_name:%[1]s} by {node_name} / max:jvm.gc.collectors.young.count{cluster_name:%[1]s} by {node_name} >= 0.1"

      thresholds = {
        critical = 0.1
        warning  = 0.09
      }
    },
    {
      name = "Old GC Duration"

      query = "max(last_1m):max:jvm.gc.collectors.old.collection_time{cluster_name:%[1]s} by {node_name} / max:jvm.gc.collectors.old.count{cluster_name:%[1]s} by {node_name} >= 0.1"

      thresholds = {
        critical = 0.1
        warning  = 0.09
      }
    },
    {
      name = "Search Latency"

      query = "max(last_1m):( derivative(sum:elasticsearch.search.fetch.time{cluster_name:%[1]s}) + derivative(sum:elasticsearch.search.query.time{cluster_name:%[1]s}) ) / derivative(sum:elasticsearch.search.query.total{cluster_name:%[1]s}) >= 0.4"

      thresholds = {
        critical = 0.4
        warning  = 0.2
      }
    },
    {
      name = "Search Rate(QPS)"

      query = "max(last_1m):derivative(sum:elasticsearch.search.query.total{cluster_name:%[1]s}) >= 1000"

      thresholds = {
        critical = 1000
        warning  = 500
      }
    },
    {
      name = "Indexing Latency"

      query = "max(last_1m):( derivative(sum:elasticsearch.indexing.index.time{cluster_name:%[1]s}) / derivative(sum:elasticsearch.indexing.index.total{cluster_name:%[1]s}) ) >= 10"

      thresholds = {
        critical = 10
        warning  = 5
      }
    },
    {
      name = "Indexing Rate"

      query = "max(last_1m):( derivative(sum:elasticsearch.indexing.index.time{cluster_name:%[1]s}) / derivative(sum:elasticsearch.indexing.index.total{cluster_name:%[1]s}) ) >= 20000"

      thresholds = {
        critical = 20000
        warning  = 10000
      }
    },
    {
      name = "Search Queue"

      query = "max(last_1m):max:elasticsearch.thread_pool.search.queue{cluster_name:%[1]s} >= 800"

      thresholds = {
        critical = 800
        warning  = 500
      }
    },

  ]

  cpf_es_article_archive_service_check_monitors = [
    {
      name = "cluster status"

      query = "\"elasticsearch.cluster_health\".over(\"cluster_name:%[1]s\").by(\"host\",\"port\").last(2).count_by_status()"

      thresholds = {
        warning  = 1
        ok       = 1
        critical = 1
      }
    },
  ]

  # clusters x monitors (query alert)
  cpf_es_article_archive_clusters_x_query_alert_monitors = [
    for pair in setproduct(local.cpf_es_article_archive_clusters, local.cpf_es_article_archive_query_alert_monitors) : merge(
      {
        cluster_name = pair[0]
      },
      pair[1]
    )
  ]

  # clusters x monitors (service check)
  cpf_es_article_archive_clusters_x_service_check_monitors = [
    for pair in setproduct(local.cpf_es_article_archive_clusters, local.cpf_es_article_archive_service_check_monitors) : merge(
      {
        cluster_name = pair[0]
      },
      pair[1]
    )
  ]
}
