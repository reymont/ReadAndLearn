docker run -d --name jolokia -p 7777:8080 docker.dev.yihecloud.com/bodsch/docker-jolokia:1.0


docker run --rm -it -v `pwd`:/data/webapps -p 7777:8080 docker.dev.yihecloud.com/base/tomcat:2.1
docker run --rm -it -v /data/jolokia/webapps:/data/webapps -p 7778:8080 docker.dev.yihecloud.com/base/tomcat:2.1

docker run --rm -it -v /data/jolokia/webapps:/opt/tomcat/webapps -p 7778:8080 docker.dev.yihecloud.com/bodsch/docker-jolokia:11
docker run -d -p 9104:9104 --restart=always --name=me   -e DATA_SOURCE_NAME="root:Admin@123@(192.168.31.211:3306)/paasos"   prom/mysqld-exporter
docker run -d -p 10001:10001 --restart=always --name=jh jmx-hello.jar
#页面访问
http://192.168.0.180:7778/html/jolokia.html?ip=10.1.100.2&port=10001

docker run -d -it -v /data/jolokia/webapps:/opt/tomcat/webapps\
 -p 7777:8080 --name jolokia\
 docker.dev.yihecloud.com/bodsch/docker-jolokia:11
#页面访问 
http://192.168.0.180:7777/html/jolokia.html?ip=10.1.100.2&port=10001

docker build -t docker.dev.yihecloud.com/base/jvmviewer:1.0 .
docker run --rm -it -p 7778:8080 docker.dev.yihecloud.com/base/jvmviewer:1.0
docker run -d --name jolokia -p 7777:8080 docker.dev.yihecloud.com/base/jvmviewer:1.0

curl -XPOST 127.0.0.1:8080/jolokia/ -d '{
	"type": "read",
	"mbean": "java.lang:type=Memory",
	"attribute": "HeapMemoryUsage",
	"target": {
		"url":"service:jmx:rmi:///jndi/rmi://10.1.100.2:10001/jmxrmi"
	}
}'
