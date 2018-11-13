

## linux

executors: 5
远程工作目录: /var/jenkins_home
用法：只允许运行绑定到这台机器的Job

ssh root@172.***.***.***
yum search java
yum install -y java-1.8.0-openjdk

## windows

若你使用前2种 launch agent，成功后会提示connected，此时点击 file-> Install as Windows Service
你差不多猜到这么作为service的好处了，不用每次在windows重启后还要launch agent，这样作为服务可以开机自启动。

## 参考：

1. http://www.cnblogs.com/GGHHLL/p/3251524.html) 