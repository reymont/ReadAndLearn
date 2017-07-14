curl -XPOST '192.168.31.215:9200/logstash-*/nginx-access/_search?pretty' -d '{
  "query": {
    "bool": {
      "filter": [{
          "range": {
            "@timestamp": {
              "from": "1499420764766",
              "to": "1499445764766",
              "include_lower": true,
              "include_upper": true
            }
          }
        }
      ]
    }
  }
}'


curl -XPOST '192.168.31.215:9200/logstash-2017.07.08/nginx-access/_search?pretty' -d '{
  "query": {
    "bool": {
      "filter": [{
          "range": {
            "@timestamp": {
              "from": "1499483992610",
              "to": "1499583992610",
              "include_lower": true,
              "include_upper": true
            }
          }
        }
      ]
    }
  },
  "aggs": {
    "methodTime":{
      "terms" : {
      "field" : "uri.keyword",
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

#20170710 date_histogram
curl -XPOST '192.168.31.215:9200/logstash-*/nginx-access/_search?pretty' -d '{
            "query": {
                "bool": {
                    "filter": [{
                        "range": {
                            "@timestamp": {
                                "from": "1499483992610",
                                "to": "1499583992610",
                                "include_lower": true,
                                "include_upper": true
                            }
                        }
                    }]
                }
            },
            "aggs": {
                "result_agg": {
                    "date_histogram": {
                        "field": "@timestamp",
                        "interval": "hour",
                        "min_doc_count": 0,
                        "extended_bounds": {
                            "min": "1499483992610",
                            "max": "1499583992610"
                        }
                    },
                    "aggs": {
                        "methodCount": {
                            "terms": {
                                "field": "uri.keyword",
                                "size": 7,
                                "order": [{
                                        "_count": "desc"
                                    },
                                    {
                                        "_term": "asc"
                                    }
                                ]
                            },
                            "aggregations": {
                                "sum_request_time": {
                                    "sum": {
                                        "field": "request_time"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }'