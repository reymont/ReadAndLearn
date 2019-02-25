解决新版sonar-java插件需要配置sonar.java.binaries参数的问题 - zxcholmes的个人页面 https://my.oschina.net/zxcholmes/blog/1529732

摘要: 解决新版sonar-java插件，尤其是4.12以后的soanr-java分析插件，在分析的时候提示Please provide compiled classes of your project with sonar.java.binaries property的问题
最近在新的docker容器上部署了sonarqube，然后在更新中心安装了java插件后，使用以前的命令分析java源码的时候出现了以下问题

ERROR: Error during SonarQube Scanner execution
org.sonar.squidbridge.api.AnalysisException: Please provide compiled classes of your project with sonar.java.binaries property
命令如下

sonar-scanner -Dsonar.projectKey=test -Dsonar.projectName=test -Dsonar.projectVersion=1.0 -Dsonar.sources=src -Dsonar.language=java

源码是在src下面的，以往来说都可以直接分析成功，但是这次提示了错误。
于是去官网看了一下

https://docs.sonarqube.org/display/PLUG/SonarJava



说是需要额外的参数，编译后的字节码，目前来说配置这个极为麻烦，尤其是有些源码暂时不需要编译的



于是在官网找到下载soanr-java插件链接：

https://sonarsource.bintray.com/Distribution/sonar-java-plugin/sonar-java-plugin-4.12.0.11033.jar

但是4.12不是我们想要的版本，而且又没有历史版本的下载链接，怎么办呢？
上github找到其它的版本。


然后替换链接版本编号部分，尝试下载成功
https://sonarsource.bintray.com/Distribution/sonar-java-plugin/sonar-java-plugin-4.10.0.10260.jar
然后进入到容器里面，把plugins下面的新版的4.12版本的sonar-java替换成4.10版本的。

重启sonaqube，大功告成，按照原来的命令分析成功！