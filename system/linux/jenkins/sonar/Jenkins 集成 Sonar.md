

* [Jenkins 集成 Sonar - CSDN博客 ](http://blog.csdn.net/kefengwang/article/details/54377055)
* [【原创】Jenkins 集成 Sonar | 王克锋的博客 ](https://kefeng.wang/2017/01/10/jenkins-sonar/)

* 集成
  * 配置Sonar Server的URL/AccessToken等信息
  * SonarQube插件把报告数据提交给Sonar Server解析
* 构建
  * 构建设置 Build 中，指定 Maven goals: “sonar:sonar” 
  * 项目构建时就会自动上报构建报告给 Sonar
