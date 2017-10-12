
* [java.lang.NoSuchMethodError: com.fasterxml.jackson.databind.type.ReferenceType.upgradeFrom(Lcom/fast-爱编程 ](http://www.w2bc.com/article/233838)

```xml
<dependency>
    <groupId>com.fasterxml.jackson.datatype</groupId>
    <artifactId>jackson-datatype-guava</artifactId>
    <version>2.6.7</version>
</dependency>
<!-- https://mvnrepository.com/artifact/com.fasterxml.jackson.datatype/jackson-datatype-guava -->
<dependency>
    <groupId>com.fasterxml.jackson.datatype</groupId>
    <artifactId>jackson-datatype-guava</artifactId>
    <version>2.6.0</version>
</dependency>
```

```sh
# 查看依赖
mvn dependency:tree | grep jackson 
```

* [spring-boot - 标签 - 赵计刚 - 博客园 ](http://www.cnblogs.com/java-zhao/tag/spring-boot/)
* [第二十章 springboot + consul（1） - 赵计刚 - 博客园 ](http://www.cnblogs.com/java-zhao/p/5527779.html)

consul的具体安装与操作查看博客的consul系列。

# 一、启动consul

（1个server+1个client，方便起见，client使用本机）：查看：http://www.cnblogs.com/java-zhao/p/5375132.html

## 1、开启虚拟机-->切换到vagrantFile中配置的节点

vagrant up
vagrant ssh n110

## 2、启动server（n110）

consul agent -server -bootstrap-expect=1  -data-dir=/tmp/consul -node=server-110 -bind=192.168.21.110 -dc=zjgdc1 -client 0.0.0.0 -ui

说明：-client 0 0 0 0 -ui-->使得客户端可以直接通过url访问服务端的consul ui

## 3、启动client（local）

consul agent -data-dir=/tmp/consul -node=client-my -bind=xxx -dc=zjgdc1
说明：xxx代表本机IP

## 4、client加入server

consul join 192.168.21.110
# 二、java部分

## 1、pom.xml

复制代码
```xml
        <!-- consul-client -->
        <dependency>
            <groupId>com.orbitz.consul</groupId>
            <artifactId>consul-client</artifactId>
            <version>0.10.0</version>
        </dependency>
        <!-- consul需要的包 -->
        <dependency>
            <groupId>org.glassfish.jersey.core</groupId>
            <artifactId>jersey-client</artifactId>
            <version>2.22.2</version>
        </dependency>
```
复制代码
说明：consul的java客户端有两个：consul-client和consul-api。

consul-client的github地址：https://github.com/OrbitzWorldwide/consul-client

## 2、ConsulService

```java
 1 package com.xxx.firstboot.service;
 2 
 3 import java.net.MalformedURLException;
 4 import java.net.URI;
 5 import java.util.List;
 6 
 7 import org.springframework.stereotype.Service;
 8 
 9 import com.orbitz.consul.AgentClient;
10 import com.orbitz.consul.Consul;
11 import com.orbitz.consul.HealthClient;
12 import com.orbitz.consul.KeyValueClient;
13 //import com.orbitz.consul.NotRegisteredException;
14 import com.orbitz.consul.StatusClient;
15 import com.orbitz.consul.model.health.ServiceHealth;
16 
17 @Service
18 public class ConsulService {
19     
20     /**
21      * 注册服务
22      * 并对服务进行健康检查
23      * servicename唯一
24      * serviceId:没发现有什么作用
25      */
26     public void registerService(String serviceName, String serviceId) {
27         Consul consul = Consul.builder().build();            //建立consul实例
28         AgentClient agentClient = consul.agentClient();        //建立AgentClient
29         
30         try {
31             /**
32              * 注意该注册接口：
33              * 需要提供一个健康检查的服务URL，以及每隔多长时间访问一下该服务（这里是3s）
34              */
35             agentClient.register(8080, URI.create("http://localhost:8080/health").toURL(), 3, serviceName, serviceId, "dev");
36         } catch (MalformedURLException e) {
37             e.printStackTrace();
38         }
39 //        try {
40 //            agentClient.pass(serviceId);//健康检查
41 //        } catch (NotRegisteredException e) {
42 //            e.printStackTrace();
43 //        }
44     }
45     
46     /**
47      * 发现可用的服务
48      */
49     public List<ServiceHealth> findHealthyService(String servicename){
50         Consul consul = Consul.builder().build();
51         HealthClient healthClient = consul.healthClient();//获取所有健康的服务
52         return healthClient.getHealthyServiceInstances(servicename).getResponse();//寻找passing状态的节点
53     }
54     
55     /**
56      * 存储KV
57      */
58     public void storeKV(String key, String value){
59         Consul consul = Consul.builder().build();
60         KeyValueClient kvClient = consul.keyValueClient();
61         kvClient.putValue(key, value);//存储KV
62     }
63     
64     /**
65      * 根据key获取value
66      */
67     public String getKV(String key){
68         Consul consul = Consul.builder().build();
69         KeyValueClient kvClient = consul.keyValueClient();
70         return kvClient.getValueAsString(key).get();
71     }
72     
73     /**
74      * 找出一致性的节点（应该是同一个DC中的所有server节点）
75      */
76     public List<String> findRaftPeers(){
77         StatusClient statusClient = Consul.builder().build().statusClient();
78         return statusClient.getPeers();
79     }
80     
81     /**
82      * 获取leader
83      */
84     public String findRaftLeader(){
85         StatusClient statusClient = Consul.builder().build().statusClient();
86         return statusClient.getLeader();
87     }
88     
89 }
```

复制代码
列出了常用API。

注意：

服务注册的时候不需要传递IP
服务注册的时候需要给出health check的url和时间间隔。该url是一个服务（要提供该服务，需要使用spring boot actuator，具体操作如下：）。
直接在pomx.ml中加入：
```xml
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
```
此时重启应用后，访问http://localhost:8080/health，得到如下结果一个json串：

```yaml
{
status: "UP",
diskSpace: - {
status: "UP",
total: 249769230336,
free: 182003318784,
threshold: 10485760
},
rabbit: - {
status: "UP",
version: "3.6.1"
},
mongo: - {
status: "UP",
version: "3.2.6"
},
db: - {
status: "UP",
myTestDbDataSource: - {
status: "UP",
database: "MySQL",
hello: 1
},
myTestDb2DataSource: - {
status: "UP",
database: "MySQL",
hello: 1
},
dataSource: - {
status: "UP",
database: "MySQL",
hello: 1
}
},
_links: - {
self: - {
href: "http://localhost:8080/health"
}
}
}
Format online
```


说明：status

UP：服务器正常（以上只要有一个组件DOWN，服务器就处于DOWN，所以我需要启动服务器上的mongo和rabbitmq，这里我之前使用了这两个组件）
DOWN：服务器挂了
## 3、ConsulController

```java
package com.xxx.firstboot.web;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import com.orbitz.consul.model.health.ServiceHealth;
import com.xxx.firstboot.service.ConsulService;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;

@Api("consul相关API")
@RestController
@RequestMapping("/consul")
public class ConsulController {
    @Autowired
    private ConsulService consulService;

    /*******************************服务注册与发现*******************************/
    @ApiOperation("注册服务")
    @RequestMapping(value="/registerService/{servicename}/{serviceid}",method=RequestMethod.POST)
    public void registerService(@PathVariable("servicename") String serviceName, 
                                @PathVariable("serviceid") String serviceId) {
        consulService.registerService(serviceName, serviceId);
    }
    
    @ApiOperation("发现服务")
    @RequestMapping(value="/discoverService/{servicename}",method=RequestMethod.GET)
     public List<ServiceHealth> discoverService(@PathVariable("servicename") String serviceName) {
        return consulService.findHealthyService(serviceName);
    }
    
    /*******************************KV*******************************/
    @ApiOperation("store KV")
    @RequestMapping(value="/kv/{key}/{value}",method=RequestMethod.POST)
    public void storeKV(@PathVariable("key") String key, 
                        @PathVariable("value") String value) {
        consulService.storeKV(key, value);
    }
    
    @ApiOperation("get KV")
    @RequestMapping(value="/kv/{key}",method=RequestMethod.GET)
    public String getKV(@PathVariable("key") String key) {
        return consulService.getKV(key);
    }

    /*******************************server*******************************/
    @ApiOperation("获取同一个DC中的所有server节点")
    @RequestMapping(value="/raftpeers",method=RequestMethod.GET)
    public List<String> findRaftPeers() {
        return consulService.findRaftPeers();
    }
    
    @ApiOperation("获取leader")
    @RequestMapping(value="/leader",method=RequestMethod.GET)
    public String leader() {
        return consulService.findRaftLeader();
    }
}
```

## 4、测试（通过swagger测试+通过consul UI查看结果）

swagger：http://localhost:8080/swagger-ui.html
consul UI：http://192.168.21.110:8500/ui/


上图展示了consul UI所展示的所有东西。services、nodes、kv、datacenter