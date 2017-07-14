
https://paas.dev.yihecloud.com/api/service/monitor/info?serviceId=728dkock72azvbkuka9b92kxib1eph3
curl -XPOST 'localhost:9200/logstash-2017.04.*/api_log/_search?pretty' -d '{
  "query": {
    "bool" : {
    "must" : [
      {
        "term" : {
          "env_type" : {
            "value" : "live",
            "boost" : 1.0
          }
        }
      },
      {
        "range" : {
          "@timestamp" : {
            "from" : "2016-12-10 00:00:00.000 +0800",
            "to" : "2017-04-12 00:00:00.000 +0800",
            "include_lower" : true,
            "include_upper" : true,
            "format" : "yyyy-MM-dd HH:mm:ss.SSS Z",
            "boost" : 1.0
          }
        }
      },
      {
        "bool" : {
          "should" : [
            {
              "term" : {
                "service_id" : {
                  "value" : "728dkock72azvbkuka9b92kxib1eph3",
                  "boost" : 1.0
                }
              }
            },
            {
              "term" : {
                "service_id" : {
                  "value" : "72gge255o5zguaw342rcdgbfkaqnboh",
                  "boost" : 1.0
                }
              }
            },
            {
              "term" : {
                "service_id" : {
                  "value" : "72fl7176a98veogdcctlrgk3d1it49s",
                  "boost" : 1.0
                }
              }
            },
            {
              "term" : {
                "service_id" : {
                  "value" : "72fkhipgjv1odxthztcnvxpaanmkwe8",
                  "boost" : 1.0
                }
              }
            }
          ],
          "disable_coord" : false,
          "adjust_pure_negative" : true,
          "boost" : 1.0
        }
      }
    ],
    "disable_coord" : false,
    "adjust_pure_negative" : true,
    "boost" : 1.0
  }
  }
}'


curl -XPOST 'localhost:9200/logstash-2017.04.*/api_log/_search?pretty' -d '{
  "query": {
    "bool" : {
    "must" : [
      {
        "term" : {
          "type" : {
            "value" : "api_log",
            "boost" : 1.0
          }
        }
      },
      {
        "term" : {
          "env_type" : {
            "value" : "live",
            "boost" : 1.0
          }
        }
      },
      {
        "term" : {
          "service_id" : {
            "value" : "728dkock72azvbkuka9b92kxib1eph3",
            "boost" : 1.0
          }
        }
      },
      {
        "term" : {
          "version_id" : {
            "value" : "728dl08g9brvnvcspctzmza84m17hqg",
            "boost" : 1.0
          }
        }
      },
      {
        "term" : {
          "interface_id" : {
            "value" : "728dlgki64dyqdxteo5qtdm8sja1593",
            "boost" : 1.0
          }
        }
      },
      {
        "range" : {
          "@timestamp" : {
            "from" : "2017-03-26 11:13:40.000 +0800",
            "to" : "2017-04-19 11:13:40.000 +0800",
            "include_lower" : true,
            "include_upper" : true,
            "format" : "yyyy-MM-dd HH:mm:ss.SSS Z",
            "boost" : 1.0
          }
        }
      }
    ],
    "disable_coord" : false,
    "adjust_pure_negative" : true,
    "boost" : 1.0
  }
  }
}'

curl -XPOST 'localhost:9200/logstash-2017.04.*/api_log/_search?pretty' -d '{
  "query": {
    "bool" : {
    "must" : [
      {
      "term" : {
        "service_id.keyword" : {
        "value" : "728dkock72azvbkuka9b92kxib1eph3",
        "boost" : 1.0
        }
      }
      }
    ]
    }
  }
}'




http://www.yihecloud.cc/api/service/monitor/info?serviceId=71ojao2e6recyykcgh7vctxgkc4bhtr
curl -XPOST 'localhost:9201/logstash-2017.04.*/api_log/_search?pretty' -d '{
  "query": {
    "bool" : {
    "must" : [
      {
      "term" : {
        "service_id.keyword" : {
        "value" : "6pp7ff9mopa1esd6triw5fiv1w4cxpw",
        "boost" : 1.0
        }
      }
      }
    ]
    }
  }
}'
curl -XPOST 'localhost:9201/logstash-2017.04.01/app_log/_search?pretty' -d '{
  "query": {
    "bool" : {
    "must" : [
      {
      "term" : {
        "service_id.keyword" : {
        "value" : "6pmd3jghiwqz8ksnareekkh3trjvshl",
        "boost" : 1.0
        }
      }
      }
    ]
    }
  }
}'

curl -XPOST 'localhost:9200/logstash-2017.03.19/api_log/_search?pretty' -d '{
  "query": {
    "bool" : {
    "must" : [
      {
      "term" : {
        "service_id.keyword" : {
        "value" : "72jpl4cnng1mveb8nvhsnfe4fbbhryk",
        "boost" : 1.0
        }
      }
      }
    ]
    }
  }
}'

curl -XPOST 'localhost:9200/logstash-2016.1*/api_log/_search?pretty' -d '{
  "query": {
    "bool" : {
    "must" : [
      {
      "term" : {
        "service_id.raw" : {
        "value" : "72fkhipgjv1odxthztcnvxpaanmkwe8",
        "boost" : 1.0
        }
      }
      }
    ]
    }
  }
}'

curl -XPOST 'localhost:9200/logstash-2016.1*/api_log/_search?pretty' -d '{
  "query": {
    "bool" : {
    "must" : [
      {
      "term" : {
        "service_id.raw" : {
        "value" : "72fkhipgjv1odxthztcnvxpaanmkwe8",
        "boost" : 1.0
        }
      }
      }
    ]
    }
  }
},
"aggs": {
  "term_service_id.raw":{
    "terms" : {
    "field" : "service_id.raw",
    "size" : 10,
    "shard_size" : -1,
    "min_doc_count" : 1,
    "shard_min_doc_count" : 0,
    "show_term_doc_count_error" : false,
    "order" : [
      {
      "_count" : "desc"
      },
      {
      "_term" : "asc"
      }
    ]
    },
    "aggregations" : {
    "range_status" : {
      "range" : {
      "field" : "status",
      "ranges" : [
        {
        "key" : "success",
        "from" : 200.0,
        "to" : 300.0
        },
        {
        "key" : "all",
        "from" : 100.0,
        "to" : 1000.0
        }
      ],
      "keyed" : false
      },
      "aggregations" : {
      "avg_request_time" : {
        "avg" : {
        "field" : "request_time"
        }
      },
      "max_request_time" : {
        "max" : {
        "field" : "request_time"
        }
      },
      "min_request_time" : {
        "min" : {
        "field" : "request_time"
        }
      }
      }
    }
    }
  }
}'
