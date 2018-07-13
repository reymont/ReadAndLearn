

* [了解构件仓库管理器Artifactory和Nexus_mryqu_新浪博客 ](http://blog.sina.com.cn/s/blog_72ef7bea0102vq0k.html)

使用Maven，可以从Maven中央仓库下载所需要的构件（artifact），但这通常不是一个好的做法，一般是在`企业内部架设一个Maven仓库服务器，在代理远程仓库的同时维护本地仓库，以节省带宽和时间`。企业仓库管理器一般可以提供高并发访问、浏览和查询、报表、访问控制、备份、对其他仓库进行代理、REST API等特性

了解一下构件仓库管理器，市场上最好的是`JFrog的Artifactory和Sonatype的Nexus`，而且这两个产品既有商业版也有免费社区版。

以Artifactory为例，Ant+Ivy、Maven和Gradle这些构建工具都可以自动下载Artifactory里的构件（artifact），此外`Jenkins、Bamboo等CI工具`也可以通过构建工具将生成的构件（artifact）部署到Artifactory上。

![artifactory-nexus.jpg](img/artifactory-nexus.jpg)

如果将构建结果部署到Artifactory，需要对Maven构建增加如下选项：
deploy -DaltDeploymentRepository=snapshots::default::http://svcartifact.yqu.com:8081/artifactory/snapshots

如果将release构建结果部署到Artifactory，需要对Maven构建增加如下选项：
deploy -DaltDeploymentRepository=release::default::http://svcartifact.yqu.com:8081/artifactory/release

或者在pom.xml中内嵌distributionManagement：
了解构件仓库管理器Artifactory和Nexus

最近网上有一个不错的帖子 Maven Repository Manager Feature Matrix ，对比了Archiva、Artifactory和Nexus的功能和价格，可供有需要做Maven仓库管理器技术选型的同学借鉴。

# 参考
[JFrog Artifactory官网](http://www.jfrog.com/#os-arti)
[Sonatype Nexus官网](http://www.sonatype.org/nexus/)
[Artifactory – 1 Min Setup](http://www.jfrog.com/video/artifactory-1-min-setup/)
[Apache Maven Deploy Plugin](https://maven.apache.org/plugins/maven-deploy-plugin/)