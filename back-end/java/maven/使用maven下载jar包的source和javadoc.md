使用maven下载jar包的source和javadoc - CooMark - 博客园
http://www.cnblogs.com/wancy86/p/mvn-sources-docs.html

使用maven菜单下载sources和javadocs没什么反应，还是命令给力。

mvn dependency:sources -DincludeArtifactIds=android

https://maven.apache.org/plugins/maven-dependency-plugin/sources-mojo.html

指定特定的java src
mvn dependency:sources -DincludeArtifactIds=qiniu-java-sdk
F:\workspace\sagittarius-webmagic>mvn dependency:sources -DincludeArtifactIds=spring-beans

使用参数下载源码包与doc包：
-DdownloadSources=true 下载源代码jar
-DdownloadJavadocs=true 下载javadoc包
mvn dependency:sources -DdownloadSources=true -DdownloadJavadocs=true

--亲测可用，下载完成之后jar的属性中的source和doc都自动关联上了(jar包属性上设置路径)。
mvn dependency:sources -DdownloadSources=true -DdownloadJavadocs=true

 

===========跳过测试==============
clean install -Dmaven.test.skip=true
or
clean install -DskipTests=true
