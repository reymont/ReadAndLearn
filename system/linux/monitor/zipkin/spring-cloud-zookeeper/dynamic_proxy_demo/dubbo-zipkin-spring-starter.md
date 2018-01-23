
# 配置项好少，就一个开关？zipkin地址配置呢？ · Issue #9 · jessyZu/dubbo-zipkin-spring-starter https://github.com/jessyZu/dubbo-zipkin-spring-starter/issues/9

改下项目的application.properties文件就可以了
src/test/java/resources/application.properties

```conf
spring.sleuth.sampler.percentage=1
spring.application.name=dubbo-zipkin-test
spring.zipkin.baseUrl=http://zipkin-host:9411
```

# dubbo-zipkin-spring-starter/README.md at master · jessyZu/dubbo-zipkin-spring-starter https://github.com/jessyZu/dubbo-zipkin-spring-starter/blob/master/README.md

# dubbo-zipkin-spring-starter
Zipkin是一款开源的分布式实时数据追踪系统,dubbo-zipkin-spring-starter是为服务治理框架dubbo 编写的instrument library,支持dubbo全链路实时调用数据统计。使用者可以直接引入此boot starter，扩展默认自动激活(AutoConfiguration)。


##springboot用户如何引入使用

```
        <dependency>
            <groupId>com.github.jessyZu</groupId>
   			 <artifactId>dubbo-zipkin-spring-starter</artifactId>
   			  <version>1.0.2</version>
        </dependency>

```

默认会自动配置zikpin功能，也可以这样关闭：

```
	dubbo.trace.enabled=false

```
##运行自带的测试
###1.下载zipkin数据收集服务器包 [zipkin-service-0.0.1-SNAPSHOT.jar](https://pan.baidu.com/s/1sl3s93n),这里以本地内存服务器做演示:

```
java -jar ./zipkin-service-0.0.1-SNAPSHOT.jar

```
打开 [http://localhost:9411/](http://localhost:9411/)  页面

zipkin服务器源码来自springcloud团队 [https://github.com/joshlong/cloud-native-workshop/tree/master/code/zipkin-service](https://github.com/joshlong/cloud-native-workshop/tree/master/code/zipkin-service)

###2.按顺序分别运行Dubbo的服务调用与提供者

* 运行TestService2Provider.test()
* 运行TestService1Provider.test()
* 运行TestService1Consumer.test()


###说明:

* 调用关系为TestService1Consumer->TestService1Provider->TestService2Provider;
* 一次调用会产生4个span，用来记录全链路的调用数据


###3.调用成功后，打开 [http://localhost:9411/](http://localhost:9411/)  页面，查询调用数据，如图：

![img1](./img1.png)

![img2](./img2.png)


![img3](./img3.png)

