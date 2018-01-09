http://192.168.0.180:7778/jolokia/read/java.lang:type=Threading
http://192.168.0.180:7778/jvmviewer/jolokia.html?ip=10.1.100.2&port=10001
curl -XPOST 192.168.0.180:7778/jolokia -d '{
	"type" : "read",
	"mbean": "java.lang:type=Threading",
	"attribute": "AllThreadIds",
	"target": {
		"url": "service:jmx:rmi:///jndi/rmi://10.1.100.2:10001/jmxrmi"
	}
}'
curl 'http://192.168.0.180:7778/jolokia/' -XPOST  -d '[
{
   "type":"EXEC",
   "mbean":"java.lang:type=Threading",
   "operation":"getThreadInfo(long,int)",
   "arguments":[79008,0],
	"target": {
		"url": "service:jmx:rmi:///jndi/rmi://10.1.100.2:10001/jmxrmi"
	}
},{
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