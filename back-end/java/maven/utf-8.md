


maven错误解决：编码GBK的不可映射字符 - Lave Zhang - 博客园
 http://www.cnblogs.com/lavezhang/p/5582484.html

接将项目改为UTF-8编码，无效！

要通过修改pom.xml文件，告诉maven这个项目使用UTF-8来编译。

方案一：

在pom.xml的/project/build/plugins/下的编译插件声明中加入下面的配置：<encoding>UTF-8</encoding>

即：
[html] view plaincopy

    <plugin>  
        <groupId>org.apache.maven.plugins</groupId>   
        <artifactId>maven-compiler-plugin</artifactId>  
        <version>3.1</version>  
        <configuration>  
            <source>1.7</source>  
            <target>1.7</target>  
            <encoding>UTF-8</encoding>  
        </configuration>  
    </plugin>  


方案二：

在pom.xml的/project/properties/下的属性配置中加入下面的配置：

<maven.compiler.encoding>UTF-8</maven.compiler.encoding>

即：（有第一句即可）

[html] view plaincopy

    <properties>  
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>  
        <maven.compiler.encoding>UTF-8</maven.compiler.encoding>  
    </properties> 



