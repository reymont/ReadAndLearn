用maven来运行一个main方法或者启动Server

在maven项目的pom.xml文件的plugins中加入"exec-maven-plugin"这个插件，这个在运行"mvn package"时，会在当前的mvn进程中直接执行指定的class文件的main方法，也可以配置其他的参数，让此main在另一个java进程中启动。如果其中将phase的内容改为"test"，就会在运行"mvn test"时执行main方法，也可以在命令行里直接用mvn运行，如下注释说明。
更详细的信息和配置方法，可参考http://mojo.codehaus.org/exec-maven-plugin/usage.html说明。
<!-- commandline: mvn exec:java -Dexec.mainClass="org.phpfirefly.test.Server" -->
<plugin>
<groupId>org.codehaus.mojo</groupId>
<artifactId>exec-maven-plugin</artifactId>
<version>1.1</version>
<executions>
<execution>
<phase>package</phase>
<goals>
<goal>java</goal>
</goals>
</execution>
</executions>
<configuration>
<mainClass>org.phpfirefly.test.Server</mainClass>
</configuration>
</plugin>


