maven 编译命令 2012/10/11

从别处拷贝来的maven项目，有时候会出现不能debug关联的情况，即按住ctrl键后不能跳转到相应的类或方法，这是需要eclipse环境生成 Eclipse 项目文件的。
        可以在cmd命令窗口下进入到maven项目包含pom.xml文件的目录下，运行 mvn eclipse:eclipse 命令即可，如果还不行，可使用mvn compile ：编译源代码 命令。
--------------------------------------------------------------------------------------------------------------------------------
下面是一些maven的常用命令：
Maven2 的运行命令为 ： mvn ，
常用命令为 ：
             mvn archetype:create ：创建 Maven 项目
             mvn compile ：编译源代码
             mvn test-compile ：编译测试代码
             mvn test ： 运行应用程序中的单元测试
             mvn site ： 生成项目相关信息的网站
             mvn clean ：清除目标目录中的生成结果
             mvn package ： 依据项目生成 jar 文件
             mvn install ：在本地 Repository 中安装 jar
             mvn eclipse:eclipse ：生成 Eclipse 项目文件
生成项目
             建一个 JAVA 项目 ： mvn archetype:create -DgroupId=com.demo -DartifactId=App
          建一个 web 项目 ： mvn archetype:create -DgroupId=com.demo -DartifactId=web-app -DarchetypeArtifactId=maven-archetype-webapp
 
生成 Eclipse 项目
普通 Eclipse 项目执行 ： mvn eclipse:eclipse
           Eclipse WTP 项目执行 ： mvn eclipse:eclipse –Dwtpversion=1.0
