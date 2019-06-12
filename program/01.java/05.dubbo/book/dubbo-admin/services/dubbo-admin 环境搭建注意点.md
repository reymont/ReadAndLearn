

dubbo-admin 环境搭建注意点 - CSDN博客 
http://blog.csdn.net/gehaixia/article/details/50468362


dubbo-admin 环境搭建注意点
github 源码： https://github.com/alibaba/dubbo.git
下载到Eclipse 后，重新用Maven工程载入。

修改pom文件：
1、webx的依赖改为3.1.6版；

    <dependency>
        <groupId>com.alibaba.citrus</groupId>
        <artifactId>citrus-webx-all</artifactId>
        <version>3.1.6</version>
    </dependency>
2、添加velocity的依赖，我用了1.7；

    <dependency>
        <groupId>org.apache.velocity</groupId>
        <artifactId>velocity</artifactId>
        <version>1.7</version>
    </dependency>
3、对依赖项dubbo添加exclusion，避免引入旧spring

    <dependency>
        <groupId>com.alibaba</groupId>
        <artifactId>dubbo</artifactId>
        <version>${project.parent.version}</version>
        <exclusions>
            <exclusion>
                <groupId>org.springframework</groupId>
                <artifactId>spring</artifactId>
            </exclusion>
        </exclusions>
    </dependency>
4、webx已有spring 3以上的依赖，因此注释掉dubbo-admin里面的spring依赖

    <!--<dependency>-->
        <!--<groupId>org.springframework</groupId>-->
        <!--<artifactId>spring</artifactId>-->
    <!--</dependency>-->
确定war包解压后lib目录没有spring 3 以下的依赖就行。
下载zookeeper :http://apache.fayea.com/zookeeper/stable/zookeeper-3.4.6.tar.gz
修改 conf下的zoo_sample.cfg 为zoon.cfg并修改里面的数据存储位置。
用tomcat发布dubbo-admin 并修改 WEB-INF下的dubbo.properties 
dubbo.registry.address=zookeeper://127.0.0.1:2181 地址和端口修改为对应的zookeeper
访问dubbo-admin:
