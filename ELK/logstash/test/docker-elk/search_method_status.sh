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
        "key" : "400",
        "from" : 400.0,
        "to" : 401.0
        },
		{
        "key" : "401",
        "from" : 401.0,
        "to" : 402.0
        },
		{
        "key" : "402",
        "from" : 402.0,
        "to" : 403.0
        },
		{
        "key" : "404",
        "from" : 404.0,
        "to" : 405.0
        },
		{
        "key" : "500",
        "from" : 500.0,
        "to" : 1000.0
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
}'
