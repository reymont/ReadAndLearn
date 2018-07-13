

Registry Reference - Dubbo - Alibaba Open Sesame 
http://dubbo.wangxingrong.com/Registry+Reference.htm

Registry Reference
(+) (#)

	推荐使用Zookeeper注册中心
Multicast Registry
(+) (#)

	不需要启动任何中心节点，只要广播地址一样，就可以互相发现
	组播受网络结构限制，只适合小规模应用或开发阶段使用。
	组播地址段: 224.0.0.0 - 239.255.255.255


提供方启动时广播自己的地址。
消费方启动时广播订阅请求。
提供方收到订阅请求时，单播自己的地址给订阅者，如果设置了unicast=false，则广播给订阅者。
消费方收到提供方地址时，连接该地址进行RPC调用。
<dubbo:registry address="multicast://224.5.6.7:1234" />
Or:

<dubbo:registry protocol="multicast" address="224.5.6.7:1234" />
为了减少广播量，Dubbo缺省使用单播发送提供者地址信息给消费者，
如果一个机器上同时启了多个消费者进程，消费者需声明unicast=false，否则只会有一个消费者能收到消息：

<dubbo:registry address="multicast://224.5.6.7:1234?unicast=false" />
Or:

<dubbo:registry protocol="multicast" address="224.5.6.7:1234">
    <dubbo:parameter key="unicast" value="false" />
</dubbo:registry>
Zookeeper Registry
(+) (#)

	建议使用dubbo-2.3.3以上版本的zookeeper注册中心客户端
	Zookeeper说明
Zookeeper是Apacahe Hadoop的子项目，是一个树型的目录服务，支持变更推送，适合作为Dubbo服务的注册中心，工业强度较高，可用于生产环境，并推荐使用，参见：http://zookeeper.apache.org
	Zookeeper安装
安装方式参见: Zookeeper安装手册，只需搭一个原生的Zookeeper服务器，并将Quick Start中Provider和Consumer里的conf/dubbo.properties中的dubbo.registry.addrss的值改为zookeeper://127.0.0.1:2181即可使用
	可靠性声明
阿里内部并没有采用Zookeeper做为注册中心，而是使用自己实现的基于数据库的注册中心，即：Zookeeper注册中心并没有在阿里内部长时间运行的可靠性保障，此Zookeeper桥接实现只为开源版本提供，其可靠性依赖于Zookeeper本身的可靠性。
	兼容性声明
因2.0.8最初设计的zookeeper存储结构不能扩充不同类型的数据，2.0.9版本做了调整，所以不兼容，需全部改用2.0.9版本才行，以后的版本会保持兼容2.0.9。
2.2.0版本改为基于zkclient实现，需增加zkclient的依赖包，2.3.0版本增加了基于curator的实现，作为可选实现策略。


流程说明：

服务提供者启动时
向/dubbo/com.foo.BarService/providers目录下写入自己的URL地址。
服务消费者启动时
订阅/dubbo/com.foo.BarService/providers目录下的提供者URL地址。
并向/dubbo/com.foo.BarService/consumers目录下写入自己的URL地址。
监控中心启动时
订阅/dubbo/com.foo.BarService目录下的所有提供者和消费者URL地址。
支持以下功能：

当提供者出现断电等异常停机时，注册中心能自动删除提供者信息。
当注册中心重启时，能自动恢复注册数据，以及订阅请求。
当会话过期时，能自动恢复注册数据，以及订阅请求。
当设置<dubbo:registry check="false" />时，记录失败注册和订阅请求，后台定时重试。
可通过<dubbo:registry username="admin" password="1234" />设置zookeeper登录信息。
可通过<dubbo:registry group="dubbo" />设置zookeeper的根节点，缺省为dubbo。
支持*号通配符<dubbo:reference group="*" version="*" />，可订阅服务的所有分组和所有版本的提供者。
在provider和consumer中增加zookeeper客户端jar包依赖：

<dependency>
    <groupId>org.apache.zookeeper</groupId>
    <artifactId>zookeeper</artifactId>
    <version>3.3.3</version>
</dependency>
或直接下载：http://repo1.maven.org/maven2/org/apache/zookeeper/zookeeper

支持zkclient和curator两种Zookeeper客户端实现：

ZKClient Zookeeper Registry
从2.2.0版本开始缺省为zkclient实现，以提升zookeeper客户端的健状性。

	ZKClient是Datameer开源的一个Zookeeper客户端实现，开源比较早，参见：https://github.com/sgroschupf/zkclient
缺省配置：

<dubbo:registry ... client="zkclient" />
或：

dubbo.registry.client=zkclient
或：

zookeeper://10.20.153.10:2181?client=zkclient
需依赖：

<dependency>
    <groupId>com.github.sgroschupf</groupId>
    <artifactId>zkclient</artifactId>
    <version>0.1</version>
</dependency>
或直接下载：http://repo1.maven.org/maven2/com/github/sgroschupf/zkclient

Curator Zookeeper Registry
从2.3.0版本开始支持可选curator实现。

	Curator是Netflix开源的一个Zookeeper客户端实现，比较活跃，参见：https://github.com/Netflix/curator
如果需要改为curator实现，请配置：

<dubbo:registry ... client="curator" />
或：

dubbo.registry.client=curator
或：

zookeeper://10.20.153.10:2181?client=curator
需依赖：

<dependency>
    <groupId>com.netflix.curator</groupId>
    <artifactId>curator-framework</artifactId>
    <version>1.1.10</version>
</dependency>
或直接下载：http://repo1.maven.org/maven2/com/netflix/curator/curator-framework

Zookeeper单机配置:

<dubbo:registry address="zookeeper://10.20.153.10:2181" />
Or:

<dubbo:registry protocol="zookeeper" address="10.20.153.10:2181" />
Zookeeper集群配置:

<dubbo:registry address="zookeeper://10.20.153.10:2181?backup=10.20.153.11:2181,10.20.153.12:2181" />
Or:

<dubbo:registry protocol="zookeeper" address="10.20.153.10:2181,10.20.153.11:2181,10.20.153.12:2181" />
同一Zookeeper，分成多组注册中心:

<dubbo:registry id="chinaRegistry" protocol="zookeeper" address="10.20.153.10:2181" group="china" />
<dubbo:registry id="intlRegistry" protocol="zookeeper" address="10.20.153.10:2181" group="intl" />
Redis Registry
(+) (#)

	Redis说明
Redis是一个高效的KV存储服务器，参见：http://redis.io
	Redis安装
安装方式参见: Redis安装手册，只需搭一个原生的Redis服务器，并将Quick Start中Provider和Consumer里的conf/dubbo.properties中的dubbo.registry.addrss的值改为redis://127.0.0.1:6379即可使用
	Redis过期数据
通过心跳的方式检测脏数据，服务器时间必须相同，并且对服务器有一定压力。
	可靠性声明
阿里内部并没有采用Redis做为注册中心，而是使用自己实现的基于数据库的注册中心，即：Redis注册中心并没有在阿里内部长时间运行的可靠性保障，此Redis桥接实现只为开源版本提供，其可靠性依赖于Redis本身的可靠性。
	从2.1.0版本开始支持


数据结构：

使用Redis的Key/Map结构存储数据。
主Key为服务名和类型。
Map中的Key为URL地址。
Map中的Value为过期时间，用于判断脏数据，脏数据由监控中心删除。(注意：服务器时间必需同步，否则过期检测会不准确)
使用Redis的Publish/Subscribe事件通知数据变更。
通过事件的值区分事件类型：register, unregister, subscribe, unsubscribe。
普通消费者直接订阅指定服务提供者的Key，只会收到指定服务的register, unregister事件。
监控中心通过psubscribe功能订阅/dubbo/*，会收到所有服务的所有变更事件。
调用过程：

服务提供方启动时，向Key:/dubbo/com.foo.BarService/providers下，添加当前提供者的地址。
并向Channel:/dubbo/com.foo.BarService/providers发送register事件。
服务消费方启动时，从Channel:/dubbo/com.foo.BarService/providers订阅register和unregister事件。
并向Key:/dubbo/com.foo.BarService/providers下，添加当前消费者的地址。
服务消费方收到register和unregister事件后，从Key:/dubbo/com.foo.BarService/providers下获取提供者地址列表。
服务监控中心启动时，从Channel:/dubbo/*订阅register和unregister，以及subscribe和unsubsribe事件。
服务监控中心收到register和unregister事件后，从Key:/dubbo/com.foo.BarService/providers下获取提供者地址列表。
服务监控中心收到subscribe和unsubsribe事件后，从Key:/dubbo/com.foo.BarService/consumers下获取消费者地址列表。
选项：

可通过<dubbo:registry group="dubbo" />设置redis中key的前缀，缺省为dubbo。
可通过<dubbo:registry cluster="replicate" />设置redis集群策略，缺省为failover。
failover: 只写入和读取任意一台，失败时重试另一台，需要服务器端自行配置数据同步。
replicate: 在客户端同时写入所有服务器，只读取单台，服务器端不需要同步，注册中心集群增大，性能压力也会更大。
Config redis registry:

<dubbo:registry address="redis://10.20.153.10:6379" />
Or:

<dubbo:registry address="redis://10.20.153.10:6379?backup=10.20.153.11:6379,10.20.153.12:6379" />
Or:

<dubbo:registry protocol="redis" address="10.20.153.10:6379" />
Or:

<dubbo:registry protocol="redis" address="10.20.153.10:6379,10.20.153.11:6379,10.20.153.12:6379" />
Simple Registry
(+) (#)

	Dogfooding
注册中心本身就是一个普通的Dubbo服务，可以减少第三方依赖，使整体通讯方式一致。
	适用性说明
此SimpleRegistryService只是简单实现，不支持集群，可作为自定义注册中心的参考，但不适合直接用于生产环境。
Export simple registry service:

<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
    xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-2.5.xsdhttp://code.alibabatech.com/schema/dubbo http://code.alibabatech.com/schema/dubbo/dubbo.xsd">
     
    <!-- 当前应用信息配置 -->
    <dubbo:application name="simple-registry" />
     
    <!-- 暴露服务协议配置 -->
    <dubbo:protocol port="9090" />
     
    <!-- 暴露服务配置 -->
    <dubbo:service interface="com.alibaba.dubbo.registry.RegistryService" ref="registryService" registry="N/A" ondisconnect="disconnect" callbacks="1000">
        <dubbo:method name="subscribe"><dubbo:argument index="1" callback="true" /></dubbo:method>
        <dubbo:method name="unsubscribe"><dubbo:argument index="1" callback="false" /></dubbo:method>
    </dubbo:service>
 
    <!-- 简单注册中心实现，可自行扩展实现集群和状态同步 -->
    <bean id="registryService" class="com.alibaba.dubbo.registry.simple.SimpleRegistryService" />
     
</beans>
Reference the simple registry service:

<dubbo:registry address="127.0.0.1:9090" />
Or:

<dubbo:service interface="com.alibaba.dubbo.registry.RegistryService" group="simple" version="1.0.0" ... >
<dubbo:registry address="127.0.0.1:9090" group="simple" version="1.0.0" />
Simple Monitor
(+) (#)

1.1 Export simple monitor service to registry:

<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
    xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-2.5.xsdhttp://code.alibabatech.com/schema/dubbo http://code.alibabatech.com/schema/dubbo/dubbo.xsd">
     
    <!-- 当前应用信息配置 -->
    <dubbo:application name="simple-monitor" />
     
    <!-- 连接注册中心配置 -->
    <dubbo:registry address="127.0.0.1:9090" />
     
    <!-- 暴露服务协议配置 -->
    <dubbo:protocol port="7070" />
     
    <!-- 暴露服务配置 -->
    <dubbo:service interface="com.alibaba.dubbo.monitor.MonitorService" ref="monitorService" />
     
    <bean id="monitorService" class="com.alibaba.dubbo.monitor.simple.SimpleMonitorService" />
     
</beans>
1.2 Reference the simple monitor service from registry:

<dubbo:monitor protocol="registry" />
2.1 Export simple monitor service without registry:

<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
    xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-2.5.xsdhttp://code.alibabatech.com/schema/dubbo http://code.alibabatech.com/schema/dubbo/dubbo.xsd">
     
    <!-- 当前应用信息配置 -->
    <dubbo:application name="simple-monitor" />
     
    <!-- 暴露服务协议配置 -->
    <dubbo:protocol port="7070" />
     
    <!-- 暴露服务配置 -->
    <dubbo:service interface="com.alibaba.dubbo.monitor.MonitorService" ref="monitorService" registry="N/A" />
     
    <bean id="monitorService" class="com.alibaba.dubbo.monitor.simple.SimpleMonitorService" />
     
</beans>
2.2 Reference the simple monitor service directly:

<dubbo:monitor address="dubbo://127.0.0.1:7070/com.alibaba.dubbo.monitor.MonitorService" />
Labels:
None
5 Child Pages Reorder Pages
Add Comment