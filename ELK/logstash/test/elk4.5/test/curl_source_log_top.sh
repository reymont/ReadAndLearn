curl -XPOST 'localhost:9200/logstash-2017*/source_log/_search?pretty' -d '{
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
				"value" : "70887932",
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

##########################
#########2017/3/9#########
##########################


curl -XPOST 'localhost:9200/logstash-2017.03.19/source_log/_search?pretty' -d '{
	"query": {
	  "bool" : {
		"filter" : [
		  {
			"range" : {
			  "@timestamp" : {
				"from" : "2017-02-06 00:00:00.000 +0800",
				"to" : "2017-03-19 23:00:00.000 +0800",
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
				"value" : "70887932",
				"boost" : 1.0
			  }
			}
		  },
		  {
			"term" : {
			  "env_id" : {
				"value" : "72eb523el6x6xpzb3vsyttbf81fnq5s",
				"boost" : 1.0
			  }
			}
		  }
		]
	  }
	}
	,
	"aggs": {
		"methodTime":{
		  "terms" : {
			"field" : "uri.keyword",
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

