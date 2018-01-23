
* https://github.com/ipeonte/dynamic_proxy_demo


application.properties
```conf
zuul.routes.zuul_demo.path=/zuul_demo/**
zuul.routes.zuul_demo.serviceId=web_client
```

DynamicProxyApplication.java
```java
@EnableZuulProxy
//@EnableDiscoveryClient
@SpringBootApplication
public class DynamicProxyApplication {

	public static void main(String[] args) {
		SpringApplication.run(DynamicProxyApplication.class, args);
	}
}
```




# Dynamic Proxy based on Apache Zuul & Apache Zookeeper

The Component Diagram shown on picture below. The advantage of using Apache Zookeeper vs. standard Netflix OSS stack 
(Service Registry + Configuration Service) is running single system vs two required for Netflix. Apache Zookeeper used 
as configuration container as well as service registry.

![Proxy Error](https://github.com/ipeonte/DynamicProxyDemo/blob/master/doc/dynamic_proxy.png)

## Prerequsties:

Read official guide
https://cloud.spring.io/spring-cloud-zookeeper/

Download Apache Zookeeper. The latest copy can be downloaded from http://apache.forsale.plus/zookeeper/current/

Unzip tar file into ${app_dir}

```sh
cd ${app_dir}
mv zookeeper-${version} zookeeper
cd zookeeper/conf
cp zoo_sample.cfg zoo.cfg
```

For demo configuration file is good enough

```sh
cd ../bin
./zkServer.sh
```

Run Zookeeper command line and add shared configuration parameters for all web clients

```sh
./zkCli.sh -server 127.0.0.1:2181

create /config data
create /config/web_client data
create /config/web_client/test.bool_var true
create /config/web_client/test.int_var 42
create /config/web_client/test.dbl_var 5.9
create /config/web_client/test.str_var qwerty
create /config/web_client/test.list_var Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec
```

## Build

```sh
mvn clean install
```

## Demo

### No Web Clients

Start dynamic proxy

```sh
java -jar DynamicProxy/target/dynamic_proxy.jar
```

Navigate to http://localhost:8080/zuul_demo/
Without any web_client running it will be 500 error.

![Proxy Error](https://github.com/ipeonte/DynamicProxyDemo/blob/master/doc/proxy_error.png)

### Single Web Client

Start first web-client

```sh
java -jar WebClient/target/web_client.jar –server.port=8081
```

Connect it directly via http://localhost:8081/info

![Web Client #1 Direct](https://github.com/ipeonte/DynamicProxyDemo/blob/master/doc/web_client_1_direct.png)

Navigate on http://localhost:8080/zuul_demo/info
Check it redirecting request on web_client on port 8081

![Web Client #1 via Proxy](https://github.com/ipeonte/DynamicProxyDemo/blob/master/doc/web_client_1_proxy.png)
### Multiple Web Clients

Start second web-client

```sh
java -jar WebClient/target/web_client.jar –server.port=8082
```

Connect it directly via http://localhost:8082/info

![Web Client #2 Direct](https://github.com/ipeonte/DynamicProxyDemo/blob/master/doc/web_client_2_direct.png)

Navigate on http://localhost:8080/zuul_demo/info
Check it redirecting requests sequentially on web_client on ports 8081 & 8082

![Web Client #1 via Proxy](https://github.com/ipeonte/DynamicProxyDemo/blob/master/doc/web_client_1_proxy.png)

![Web Client #2 via Proxy](https://github.com/ipeonte/DynamicProxyDemo/blob/master/doc/web_client_2_proxy.png)

### Back to Single Web Client

Stop web_client on port 8081

Navigate on http://localhost:8080/zuul_demo/info
Check it redirecting requests only on web_client on ports 8082

![Web Client #2 via Proxy](https://github.com/ipeonte/DynamicProxyDemo/blob/master/doc/web_client_2_proxy.png)
