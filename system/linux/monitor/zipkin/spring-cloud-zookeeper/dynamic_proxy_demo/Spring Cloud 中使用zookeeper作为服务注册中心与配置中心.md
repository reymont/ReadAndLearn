Spring Cloud 中使用zookeeper作为服务注册中心与配置中心 - CSDN博客 http://blog.csdn.net/liusanchun/article/details/78597644

前段时间，了解了通过spring-cloud-config-server与spring-cloud-eureka-server作为配置中心与注册中心，同时了解到基于zookeeper或consul可以完成同样的事情，所以必须了解一下，这样有利于实际工作的技术对比与选型。

安装zookeeper

下载

zookeeper官网下载地址

解压

tar -xvf zookeeper-3.4.10.tar.gz
1
启动zookeeper

cd zookeeper-3.4.10
cd conf
cp zoo_sample.cfg zoo.cfg
cd ../bin
sh zkServer.sh start
1
2
3
4
5
使用zookeeper作为服务注册中心

maven依赖

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-discovery</artifactId>
        </dependency>
1
2
3
4
激活

package com.garlic.springcloudzookeeperclientapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * zookeeper作为服务注册中心，应用启动类
 *
 * @author sam.liu
 */
@SpringBootApplication
@EnableDiscoveryClient
public class SpringCloudZookeeperClientAppApplication {

    public static void main(String[] args) {
        SpringApplication.run(SpringCloudZookeeperClientAppApplication.class, args);
    }
}
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
application.properties

## 配置应用名称
spring.application.name=spring-cloud-zookeeper-client-app

## 配置服务端口
server.port=8080

## 关闭安全控制
management.security.enabled=false

## 配置zookeeper地址
spring.cloud.zookeeper.connect-string=localhost:2181
1
2
3
4
5
6
7
8
9
10
11
使用DiscoveryClient获取注册服务列表

package com.garlic.springcloudzookeeperclientapp.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.client.ServiceInstance;
import org.springframework.cloud.client.discovery.DiscoveryClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

/**
 * 提供Rest Api，根据实例名称获取注册服务列表
 *
 * @author sam.liu
 * @create 2017-11-21 20:47
 * @contact 563750241
 * @email lsc19890723@163.com
 */
@RestController
@RequestMapping("/zookeeper")
public class ZookeeperController {

    @Value("${spring.application.name}")
    private String instanceName;

    private final DiscoveryClient discoveryClient;

    @Autowired
    public ZookeeperController(DiscoveryClient discoveryClient) {
        this.discoveryClient = discoveryClient;
    }

    @GetMapping
    public String hello() {
        return "Hello,Zookeeper.";
    }

    @GetMapping("/services")
    public List<String> serviceUrl() {
        List<ServiceInstance> list = discoveryClient.getInstances(instanceName);
        List<String> services = new ArrayList<>();
        if (list != null && list.size() > 0 ) {
            list.forEach(serviceInstance -> {
                services.add(serviceInstance.getUri().toString());
            });
        }
        return services;
    }


}
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
注：可以启动不同的实例，此处我启动了端口8080与8081两个实例，然后使用端点可以查询到所注册的服务列表
同样可以通过zookeeper相关命令查询到说注册的服务列表
sh zkCli.sh
1
[services, zookeeper]
[zk: localhost:2181(CONNECTED) 1] ls /
[services, zookeeper]
[zk: localhost:2181(CONNECTED) 2] ls /services
[spring-cloud-zookeeper-client-app]
[zk: localhost:2181(CONNECTED) 3] ls /services/spring-cloud-zookeeper-client-app
[be61af3d-ffc2-4ffc-932c-26bc0f94971c, bcf21ece-e9e1-4a91-b985-8828688370b8]
[zk: localhost:2181(CONNECTED) 4]
1
2
3
4
5
6
7
8
使用zookeeper作为配置中心

使用zkCli创建配置信息

[zk: localhost:2181(CONNECTED) 27] create /config ""
Created /config
[zk: localhost:2181(CONNECTED) 28] create /config ""
Created /config/garlic
[zk: localhost:2181(CONNECTED) 29] create /config/garlic/name "default"
Created /config/garlic/name
[zk: localhost:2181(CONNECTED) 30] set /config/garlic-dev/name "dev"
Node does not exist: /config/garlic-dev/name
[zk: localhost:2181(CONNECTED) 31] create /config/garlic-dev/name "dev"
Created /config/garlic-dev/name
[zk: localhost:2181(CONNECTED) 32] create /config/garlic-test/name "test"
Created /config/garlic-test/name
[zk: localhost:2181(CONNECTED) 33] create /config/garlic-prod/name "prod"
1
2
3
4
5
6
7
8
9
10
11
12
13
maven依赖

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-config</artifactId>
        </dependency>
1
2
3
4
bootstrap.properties

## 启用zookeeper作为配置中心
spring.cloud.zookeeper.config.enabled = true

## 配置根路径
spring.cloud.zookeeper.config.root = config

## 配置默认上下文
spring.cloud.zookeeper.config.defaultContext = garlic

## 配置profile分隔符
spring.cloud.zookeeper.config.profileSeparator = -
1
2
3
4
5
6
7
8
9
10
11
spring.cloud.zookeeper.config.root对应zkCli创建的config目录，defaultContext对应创建的garlic或garlic-*目录，根据profile来确定获取dev还是test或者prod配置
application.properties

## 配置应用名称
spring.application.name=spring-cloud-zookeeper-config-app

## 配置服务端口
server.port=10000

## 关闭安全控制
management.security.enabled=false

spring.profiles.active=dev
1
2
3
4
5
6
7
8
9
10
编写Controller来动态获取zookeeper配置中心的数据

package com.garlic.springcloudzookeeperconfigapp.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 提供Rest Api，获取配置在zookeeper中的配置信息
 *
 * @author sam.liu
 * @create 2017-11-21 16:13
 * @contact 563750241
 * @email liusc@payexpress.biz
 */
@RestController
@RequestMapping("/zookeeper")
@RefreshScope // 必须添加，否则不会自动刷新name的值
public class ZookeeperController {

    @Autowired
    private Environment environment;

    @Value("${name}")
    private String name;

    @GetMapping
    public String hello() {
        return "Hello, " + name;
    }

    @GetMapping("/env")
    public String test() {
        String name = environment.getProperty("name");
        System.out.println(name);
        return "Hello," + name;
    }

}
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
启动配置实例之后，可以通过zkCli修改garlic下name的值，然后通过访问端点来查看值是否变化
至此，使用zookeeper作为服务注册中心与配置中心就完成了，我们可以通过使用zookeeper作为配置中心，然后使用zuul作为API网关，配置动态路由，为服务提供者，配置数据库连接相关信息。