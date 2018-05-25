

* [Cobertura Plugin - Jenkins - Jenkins Wiki ](https://wiki.jenkins.io/display/JENKINS/Cobertura+Plugin)
* [jenkins集成cobertura，调用显示cobertura的report - JasonYao的程序猿路 - CSDN博客 ](http://blog.csdn.net/yaominhua/article/details/40684647)
* [Cobertura + jenkins 单元测试代码覆盖率统计 - testway - 博客园 ](http://www.cnblogs.com/testway/p/6380656.html)

1、新建一个maven工程，在src/main/java 下建一个CoverageTest.java 类

复制代码
package test_junit;

public class CoverageTest {

    public CoverageTest() {
        // TODO Auto-generated constructor stub
    }

    public static void main(String[] args) {
        // TODO Auto-generated method stub

    }
    
    public static int  testadd(int x, int y){
        int c = 0;
        if(x == 10){
            c = x + y;
        }else{
            c = (x + y)*2;
        }
        return c;
    }
}
复制代码
2、在src/main/java  新建一个测试类JunitTest.java

复制代码
package junit;

import org.junit.Assert;
import org.junit.Test;

import test_junit.CoverageTest;

/**
 * Created by 000284 on 2017/2/6.
 */
public class JunitTest {
    @Test
    public void testadd(){
        int b = CoverageTest.testadd(5, 20);
        Assert.assertEquals(b,50);
    }


}
复制代码
3、pom.xml 文件

复制代码
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>testunit</groupId>
    <artifactId>test_junit</artifactId>
    <version>1.0-SNAPSHOT</version>
 <profiles>
        <!-- Jenkins by default defines a property BUILD_NUMBER which is used to enable the profile. -->
        <profile>
            <id>jenkins</id>
            <activation>
                <property>
                    <name>env.BUILD_NUMBER</name>
                </property>
            </activation>
            <build>
                <plugins>
                    <plugin>
                        <groupId>org.codehaus.mojo</groupId>
                        <artifactId>cobertura-maven-plugin</artifactId>
                        <version>2.7</version>
                        <configuration>
                            <formats>
                                <format>xml</format>
                            </formats>
                        </configuration>
                        <executions>
                            <execution>
                                <phase>package</phase>
                                <goals>
                                    <goal>cobertura</goal>
                                </goals>
                            </execution>
                        </executions>
                    </plugin>
                </plugins>
            </build>
        </profile>
    </profiles>
    <dependencies>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
        </dependency>
    </dependencies>

</project>
复制代码
3、jenkins 安装插件cobertura

4、新建jenkins job

build >Goals and options  设置：clean cobertura:cobertura

Cobertura xml report pattern 设置： **/target/site/cobertura/coverage.xml

post setps 设置：Enable the "Publish Cobertura Coverage Report" publisher

5、构建job 查看 Coverage Report 就会显示覆盖率报表