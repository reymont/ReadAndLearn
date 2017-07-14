#20170708
curl -XPOST '192.168.31.215:9200/logstash-*/nginx-access/_search?pretty' -d '{
  "query": {
    "bool": {
      "filter": [{
          "range": {
            "@timestamp": {
              "gte": "1499420764766",
              "lte": "1499442764766"
            }
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
        "min_doc_count": 0,
        "extended_bounds": {
          "min": "1499420764766",
          "max": "1499445764766"
        }
      },
      "aggs": {
				"success_sum": {
					"filter": {
						"term": {
							"status": "200"
						}
					}
				},
        "total_ip": {
          "cardinality": {
            "field": "remote_addr.keyword"
          }
        }
      }
    }
  }
}'


curl -XPOST '192.168.31.215:9200/logstash-*/nginx-access/_search?pretty' -d '{
  "query": {
    "bool": {
      "filter": [{
          "range": {
            "@timestamp": {
              "gte": "1499385600000",
              "lte": "1499414938679"
            }
          }
        }
      ]
    }
  }
}'

curl -XPOST '192.168.31.215:9200/logstash-*/nginx-access/_search?pretty' -d '{
  "query": {
    "bool": {
      "filter": [{
          "range": {
            "@timestamp": {
              "gte": "1499385600000",
              "lte": "1499414938679"
            }
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
        "min_doc_count": 0,
        "extended_bounds": {
          "min": "1499385600000",
          "max": "1499414938679"
        }
      },
      "aggs": {
        "total_ip": {
          "cardinality": {
            "field": "remoteAddr.keyword"
          }
        }
      }
    }
  }
}'
