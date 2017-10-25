

* [学习Maven之Maven Enforcer Plugin - 辵鵵 - 博客园 ](http://www.cnblogs.com/qyf404/p/4829327.html)

Enforcer可以在项目validate时，对项目环境进行检查。

Enforcer配置后默认会在validate后执行enforcer:enforce,然后对项目环境进行检查。

```sh
#全局命令
mvn validate
#只执行这个插件
mvn enforcer:enforce
#-Denforcer.skip=true 来跳过enforcer插件执行
mvn clean validate -Denforcer.skip=true
```

# Maven Enforcer plugin标签详解

```xml
<plugin>
<artifactId>maven-enforcer-plugin</artifactId>
<version>1.4.1</version>
<executions>
  <execution>
    <id>default-cli</id>         －－一个执行实例的id
      <goals>
        <goal>enforce</goal>     －－执行的命令
      </goals>
      <phase>validate</phase>    －－执行的阶段
      <configuration>
        <rules>                  －－规则
          <requireJavaVersion>   －－JDK的版本
            <message>            －－失败后提示消息
              <![CDATA[You are running an older version of Java. This application requires at least JDK ${java.version}.]]>
             </message>
             <version>[${java.version}.0,)</version>   －－JDK版本规则
           </requireJavaVersion>
         </rules>
       </configuration>
    </execution>
  </executions>
</plugin>     
```