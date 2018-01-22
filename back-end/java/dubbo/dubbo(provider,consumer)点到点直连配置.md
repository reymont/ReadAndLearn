
dubbo(provider,consumer)点到点直连配置 - CSDN博客 http://blog.csdn.net/nauwzj/article/details/18708033

1.服务端接口配置（providr样例）applicationContext-dubbo-smk.xml：

<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
    xmlns="http://www.springframework.org/schema/beans"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
 http://www.springframework.org/schema/beans/spring-beans.xsd
 http://code.alibabatech.com/schema/dubbo
 http://code.alibabatech.com/schema/dubbo/dubbo.xsd" >

    <!-- 声明需要暴露的服务接口,直连时，token=true要去掉，会有不安全因素，但直连一般用于内部使用，安全问题可以暂忽略 -->
     <dubbo:service interface="com.xxx.SmkService" ref="smkService"  version="1.0"/>

</beans>

2.服务端注册配置：

<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
 xsi:schemaLocation="http://www.springframework.org/schema/beans
 http://www.springframework.org/schema/beans/spring-beans.xsd
 http://code.alibabatech.com/schema/dubbo
 http://code.alibabatech.com/schema/dubbo/dubbo.xsd">      
 <!-- 提供方应用信息，用于计算依赖关系 -->
 <dubbo:application name="xxcommon"></dubbo:application>
  <!-- dubbo接口去除注册中心，采用直连的方式  -->
    <dubbo:registry address="N/A" /> 
    <!-- 使用multicast广播注册中心暴露发现服务地址 -->
   <!--   <dubbo:registry address="multicast://xxx.5x.x.x:1234?unicast=false" />-->
 <!--dubbo集群开发，请激活下面条目，并注销上面的多播multicast -->
 <!--<dubbo:registry protocol="zookeeper" address="xx.xx.xx.xx:2181,xx.xx.xx.68:2181" />-->
 <!-- 用dubbo协议在20880端口暴露服务 -->
 <dubbo:protocol name="dubbo" port="20880" ></dubbo:protocol>
<!--   <dubbo:service interface="com.xxDownloadService" version="1.0" ref="downloadService" />
 <dubbo:service interface="com.xx.UploadService" version="1.0" ref="uploadService" />-->
</beans>

3.dubbo客户端配置(consumer）

<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
    xmlns="http://www.springframework.org/schema/beans"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
 http://www.springframework.org/schema/beans/spring-beans.xsd
 http://code.alibabatech.com/schema/dubbo
 http://code.alibabatech.com/schema/dubbo/dubbo.xsd" >

    <!-- 消费方应用名，用于计算依赖关系，不是匹配条件，不要与提供方一样 -->

    <dubbo:application name="consumer-of-znmhcommon" />
    <!-- dubbo接口去除注册中心，采用直连的方式  -->
  <!--  <dubbo:registry address="N/A" ></dubbo:registry> -->  
    <!-- 使用multicast广播注册中心暴露发现服务地址 -->
   <!--   <dubbo:registry address="multicast://224.5.6.7:1234?unicast=false" />-->
   <!--<dubbo:registry protocol="zookeeper" address="xx.xx.xx.xx:2181,xx.xx.xx.xx:2181" />-->
   
    <!-- 生成远程服务代理，可以和本地bean一样使用 -->

    <dubbo:consumer timeout="30000" >
    </dubbo:consumer>
 <dubbo:reference 
        id="demoService" 
        interface="com.xx.DemoService"
        url="dubbo://127.0.0.1:20880/com.xx.DemoService"
        version="1.0" />
 
  <dubbo:reference
        id="smkService"
        interface="com.xx.SmkService"
        url="dubbo://xx:20880/com.xx.SmkService"
        version="1.0" />   
</beans>