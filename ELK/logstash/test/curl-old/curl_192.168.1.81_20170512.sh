curl -XPOST 'localhost:9201/logstash-2017.05*/app_log/_search?pretty' -d '{
  "query": {
  "bool" : {
    "filter" : [
      {
        "range" : {
          "@timestamp" : {
            "from" : "2017-05-12 00:00:00.000 +0800",
            "to" : "2017-05-12 11:23:39.945 +0800",
            "include_lower" : true,
            "include_upper" : true,
            "format" : "yyyy-MM-dd HH:mm:ss.SSS Z",
            "boost" : 1.0
          }
        }
      },
      {
        "term" : {
          "service_id.keyword" : {
            "value" : "7204fll2arwub8nurgcwjt4js9vqjii",
            "boost" : 1.0
          }
        }
      },
      {
        "term" : {
          "env_id.keyword" : {
            "value" : "7204ghc58d6o2wjr3ztwdvjdyvgopqn",
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
    "min_doc_count" : 0,
	"format": "yyyy-MM-dd hh:mm:ss.SSS Z",
    "extended_bounds" : {
      "min" : "2017-05-11T00:00:00+0800",
      "max" : "2017-05-12T23:00:00+0800"
    }
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
