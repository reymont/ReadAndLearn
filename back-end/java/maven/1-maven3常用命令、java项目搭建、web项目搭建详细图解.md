maven3常用命令、java项目搭建、web项目搭建详细图解 - CSDN博客 http://blog.csdn.net/edward0830ly/article/details/8748986

------------------------------maven3常用命令---------------------------

1、常用命令

　　　　1）创建一个Project

 

mvn archetype:generate -DgroupId=com.mycompany.app -DartifactId=my-app -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
 

　　mvn archetype:generate　　固定格式

　　-DgroupId　　　　　　　　　组织标识（包名）

　　-DartifactId　　　　　　　　项目名称

　　-DarchetypeArtifactId　　  指定ArchetypeId，maven-archetype-quickstart，创建一个Java Project；maven-archetype-webapp，创建一个Web Project

　　-DinteractiveMode　　　　　　是否使用交互模式

　　　　2）编译源代码

mvn compile
 　　　3）编译测试代码

mvn test-compile
 　　　4）清空

mvn clean
 　　　5）运行测试

mvn test
 　　　6）生产站点目录并打包

mvn site-deploy
 　　　7）安装当前工程的输出文件到本地仓库

mvn install
 　　　8）打包

mvn package
 　　　9）先清除再打包

mvn clean package
 　　　10）打成jar包

mvn jar:jar
　　　 11）生成eclipse项目　　

mvn eclipse:eclipse
　　　 12）查看帮助信息

mvn help:help
　　　13）查看maven有哪些项目类型分类

mvn archetype:generate -DarchetypeCatalog=intrenal
 

 

　　2、标准的Maven项目结构　　                                       

　　　　　　　　　　　　　　　　　　　　

　　　　src/main/java　　存放项目的源代码

　　　　src/test/java　　存放测试源代码

　　　　如果要存放一些配置文件，可以再建立一个目录src/main/resource存放，如存放log4j.properties等





------------------------------java项目搭建---------------------------

使用Maven构建一个简单的Java项目

　　1、进入命令行，执行下面的语句。

mvn archetype:generate -DgroupId=cn.luxh.app -DartifactId=my-app -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
　　执行完成后，可以看到如下结果：



　　BUILD SUCCESS，当在前用户目录下（即C:\Documents and Settings\Administrator）下构建了一个Java Project叫做my-app。

　　2、进入my-app目录，可以看到有一个pom.xml文件，这个文件是Maven的核心。

　　　　1）pom意思就是project object model。

　　　　2）pom.xml包含了项目构建的信息，包括项目的信息、项目的依赖等。

　　　　3）pom.xml文件是可以继承的，大型项目中，子模块的pom.xml一般都会继承于父模块的pom.xml

　　　　4）刚构建的pom.xml说明

复制代码
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>cn.luxh.app</groupId>
  <artifactId>my-app</artifactId>
  <packaging>jar</packaging>
  <version>1.0-SNAPSHOT</version>
  <name>my-app</name>
  <url>http://maven.apache.org</url>
  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>3.8.1</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
</project>
复制代码
 　　　　节点元素说明：　　　　

复制代码
       <project>　　　　　　pom文件的顶级节点

　　　　<modelVersion>　　　object model版本，对Maven2和Maven3来说，只能是4.0.0　

　　　　<groupId>　　　　　　项目创建组织的标识符，一般是域名的倒写

　　　　<artifactId>　　　　定义了项目在所属组织的标识符下的唯一标识，一个组织下可以有多个项目

　　　　<packaging>　　　　  打包的方式，有jar、war、ear等

　　　　<version>　　　　　  当前项目的版本，SNAPSHOT，表示是快照版本，在开发中

　　　　<name>　　　　　　　 项目的名称

　　　　<url>　　　　　　　　项目的地址

　　　　<dependencies>　　 构建项目依赖的jar

　　　　<description>　　　　项目的描述
复制代码
 　　　　其中由groupId、artifactId和version唯一的确定了一个项目坐标

　　3、构建的my-app项目结构如下

　　　　　　　　　　　　　　　　　　　　

　　　　1）编译源程序，进入命令行，切换到my-app目录，执行命令：mvn clean compile

 



 

　　　　编译成功，在my-app目录下多出一个target目录，target\classes里面存放的就是编译后的class文件。

　　　　2）测试，进入命令行，切换到my-app目录，执行命令：mvc clean test

 



 

　　　　测试成功，在my-app\target目录下会有一个test-classes目录，存放的就是测试代码的class文件。

　　　　3）打包，进入命令行，切换到my-app目录，执行命令：mvc clean package，执行打包命令前，会先执行编译和测试命令

 



　　　　构建成功后，会再target目录下生成my-app-1.0-SNAPSHOT.jar包。

　　　　4）安装，进入命令行，切换到my-app目录，执行命令：mvc clean install ，执行安装命令前，会先执行编译、测试、打包命令

 



 

 　　构建成功，就会将项目的jar包安装到本地仓库。

　　　　5）运行jar包，进入命令行，切换到my-app目录，执行命令：java -cp target\my-app-1.0-SNAPSHOT.jar cn.luxh.app.App

 






------------------------------web项目搭建---------------------------


1、进入命令行，执行：

mvn archetype:generate -DgroupId=cn.luxh.app -DartifactId=my-web-app -DarchetypeArtifactId=maven-archetype-webapp -DinteractivMode=false
　　出现一些版本号确认等直接回车就行，构建成功出现下面的提示。



　　在当前用户目录下，生成的web项目目录结构如下：

　　　　　　　　　　　　　　　　　　　　　　　　

　　2、当然这个空的项目，只有一个index.jsp页面，打包发布运行。

　　　　1）在命令行切换到my-web-app目录，执行：mvn package，构建成功后，my-web-app目录下多了一个target目录，在这个目录下会打包成my-web-app.war，把这个war包拷贝到Tomcat的发布目录下就可以运行了。　



　　　　2）集成Jetty发布运行，需要配置pom.xml。

复制代码
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>cn.luxh.app</groupId>
  <artifactId>my-web-app</artifactId>
  <packaging>war</packaging><!--web项目默认打包方式 war-->
  <version>1.0-SNAPSHOT</version>
  <name>my-web-app Maven Webapp</name>
  <url>http://maven.apache.org</url>
  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>3.8.1</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
  <build>
    <finalName>my-web-app</finalName>
    
    <pluginManagement>
    <!--配置Jetty-->
      <plugins>
        <plugin>
         <groupId>org.mortbay.jetty</groupId>   
         <artifactId>maven-jetty-plugin</artifactId>
        </plugin>
      </plugins>
</pluginManagement>

    
  </build>
  
</project>
复制代码
　　　　然后执行：mvn jetty:run 就可以在8080端口上访问应用了。