Maven Jetty Plugin运行配置jetty:run 2012/10/11

如果这个工程是标准的maven-webapp那么基本上不用修改，直接运行jetty:run就可以执行。
但是有时候会报错说
[ERROR] No plugin found for prefix 'jetty' in the current project and in the plu
gin groups [org.apache.maven.plugins, org.codehaus.mojo] available from the repo
sitories [local (C:\Documents and Settings\reymont.li\.m2\repository), central (
http://repo.maven.apache.org/maven2)] -> [Help 1]
在pom.xml的project.build节点下添加

            <plugin>
                <groupId>org.mortbay.jetty</groupId>
                <artifactId>maven-jetty-plugin</artifactId>
                <version>6.1.10</version>
            </plugin>

        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>servlet-api</artifactId>
            <version>2.5</version>
        </dependency>

In order to run Jetty on a webapp project which is structured according to the usual Maven defaults (resources in ${basedir}/src/main/webapp, classes in${project.build.outputDirectory} and the web.xml descriptor at ${basedir}/src/main/webapp/WEB-INF/web.xml, you don't need to configure anything.
Simply type:
mvn jetty:run
This will start Jetty running on port 8080 and serving your project. Jetty will continue to run until the plugin is explicitly stopped, for example, by a <cntrl-c>. 


mvn jetty:run有几个扩展命令
mvn jetty:run-war
先打包，让后再部署指定的war。如果不指定webApp，默认为${project.build.directory}/${project.build.finalName}.war
<project> 
... 
<plugins> 
... 
<plugin> 
<groupId>org.mortbay.jetty</groupId> 
<artifactId>maven-jetty-plugin</artifactId> 
<configuration> 
<webApp>${basedir}/target/mycustom.war</webApp> 
</configuration> 
</plugin> 
</plugins> 
</project> 
mvn jetty:run-exploded
就是war解压后的文件夹，配置和jetty:run-war一致。
<project> 
... 
<plugins> 
... 
<plugin> 
<groupId>org.mortbay.jetty</groupId> 
<artifactId>maven-jetty-plugin</artifactId> 
<configuration> 
<webApp>${basedir}/target/myfunkywebapp</webApp> 
</configuration> 
</plugin> 
</plugins> 
</project> 
mvn jetty:deploy-war
基本上和jetty:run-war一样，只是没有先package war
