
docker pull registry.alauda.cn/library/telegraf
#生成sample-config
docker run --rm telegraf -sample-config > telegraf.conf
docker run --rm registry.alauda.cn/library/telegraf -sample-config > telegraf.conf
docker run -v $PWD/telegraf.conf:/etc/telegraf/telegraf.conf:ro telegraf

docker run -d --name=telegraf \
      --net=influxdb \
      -v $PWD/telegraf.conf:/etc/telegraf/telegraf.conf:ro \
      telegraf

docker run -d --name jolokia -p 7777:8080 --restart=always bodsch/docker-jolokia  
docker run -d --name jolokia -p 7777:8080 --restart=always docker.dev.yihecloud.com/base/jvmviewer:1.0
docker run -d -p 10001:10001 --restart=always --name=jh jmx-hello

http://192.168.31.212:7777/jvmviewer/jolokia.html?ip=192.168.31.212&port=10001

#maven jmx
<build>
    <plugins>
    <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
        <configuration>
            <jvmArguments>-XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xdebug
                -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005
            </jvmArguments>
            <arguments>
                <argument>--spring.profiles.active=dev</argument>
            </arguments>
        </configuration>
    </plugin>
    </plugins>
</build>



#proxy模式
curl -XPOST 192.168.0.179:8888/jolokia/ -d '{
	"type": "read",
	"mbean": "java.lang:type=Memory",
	"attribute": "HeapMemoryUsage",
	"target": {
		"url": "service:jmx:rmi:///jndi/rmi://192.168.0.179:10001/jmxrmi"
	}
}'
curl -XPOST 192.168.0.179:8888/jolokia/ -d '{
	"type": "read",
	"mbean": "java.lang:type=Memory",
	"attribute": "HeapMemoryUsage",
	"target": {
		"url": "service:jmx:rmi:///jndi/rmi://192.168.0.176:10001/jmxrmi"
	}
}'|python -m json.tool
curl -XPOST 127.0.0.1:7777/jolokia/ -d '{
	"type": "read",
	"mbean": "java.lang:type=Memory",
	"attribute": "HeapMemoryUsage",
	"target": {
		"url":"service:jmx:rmi:///jndi/rmi://192.168.0.179:10001/jmxrmi"
	}
}'
#获取元数据
http://localhost:7777/jolokia/read/java.lang:name=Metaspace,type=MemoryPool/Usage
#批量获取数据&查询API
curl -XPOST 192.168.0.179:8888/jolokia -d '[{
	"type": "read",
	"mbean": "java.lang:type=Memory",
	"attribute": "HeapMemoryUsage"
},
{
	"type": "search",
	"mbean": "java.lang:type=MemoryPool,*"
}
]'
{
	"timestamp": 1492661554,
	"status": 200,
	"request": {
		"mbean": "java.lang:type=MemoryPool,*",
		"type": "search"
	},
	"value": ["java.lang:name=PS Eden Space,type=MemoryPool", "java.lang:name=PS Survivor Space,type=MemoryPool", "java.lang:name=Code Cache,type=MemoryPool", "java.lang:name=PS Perm Gen,type=MemoryPool", "java.lang:name=PS Old Gen,type=MemoryPool"]
}
curl -XPOST 192.168.0.179:8888/jolokia -d '{
	"type": "search",
	"mbean": "java.lang:type=MemoryPool,*"
}'
curl -XPOST 127.0.0.1:7777/jolokia -d '{
	"type": "search",
	"mbean": "java.lang:type=MemoryPool,*"
}'
curl -XPOST 192.168.0.179:8888/jolokia -d '{
	"type" : "read",
	"mbean": "java.lang:name=Code Cache,type=MemoryPool",
	"attribute": "Usage"
}'
#需要新增"/"下划线
curl 'http://localhost:7777/jolokia/' -XPOST  -d '{
	"type": "read",
	"mbean": "java.lang:type=Memory",
	"attribute": "HeapMemoryUsage"
}'
#线程
http://localhost:7777/jolokia/read/java.lang:type=Threading/AllThreadIds
#批量线程[2,0]表示线程2，stackTrace无值
curl 'http://localhost:7777/jolokia/' -XPOST  -d '[{
   "type":"EXEC",
   "mbean":"java.lang:type=Threading",
   "operation":"getThreadInfo(long,int)",
   "arguments":[2,0]
},{
   "type":"EXEC",
   "mbean":"java.lang:type=Threading",
   "operation":"getThreadInfo(long,int)",
   "arguments":[3,0]
},{
   "type":"EXEC",
   "mbean":"java.lang:type=Threading",
   "operation":"getThreadInfo(long,int)",
   "arguments":[4,0]
}]'
curl 'http://localhost:7777/jolokia/' -XPOST  -d '{
   "type":"EXEC",
   "mbean":"java.lang:type=Threading",
   "operation":"getThreadInfo(long)",
   "arguments":2
}'
curl -XPOST 'http://localhost:7777/jolokia/' -d '{
	"type": "search",
	"mbean": "java.lang:type=Threading*",
	"operation":"getThreadInfo*"
}'
curl 'http://localhost:7777/jolokia/' -XPOST  -d '{
   "type":"EXEC",
   "mbean":"java.lang:type=Threading",
   "operation":"dumpAllThreads",
   "arguments":[true,true]
}'



