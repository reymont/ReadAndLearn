

http://blog.csdn.net/zsmissyou/article/details/62445899

$ mvn dependency:tree|grep velocity
[INFO] |  +- org.apache.velocity:velocity:jar:1.6.4:compile

意思是maven库里没有dubbo2.5.4-SNAPSHOT.jar这个版本的dubbo的jar包，把dubbo-admin项目的pom.xml的

<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>dubbo</artifactId>
    <version>${project.parent.version}</version>
</dependency>
改为

<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>dubbo</artifactId>
    <version>2.5.3</version>
</dependency>
重新build即可！