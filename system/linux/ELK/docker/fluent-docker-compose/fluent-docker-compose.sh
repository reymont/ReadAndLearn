# https://github.com/kzk/docker-compose-efk


http://172.20.62.42/
http://172.20.62.42:5601/app/kibana

fluentd-*

# docker-compose build logstash 重建
# docker-compose up -d更新的会重新创建，未更新的则不变
# 172.20.62.42

docker build -t fluent/fluentd-es .
docker run -d -p 24224:24224 -p 24224:24224/udp\
  -v /opt/fluentd/conf:/fluentd/etc \
  -v /opt/fluent/data:/fluentd/log \
  -v /etc/hosts:/etc/hosts \
  --log-driver=fluentd \
  --name=fd \
  fluent/fluentd-es
docker run -d -p 80:8080 --log-driver=fluentd\
  --log-opt fluentd-address=172.20.62.69:24224\
  httpd:2.2.32

  
  image: httpd:2.2.32
    ports:
      - "80:8080"
    depends_on:
      - fluentd
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
        tag: httpd.access