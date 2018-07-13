

Hystrix的使用（一） - CSDN博客
 http://blog.csdn.net/findmyself_for_world/article/details/54377980

（一）下载网址
https://github.com/kennedyoliveira/standalone-hystrix-dashboard


注意：第一次使用的时候下载的一致有问题，后来详细阅读网址中的文章，一步一步的才正确下载使用。
所以一定要阅读原始文章，并且按照文档操作！

下载后，随便放在一个地方，执行语句：
java -jar standalone-hystrix-dashboard-{VERSION}-all.jar

就可以使用了(但是有个问题，每次都要执行一遍，才能调用接口查看)
http://localhost:7979/hystrix-dashboard/



下面是别人的阳历，主要是我这边是在不知道怎么上传图片


一、hystrixdashboard

作用：

监控各个hystrixcommand的各种值。
通过dashboards的实时监控来动态修改配置，直到满意为止
仪表盘：



 

二、启动hystrix

1、下载standalone-hystrix-dashboard-1.5.3-all.jar

https://github.com/kennedyoliveira/standalone-hystrix-dashboard:该页面提供了一个很好的视频教学。
2、启动hystrix-dashboard

java -jar -DserverPort=7979 -DbindAddress=localhost standalone-hystrix-dashboard-1.5.3-all.jar
注意：其中的serverPort、bindAddress是可选参数，若不添加，默认是7979和localhost
3、测试

浏览器输入http://localhost:7979/hystrix-dashboard/，出现小熊页面就是正确了。
 

三、代码

1、pom.xml

复制代码
 1         <dependency>
 2             <groupId>com.netflix.hystrix</groupId>
 3             <artifactId>hystrix-core</artifactId>
 4             <version>1.4.10</version>
 5         </dependency>
 6         <!-- http://mvnrepository.com/artifact/com.netflix.hystrix/hystrix-metrics-event-stream -->
 7         <dependency>
 8             <groupId>com.netflix.hystrix</groupId>
 9             <artifactId>hystrix-metrics-event-stream</artifactId>
10             <version>1.4.10</version>
11         </dependency>
复制代码
说明：

hystrix-core：hystrix核心接口包
hystrix-metrics-event-stream：只要客户端连接还连着，hystrix-metrics-event-stream就会不断的向客户端以text/event-stream的形式推送计数结果（metrics）
2、配置HystrixMetricsStreamServlet

复制代码
 1 package com.xxx.firstboot.hystrix.dashboard;
 2 
 3 import org.springframework.boot.context.embedded.ServletRegistrationBean;
 4 import org.springframework.context.annotation.Bean;
 5 import org.springframework.context.annotation.Configuration;
 6 
 7 import com.netflix.hystrix.contrib.metrics.eventstream.HystrixMetricsStreamServlet;
 8 
 9 @Configuration
10 public class HystrixConfig {
11 
12     @Bean
13     public HystrixMetricsStreamServlet hystrixMetricsStreamServlet(){
14         return new HystrixMetricsStreamServlet();
15     }
16     
17     @Bean
18     public ServletRegistrationBean registration(HystrixMetricsStreamServlet servlet){
19         ServletRegistrationBean registrationBean = new ServletRegistrationBean();
20         registrationBean.setServlet(servlet);
21         registrationBean.setEnabled(true);//是否启用该registrationBean
22         registrationBean.addUrlMappings("/hystrix.stream");
23         return registrationBean;
24     }
25 }
复制代码
说明：以上方式是springboot注入servlet并进行配置的方式。

参考：第二十四章 springboot注入servlet