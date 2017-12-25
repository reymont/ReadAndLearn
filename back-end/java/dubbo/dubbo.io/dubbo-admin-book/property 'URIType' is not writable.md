

* 2.5.4-SNAPSHOT dubbo admin error · Issue #50 · alibaba/dubbo 
  https://github.com/alibaba/dubbo/issues/50
* dubbo-admin在jdk 1.8上部署出错问题 - 涂墨留香 - 博客园 
  http://www.cnblogs.com/BensonHe/p/4135768.html

原因之前找到了，是因为用了jdk8

我使用的是JDK 1.8.0_05, dubbo-admin版本是2.5.4-SNAPSHOT，也遇到了一样的问题。解决方案如@ddatsh ：

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
确定war包解压后lib目录没有spring 3 以下的依赖就行。然后运行正常了。