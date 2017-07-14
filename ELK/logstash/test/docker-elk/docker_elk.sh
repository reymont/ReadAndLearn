#docker-compose build logstash 重建
#docker-compose up -d更新的会重新创建，未更新的则不变


#健康检查
curl localhost:9200/_cluster/health?pretty
#查看索引
curl localhost:9200/_cat/indices
curl localhost:9200/logstash-2017.07.07/nginx-access-test/_search?pretty
curl localhost:9200/logstash-2017.07.07/nginx-access/_search?pretty
#删除索引
curl -XDELETE localhost:9200/logstash-2017.07.07*
curl -XDELETE localhost:9200/logstash-*
#查看映射
curl localhost:9200/_mappings?pretty
curl localhost:9200/logstash-2017.07.07/_mappings?pretty
curl -XGET http://127.0.0.1:9200/logstash-*/_mapping?pretty > my_mapping.json
- ./logstash/config/logstash_template.json:/usr/share/logstash/config/logstash_template.json

curl -XPUT http://127.0.0.1:9200/logstash-2017.07.08/_mapping -d '@logstash_template.json'

curl -XPUT localhost:9200/logstash-2017.07.07/_mapping/nginx-access -d  ' 
{
  "properties": {
    "requestTime": {
      "type": "text",
      "fielddata": false
     }
   }
}'

#将sysctl文件描述符修改为655360
sysctl -w vm.max_map_count=655360
docker run -p 5601:5601 -p 9200:9200 -p 5044:5044 -it --name elk sebp/elk

#测试命令
docker exec -it elk /bin/bash
/opt/logstash/bin/logstash -e 'input { stdin { } } output { elasticsearch { hosts => ["localhost"] } }'

#
curl -v http://localhost:9200/_search?pretty 
#kibana
http://192.168.31.215:5601

#只启动elasticsearch
docker run -p 5601:5601 -p 9200:9200 -p 5044:5044 -it \
    -e LOGSTASH_START=0 -e KIBANA_START=0 --name elk sebp/elk
#堆栈信息
docker run -p 5601:5601 -p 9200:9200 -p 5044:5044 -it \
    -e ES_HEAP_SIZE="2g" -e LS_HEAP_SIZE="1g" -e LS_OPTS="--no-auto-reload" \
    --name elk sebp/elk
#logstash
##在nginx服务器上安装nc
yum install -y nc
nc 192.168.31.215 5000 < /var/log/nginx/access.log
	
#filebeat
##权限
chmod +r /var/log/nginx/access.log
chmod +r /var/log/nginx/error.log
##rm方式
docker run --rm \
  -v /opt/elk/filebeat/filebeat.yml:/usr/share/filebeat/filebeat.yml \
  docker.elastic.co/beats/filebeat:5.4.3
##d方式
docker run -d --name fb --privileged=true \
  -v /opt/elk/filebeat/filebeat.yml:/usr/share/filebeat/filebeat.yml \
  -v /var/lib/docker/containers:/var/lib/docker/containers \
  -v /var/log/nginx:/var/log/nginx \
  docker.elastic.co/beats/filebeat:5.4.3;docker logs -f fb
##查看filebeat的模板
curl -v http://192.168.31.215:9200/_template/filebeat?pretty
https://raw.githubusercontent.com/spujadas/elk-docker/master/logstash-beats.crt 


