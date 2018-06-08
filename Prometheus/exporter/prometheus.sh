#docker
https://docker.dev.yihecloud.com/auth/registry/repos/base/prometheus/_tags
docker push docker.dev.yihecloud.com/base/prometheus:1.0
docker build -t docker.dev.yihecloud.com/base/prometheus:1.0 .
docker run -d -p 9091:9090 -p 9002:9001 --restart=always\
  -v /opt/open-falcon/prometheus:/etc/prometheus/\
  -v /opt/open-falcon/prometheus/data:/prometheus\
  --name prom2 docker.dev.yihecloud.com/base/prometheus:1.0;docker logs -f prom2
docker run -d -p 9090:9090 -p 9001:9001 --restart=always\
  -v /opt/open-falcon/prometheus:/etc/prometheus/\
  -v /opt/open-falcon/prometheus/data:/prometheus\
  -v /etc/localtime:/etc/localtime:ro\
  --name prom docker.dev.yihecloud.com/base/prometheus:1.0;docker logs -f prom
docker run --rm -it -p 9090:9090 -p 9001:9001\
  --name prom docker.dev.yihecloud.com/base/prometheus:1.0
docker run --rm -it -p 9092:9090 -p 9002:9001 --entrypoint=bash  --name prom2 docker.dev.yihecloud.com/base/prometheus:1.0
docker run --rm -it -p 9092:9090 -p 9002:9001 \
  -v /opt/open-falcon/prometheus/data:/prometheus \
  --name prom2 docker.dev.yihecloud.com/base/prometheus:1.0 
docker run -it -p 9090:9090 -p 9001:9001 --entrypoint=/opt/startup.sh \
  -v /opt/open-falcon/prometheus/data:/prometheus2 \
  --name prom2 docker.dev.yihecloud.com/base/prometheus:1.0 \
  -config.file=/etc/prometheus/prometheus.yml \
  -storage.local.path=/prometheus2 \
  -web.console.libraries=/usr/share/prometheus/console_libraries \
  -web.console.templates=/usr/share/prometheus/consoles
docker run --rm -ti -p 9091:9090 -p 9002:9001 \
  -v /opt/open-falcon/prometheus:/etc/prometheus/\
  -v /opt/open-falcon/prometheus/data:/prometheus\
  --name prom2 docker.dev.yihecloud.com/base/prometheus:1.0 sh
docker run -d -p 9090:9090 -p 9001:9001 --restart=always\
  -v /opt/open-falcon/prometheus:/etc/prometheus/\
  -v /opt/open-falcon/prometheus/data:/prometheus\
  --name prom docker.dev.yihecloud.com/base/prometheus:1.0;docker logs -f prom
docker run -d -p 9090:9090 --restart=always\
  -v /opt/open-falcon/OpenBridge-passos-proxy/open-falcon/src/prometheus:/etc/prometheus/\
  --name prom prom/prometheus;docker logs -f prom  
docker run -d -p 9090:9090 --restart=always\
  -v /opt/open-falcon/prometheus:/etc/prometheus/\
  --name prom prom/prometheus;docker logs -f prom 
  
docker run -d -p 9090:9090 --restart=always\
  -v /opt/open-falcon/prometheus/:/etc/prometheus/\
  --name prom docker.dev.yihecloud.com/base/prometheus:1.0;docker logs -f prom
docker run -p 9090:9090 -v `pwd`/prometheus.yml:/etc/prometheus/prometheus.yml --name prom prom/prometheus
docker rm -f prom
docker run --rm -p 9090:9090 -v /opt/open-falcon/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml --name prom prom/prometheus
docker run -d -p 9090:9090 -v /opt/open-falcon/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml --name prom prom/prometheus

docker run -d -p 9090:9090 --restart=always\
  -v /opt/open-falcon/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml\
  -v /opt/open-falcon/prometheus/alert.rules:/etc/prometheus/alert.rules\
  --name prom prom/prometheus

mkdir -p /opt/open-falcon/prometheus/
docker run -d -p 9090:9090 --restart=always\
  -v /opt/open-falcon/prometheus/:/etc/prometheus/\
  --name prom docker.dev.yihecloud.com/base/prometheus;docker logs -f prom
  
docker run -d -p 9090:9090 --restart=always\
  -v `pwd`:/etc/prometheus/\
  --name prom docker.dev.yihecloud.com/base/prometheus;docker logs -f prom
  
-storage.local.engine=none
openssl s_client -showcerts -connect 192.168.31.221:6443

#编译prometheus
make build

#blackbox_exporter
go build .
docker build -t docker.cloudos.yihecloud.com/prom/blackbox_exporter:1.0 .
docker run -d -p 9115:9115 --restart=always\
  --name be -v `pwd`:/config\
  docker.cloudos.yihecloud.com/prom/blackbox_exporter:1.0\
  -config.file=/config/blackbox.yml
  
#query
http://192.168.31.212:9090/api/v1/query?query=up
http://192.168.31.212:9090/api/v1/query?query=up&time=1498121586
#Querying metadata
http://192.168.31.212:9090/api/v1/series?match[]=up&match[]=process_start_time_seconds{job="prometheus"}
http://192.168.31.212:9090/api/v1/label/job/values
http://192.168.31.212:9090/api/v1/targets

#编译
#升级golang 1.8
wget http://www.golangtc.com/static/go/1.8/go1.8.linux-amd64.tar.gz
yum --showduplicates list golang | expand
yum remove -y golang
/usr/local/go
vi /etc/profile
export PATH=$PATH:/usr/local/go/bin
go env
wget  https://github.com/prometheus/prometheus/releases/download/v1.6.3/prometheus-1.6.3.linux-arm64.tar.gz
#将-u注销，不再强制更新promu
wget https://github.com/prometheus/node_exporter/releases/download/v0.14.0/node_exporter-0.14.0.linux-amd64.tar.gz
vi Makefile
go $(GO) get -u github.com/prometheus/promu
make build

#重新加载配置文件
curl -XPOST http://192.168.0.180:9090/-/reload
curl -XPOST 127.0.0.1:9090/-/reload
curl -XPOST 127.0.0.1:9090/config/prometheus.yml -d 'global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:
#  - job_name: server
#    static_configs:
#      - targets: ["192.168.0.179:9090"]
  - job_name: federate
    honor_labels: true
    metrics_path: "/federate"
    params:
      match[]:
        - "{__name__=~"^go.*"}"   # Request all job-level time series
        - "{__name__=~"^c.*"}"
    static_configs:
      - targets:
        - 192.168.0.180:9090
#  - job_name: linux
#    static_configs:
#      - targets: ["192.168.0.179:9100"]
#        labels:
#          instance: db1
#  - job_name: container
#    static_configs:
#      - targets: ["192.168.0.181:4194","192.168.0.182:4194","192.168.0.183:4194","192.168.0.184:4194","192.168.0.185:4194","192.168.0.186:4194"]
    #kubernetes_sd_configs:
    #  - role: pod
    #    api_server: "http://192.168.0.180:8080"
#  - job_name: mysql
#    metrics_path: ""
#    static_configs:
#      - targets: ["192.168.0.173:3306"]

rule_files:
  - "/etc/prometheus/alert.rules"'

http://192.168.0.179:9090
#监听对象
http://192.168.0.180:9090/targets

#node-exporter
docker run -d -p 9100:9100   -v "/proc:/host/proc"   -v "/sys:/host/sys"   -v "/:/rootfs"   --net="host"   quay.io/prometheus/node-exporter     -collector.procfs /host/proc     -collector.sysfs /host/sys     -collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"
wget https://github.com/prometheus/node_exporter/releases/download/v0.13.0/node_exporter-0.13.0.linux-amd64.tar.gz
tar -zxvf node_exporter-0.13.0.linux-amd64.tar.gz 
cd node_exporter-0.13.0.linux-amd64
./node_exporter 

docker pull prom/node-exporter
docker run -d --restart=always --name=ne -p 9100:9100 prom/node-exporter
docker tag prom/node-exporter docker.dev.yihecloud.com/base/node-exporter
docker push docker.dev.yihecloud.com/base/node-exporter
docker run -d --restart=always --name=ne -p 9100:9100 docker.dev.yihecloud.com/base/node-exporter
docker tag prom/node-exporter docker.cloudos.yihecloud.com/base/node-exporter
docker push docker.cloudos.yihecloud.com/base/node-exporter
docker run -d --restart=always --name=ne -p 9100:9100 docker.cloudos.yihecloud.com/base/node-exporter


http://192.168.0.179:9100/metrics

#mysqld-exporter
docker pull prom/mysqld-exporter
docker tag prom/mysqld-exporter docker.dev.yihecloud.com/base/mysqld-exporter
docker push docker.dev.yihecloud.com/base/mysqld-exporter
docker run -d -p 9104:9104 --restart=always --name=me \
  -e DATA_SOURCE_NAME="root:Admin@123@(192.168.0.173:3306)/paasos" \
  docker.dev.yihecloud.com/base/mysqld-exporter
docker run -d -p 9104:9104 --restart=always --name=me \
  -e DATA_SOURCE_NAME="root:Admin@123@(192.168.31.211:3306)/paasos" \
  prom/mysqld-exporter
		
192.168.0.179:9104/metrics http://192.168.0.179:9104/metrics

#ngnix
https://console.cloudos.yihecloud.com/prom/api/v1/query?query=up&time=1497853428.685&_=1497853409964
https://console.cloudos.yihecloud.com/prom/graph
		

