#集群健康
curl 'localhost:920/_cluster/health?pretty'
curl 'localhost:9201/_cluster/state/nodes?pretty'
curl 'localhost:9201/_cat/nodes?v'
#主节点上获取pod信息
kubectl get pods --all-namespaces

#elasticsearch 版本 2.3.3 集群部署
docker create --name node-1 
  -e PROJECT_CODE=yhxy -e NODE_NAME=node-1 -e PATH_DATA=/data/data -e PATH_LOGS=/data/logs 
  -e EL_NETWORK=192.168.10.84:9301,192.168.10.84:9302,192.168.10.84:9303 
  -v /data/elasticsearch/node-1:/data 
  -p 9201:9200 -p 9301:9300 -p 9401:9400 
  192.168.1.72:5000/store/elasticsearch:2.3.3 /opt/startup.sh
docker create --name node-2 
  -e PROJECT_CODE=yhxy -e NODE_NAME=node-2 -e PATH_DATA=/data/data -e PATH_LOGS=/data/logs 
  -e EL_NETWORK=192.168.10.84:9301,192.168.10.84:9302,192.168.10.84:9303 
  -v /data/elasticsearch/node-2:/data 
  -p 9202:9200 -p 9302:9300 -p 9402:9400 
  192.168.1.72:5000/store/elasticsearch:2.3.3 /opt/startup.sh
docker create --name node-3 
  -e PROJECT_CODE=yhxy -e NODE_NAME=node-3 -e PATH_DATA=/data/data -e PATH_LOGS=/data/logs 
  -e EL_NETWORK=192.168.10.84:9301,192.168.10.84:9302,192.168.10.84:9303 
  -v /data/elasticsearch/node-3:/data -p 9203:9200 -p 9303:9300 -p 9403:9400 
  192.168.1.72:5000/store/elasticsearch:2.3.3 /opt/startup.sh

#时区
cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
curl 'localhost:9202/_cat/nodes?v'
#elasticsearch 版本 5.0 集群部署
docker run -dti --restart=always --name elasticsearch \
  -e ES_JAVA_OPTS="-Xms1g -Xmx1g -Duser.timezone=GMT+08" \
  -v /data/elasticsearch/data:/usr/share/elasticsearch/data \
  -v /data/elasticsearch/config:/usr/share/elasticsearch/config \
  -v /etc/localtime:/etc/localtime \
  -p 9200:9200 \
  -p 9300:9300 \
  docker.yihecloud.com/openbridge/elk/elasticsearch:5.0
docker run -dti --restart=always --name elk-1 \
  -e ES_JAVA_OPTS="-Xms1g -Xmx1g -Duser.timezone=GMT+08" \
  -v /data/elasticsearch1/data:/usr/share/elasticsearch/data \
  -v /data/elasticsearch1/config:/usr/share/elasticsearch/config \
  -v /data/elasticsearch1/logs:/usr/share/elasticsearch/logs \
  -v /etc/localtime:/etc/localtime \
  -p 9201:9200 \
  -p 9301:9300 \
  docker.yihecloud.com/openbridge/elk/elasticsearch:5.0
docker run -dti --restart=always --name elk-2 \
  -e ES_JAVA_OPTS="-Xms512m -Xmx512m -Duser.timezone=GMT+08" \
  -v /data/elasticsearch2/data:/usr/share/elasticsearch/data \
  -v /data/elasticsearch2/config:/usr/share/elasticsearch/config \
  -v /data/elasticsearch2/logs:/usr/share/elasticsearch/logs \
  -v /etc/localtime:/etc/localtime \
  -p 9202:9200 \
  -p 9302:9300 \
  docker.yihecloud.com/openbridge/elk/elasticsearch:5.0
  
#elasticsearch demo环境
docker run -dti --restart=always --name elk-1 \
  -e ES_JAVA_OPTS="-Xms1g -Xmx1g -Duser.timezone=GMT+08" \
  -v /data/elasticsearch/node-1/data:/usr/share/elasticsearch/data \
  -v /data/elasticsearch/node-1/config:/usr/share/elasticsearch/config \
  -v /data/elasticsearch/node-1/logs:/usr/share/elasticsearch/logs \
  -v /etc/localtime:/etc/localtime \
  -p 9201:9200 \
  -p 9301:9300 \
  docker.yihecloud.com/openbridge/elk/elasticsearch:5.0;docker logs -f elk-1
  
  