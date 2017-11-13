Archiva 环境下配置 Maven2 SNAPSHOTS 快照库2012/10/11

Archiva是Apache组织发布的 Maven 库管理的一个系统工具，非常好用。项目链接: http://archiva.apache.org/
1) Archiva安装好之后，首先需要为其创建一个负责deploy的用户，登录archiva，选择user management，选择create new user，创建一个新用户archiva.gehouse，密码pass123，并使其用户代码库的管理和监视权限。
2) 在Archiva中创建好SNAPSHOTS代码库，例如URL为：http://archiva.gehouse.cn/repository/snapshots。
3) 在setting.xml中，的servers节点中加入server节点，id用来表示这个server，deploy时用到：
    <server>
        <id>archiva.snapshots</id>
        <username>archiva.gehouse</username>
        <password>pass123</password>
    </server>

4) 在项目的pom.xml中加入distributionManagement节点，id对于setting.xml中的server中的id：
 
    <distributionManagement>
        <snapshotRepository>
            <id>archiva.snapshots</id>
            <name>Internal Snapshot Repository</name>
            <url>dav:http://archiva.gehouse.cn/repository/snapshots</url>
        </snapshotRepository>
    </distributionManagement>
 

pom.xml中还需要加入build节点，用maven-wagon插件，使用webdav协议上传snapshot代码包，完整的pom.xml文件如下：
 
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.gehouse</groupId>
    <artifactId>test2</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <build>
        <extensions>
            <extension>
                <groupId>org.apache.maven.wagon</groupId>
                <artifactId>wagon-webdav</artifactId>
                <version>1.0-beta-2</version>
            </extension>
        </extensions>
    </build>
    <dependencies>
        <dependency>
            <groupId>com.gehouse</groupId>
            <artifactId>gehouse-util</artifactId>
            <version>1.0.0-SNAPSHOT</version>
        </dependency>
    </dependencies>
    <repositories>
        <repository>
            <id>snapshots</id>
            <name>Archiva Managed Snapshot Repository</name>
            <url>http://archiva.gehouse.cn/repository/snapshots</url>
        </repository>
    </repositories>
    <distributionManagement>
        <snapshotRepository>
            <id>archiva.snapshots</id>
            <name>Internal Snapshot Repository</name>
            <url>dav:http://archiva.gehouse.cn/repository/snapshots</url>
        </snapshotRepository>
    </distributionManagement>
</project>
 

5) 在项目中使用命令：mvn deploy 就可以把生成的snapshot包，部署到服务器中了，项目的其他同事可以随时拿到快照了。
