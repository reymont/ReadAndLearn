既使用maven又使用lib下的Jar包 2012/10/11

有些项目的jar包不是在maven服务器上能够下载的，那么需要将这样的包放在项目的lib目录下，
不过这样会导致maven打包时找不到包，报错。可以通过下面的配置解决这个问题
<build>
<plugins>
<plugin>
<artifactId>maven-compiler-plugin</artifactId>
<configuration>
<source>1.6</source>
<target>1.6</target>
<encoding>UTF-8</encoding>
<compilerArguments>
<extdirs>src\main\webapp\WEB-INF\lib</extdirs>
</compilerArguments>
</configuration>
</plugin>
</plugins>
</build>

上面解决maven编译问题，下面还需要解决IntelliJ编译问题
