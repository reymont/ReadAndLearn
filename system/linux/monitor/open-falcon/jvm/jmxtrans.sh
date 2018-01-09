#创建镜像
docker create --name influx-data -v /data/jmx tutum/influxdb
docker run -d --volumes-from influx-data -p 8083:8083 -p 8086:8086 --expose 2003 --expose 8084 -e PRE_CREATE=grafana -e GRAPHITE_DB="grafana" -e GRAPHITE_BINDING=':2003' -e GRAPHITE_PROTOCOL="tcp" --name influxdb tutum/influxdb
docker run -d --link influxdb:influxdb -p 3000:3000 tutum/grafana
docker run -d -v `pwd`/json-files:/var/lib/jmxtrans -P jmxtrans/jmxtrans
docker pull registry.alauda.cn/library/telegraf
#拷贝命令
scp openbridge-monitor.jar root@192.168.0.176:/opt/open-falcon
#执行monitor测试例子
java -Djava.rmi.server.hostname=192.168.0.179 -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.port=10001 -jar openbridge-monitor.jar
java -Djava.rmi.server.hostname=192.168.0.176 -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.port=10001 -jar openbridge-monitor.jar
#influxdb-ui界面
http://192.168.0.179:8083/
# 可以使用这个，这个是查询所有表，显示1条记录
select * from /.*/ limit 1
# 也可以使用这个，这个是显示所有表
show measurements
#测试新增数据
curl -XPOST 'http://localhost:8086/write?db=grafana' -d 'cpu,host=server01,region=uswest load=42 1434055562000000000'




