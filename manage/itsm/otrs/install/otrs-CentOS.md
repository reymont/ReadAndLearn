

CentOS - OTRS https://wiki.otrs.org.cn/CentOS


CentOS
本篇基于CentOs 6.x环境，收录必要的安装过程
更新补丁包 yum -y update
```sh
#关闭 selinux 接着重启服务器
vim /etc/selinux/config 修改SELINUX=disabled
reboot
#安装EPEL扩展和一些perl模块
yum -y install epel-release
#yum -y update  //不一定需要操作
yum -y install sendmail setuptool httpd mysql-server mysql mod_perl perl-Net-DNS \
perl-XML-Parser perl-DateTime perl-TimeDate perl-IO-Socket-SSL perl-DateTime-Format-Builder perl-Apache-DBI
yum -y install perl perl-Crypt-SSLeay perl-Digest-SHA perl-Net-LDAP procmail \
perl-core perl-LDAP perl-Encode-HanExtra perl-GD perl-JSON-XS perl-Mail-IMAPClient perl-PDF-API2 perl-PDF-API2-Text-CSV_XS
yum -y install perl-YAML-XS perl-YAML gcc gcc-c++ perl-Archive-Zip perl-Template-Toolkit
yum -y install system-config-firewall-base system-config-date system-config-firewall \
system-config-firewall-tui system-config-network-tui system-config-services system-config-services-docs
yum -y install mlocate perl-CPAN perl-Crypt-Eksblowfish perl-GD-Text perl-GDGraph \
perl-GDTextUtil perl-Text-CSV-Separator perl-Text-CSV_XS perl-YAML perl-YAML-LibYAML perl-XML-LibXSLT
```


```sh
# http://www.linuxidc.com/Linux/2016-03/129683.htm
# 2、安装MariaDB
# yum -y remove mariadb-server mariadb mariadb-devel
yum -y install mariadb-server mariadb mariadb-devel
systemctl start mariadb
systemctl enable mariadb
mysql
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('123456');
# 配置帐号和密码
-uroot -p
create user 'otrs'@'localhost' identified by 'otrs';
grant all on otrs.* to 'otrs'@'localhost';
flush privileges;
# root使用123456从任何主机连接到mysql服务器
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
flush privileges;
# 配置MySQL
# 为达到OTRS对MySQL配置要求，需要对my.cnf添加两行参数 设置MySQL允许包的大小,添加到[mysqld]下
vim /etc/my.cnf
max_allowed_packet=20M
innodb_log_file_size=512M
# 修改密码
# http://www.cnblogs.com/xiaochaohuashengmi/archive/2011/10/16/2214272.html
chgrp -R mysql /var/lib/mysql
chmod -R 770 /var/lib/mysql
service mysqld start 


service mariadb start

systemctl disable mariadb
mysql_secure_installation
firewall-cmd --permanent --add-service mysql
systemctl restart firewalld.service
iptables -L -n|grep 3306

# 接下来登录重置密码：
$ mysql -u root
mysql > use mysql;
mysql > update user set password=password(‘123456‘) where user=‘root‘;
mysql > exit;


# 如要其他机器能访问，在mysql.user中添加一个Host为'%'的user,然后flush priviledges;，
# 最后防火墙加一句类似这样的语句即可(开通3306端口)：
-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 3306 -j ACCEPT
```

```sh
#重要服务设置为开机启动并启动相关服务
 chkconfig --level 235 mysqld on
 chkconfig --level 235 httpd on
 chkconfig --level 235 ntpd on
 service httpd start
 service ntpd start
 service mysqld start
关闭防火墙（建议在线上环境，根据实际的安全需求配置防火墙）
 service iptables stop
或
 /etc/init.d/iptables stop


 

service mysqld restart

安装OTRS（以下为3.x版本为例，其它版本至5.x同方式操作）
#查看版本
cat /etc/redhat-release 
 wget http://ftp.otrs.org/pub/otrs/RPMS/rhel/6/otrs-3.3.8-01.noarch.rpm
 wget http://ftp.otrs.org/pub/otrs/RPMS/rhel/7/otrs-5.0.23-01.noarch.rpm
# yum安装本地包
 yum localinstall -y otrs-5.0.23-01.noarch.rpm
 rpm -ivh otrs-3.3.8-01.noarch.rpm
 Preparing...                ########################################### [100%]
 Check OTRS user ... otrs added.
    1:otrs                   ########################################### [100%]
 Next steps: 
 [httpd services]
  Restart httpd 'service httpd restart'
 [install the OTRS database]
  Make sure your database server is running.
  Use a web browser and open this link:
  http://localhost/otrs/installer.pl
 [OTRS services]
  Start OTRS 'service otrs start' (service otrs {start|stop|status|restart).
  ((enjoy))
  Your OTRS Team
# 安装
http://172.20.8.50/otrs/installer.pl
```
配置MySQL的优化参数
https://ask.otrs.org.cn/question/29
检查是否还存在perl模块缺失
 cd /opt/otrs/bin
[root@localhost bin]# ./otrs.CheckModules.pl
[root@localhost bin]# service httpd restart
补全所有perl模块后，浏览器打开otrs的配置页面进行配置，配置完成后即可使用
http://OTRS服务器IP地址/otrs/installer.pl

附OTRS基础知识：
初次安装的地址 otrs/installer.pl (安装完成后默认情况下是无法再次访问的)
支持人员登录地址 otrs/index.pl
用户门户登录地址 otrs/customer.pl
公共FAQ访问地址(如果有装FAQ模块) otrs/public.pl