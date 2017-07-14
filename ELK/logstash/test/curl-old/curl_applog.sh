curl - XPOST '101.200.82.115:9200/logstash-*/app_log/_search?pretty' - d '{
	"query": {
		"bool": {
			"filter": [{
					"range": {
						"@timestamp": {
							"gte": "2016-01-2710:26:40.111 +0800",
							"lte": "2016-01-2810:26:42.222 +0800",
							"format": "yyyy-MM-ddHH:mm:ss.SSS Z"
						}
					}
				}, {
					"term": {
						"env_id": "12313"
					}
				}
			]
		}
	},
	"aggs": {
		"result_agg": {
			"date_histogram": {
				"field": "@timestamp",
				"interval": "hour",
				"format": "yyyy-MM-ddHH:mm:ss.SSS Z",
				"min_doc_count": 0,
				"extended_bounds": {
					"min": "2016-01-2710:26:40.111 +0800",
					"max": "2016-01-2810:26:42.222 +0800"
				}
			},
			"aggs": {
				"total_sum": {
					"sum": {
						"field": "request_time"
					}
				},
				"success_sum": {
					"filter": {
						"term": {
							"status": "200"
						}
					}
				},
				"total_ip": {
					"cardinality": {
						"field": "remote_addr.raw"
					}
				}
			}
		}
	}
}'
