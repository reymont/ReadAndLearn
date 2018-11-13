

* [jenkins + jacoco 单元测试覆盖率 - testway - 博客园 ](http://www.cnblogs.com/testway/p/6384056.html)

jenkins + jacoco 单元测试覆盖率

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
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>fc</groupId>
    <artifactId>test_junit</artifactId>
    <version>1.0-SNAPSHOT</version>

    <dependencies>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
            <scope>test</scope>
        </dependency>
    
        <!-- https://mvnrepository.com/artifact/org.jacoco/jacoco-maven-plugin -->
        <dependency>
            <groupId>org.jacoco</groupId>
            <artifactId>jacoco-maven-plugin</artifactId>
            <version>0.7.8</version>
        </dependency>

    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-pmd-plugin</artifactId>
                <version>3.7</version>
                <configuration>
                    <skipEmptyReport>false</skipEmptyReport>
                </configuration>
                <executions>
                    <execution>
                        <phase>verify</phase>
                        <goals>
                            <goal>check</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>0.7.8</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>prepare-agent</goal>
                            <goal>report</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>

        </plugins>
    </build>

</project>
复制代码
3、jenkins 安装插件jacoco

4、新建jenkins job



5、结果



 

标签: Maven, jacoco, 覆盖率