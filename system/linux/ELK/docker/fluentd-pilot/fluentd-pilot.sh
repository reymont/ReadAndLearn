


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

# 查看状态
curl -m 1 -s -o /dev/null -w '%{http_code}' http://127.0.0.1:9200/
# 查看索引
curl localhost:9200/_cat/indices
