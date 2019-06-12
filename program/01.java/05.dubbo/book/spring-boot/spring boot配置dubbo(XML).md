spring boot配置dubbo(XML) - CSDN博客
 http://blog.csdn.net/wohaqiyi/article/details/73159261

上一篇写的是spring boot在自己的properties配置文件中简单配置dubbo的步骤，那种配置有很多的功能（比如超时时间、是否检查）等等，配置起来也挺麻烦的，而我们也习惯传统的那种XML形式的dubbo配置。

这一篇写的是spring boot与传统的dubbo xml文件的结合。

一、dubbo发布方配置

1、首先引入依赖，但是这些依赖就不是上一篇的那个spring boot dubbo的依赖，而是dubbo自己的那几个依赖，引错了，会发布不成功的，我是配置的如下：

 <!--  如果dubbo的配置来自于单独的xml文件，不是来自于spring boot的application配置文件
                  那么，导入dubbo相关包，必须单独导入，不能用spring boot和dubbo的jar包-->
<dependency>
    <groupId>org.apache.zookeeper</groupId>
    <artifactId>zookeeper</artifactId>
    <version>3.4.8</version>
    <exclusions>
    <!--如果你用的logback日志，该包会引起jar包冲突-->
        <exclusion>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-log4j12</artifactId>
        </exclusion>
    </exclusions>
</dependency>
<dependency>
    <groupId>com.101tec</groupId>
    <artifactId>zkclient</artifactId>
    <version>0.3</version>
</dependency>
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>dubbo</artifactId>
    <version>2.5.3</version>
    <exclusions>
        <exclusion>
            <groupId>org.springframework</groupId>
            <artifactId>spring</artifactId>
        </exclusion>
    </exclusions>
</dependency>
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
2.然后在src/main/resources下，添加一个dubbo provider的配置文件dubbo-provider.xml （名字随便起），内容如下:

  <!-- 提供方应用名称信息，这个相当于起一个名字，我们dubbo管理页面比较清晰是哪个应用暴露出来的 -->
    <dubbo:application name="dubbo-provider-qssj"/>
    <!-- 使用zookeeper注册中心暴露服务地址 -->
<dubbo:registry protocol="zookeeper" address="192.168.1.160:2181" />
<dubbo:protocol name="dubbo" port="31001" />

<dubbo:service interface="test.spring.dubboService.TestDubboService" ref="testDubboService" timeout="1800000" version="1.0.0.1"/>
    <bean id="testDubboService" class="test.spring.dubboService.impl.TestDubboServiceImpl"/>
1
2
3
4
5
6
7
8
  以上内容与传统的dubbo xml配置文件没什么区别，可以从网上搜到。

3.然后也是需要在发布接口的实现类上加@Service 注解，但是这个注解就变成了org.springframework.stereotype.Service 。具体如下。

package test.spring.dubboService.impl;
import org.springframework.stereotype.Service;
import test.spring.dubboService.TestDubboService;
@Service
public class TestDubboServiceImpl implements TestDubboService {
    @Override
    public String getName(String name) {
        // TODO Auto-generated method stub
        return "姓名："+name;
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
4.最后启动类引入以下该dubbo-provider.xml 文件，如下：

package test.spring;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ImportResource;
@SpringBootApplication //spring boot启动必须引入的注解
@ImportResource({"classpath:dubbo-provider.xml"}) 
public class SpringBootTest {
    public static void main(String[] args) {
      SpringApplication.run(SpringBootTest.class, args);
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
5.最后运行启动类，就会在dubbo上看到该发布的接口。

这里写图片描述

6.发布方的最终项目结构如下：

这里写图片描述 
  结构与上一篇那种springboot 的properties配置dubbo没什么区别。

二、调用方项目配置

1、依然是先引入依赖，与上边发布方的依赖是一样的。

2、然后在src/main/resources下添加一个dubbo-consumer.xml 配置文件，内容如下：

<!-- 消费方应用名，用于计算依赖关系，不是匹配条件，不要与提供方一样 -->
<dubbo:application name="dubbo-consumer-qssj" />
<dubbo:consumer timeout="1800000" retries="0" />
<dubbo:registry protocol="zookeeper" address="192.168.1.160:2181" />
<dubbo:reference id="testDubboService" interface="test.spring.dubboService.TestDubboService" check="false"  version="1.0.0.1"/>
1
2
3
4
5
3.然后复制一份test.spring.dubboService.TestDubboService 接口放到消费者这边，如下：

这里写图片描述

  多说一句，用这种方式配置，controller的位置不需要比调用的dubbo接口位置低。

4.调用的地方加入@Autowired 注解，如下：

package test.spring.dubboService.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import test.spring.dubboService.TestDubboService;
@RestController
public class TestController {
    @Autowired
    TestDubboService testDubboService;
    @RequestMapping(value="abc/akf",method=RequestMethod.GET)
    public String abc(String name){  
        return testDubboService.getName(name);
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
5.在启动类引入dubbo-consumer.xml ，具体如下：

package test.spring;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ImportResource;

@SpringBootApplication //spring boot启动必须引入的注解
@ImportResource({"classpath:dubbo-consumer.xml"}) 
public class SpringBootTest {
    public static void main(String[] args) {
      SpringApplication.run(SpringBootTest.class, args);
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
6.运行启动类，访问controller，则看到调用成功。

这里写图片描述

下一篇说下spring boot配置dubbo注意的问题。