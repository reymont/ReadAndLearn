#健康检查
curl localhost:9200/_cluster/health?pretty
#查询
curl http://localhost:9200/logstash-2016.12.21
curl localhost:9201/logstash-2017.04.01/app_log/_search?pretty
curl localhost:9201/logstash-2017.04.04/api_log/_search?pretty
curl localhost:9200/logstash-2017.04.01/store/_search?pretty
curl localhost:9200/logstash-2017.03.19/api_log/_search?pretty -d '
{
    "aggs" : {
        "genres" : {
            "terms" : { "field" : "service_id.keyword" }
        }
    }
}'
curl -XPUT localhost:9200/logstash-2017.03.19/_mapping/api_log -d  ' 
{
  "properties": {
    "service_id": {
      "type": "text",
      "fielddata": false
     }
   }
}'
#备份
tar czf elk-data-20170207.tar.gzip ./elasticsearch
#查看索引
curl localhost:9201/_cat/indices?v|grep 2017.03.15
curl localhost:9201/_cat/indices?v|grep 2017.04
curl localhost:9200/_cat/indices?v|grep 2017.04
#删除索引
curl -XDELETE localhost:9201/logstash-2017.03.17*
curl -XDELETE localhost:9201/logstash-*
curl -XDELETE localhost:9201/logstash-2017.04.12
#将sysctl文件描述符修改为655360
echo "vm.max_map_count=655360" >> /etc/sysctl.conf
sysctl -p
#或者
sysctl -w vm.max_map_count=655360
docker run -p 5601:5601 -p 9200:9200 -p 5044:5044 -it --name elk sebp/elk
#查看文件夹大小
du -d 1 -h
#获取分片信息
curl -XGET 'localhost:9201/_cat/shards?v'
#根据serviceId查找配置文件
grep 729on5e9pp879fzw9dvfxlhpdfaqihw *
#查看映射
curl localhost:9201/logstash-2017.03.17/_mappings?pretty
curl -XDELETE localhost:9201/logstash-2017.04.02/_mappings/_default_?pretty
curl localhost:9201/logstash-2017.04.01/_mappings/_default_
curl localhost:9200/logstash-2017.04.04/_mappings

#提交索引模板logstash.tmpl
cd /data/logstash/config
curl -XPUT localhost:9201/_template/logstash?pretty -d @logstash.json
curl -XDELETE localhost:9201/_template/logstash
curl -XGET localhost:9200/_template/logstash*?pretty
curl -XGET localhost:9201/_template/logstash*?pretty
curl -XGET localhost:9201/_template/mappings*?pretty
#logstash容器中的模板，
cat /usr/local/logstash/template/logstash.tmpl
#禁用dynamic mapping
curl -XPUT localhost:9201/logstash-2017.03.17 d'
{
   "mappings" : {
      "_default_" : {
         "dynamic" : "false"
      }
   }
}'
curl -XPUT 'http://localhost:9201/logstash-2017.03.17/_settings?preserve_existing=true' -d '{
  "index.mapper.dynamic" : "false"
}'
curl -XPUT 'http://localhost:9201/_all/_settings?preserve_existing=true&pretty' -d '{
  "index.mapper.dynamic" : "false"  
}'

#elasticsearch 版本 5.0 单点部署
docker run -dti --restart=always --name elasticsearch \
  -e ES_JAVA_OPTS="-Xms512m -Xmx512m" \
  -v /data/elasticsearch/data:/usr/share/elasticsearch/data \
  -v /data/elasticsearch/config:/usr/share/elasticsearch/config \
  -p 9200:9200 \
  -p 9300:9300 \
  docker.yihecloud.com/openbridge/elk/elasticsearch:5.0

#elasticsearch 版本 2.3.3
docker run -dti --restart=always --name elk-1 \
  -e PROJECT_CODE=yhxy \
  -e NODE_NAME=elk-1 \
  -e PATH_DATA=/data/data \
  -e PATH_LOGS=/data/logs \
  -e EL_NETWORK=192.168.0.179:9300 \
  -v /data/elasticsearch:/data \
  -p 9200:9200 \
  -p 9300:9300 \
  192.168.0.171:5000/openbridge/elasticsearch:2.3.3 /opt/startup.sh

#将/data目录下所有文件全部设置为root
chown -R 'root' /data
mkdir scripts
docker logs -f elasticsearch
docker rm -f elasticsearch

#logstash
docker run -dti --restart=always --name logstash \
  -e ELASTIC_CLUSTER_1=192.168.0.191:9200 \
  -v /data/logstash:/data \
  -p 5044:5044 \
  docker.yihecloud.com/openbridge/elk/logstash:5.0
  
docker run -dti --restart=always --name logstash \
  -v $data_dir/logstash:/logstash \
  -p 12201:12201 \
  -p 12201:12201/udp \
  -p 9600:9600 \
  $registry/logstash:$version logstash -f /logstash/gelf.conf

#logstash 版本 2.3.1
docker run -dti --restart=always --name logstash \
  -e PAASOS_API_URL=https://paas.dev.yihecloud.com/api \
  -e ELASTIC_CLUSTER_1=192.168.0.179:9200 \
  -v /data/logstash:/data \
  -p 5544:5544 \
  192.168.0.171:5000/openbridge/logstash:2.3.1 /opt/startup.sh

docker rm -f logstash
docker logs -f logstash


#kibana
http://192.168.0.192:5601
docker run -dti --restart=always --name kibana \
  -p 5601:5601 \
  -e ELASTICSEARCH_URL=http://192.168.0.191:9200 \
  docker.yihecloud.com/openbridge/elk/kibana:5.0

docker run -dti --name kibana \
  -p 5601:5601 \
  -e ELASTICSEARCH_URL=http://192.168.0.179:9200 \
  docker.yihecloud.com/openbridge/elk/kibana:5.0  
  
docker run -dti --restart=always --name kibana \
  -p 5601:5601 \
  -e ELASTICSEARCH_URL=http://192.168.10.84:9201 \
  docker.yihecloud.com/openbridge/elk/kibana:5.0
#192.168.70.62  
docker run -dti --name kibana \
  -p 5601:5601 \
  -e ELASTICSEARCH_URL=http://192.168.110.122:9201 \
  docker.yihecloud.com/openbridge/elk/kibana:5.0

