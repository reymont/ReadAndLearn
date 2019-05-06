

### 1. 安装 192.168.0.243
# https://hub.docker.com/r/dajobe/hbase HBase 2.1.2 in Docker 
# https://hbase.apache.org/
# https://hbase.apache.org/book.html
docker pull dajobe/hbase
docker rm -f hbase
rm -rf /opt/hbase/data/*
# --network=host \
docker run -d --restart=always --name=hbase -h hbase \
  -v /opt/hbase/data:/data \
  -p 12181:2181 \
  -p 18080:8080 \
  -p 18085:8085 \
  -p 19090:9090 \
  -p 19095:9095 \
  -p 16000:16000 \
  -p 16010:16010 \
  -p 16020:16020 \
  dajobe/hbase
docker logs -f hbase
# 安装ps 
apt-get update && apt-get install -y procps

### 2. Find Hbase status
# The region servers status pages
http://192.168.0.243:16010/master-status
# Thrift UI
http://192.168.0.243:19095/thrift.jsp
# REST server UI
http://192.168.0.243:18085/rest.jsp
# (Embedded) Zookeeper status
http://192.168.0.243:16010/zk.jsp

### 3. 安装happybase
yum install -y gcc python-devel libevent-devel
pip install happybase

import happybase
connection = happybase.Connection('192.168.0.243',19090)
connection.create_table('table-name', { 'family': dict() } )
connection.tables()
table = connection.table('table-name')
table.put('row-key', {'family:qual1': 'value1', 'family:qual2': 'value2'})
for k, data in table.scan():
    print k, data

### 4. java
docker exec -it hbase bash
hbase shell
list


