curl -XPOST 'localhost:9201/logstash-2017.04*/api_log/_search?pretty' -d '{
  "query": {
    "bool" : {
    "filter" : [
      {
        "range" : {
          "@timestamp" : {
            "from" : "2017-04-24 00:00:00.000 +0800",
            "to" : "2017-04-26 23:00:00.000 +0800",
            "include_lower" : true,
            "include_upper" : true,
            "format" : "yyyy-MM-dd HH:mm:ss.SSS Z",
            "boost" : 1.0
          }
        }
      }
    ],
    "must_not" : [
      {
        "term" : {
          "request_type" : {
            "value" : "gif",
            "boost" : 1.0
          }
        }
      },
      {
        "term" : {
          "request_type" : {
            "value" : "png",
            "boost" : 1.0
          }
        }
      },
      {
        "term" : {
          "request_type" : {
            "value" : "css",
            "boost" : 1.0
          }
        }
      },
      {
        "term" : {
          "request_type" : {
            "value" : "js",
            "boost" : 1.0
          }
        }
      },
      {
        "term" : {
          "request_type" : {
            "value" : "ico",
            "boost" : 1.0
          }
        }
      },
      {
        "term" : {
          "request_type" : {
            "value" : "html",
            "boost" : 1.0
          }
        }
      }
    ],
    "disable_coord" : false,
    "adjust_pure_negative" : true,
    "boost" : 1.0
  }
},
"aggs": {
  "result_agg": {
  "date_histogram" : {
    "field" : "@timestamp",
    "interval" : "1h",
    "offset" : 0,
    "order" : {
      "_key" : "asc"
    },
    "keyed" : false,
    "min_doc_count" : 0
  },
  "aggregations" : {
    "success_count" : {
      "filter" : {
        "term" : {
          "status" : {
            "value" : "200",
            "boost" : 1.0
          }
        }
      }
    },
    "total_sum" : {
      "sum" : {
        "field" : "request_time"
      }
    },
    "total_ip" : {
      "cardinality" : {
        "field" : "remote_host.keyword"
      }
    }
  }
    }
  }
}'
