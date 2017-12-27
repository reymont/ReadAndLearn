http://blog.csdn.net/tigereg000/article/details/46344257

最近老大要求准备使用Jenkins搭建持续集成环境，因此我这边开始了搭建Jenkins环境搭建之旅，这里讲解的是两种搭建方式，网上均有一定介绍，本文章只讲述如何搭建安装
一、环境准备:
1、CentOS 6.5 完整版安装，安装完成后开启SSH服务: [root@localhost bin]# /etc/init.d/sshd start
2、我这边使用SecureCRT进行远程SSH连接，默认CentOS6.5不支持rz和sz命令，安装命令: [root@localhost bin]# yum install lrzsz
3、保证CentOS可正常访问网络
4、安装JDK
若安装的是完整版的CentOS6.5操作系统，我这边未重新下载JDK，而是采用系统自带的jre-1.7.0-openjdk
第一步：检查安装的jre版本命令:   [root@localhost Jenkins]# java -version
             java version "1.7.0_09-icedtea"
            OpenJDK Runtime Environment (rhel-2.3.4.1.el6_3-x86_64)
            OpenJDK 64-Bit Server VM (build 23.2-b09, mixed mode)
第二步：配置JDK环境变量：[root@localhost Jenkins]# vi /etc/profile
在最后几行增加
JAVA_HOME=/usr/lib/jvm/jre-1.7.0-openjdk.x86_64
JRE_HOME=/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.9.x86_64/jre
PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME
export JAVA_HOME
export JRE_HOME
export PATH
保存配置信息: [root@localhost Jenkins]# source /etc/profile

二、安装方式1
第一步 [root@localhost yum.repos.d]# wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
第二步[root@localhost yum.repos.d]# rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
第三步[root@localhost yum.repos.d]# yum install jenkins
第四步 修改端口 [root@localhost yum.repos.d]# vi /etc/sysconfig/jenkins
找到 JENKINS_PORT="8080"，改成 JENKINS_PORT="9000"
找到 JENKINS_AJP_PORT="8009" ，改成 JENKINS_AJP_PORT="9001"
第五步 启动Jenkins 服务: [root@localhost yum.repos.d]# service jenkins start
Starting Jenkins [  OK  ]
第六步 登录Jenkins网站 http://192.168.25.133:9000/，安装完成

三、安装方式2:
第一步 下载tomcat7: apache-tomcat-7.0.33.tar.gz
在Jenkins官网上下载最新的Jenkins包: jenkins.war
第二步 解压tomcat7: [root@localhost Jenkins]# tar -zxvf apache-tomcat-7.0.33.tar.gz 
第三步 移动tomcat7:[root@localhost Jenkins]# mv apache-tomcat-7.0.33 /usr/local/tomcat
第四步 配置环境变量:[root@localhost Jenkins]# vi /etc/profile
在最后几行增加   TOMCAT_HOME=/usr/local/tomcat
保存变量:[root@localhost Jenkins]# source /etc/profile
第五步: 把jenkins.war 放置到tomcat的webapps下: cp jenkins.war /usr/local/tomcat/webapps/
第六步: 启动tomcat服务: [root@localhost tomcat]# /usr/local/tomcat/bin/startup.sh
第七步: 访问Jenkins网站 http://192.168.25.133:8080/jenkins/,安装完成