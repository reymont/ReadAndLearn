使用 Docker 搭建代码质量检测平台 SonarQube - CSDN博客 http://blog.csdn.net/xl_lx/article/details/78717584

前言

想成为一名优秀的工程师，代码质量一定要过关！

前提

安装最新版的 Docker ！

开始搭建

1、获取 postgresql 的镜像

$ docker pull postgres

2、启动 postgresql

$ docker run --name db -e POSTGRES_USER=sonar -e POSTGRES_PASSWORD=sonar -d postgres

3、获取 sonarqube 的镜像

$ docker pull sonarqube

4、启动 sonarqube

$ docker run --name sq --link db -e SONARQUBE_JDBC_URL=jdbc:postgresql://db:5432/sonar -p 9000:9000 -d sonarqube

至此，平台搭建完毕。

代码质量检验

1、打开 http://localhost:9000/ , 点击 "Log in"



sonar平台

登录账号：admin 密码：admin

2、以 Maven 项目为例，此处有一个 security-oauth2-qq 项目：



Maven 项目

3、执行命令，检测代码质量

$ mvn sonar:sonar

4、成功之后，返回到浏览器，就可以浏览自己的项目的代码质量了



综合评分



Code Dashboard



精准分析

总结

目前码云上代码分析工具首推的也是 sonarqube，支持各种语言的程序检测，使用简单方便，感觉非常适合微服务的代码评审，强烈推荐。