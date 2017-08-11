curl -XPUT 'localhost:9201/_template/logstash?pretty' -d'
{
  "order": 0,
  "template": "*", 
  "mappings": {
    "_default_": { 
      "_all": { 
        "enabled": false
      }
    }
  }
}'
curl localhost:9201/_template/*?pretty
curl -XDELETE localhost:9201/logstash-2017.04.12
curl -XDELETE localhost:9201/_template/logstash
curl localhost:9201/_cat/indices?v|grep 2017.04.12
curl localhost:9201/logstash-2017.04.12/_mappings/_default_?pretty
curl localhost:9201/logstash-2017.04.12/_mappings?pretty
curl -XPOST 'localhost:9201/logstash-2017.04.12/api_log/_search?pretty' -d '{
  "query": {
    "bool" : {
		"must" : [
		  {
			"term" : {
			  "service_id.keyword" : {
				"value" : "6pec050b128roxcxvhythnjbujaf8jw",
				"boost" : 1.0
			  }
			}
		  }
		]
	  }
	}
}'
curl -XPOST 'localhost:9201/logstash-2017.04.12/api_log/_search?pretty' -d '{
  "query": {
    "bool" : {
		"must" : [
		  {
			"term" : {
			  "service_id.keyword" : {
				"value" : "6pec050b128roxcxvhythnjbujaf8jw",
				"boost" : 1.0
			  }
			}
		  },
      {
        "term" : {
          "version_id.keyword" : {
            "value" : "6pec1mba46f68gy1pu8hdkwkatyue9r",
            "boost" : 1.0
          }
        }
      },
      {
        "term" : {
          "interface_id.keyword" : {
            "value" : "6pec22a7gczvxlg9npbpjoguvjnj8ew",
            "boost" : 1.0
          }
        }
      }
		]
	  }
	}
}'
curl -XPOST 'localhost:9201/logstash-2017.04.12/api_log/_search?pretty' -d '{
  "query": {
    "bool" :  {
    "must" : [
      {
        "term" : {
          "type.keyword" : {
            "value" : "api_log",
            "boost" : 1.0
          }
        }
      },
      {
        "term" : {
          "env_type.keyword" : {
            "value" : "test",
            "boost" : 1.0
          }
        }
      },
      {
        "term" : {
          "service_id.keyword" : {
            "value" : "6pec050b128roxcxvhythnjbujaf8jw",
            "boost" : 1.0
          }
        }
      },
      {
        "term" : {
          "version_id.keyword" : {
            "value" : "6pec1mba46f68gy1pu8hdkwkatyue9r",
            "boost" : 1.0
          }
        }
      },
      {
        "term" : {
          "interface_id.keyword" : {
            "value" : "6pec22a7gczvxlg9npbpjoguvjnj8ew",
            "boost" : 1.0
          }
        }
      },
      {
        "range" : {
          "@timestamp" : {
            "from" : "2017-03-26 12:45:08.000 +0800",
            "to" : "2017-04-19 12:45:08.000 +0800",
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