

* [使用Spring Cloud构建统一配置中心 - 简书 ](http://www.jianshu.com/p/69dea19abf04)

* Spring Cloud Config
  * Spring Cloud Config项目是一个解决分布式系统的配置管理方案。它包含了Client和Server两个部分

config server的resource目录下的application.properties:
```sh
server.port=8888
#指的项目配置仓库的位置，可以是：git文件夹、svn文件夹或者github项目位置
spring.cloud.config.server.git.uri=file://Users/whthomas/config-repo

spring.application.name=configserver
spring.cloud.config.uri=http://localhost:8888
```
启动项目的代码：
```java
@SpringBootApplication
@EnableConfigServer
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
```
多了一个`@EnableConfigServer`注解。

* 环境资源的命名规则由以下的三个参数确定：
  * {application}映射到Config客户端的spring.application.name属性
  * {profile}映射到Config客户端的spring.profiles.active属性，可以用来区分环境，比如dev，test，produce等等
  * {label}映射到Git服务器的commit id,分支名称或者tag，默认值为master
  * 仓库中的配置文件会被转换成web接口，访问可以参照以下的规则：

```
/{application}/{profile}[/{label}]
/{application}-{profile}.yml
/{label}/{application}-{profile}.yml
/{application}-{profile}.properties
/{label}/{application}-{profile}.properties
```


百度开源的disconf（https://github.com/knightliao/disconf ）还是目前比较理想的配置中心方案
