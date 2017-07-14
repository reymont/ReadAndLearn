# 查看所有的模板
curl localhost:9201/_template/*?pretty
# 清空对应的模板（logstash）
curl -XDELETE localhost:9201/_template/logstash

# 
curl localhost:9201/logstash-2017.04.12/_mappings?pretty


# 查看对应日期的索引
curl localhost:9201/_cat/indices?v|grep 2017.04.12

# 删除对应日期的索引
curl -XDELETE localhost:9201/logstash-2017.04.12

# 查看对应日期指定日志类型的数据
curl localhost:9201/logstash-2017.04.04/api_log/_search?pretty


# 查看具体serviceid对应日期指定日志类型的数据（替换service_id.keyword.velue为上面查询到的service_id）
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

