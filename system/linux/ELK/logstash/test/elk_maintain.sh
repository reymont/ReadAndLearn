
#查看基本配置
curl -XGET 192.168.31.215:9200
curl -XGET '192.168.31.215:9200/logstash-*?pretty'
#查看磁盘信息
curl -X GET http://localhost:9200/_cat/allocation?v
#查看分片
curl -X GET http://localhost:9200/_cat/shards?v