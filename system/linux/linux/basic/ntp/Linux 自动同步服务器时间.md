Linux 自动同步服务器时间 - pursuer.chen - 博客园
 http://www.cnblogs.com/chenmh/p/5485829.html

yum -y install ntp
ntpdate -u cn.pool.ntp.org


 Linux服务器运行久时，系统时间就会存在一定的误差，本篇文章就来介绍怎样使服务器的时间和网络服务器的时间同步。

网络时间服务器

首先得确保这些服务器都能ping通否则是无法时间同步的。否则会报错“no server suitable for synchronization found”

中国国家授时中心：210.72.145.44   ----暂时无法使用
NTP服务器(上海) ：ntp.api.bz
中国ntp服务器：cn.pool.ntp.org
pool.ntp.org
时间同步工具

rdate:rdate -s

ntpdate:ntpdate -u(使用-u参数会返回误差，也可以使用-s)

以上两个工具都可以用来同步网络时间服务器，centos默认都有安装，两个工具的使用方法都很简单，本章主要介绍ntpdate工具。如果没有安装安装方法如下：

yum -y install ntp
同步时间

1.修改时区

cp -y /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
vim  /etc/sysconfig/clock

ZONE="Asia/Shanghai"
UTC=false
ARC=false
2.同步时间

/usr/sbin/ntpdate -u cn.pool.ntp.org
3.写入硬件时间

服务器每次重启都会参考硬件的时间，所以需要将当前系统的时间写入到硬件。

查看当前硬件时间：

hwclock -r
[root@localhost ~]# hwclock -r
Thu 12 May 2016 08:05:43 PM CST  -0.674165 seconds
写入硬件时间：

hwclock -w
自动时间同步

1.配置开机启动校验

vim /etc/rc.d/rc.local

/usr/sbin/ntpdate -u cn.pool.ntp.org> /dev/null 2>&1; /sbin/hwclock -w
2.配置定时任务

vim /etc/crontab

00 10 * * * root /usr/sbin/ntpdate -u cn.pool.ntp.org > /dev/null 2>&1; /sbin/hwclock -w 
或者

crontab -e

00 10 * * * /usr/sbin/ntpdate -u cn.pool.ntp.org > /dev/null 2>&1; /sbin/hwclock -w
安装定时服务crontab参考：http://www.cnblogs.com/chenmh/p/5430258.html

总结
 定时任务的内容可以参考我之前写的文章：http://www.cnblogs.com/chenmh/p/5430258.html