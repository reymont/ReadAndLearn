curl -XPOST 'localhost:9201/logstash-2017*/api_log/_search?pretty' -d '{
	"query": {
  "bool" : {
    "filter" : [
      {
        "term" : {
          "env_type.keyword" : {
            "value" : "live",
            "boost" : 1.0
          }
        }
      },
      {
        "range" : {
          "@timestamp" : {
            "from" : "2017-03-25 00:00:00.000 +0800",
            "to" : "2017-04-01 23:59:00.000 +0800",
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
},
	"aggs": {
		"success_ratio":{
  "terms" : {
    "field" : "service_id.keyword",
    "size" : 5,
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
    "ok" : {
      "filter" : {
        "term" : {
          "status" : {
            "value" : "200",
            "boost" : 1.0
          }
        }
      }
    }
  }
}
	}
}'




#############################################################################


curl -XPOST 'localhost:9200/logstash-2017*/app_log/_search?pretty' -d '{
	"query": {
	  "bool" : {
		"filter" : [
		  {
			"range" : {
			  "@timestamp" : {
				"from" : "2017-02-06 00:00:00.000 +0800",
				"to" : "2017-02-08 23:00:00.000 +0800",
				"include_lower" : true,
				"include_upper" : true,
				"format" : "yyyy-MM-dd HH:mm:ss.SSS Z",
				"boost" : 1.0
			  }
			}
		  },
		  {
			"term" : {
			  "service_id.raw" : {
				"value" : "728lb0e2lurvheheehntxlcqfwgog42",
				"boost" : 1.0
			  }
			}
		  }
		]
	  }
	},
	"aggs": {
		"methodTime":{
		  "terms" : {
			"field" : "uri.raw",
			"size" : 1,
			"shard_size" : -1,
			"min_doc_count" : 1,
			"shard_min_doc_count" : 0,
			"show_term_doc_count_error" : false,
			"order" : {
			  "sum_request_time" : "desc"
			}
		  },
		  "aggregations" : {
			"sum_request_time" : {
			  "sum" : {
				"field" : "request_time"
			  }
			}
		  }
		}
	}
}'
