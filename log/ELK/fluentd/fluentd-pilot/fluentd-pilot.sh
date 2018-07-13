
# https://github.com/AliyunContainerService/fluentd-pilot
# https://github.com/AliyunContainerService/fluentd-pilot/blob/master/docs/docs.md

yum -y install epel-release
yum -y git
yum -y install docker-compose

git clone git@github.com:AliyunContainerService/fluentd-pilot.git
git clone https://github.com/AliyunContainerService/fluentd-pilot.git
cd fluentd-pilot/quickstart
./run

docker run --rm -it \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /:/host \
    registry.cn-hangzhou.aliyuncs.com/acs-sample/fluentd-pilot:latest

docker run -it --rm  -p 10080:8080 \
    -v /usr/local/tomcat/logs \
    --label aliyun.logs.catalina=stdout \
    --label aliyun.logs.access=/usr/local/tomcat/logs/localhost_access_log.*.txt \
    tomcat

docker run -it --rm  -p 10080:8080 \
    -v /usr/local/tomcat/logs \
    --label aliyun.logs.catalina=stdout \
    tomcat

# 查看状态
curl -m 1 -s -o /dev/null -w '%{http_code}' http://127.0.0.1:9200/
# 查看索引
curl localhost:9200/_cat/indices


docker run --rm -it \
    --privileged \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /:/host \
    -e FLUENTD_OUTPUT=elasticsearch \
    -e ELASTICSEARCH_HOST=${ELASTICSEARCH_HOST} \
    -e ELASTICSEARCH_PORT=${ELASTICSEARCH_PORT} \
    registry.cn-hangzhou.aliyuncs.com/acs-sample/fluentd-pilot:latest