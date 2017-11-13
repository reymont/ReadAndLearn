

Jenkin插件开发最新方式（mvn archetype:generate -Dfilter=io.jenkins.archetypes:plugin）


Jenkin插件开发最新方式（mvn archetype:generate -Dfilter=io.jenkins.archetypes:plugin） - CSDN博客 
http://blog.csdn.net/xlyrh/article/details/78366240?locationNum=4&fps=1

# 一、环境依赖

## 1.1 JDK配置

JDK版本要求在1.6以上


E:\jenkinsplugin>java -version  
java version "1.8.0_91"  
Java(TM) SE Runtime Environment (build 1.8.0_91-b15)  
Java HotSpot(TM) 64-Bit Server VM (build 25.91-b15, mixed mode)

## 1.2 Maven配置

Maven官方要求版本在3以上

E:\jenkinsplugin>mvn -version  
Apache Maven 3.2.1 (ea8b2b07643dbb1b84b6d16e1f08391b666bc1e9; 2014-02-15T01:37:5  
2+08:00)  
Maven home: D:\Atlassian\atlassian-plugin-sdk-6.2.14\apache-maven-3.2.1  
Java version: 1.8.0_91, vendor: Oracle Corporation  
Java home: C:\Program Files\Java\jdk1.8.0_91\jre  
Default locale: zh_CN, platform encoding: GBK  
OS name: "windows 7", version: "6.1", arch: "amd64", family: "dos"

## 1.3 Maven环境配置

到用户目录的.m2下修改setting.xml文件，配置Jenkins库依赖，C:\Users\Administrator\.m2\settings.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>  
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"  
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">  
  <pluginGroups>  
    <pluginGroup>org.jenkins-ci.tools</pluginGroup>  
  </pluginGroups>  
  <mirrors>  
     <mirror>  
      <id>repo.jenkins-ci.org</id>  
      <url>https://repo.jenkins-ci.org/public/</url>  
      <mirrorOf>m.g.o-public</mirrorOf>  
   </mirror>  
  </mirrors>  
  <profiles>  
      <profile>  
      <id>jenkins</id>  
      <activation>  
        <activeByDefault>true</activeByDefault> <!-- change this to false, if you don't like to have it on per default -->  
      </activation>  
      <repositories>  
        <repository>  
          <id>repo.jenkins-ci.org</id>  
          <url>https://repo.jenkins-ci.org/public/</url>  
        </repository>  
      </repositories>  
      <pluginRepositories>  
        <pluginRepository>  
          <id>repo.jenkins-ci.org</id>  
          <url>https://repo.jenkins-ci.org/public/</url>  
        </pluginRepository>  
      </pluginRepositories>  
      </profile>  
   </profiles>  
</settings>
```

# 二、插件开发

## 2.1 创建

原命令：mvn hpi:create或者mvn -U org.jenkins-ci.tools:maven-hpi-plugin:create
执行后错误信息如下：

E:\jenkinsplugin>mvn hpi:create  
[INFO] Scanning for projects...  
[INFO]  
[INFO] Using the builder org.apache.maven.lifecycle.internal.builder.singlethrea  
ded.SingleThreadedBuilder with a thread count of 1  
[INFO]  
[INFO] ------------------------------------------------------------------------  
[INFO] Building Maven Stub Project (No POM) 1  
[INFO] ------------------------------------------------------------------------  
[INFO]  
[INFO] --- maven-hpi-plugin:2.1:create (default-cli) @ standalone-pom ---  
[INFO] ------------------------------------------------------------------------  
[INFO] BUILD FAILURE  
[INFO] ------------------------------------------------------------------------  
[INFO] Total time: 2.839 s  
[INFO] Finished at: 2017-10-27T15:48:34+08:00  
[INFO] Final Memory: 17M/222M  
[INFO] ------------------------------------------------------------------------  
[ERROR] Failed to execute goal org.jenkins-ci.tools:maven-hpi-plugin:2.1:create  
(default-cli) on project standalone-pom: Unimplemented!  
[ERROR] hpi:create is obsolete. Instead use:  
[ERROR] ====  
[ERROR] mvn archetype:generate -Dfilter=io.jenkins.archetypes:  
[ERROR] ====  
[ERROR] -> [Help 1]  
[ERROR]  
[ERROR] To see the full stack trace of the errors, re-run Maven with the -e swit  
ch.  
[ERROR] Re-run Maven using the -X switch to enable full debug logging.  
[ERROR]  
[ERROR] For more information about the errors and possible solutions, please rea  
d the following articles:  
[ERROR] [Help 1] http://cwiki.apache.org/confluence/display/MAVEN/MojoExecutionE  
xception

更新后使用的最新命令如下，首次创建需要Download必须的依赖，需要一些时间
mvn archetype:generate -Dfilter=io.jenkins.archetypes:plugin


E:\>mvn archetype:generate -Dfilter=io.jenkins.archetypes:plugin  
[INFO] Scanning for projects...  
[INFO]  
[INFO] Using the builder org.apache.maven.lifecycle.internal.builder.singlethrea  
ded.SingleThreadedBuilder with a thread count of 1  
[INFO]  
[INFO] ------------------------------------------------------------------------  
[INFO] Building Maven Stub Project (No POM) 1  
[INFO] ------------------------------------------------------------------------  
[INFO]  
[INFO] >>> maven-archetype-plugin:3.0.1:generate (default-cli) @ standalone-pom  
>>>  
[INFO]  
[INFO] <<< maven-archetype-plugin:3.0.1:generate (default-cli) @ standalone-pom  
<<<  
[INFO]  
[INFO] --- maven-archetype-plugin:3.0.1:generate (default-cli) @ standalone-pom  
---
执行过程中需要提交一些信息，
1、选择archetype，提示列出了三种，这里选择一个空白的插件框架1

Choose archetype:  
1: remote -> io.jenkins.archetypes:empty-plugin (Skeleton of a Jenkins plugin wi  
th a POM and an empty source tree.)  
2: remote -> io.jenkins.archetypes:global-configuration-plugin (Skeleton of a Je  
nkins plugin with a POM and an example piece of global configuration.)  
3: remote -> io.jenkins.archetypes:hello-world-plugin (Skeleton of a Jenkins plu  
gin with a POM and an example build step.)  
Choose a number or apply filter (format: [groupId:]artifactId, case sensitive co  
ntains): : 1  

2、选择版本，默认1.2

Choose io.jenkins.archetypes:empty-plugin version:  
1: 1.0  
2: 1.1  
3: 1.2  
Choose a number: 3:   

3、提供groupId，
Define value for property 'groupId':XXX.XXX.XXX
4、提供ArtifactId，项目名称

Define value for property 'artifactId':XXX
5、提供版本号，默认1.0-SNAPSHOT
Define value for property 'version' 1.0-SNAPSHOT:
6、提供应用包名，默认groupId

Define value for property 'package' XXX.XXX.XXX: :
7、确认以上信息

Confirm properties configuration:Y
创建成功

[INFO] Project created from Archetype in dir: E:\jenkinsplugin\  
[INFO] --------------------------------------------------------  
[INFO] BUILD SUCCESS  
[INFO] --------------------------------------------------------  
[INFO] Total time: 18:57 min  
[INFO] Finished at: 2017-10-27T17:09:59+08:00  
[INFO] Final Memory: 15M/123M  
[INFO] --------------------------------------------------------
2.1 编译插件生成hpi文件

cd到XXX工程目录下，执行以下命令
mvn install 或者mvn package
执行完成如下

[INFO] Skipping packaging of the test-jar  
[INFO] -----------------------------------------------------------  
[INFO] BUILD SUCCESS  
[INFO] -----------------------------------------------------------  
[INFO] Total time: 02:11 min  
[INFO] Finished at: 2017-10-27T17:14:20+08:00  
[INFO] Final Memory: 54M/749M  
[INFO] -----------------------------------------------------------


官方链接：https://wiki.jenkins.io/display/JENKINS/Plugin+tutorial#Plugintutorial-CreatingaNewPlugin