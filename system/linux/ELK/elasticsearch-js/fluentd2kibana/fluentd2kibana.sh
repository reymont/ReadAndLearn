

# https://github.com/reymont/fluentd2kibana

curl 127.0.0.1:3000
curl -XPOST 127.0.0.1:3000

curl localhost:9200/_cat/indices

curl -s 192.168.99.100:9200/_cat/indices
curl -s 192.168.99.100:9200/_search?pretty
# 获取kibana索引数据
curl -s 192.168.99.100:9200/.kibana/_search?pretty
curl localhost:9200/.kibana/_search?pretty

# post param
curl -XGET localhost:3000/kibana?hostname=172.20.62.94
curl -X POST -H 'Content-Type: application/json' -d '{"hostname":"172.20.62.94"}'\
 localhost:3000/kibana
curl -X POST -H 'Content-Type: application/json'\
 -d '{"hostname":"172.20.62.94","micro_service":"common-service"}'\
 localhost:3000/kibana
curl -X POST -H 'Content-Type: application/json'\
 -d '{"hostname":"172.20.62.94","micro_service":"translate-service"}'\
 localhost:3000/kibana
curl -X POST -F 'hostname=172.20.62.94'\
 localhost:3000/kibana

# jtp_java_log
# http://blog.didispace.com/books/elasticsearch-definitive-guide-cn/030_Data/15_Get.html
## 检索文档的一部分
curl -s 172.20.62.42:9200/logstash-2018.01.02/jtp_java_log/AWC1bxdCiCL6Yq5fmDtx?_source=hostname
## 只想得到_source字段而不要其他的元数据
curl 172.20.62.42:9200/logstash-2018.01.02/jtp_java_log/AWC1bxdCiCL6Yq5fmDtx/_source?pretty
