

* [Jenkins持续集成 - 安装配置 | 会飞的污熊 ](https://www.xncoding.com/2017/03/20/fullstack/jenkins01.html)

Jenkins持续集成 - 安装配置
 发表于 2017-03-20 |  分类于 fullstack |  阅读次数 3143
Jenkins是一个用Java编写的开源的持续集成工具，前身是Hudson项目。 在与Oracle发生争执后，项目从Hudson复制过来继续发展。

Jenkins提供了软件开发的持续集成服务。它运行在Servlet容器中（例如Apache Tomcat）。 它支持许多软件配置管理（SCM）工具，可以执行基于Apache Ant和Apache Maven的项目， 以及任意的Shell脚本和Windows批处理命令。Jenkins的主要开发者是川口耕介，MIT许可证。

安装

环境：CentOS7.2、JDK8、Nginx、Tomcat8、Jenkins2

Jenkins有很多中安装方式，这里我选择war包的形式，将其部署至tomcat中，然后使用nginx做反向代理。

安装JDK8

先查查看系统上面是否有其他的旧版本，有的话就卸载掉：

1
2
3
sudo rpm -qa | grep jdk
jdk-1.7.0_45-fcs.x86_64
sudo rpm -e jdk-1.7.0_45
下载最新的JDK8压缩包

1
2
3
4
cd /opt/
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.tar.gz"
# or go to http://mirrors.linuxeye.com/jdk/
tar xzf jdk-8u121-linux-x64.tar.gz
使用alternatives命令安装java

1
2
3
4
5
6
7
8
9
10
11
12
13
cd /opt/jdk1.8.0_121/
sudo chown -R root:root /opt/jdk1.8.0_121/
alternatives --install /usr/bin/java java /opt/jdk1.8.0_121/bin/java 2
alternatives --config java
There are 3 programs which provide 'java'.
  Selection    Command
-----------------------------------------------
*  1           /opt/jdk1.7.0_71/bin/java
 + 2           /opt/jdk1.8.0_60/bin/java
   3           /opt/jdk1.8.0_121/bin/java
Enter to keep the current selection[+], or type selection number: 3
配置javac和jar命令

1
2
3
4
alternatives --install /usr/bin/jar jar /opt/jdk1.8.0_121/bin/jar 2
alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_121/bin/javac 2
alternatives --set jar /opt/jdk1.8.0_121/bin/jar
alternatives --set javac /opt/jdk1.8.0_121/bin/javac
检查是否安装成功:

1
2
3
4
5
java -version
java version "1.8.0_121"
Java(TM) SE Runtime Environment (build 1.8.0_121-b13)
Java HotSpot(TM) 64-Bit Server VM (build 25.121-b13, mixed mode)
配置JAVA_HOME环境变量，编辑/etc/profile文件，最后加入

1
2
3
export JAVA_HOME=/opt/jdk1.8.0_121
export JRE_HOME=/opt/jdk1.8.0_121/jre
export PATH=$PATH:$JAVA_HOME/bin
source /etc/profile 搞定！

安装Tomcat8

创建tomcat家目录和用户：

1
2
3
sudo groupadd tomcat
sudo mkdir /opt/tomcat
sudo useradd -s /bin/nologin -g tomcat -d /opt/tomcat tomcat
下载最新的tomcat压缩包并解压至/opt/tomcat目录：

1
2
3
cd ~
wget http://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-8/v8.5.13/bin/apache-tomcat-8.5.13.tar.gz
sudo tar -zxvf apache-tomcat-8.5.13.tar.gz -C /opt/tomcat --strip-components=1
配置权限

1
chown -R tomcat:tomcat /opt/tomcat
配置Systemd服务脚本，sudo vi /etc/systemd/system/tomcat.service，写入下面内容：

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target
[Service]
Type=forking
Environment=JAVA_HOME=/opt/jdk1.8.0_121
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/bin/kill -15 $MAINPID
User=tomcat
Group=tomcat
[Install]
WantedBy=multi-user.target
安装haveged，这个主要是用来保证安全性：

1
2
3
sudo yum install haveged
sudo systemctl start haveged.service
sudo systemctl enable haveged.service
重启tomcat服务:

1
2
sudo systemctl start tomcat.service
sudo systemctl enable tomcat.service
防火墙配置：

1
2
sudo firewall-cmd --zone=public --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
然后你就可以打开浏览器看看效果：http://[your-server-ip]:8080

配置管理员，sudo vi /opt/tomcat/conf/tomcat-users.xml

1
<user username="yourusername" password="yourpassword" roles="manager-gui,admin-gui"/>
重启：sudo systemctl restart tomcat.service

安装配置nginx

关于nginx的安装和配置我这里再不多讲，可以去参考下我前面写的几篇。这里我用它来作为tomcat的反向代理。

vi /usr/local/nginx/conf/conf.d/jenkins.conf

内容如下：

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
upstream jenkins{
  #server localhost down;
  server localhost:8080 weight=10 max_fails=2 fail_timeout=30s;
  #server 10.122.22.2 backup;
}
server {
  listen 8080;
  server_name _;
  access_log /var/log/nginx/jenkins.log main;
  error_log /var/log/nginx/jenkins_error.log error;
  location / {
      proxy_pass http://jenkins;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $host;
      proxy_set_header X-NginX-Proxy true;
  }
}
然后重启nginx：systemctl restart nginx.service

最后访问：http://server-ip:8080 看到效果

安装GitLab

我专门写过一篇文章怎样安装和使用Gitlab，请查阅 centos7安装gitlab8.8

安装jenkins

下载最新的war包：

1
wget http://mirrors.jenkins.io/war-stable/latest/jenkins.war
将其解压至tomcat的webapps/ROOT目录下面

1
2
3
4
5
6
mv jenkins.war /opt/tomcat/webapps/ROOT/
cd /opt/tomcat/webapps/ROOT/
unzip jenkins.war
rm -f jenkins.war
cd ~
chown -R tomcat:tomcat /opt/tomcat
重启tomcat：systemctl restart tomcat.service

打开 http://server-ip:8080 即可看到jenkins欢迎页面！

配置

第一次进入jenkins需要你输入root密码，你安装引导把那个文件打开输入就是。 然后设置root密码，安装推荐插件，耐心等待片刻即可。

界面先来一个吧，很熟悉的界面：



Gitlab插件

我这里要使用Gitlab来做演示，所以先安装相应的插件

GitLab Plugin
Gitlab Hook Plugin
AnsiColor（可选）这个插件可以让Jenkins的控制台输出的log带有颜色（就和linux控制台那样）
Jenkins系统设置

操作： Manage Jenkins -> Configure System

Jenkins内部shell UTF-8 编码设置，如下图所示，LANG=zh_CN.UTF-8



Jenkins Location和Email设置，如下图所示



配置SSH

本机生成SSH：ssh-keygen -t rsa -C "Your email"，最终生成id_rsa和id_rsa.pub(公钥)

Gitlab上添加公钥：复制id_rsa.pub里面的公钥添加到Gitlab

Jenkins上配置密钥到SSH：复制id_rsa里面的公钥添加到Jenkins（private key选项）

操作： Manage Jenkins -> Credentials -> System -> Global credentials (unrestricted) -> Add Credentials

然后选择kind类型为SSH username with private key，username随便填， Private Key选择Enter directly，然后把你的私钥直接copy到这里来，保存即可。 如果你生成sshkey的时候输入了密码，那么这里的Passphrase也要输入，否则留空。



第一个pipeline

直接参考官网教程：https://jenkins.io/doc/pipeline/tour/hello-world/#examples

先在本地clone工程：

1
git clone git@192.168.217.161:xiongneng/testproject.git
然后添加一个文件叫Jenkinsfile，这里我选的是python的例子，里面内容如下：

1
2
3
4
5
6
7
8
9
10
pipeline {
    agent { docker 'python:3.5.1' }
    stages {
        stage('build') {
            steps {
                sh 'python --version'
            }
        }
    }
}
然后提交后push上去即可：

1
2
git commt -a -m "add Jenkinsfile"
git push origin master
接下来完全按照官网教程来：

Copy one of the examples below into your repository and name it Jenkinsfile
Click the New Item menu within Jenkins Click New Item on the Jenkins home page
Provide a name for your new item (e.g. My Pipeline) and select Multibranch Pipeline
Click the Add Source button, choose the type of repository you want to use and fill in the details.
Click the Save button and watch your first Pipeline run!
第一次运行踩过的一些坑：

主机上面先安装docker，不然会报命令找不到
我使用过的tomcat来运行jenkins，这个进程是使用tomcat用户启动，执行命令也是tomcat用户， 所以需要确保tomcat用户可使用su - c执行，也就是shell为/bin/bash而不是/sbin/nologin
Cannot connect to the Docker daemon. Is the docker daemon running on this host? 先切换到tomcat用户执行docker pull python:3.5.1命令发现报错一样，那么看看docker进程是否启动。
1
2
3
4
systemctl status docker
systemctl stop docker
systemctl start docker
....OK
最后看运行结果： 

说明已经在执行脚本了，那么耐心等待就行！

升级

Jenkins的升级非常简单，插件升级就去插件管理里面去在线升级，如果Jenkins本身要升级就下载最新war包替换， 修改权限拥有者重启tomcat服务即可。

