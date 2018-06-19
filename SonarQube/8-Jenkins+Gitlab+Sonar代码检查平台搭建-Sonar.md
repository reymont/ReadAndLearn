Jenkins+Gitlab+Sonar代码检查平台搭建-Sonar - CSDN博客 http://blog.csdn.net/dream_flying_bj/article/details/54695211

sonar平台搭建

安装sonar环境

解压缩
 unzip sonarqube-5.6.4.zip -d /usr/local/src/
 unzip sonar-scanner-2.6.1.zip -d /usr/local/src/
添加环境变量
export PATH="/letv/redis-2.8.17/src:$SONAR_HOME:$SONAR_RUNNER_HOME/bin:$MAVEN_HOME/bin:$PATH"
export SONAR_HOME=/usr/local/src/sonarqube-5.6.4/bin/linux-x86-64
export SONAR_RUNNER_HOME=/usr/local/src/sonar-scanner-2.6.1/
export MAVEN_HOME=/usr/local/src/apache-maven-3.3.9
1
2
3
4
5
6
7
8
安装数据库并配置 >Sonar还需要安装mysql数据库(5.6以上) 
这个集团dba安装好了，看看合适不

自己安装这个只有自己搞了这个是5.6的，集团数据库版本不支持。
# rpm -ivh https://mirror.tuna.tsinghua.edu.cn/mysql/yum/mysql57-community-el6/mysql-community-release-el6-7.noarch.rpm
#yum install mysql-server -y
# /etc/init.d/mysqld start

#mysql
CREATE DATABASE sonar CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL ON sonar.* TO 'sonar'@'localhost' IDENTIFIED BY 'sonar@pw';
GRANT ALL ON sonar.* TO 'sonar'@'%' IDENTIFIED BY 'sonar@pw';
FLUSH PRIVILEGES;
搞定
sonar.jdbc.username=sonar
sonar.jdbc.password=******
sonar.jdbc.url=jdbc:mysql://localhost:3306/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance
sonar.web.host=0.0.0.0
sonar.web.port=9000
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
之前测试环境的一些坑

1、mysql5.7需要使用复杂密码（不建议用），同时修改密码方法如下
先修改vim /etc/my.cnf
#skip-grant-tables
再试下
update mysql.user set authentication_string=password('keYnZh0oK5pUIoIx') where user='root' ;
ALTER USER 'root'@'localhost'IDENTIFIED BY 'DwlRDko4aTeO^WzH';
之后取消#skip-grant-tables
重启mysqld，再创建sonar库才可以。
2、修改jdbc连接池
/usr/local/sonar/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=DwlRDko4aTeO^WzH
sonar.jdbc.url=jdbc:mysql://localhost:3306/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance
3、jdk版本必须1.8以上不然抛异常
/usr/local/sonar/logs/sonar.log
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
来来来测试下集团mysql

 mysql -h 10.149.14.242 -P3927 -u sonar_w -p *******

/usr/local/src/sonarqube-5.6.4/conf
修改配置文件如下
sonar.jdbc.username=sonar_w
sonar.jdbc.password=NjI2OGExO7TI4NDU1
sonar.jdbc.url=jdbc:mysql://10.149.14.242:3927/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance
sonar.web.host=0.0.0.0
sonar.web.port=9000
1
2
3
4
5
6
7
8
9
启动sonar

source /etc/profile
sonar.sh start
1
2
查看日志,发现链接数据库报错

tail -f /usr/local/src/sonarqube-5.6.4/logs/sonar.log
2017.01.23 17:58:21 ERROR web[o.a.c.c.C.[.[.[/]] Exception sending context initialized event to listener instance of class org.sonar.server.platform.PlatformServletContextListener
org.sonar.api.utils.MessageException: Unsupported mysql version: 5.5. Minimal supported version is 5.6.
1
2
3
查看mysql版本，不符合5.6的要求

mysql> status
--------------
mysql  Ver 14.14 Distrib 5.1.73, for redhat-linux-gnu (x86_64) using readline 5.1

Connection id:      354
Current database:   
Current user:       sonar_w@10.127.96.124
SSL:            Not in use
Current pager:      stdout
Using outfile:      ''
Using delimiter:    ;
Server version:     5.5.5-10.0.14-MariaDB-log Source distribution
Protocol version:   10
Connection:     10.149.14.242 via TCP/IP
Server characterset:    utf8
Db     characterset:    utf8
Client characterset:    utf8
Conn.  characterset:    utf8
TCP port:       3927
Uptime:         7 hours 25 min 23 sec

Threads: 2  Questions: 5224  Slow queries: 0  Opens: 0  Flush tables: 1  Open tables: 63  Queries per second avg: 0.195
--------------
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
23
IE输入http://10.127.96.124:9000/看是否能正常访问这个过程需要大约10几分钟，默认用户名和密码都是admin，安装完了我必须自己新建一个用户赋予admin权限，曾经的曾经被队友坑admin的权限都给删了。英文界面不是很友好，下面就把他汉化。

cd /usr/local/src/sonarqube-5.6.4/extensions/plugins
/usr/local/src/sonarqube-5.6.4/bin/linux-x86-64/sonar.sh restart
1
2
搞得麻烦 我直接写了个启动脚本分享下

#!/bin/sh  
#  
# rc file for SonarQube  
#  
# chkconfig: 345 96 10  
# description: SonarQube system (www.sonarsource.org)  
#  
### BEGIN INIT INFO  
# Provides: sonar  
# Required-Start: $network  
# Required-Stop: $network  
# Default-Start: 3 4 5  
# Default-Stop: 0 1 2 6  
# Short-Description: SonarQube system (www.sonarsource.org)  
# Description: SonarQube system (www.sonarsource.org)  
### END INIT INFO  

#/usr/bin/sonar $*
/usr/local/src/sonarqube-5.6.4/bin/linux-x86-64/sonar.sh $*

service sonar restart 没问题
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
这里写图片描述

开机启动

SonarQube开机自启动（Ubuntu, 32位）：
sudo ln -s $SONAR_HOME/bin/linux-x86-32/sonar.sh /usr/bin/sonar
sudo chmod 755 /etc/init.d/sonar
sudo update-rc.d sonar defaults
SonarQube开机自启动（RedHat, CentOS, 64位）：
#sudo ln -s $SONAR_HOME/bin/linux-x86-64/sonar.sh /usr/bin/sonar
sudo ln -s $SONAR_HOME/sonar.sh /usr/bin/sonar
sudo chmod 755 /etc/init.d/sonar
sudo chkconfig --add sonar
1
2
3
4
5
6
7
8
9
安装sonar插件

安装扫描器插件 >注意这个扫描器要安装在jenkins服务器上

# cd /usr/local/src/
# wget https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-2.6.1.zip 
# unzip sonar-scanner-2.6.1.zip -d /usr/local/
#ln -s /usr/local/sonar-scanner-2.6.1/ /usr/local/sonar-scanner
配置让扫描器跟sonar关联起来
# cd 
# cd /usr/local/sonar-scanner/conf/
# grep "^[a-Z]" sonar-scanner.properties 
sonar.host.url=http://10.0.0.102:9000
sonar.sourceEncoding=UTF-8
sonar.jdbc.username=sonar
sonar.jdbc.password=sonar@pw
sonar.jdbc.url=jdbc:mysql://10.0.0.102:3306/sonar?useUnicode=true&characterEncoding=utf8
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
下载测试代码来进行测试

# cd
# wget https://github.com/SonarSource/sonar-examples/archive/master.zip
# unzip master.zip
# cd /root/sonar-examples-master/projects/languages/php/php-sonar-runner
# /usr/local/sonar-scanner/bin/sonar-scanner
1
2
3
4
5
测试一下

[root@gitlab-102 php]# pwd
/root/sonar-examples-master/projects/languages/php
[root@gitlab-102 php]# cat php-sonar-runner/sonar-project.properties 
# Required metadata
sonar.projectKey=org.sonarqube:php-simple-sq-scanner
#项目名称
sonar.projectName=PHP :: Simple Project :: SonarQube Scanner
#版本号
sonar.projectVersion=1.0

# Comma-separated paths to directories with sources (required)
#代码目录
sonar.sources=src

#语言格式
# Language
sonar.language=php
# 编码
# Encoding of the source files
sonar.sourceEncoding=UTF-8
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
sonar的token 
这里写图片描述

配置sonar 
这里写图片描述
配置sonar scanner 
这里写图片描述
Jenkins直接拉起我之前上传gitlab的代码 
这里写图片描述