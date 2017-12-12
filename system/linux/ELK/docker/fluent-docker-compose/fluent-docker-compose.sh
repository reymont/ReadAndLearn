# https://github.com/kzk/docker-compose-efk


http://172.20.62.42/
http://172.20.62.42:5601/app/kibana

fluentd-*

# docker-compose build logstash 重建
# docker-compose up -d更新的会重新创建，未更新的则不变
# 172.20.62.42

docker build -t fluent/fluentd-es .
# log-driver
docker run -d -p 24224:24224 -p 24224:24224/udp\
  -v /opt/fluentd/conf:/fluentd/etc \
  -v /opt/fluent/data:/fluentd/log \
  -v /etc/hosts:/etc/hosts \
  --log-driver=fluentd \
  --name=fd \
  fluent/fluentd-es
docker run -d -p 24224:24224 -p 24224:24224/udp\
  -v /opt/fluentd/conf:/fluentd/etc \
  -v /opt/fluent/data:/fluentd/log \
  -v /etc/hosts:/etc/hosts \
  --name=fd \
  fluent/fluentd-es
docker run -d -p 8082:80 --log-driver=fluentd\
  --log-opt fluentd-address=172.20.62.69:24224\
  --log-opt tag=httpd.access\
  httpd:2.2.32
# Let’s access to httpd to generate some access logs. curl command is always your friend.
curl http://localhost:8082/