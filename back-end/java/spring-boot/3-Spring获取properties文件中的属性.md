Spring获取properties文件中的属性 - CSDN博客 http://blog.csdn.net/wlfighter/article/details/52563605

1.前言

本文主要是对这两篇blog的整理，感谢作者的分享 
Spring使用程序方式读取properties文件 
Spring通过@Value注解注入属性的几种方式

2.配置文件

application.properties

socket.time.out=1000
1
3.使用spring代码直接载入配置文件，获取属性信息

代码如下：

Resource resource = new ClassPathResource("/application.properties");
Properties props = PropertiesLoaderUtils.loadProperties(resource);
1
2
4.使用@Value注解获取属性

4.1 使用PropertyPlaceholderConfigurer

spring配置

<bean class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
    <property name="location" value="classpath:application.properties" />
</bean>
1
2
3
代码

@Value("${socket.time.out}")
int socketTimeout;
1
2
4.2 使用PropertiesFactoryBean

Spring配置

<bean id="application" class="org.springframework.beans.factory.config.PropertiesFactoryBean">
    <property name="location" value="classpath:application.properties" />
</bean>
1
2
3
代码

@Value("#{$application['socket.time.out']}")
int socketTimeOut;
1
2
4.3 备注：

如果将代码部署到resin容器，使用4.1的方法,在程序启动时，总是报无法将”${socket.time.out}”转换成整数的错误。这说明程序并没有找到对应的配置属性。但是在进行单元测试的使用使用ApplicationContext时，则能够找到对应的属性。这可能是在容器里面使用的是WebApplicationContext的问题吧。目前还没有找到确切的原因，现在这里mark一下。 
使用4.2的方式，部署之后能够获取对应的属性值。