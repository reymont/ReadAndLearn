docker pull registry.alauda.cn/googlelib/cadvisor
docker pull registry.cn-hangzhou.aliyuncs.com/acs-sample/google-cadvisor:v0.23
docker tag registry.alauda.cn/googlelib/cadvisor google/cadvisor:latest
docker tag registry.cn-hangzhou.aliyuncs.com/acs-sample/google-cadvisor:v0.23 google/cadvisor:latest
docker rm -f cadvisor;docker run --volume=/:/rootfs:ro --volume=/var/run:/var/run:rw --volume=/sys:/sys:ro --volume=/var/lib/docker/:/var/lib/docker:ro --publish=8084:8080 --name=cadvisor -d google/cadvisor:latest -storage_driver=influxdb -storage_driver_db=cadvisor -storage_driver_host=192.168.0.179:8086;docker logs -f cadvisor

#重启
docker run -d --name=influxdb -p 8083:8083 -p 8086:8086 --restart=always -expose 8090 --expose 8099 tutum/influxdb
#influxdb创建数据库
http://192.168.0.179:8083/
CREATE DATABASE "cadvisor"
select * from cpu_usage_user where time > '2017-04-19 11:12:31.201730063'