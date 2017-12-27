
* [获取Jenkins project build结果 - ljj_9的专栏 - CSDN博客 ](http://blog.csdn.net/ljj_9/article/details/70270977)

* 获取某一个构建版本号为6的构建结果：
 String json = "curl http://192.168.165.214:8081/job/pro-ljj_mir-ljj/6/api/xml --user admin:123456  ";

* 获取最后一次构建的构建结果：
String json = "curl http://192.168.165.214:8081/job/pro-ljj_mir-ljj/lastBuild/api/xml --user admin:123456  "; 

* 获取最后一次构建的版本号：
String json = "curl  http://192.168.165.214:8081/job/laijinjie-pro_laijinjie-mir/lastBuild/buildNumber --user admin:123456 ";

* 获取某个项目所以构建版本号的结果;
String json = "curl  http://192.168.165.214:8081/job/pro-ljj_mir-ljj/api/xml --user admin:123456 ";

以上pro-ljj_mir-ljj为项目名称，最后的是账号密码。