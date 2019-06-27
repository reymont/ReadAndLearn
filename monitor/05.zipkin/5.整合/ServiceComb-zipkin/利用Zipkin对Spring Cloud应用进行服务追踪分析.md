利用Zipkin对Spring Cloud应用进行服务追踪分析-博客-云栖社区-阿里云 https://yq.aliyun.com/articles/60165

摘要： 本文简单介绍了如何利用Zipkin对SpringCloud应用进行服务分析。在实际的应用场景中，Zipkin可以结合压力测试工具一起使用，分析系统在大压力下的可用性和性能。

zipkin_docker_small

设想这么一种情况，如果你的微服务数量逐渐增大，服务间的依赖关系越来越复杂，怎么分析它们之间的调用关系及相互的影响？

服务追踪分析

一个由微服务构成的应用系统通过服务来划分问题域，通过REST请求服务API来连接服务来完成完整业务。对于入口的一个调用可能需要有多个后台服务协同完成，链路上任何一个调用超时或出错都可能造成前端请求的失败。服务的调用链也会越来越长，并形成一个树形的调用链。

trace_tree

随着服务的增多，对调用链的分析也会越来越负责。设想你在负责下面这个系统，其中每个小点都是一个微服务，他们之间的调用关系形成了复杂的网络。

internal_services

有密集恐惧症的同学就忽略吧。

针对服务化应用全链路追踪的问题，Google发表了Dapper论文，介绍了他们如何进行服务追踪分析。其基本思路是在服务调用的请求和响应中加入ID，标明上下游请求的关系。利用这些信息，可以可视化地分析服务调用链路和服务间的依赖关系。

Spring Cloud Sleuth和Zipkin

对应Dpper的开源实现是Zipkin，支持多种语言包括JavaScript，Python，Java, Scala, Ruby, C#, Go等。其中Java由多种不同的库来支持。

在这个示例中，我们准备开发两个基于Spring Cloud的应用，利用Spring Cloud Sleuth来和Zipkin进行集成。Spring Cloud Sleuth是对Zipkin的一个封装，对于Span、Trace等信息的生成、接入HTTP Request，以及向Zipkin Server发送采集信息等全部自动完成。

这是Spring Cloud Sleuth的概念图。

springcloud_sleuth_trace_id

服务REST调用

本次演示的服务有两个：tracedemo做为前端服务接收用户的请求，tracebackend为后端服务，tracedemo通过http协议调用后端服务。

利用RestTemplate进行HTTP请求调用

tracedemo应用通过restTemplate调用后端tracedemo服务，注意，URL中指明tracedemo的地址为backend。

@RequestMapping("/")
public String callHome(){
    LOG.log(Level.INFO, "calling trace demo backend");
    return restTemplate.getForObject("http://backend:8090", String.class);
}
后端服务响应HTTP请求，输出一行日志后返回经典的“hello world”。

@RequestMapping("/")
public String home(){
    LOG.log(Level.INFO, "trace demo backend is being called");
    return "Hello World.";
}
引入Sleuth和Zipkin依赖包

可以看到，这是典型的两个spring应用通过RestTemplate进行访问的方式，哪在HTTP请求中注入追踪信息并把相关信息发送到Zipkin Server呢？答案在两个应用所加载的JAR包里。

本示例采用gradle来构建应用，在build.gradle中加载了sleuth和zipkin相关的JAR包：

dependencies {
    compile('org.springframework.cloud:spring-cloud-starter-sleuth')
    compile('org.springframework.cloud:spring-cloud-sleuth-zipkin')
    testCompile('org.springframework.boot:spring-boot-starter-test')
}
Spring应用在监测到Java依赖包中有sleuth和zipkin后，会自动在RestTemplate的调用过程中向HTTP请求注入追踪信息，并向Zipkin Server发送这些信息。

哪么Zipkin Server的地址又是在哪里指定的呢？答案是在application.properties中：

spring.zipkin.base-url=http://zipkin-server:9411
注意Zipkin Server的地址为zipkin-server。

构建Docker镜像

为这两个服务创建相同的Dockerfile，用于生成Docker镜像：

FROM java:8-jre-alpine
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/' /etc/apk/repositories
VOLUME /tmp
ADD build/libs/*.jar app.jar
RUN sh -c 'touch /app.jar'
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
构建容器镜像的步骤如下：

cd tracedemo
./gradlew build
docker build -t zipkin-demo-frontend .

cd ../tracebackend
./gradlew build
docker build -t zipkin-demo-backend .
构建镜像完成后用docker push命令上传到你的镜像仓库。

Zipkin Server

利用Annotation声明方式创建Zipkin

在build.gradle中引入Zipkin依赖包。

dependencies {
    compile('org.springframework.boot:spring-boot-starter')
    compile('io.zipkin.java:zipkin-server')
    runtime('io.zipkin.java:zipkin-autoconfigure-ui')
    testCompile('org.springframework.boot:spring-boot-starter-test')
}
在主程序Class增加一个注解@EnableZipkinServer

```java
@SpringBootApplication
@EnableZipkinServer
public class ZipkinApplication {

    public static void main(String[] args) {
        SpringApplication.run(ZipkinApplication.class, args);
    }
}
```
在application.properties将端口指定为9411。

server.port=9411
构建Docker镜像

Dockerfile和前面的两个服务一样，这里就不重复了。

在阿里云容器服务上部署

创建docker-compose.yml文件，内容如下：

```yml
version: "2"
services:
  zipkin-server:
    image: registry.cn-hangzhou.aliyuncs.com/jingshanlb/zipkin-demo-server
    labels:
      aliyun.routing.port_9411: http://zipkin
    restart: always

  frontend:
    image: registry.cn-hangzhou.aliyuncs.com/jingshanlb/zipkin-demo-frontend
    labels:
      aliyun.routing.port_8080: http://frontend
    links:
      - zipkin-server
      - backend
    restart: always

  backend:
    image: registry.cn-hangzhou.aliyuncs.com/jingshanlb/zipkin-demo-backend
    links:
      - zipkin-server
    restart: always
```
在阿里云容器服务上使用编排模版创建应用，访问zipkin端点，可以看到服务分析的效果。

访问前端应用3次，页面显示3次服务调用。

trace1

点击其中任意一个trace，可以看到请求链路上不同span所花费的时间。

trace2

进入Dependencies页面，还可以看到服务之间的依赖关系。

trace3

从这个过程可以看出，Zipkin和Spring Cloud的集成做得很好。而且对服务追踪分析的可视化也很直观。

注意的是，在生产环境中还需要为Zipkin配置数据库，这里就不详细介绍了。

本文的示例代码在此：https://github.com/binblee/zipkin-demo

小节

本文简单介绍了如何利用Zipkin对SpringCloud应用进行服务分析。在实际的应用场景中，Zipkin可以结合压力测试工具一起使用，分析系统在大压力下的可用性和性能。这部分内容未来会在DevOps系列中继续介绍。