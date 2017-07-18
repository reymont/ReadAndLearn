#默认mappings设置了raw

curl localhost:9200/logstash-2017.07.17/_mappings
#删除索引
curl -XDELETE localhost:9200/logstash-*
#查看索引
curl localhost:9200/_cat/indices?v

#禁用dynamic mapping
curl -XPUT localhost:9200/logstash-2017.07.17 -d'
{
   "mappings" : {
      "_default_" : {
         "dynamic" : "true"
      }
   }
}'

#默认索引
curl -XGET localhost:9200/_template/logstash*
curl -XDELETE localhost:9200/_template/logstash*
#重新映射string包含keyword
curl -XPUT localhost:9200/_template/logstash* -d '{
  "template": "logstash-*",
  "mappings": {
    "_default_": {
      "_all": {
        "enabled": true,
        "omit_norms": true
      },
      "dynamic_templates": [{
          "message_field": {
            "mapping": {
              "fielddata": {
                "format": "disabled"
              },
              "index": "analyzed",
              "omit_norms": true,
              "type": "string"
            },
            "match": "message",
            "match_mapping_type": "string"
          }
        }, {
          "string_fields": {
            "mapping": {
              "fielddata": {
                "format": "disabled"
              },
              "index": "analyzed",
              "omit_norms": true,
              "type": "string",
              "fields": {
                "keyword": {
                  "type": "keyword"
                }
              }
            },
            "match": "*",
            "match_mapping_type": "string"
          }
        }, {
          "float_fields": {
            "mapping": {
              "type": "float",
              "doc_values": true
            },
            "match": "*",
            "match_mapping_type": "float"
          }
        }, {
          "double_fields": {
            "mapping": {
              "type": "double",
              "doc_values": true
            },
            "match": "*",
            "match_mapping_type": "double"
          }
        }, {
          "byte_fields": {
            "mapping": {
              "type": "byte",
              "doc_values": true
            },
            "match": "*",
            "match_mapping_type": "byte"
          }
        }, {
          "short_fields": {
            "mapping": {
              "type": "short",
              "doc_values": true
            },
            "match": "*",
            "match_mapping_type": "short"
          }
        }, {
          "integer_fields": {
            "mapping": {
              "type": "integer",
              "doc_values": true
            },
            "match": "*",
            "match_mapping_type": "integer"
          }
        }, {
          "long_fields": {
            "mapping": {
              "type": "long",
              "doc_values": true
            },
            "match": "*",
            "match_mapping_type": "long"
          }
        }, {
          "date_fields": {
            "mapping": {
              "type": "date",
              "doc_values": true
            },
            "match": "*",
            "match_mapping_type": "date"
          }
        }, {
          "geo_point_fields": {
            "mapping": {
              "type": "geo_point",
              "doc_values": true
            },
            "match": "*",
            "match_mapping_type": "geo_point"
          }
        }
      ],
      "properties": {
        "status": {
          "type": "long"
        },
        "request_time": {
          "type": "double"
        }
      }
    }
  }
}'


curl -XPOST 'localhost:9200/logstash-2017*/app_log/_search'
curl -XPOST 'localhost:9200/logstash-2017*/app_log/_search?pretty' -d '{
"query": {
  "bool" : {
    "filter" : [
      {
        "range" : {
          "@timestamp" : {
            "from" : "2017-07-17 00:00:00.000 +0800",
            "to" : "2017-07-18 12:03:01.397 +0800",
            "include_lower" : true,
            "include_upper" : true,
            "format" : "yyyy-MM-dd HH:mm:ss.SSS Z",
            "boost" : 1.0
          }
        }
      }
    ]
  }
}
}'
curl -XPOST 'localhost:9200/logstash-2017*/app_log/_search?pretty' -d '{
  "query": {
    "term": {
      "service_id": {
        "value": "72728cen1l6hbk4eqrifgsfrkup1s48"
      }
    }
  }
}'
curl -XPOST 'localhost:9200/logstash-2017*/app_log/_search?pretty' -d '{
  "query": {
    "term": {
      "service_id.raw": {
        "value": "72728cen1l6hbk4eqrifgsfrkup1s48"
      }
    }
  }
}'
curl -XPOST 'localhost:9200/logstash-2017*/app_log/_search?pretty' -d '{
  "query": {
    "term": {
      "service_id.keyword": {
        "value": "72728cen1l6hbk4eqrifgsfrkup1s48"
      }
    }
  }
}'
curl -XPOST 'localhost:9200/logstash-2017*/app_log/_search?pretty' -d '{
"query": {
  "bool" : {
    "filter" : [
      {
        "range" : {
          "@timestamp" : {
            "from" : "2017-07-18 00:00:00.000 +0800",
            "to" : "2017-07-18 12:03:01.397 +0800",
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
            "value" : "72728cen1l6hbk4eqrifgsfrkup1s48",
            "boost" : 1.0
          }
        }
      }
    ]
  }
}
}'

curl -XPOST 'localhost:9200/logstash-2017*/app_log/_search?pretty' -d '{
"query": {
  "bool" : {
    "filter" : [
      {
        "range" : {
          "@timestamp" : {
            "from" : "2017-07-18 00:00:00.000 +0800",
            "to" : "2017-07-18 12:03:01.397 +0800",
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
            "value" : "72728cen1l6hbk4eqrifgsfrkup1s48",
            "boost" : 1.0
          }
        }
      },
      {
        "term" : {
          "env_id.keyword" : {
            "value" : "7285hcmldtsrddah2ycq1p442gl9occ",
            "boost" : 1.0
          }
        }
      }
    ]
  }
}
}'

curl -XPOST 'localhost:9200/logstash-2017*/app_log/_search?pretty' -d '{
"query": {
  "bool" : {
    "filter" : [
      {
        "range" : {
          "@timestamp" : {
            "from" : "2017-07-17 00:00:00.000 +0800",
            "to" : "2017-07-17 12:03:01.397 +0800",
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
            "value" : "745c0aoghuq4r2nrevgenueznplqftq",
            "boost" : 1.0
          }
        }
      },
      {
        "term" : {
          "env_id.keyword" : {
            "value" : "745c0g3plh6budisckv9uhkuzjvqnpx",
            "boost" : 1.0
          }
        }
      }
    ]
  }
}'


curl -XPOST 'localhost:9200/logstash-2017*/_search?pretty' -d '{
"query": {
  "bool" : {
    "filter" : [
      {
        "range" : {
          "@timestamp" : {
            "from" : "2017-07-16 00:00:00.000 +0800",
            "to" : "2017-07-18 12:03:01.397 +0800",
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
            "value" : "745c0aoghuq4r2nrevgenueznplqftq",
            "boost" : 1.0
          }
        }
      }
    ]
  }
}
,
  "aggs":{
  "methodCount":{
  "terms" : {
    "field" : "uri.keyword",
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
  }
}
  }
}'
