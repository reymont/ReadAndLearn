* [Jenkins CLI ](https://jenkins.io/doc/book/managing/cli/)
* [jenkins-cli命令使用总结 - 丹江湖畔养蜂子赵大爹 - 博客园 ](http://www.cnblogs.com/honeybee/p/6525902.html)

jenkins-->系统管理-->Jenkins CLI
```sh
#下载：jenkins-cli.jar
wget http://192.168.53.100:8090/jenkins/jnlpJars/jenkins-cli.jar
#测试一下help指令：
java -jar jenkins-cli.jar -s http://192.168.53.100:8090/jenkins help
# 配置jenkins-cli的端口TCP端口
jenkins-->系统管理-->Configure Global Security-->勾选启用安全->TCP port for JNLP agents选择随机端口或者指定端口均可以

##登录jenkins
java -jar jenkins-cli.jar -s http://192.168.53.100:8090/jenkins login --username fuxin.zhao --password 123456
java -jar jenkins-cli.jar -s http://192.168.53.100:8090/jenkins login --username admin --password admin
##查看当前登录的是谁
java -jar jenkins-cli.jar -s http://192.168.53.100:8090/jenkins who-am-i
##查看job列表
java -jar jenkins-cli.jar -s http://192.168.53.100:8090/jenkins list-jobs
##退出登录
java -jar jenkins-cli.jar -s http://192.168.53.100:8090/jenkins logout
##重新加载job的配置
java -jar jenkins-cli.jar -s http://192.168.53.100:8090/jenkins reload-job MultiJobTest-step2-2 --username fuxin.zhao --password 123456
```