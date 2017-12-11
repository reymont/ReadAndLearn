# https://hub.docker.com/_/elasticsearch/
# 安装
yum install -y epel-release git docker
docker pull elasticsearch
docker pull elasticsearch:5.6.3

# Elasticsearch uses a hybrid mmapfs / niofs directory by default to store its indices. 
# The default operating system limits on mmap counts is likely to be too low, 
# which may result in out of memory exceptions.
sysctl -w vm.max_map_count=262144
# To set this value permanently, update the vm.max_map_count setting in /etc/sysctl.conf. 
# To verify after rebooting, run sysctl vm.max_map_count.
# 将sysctl文件描述符修改为655360
echo "vm.max_map_count=655360" >> /etc/sysctl.conf
sysctl -p
mkdir -p /opt/elk/esdata
chmod g+rwx /opt/elk/esdata
chown 1000:1000 esdata

# You can run the default elasticsearch command simply:
docker run -d elasticsearch
# You can also pass in additional flags to elasticsearch:
docker run -d elasticsearch -Des.node.name="TestNode"
# volume mounted at /usr/share/elasticsearch/config:
docker run -d -v "$PWD/config":/usr/share/elasticsearch/config elasticsearch
# This image is configured with a volume at /usr/share/elasticsearch/data to hold the persisted index data
docker run -d -v "$PWD/esdata":/usr/share/elasticsearch/data elasticsearch
docker run --privileged=true --name es -d \
  -v /opt/elk/esdata:/usr/share/elasticsearch/data \
  -p 9200:9200 \
  elasticsearch:5.6.3
# Inspect status of cluster:
curl http://127.0.0.1:9200/_cat/health
# This image includes EXPOSE 9200 9300 (default http.port), 

# Cluster
docker run -d --name elas elasticsearch -Etransport.host=0.0.0.0 -Ediscovery.zen.minimum_master_nodes=1

