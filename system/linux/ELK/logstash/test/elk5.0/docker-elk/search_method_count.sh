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
    "methodCount":{
      "terms" : {
        "field" : "uri.keyword",
        "size" : 10,
        "order" : [
          {
            "_count" : "desc"
          },
          {
            "_term" : "asc"
          }
        ]
      }
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
    "methodCount":{
      "terms" : {
        "field" : "uri.keyword",
        "size" : 7,
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