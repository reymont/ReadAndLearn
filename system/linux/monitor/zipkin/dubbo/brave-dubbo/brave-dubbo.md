

https://github.com/jgchen/brave-dubbo

使用步骤：

maven添加该项目jar包（自己打包安装到本地仓库）

        <dependency>
            <groupId>io.zipkin.brave</groupId>
            <artifactId>brave-dubbo</artifactId>
            <version>1.0.0-SNAPSHOT</version>
        </dependency>
spring中配置

打印日志方式
        <bean id="brave" class="com.github.kristofa.brave.dubbo.BraveFactoryBean" p:serviceName="serviceName" p:zipkinHost="" p:rate="1.0" />
http方式
        <bean id="brave" class="com.github.kristofa.brave.dubbo.BraveFactoryBean" p:serviceName="serviceName" p:zipkinHost="http://10.168.16.111:9411/" p:rate="1.0" />
参考文档:

http://www.tuicool.com/articles/f2qAZnZ

# source code jar

```sh
# https://my.oschina.net/u/914897/blog/402476
# http://www.cnblogs.com/dingyingsi/p/3780918.html

mvn clean source:jar install -Dmaven.test.skip=true
执行 mvn install，maven会自动将source install到repository 。
执行 mvn deploy，maven会自动将source deploy到remote-repository 。
执行 mvn source:jar，单独打包源码。
```

```xml
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-source-plugin</artifactId>
                <version>2.4</version>
                <executions>
                    <execution>
                        <id>attach-sources</id>
                        <phase>verify</phase>
                        <goals>
                            <goal>jar-no-fork</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
```