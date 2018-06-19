

dubbo服务自动化测试搭建 - 佳丽 - 博客园 
http://www.cnblogs.com/anion-blogs/p/6026516.html

java实现dubbo的消费者服务编写；ruby实现消费者服务的接口测试；通过消费者间接测试dubbo服务接口的逻辑

 内容包括：dubbo服务本地调用环境搭建，dubbo服务启动，消费者部署，脚本编写测试

自动化测试框架逻辑如下图：



一、dubbo服务本地环境搭建：

zookeeper部署：

http://www.apache.org/dyn/closer.cgi/zookeeper/ 下载 直接解压；

修改配置文件：conf/zoo_sample.cfg 变更为zoo.cfg;打开文件配置需要的信息

双击bin目录下的zkServer.cmd即可启动（Windows下 ）linux 使用zkServer.sh

 

 

Dubbo-admin管理平台：

网上下载war；放到tomcatwebapps中 ；

或者下载源码编译 https://github.com/alibaba/dubbo；直接编译dubbo-admin即可：进入目录：输入命令：mvn package -Dmaven.skip.test=true 编译好后会生成war包 

tomcat的配置需要修改 端口不可被占用。Conf/Server.xml；

截图如下：

 





 

8088是访问tomcat服务的端口

Dubbo-admin项目包的中zookeeper配置需要配置成自己的zookeeper地址。

apache-tomcat-7.0.53\webapps\dubbo-admin-2.4.1\WEB-INF\dubbo.properties

 

 

配置好后，先启动zookeeper 再启动tomcat

输入网址：http://localhost:8088/dubbo-admin-2.4.1/ 即可进入。

 

 

 

 

二、dubbo服务启动

将dubbo服务放置tomcat中 配置zookeeper 然后启动（可以和dubbo-admin公用一个tomcat），这样可以在dubbo-admin管理平台看到我们注册的dubbo服务提供者

 

 

 

三、消费者部署启动（http协议的web服务）

这个消费者web服务需要开发在开发dubbo项目的时候，一起开发出来。

Web服务功能：不做任何业务处理，仅是请求dubbo里面提供的api 原封不动返回请求dubbo返回的数据；供测试部署作为dubbo服务的消费者。即dubbo服务测试的一个管道，这样可以直接用http接口测试工具测dubbo服务。（所以后续dubbo项目的测试得麻烦开发开发完成后写一个web项目（消费者）供测试调用dubbo提供者）

例如：

 

 

 

将消费者放到tomcat中，配置好zookeeper，启动就可以注册到注册中心。

 

 

消费者服务主要的配置说明：

1. 引入dubbo-api jar包，pom.xml

2.消费者spring配置文件applicationContext-consumer.xml:配置zookeeper(自己搭建的或者测试环境已有的)以及需要用到的dubbo的interface

 



 

 

 

如果用的是测试环境公用的zookeeper，interface的配置需要加上你想访问的dubbo的url地址：

 

 

3. 然后将消费者项目放到tomcat中启动，注意tomcat的端口不要被占用。(例如设置的访问端口为8089)

 

四、dubbo接口测试

1. 接口工具请求消费者获取dubbo返回的数据：

 

 

 

2. ruby脚本自动化测试dubbo：

Ruby脚本编写接口自动化，直接请求消费者服务，进行dubbo服务的功能逻辑测试。和http接口自动化测试无区别。

 

 

分类: ruby
标签: ruby接口测试, dubbo服务测试