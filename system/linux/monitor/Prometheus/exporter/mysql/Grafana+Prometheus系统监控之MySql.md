Grafana+Prometheus系统监控之MySql-博客-云栖社区-阿里云
https://yq.aliyun.com/articles/251561

摘要： 架构 grafana和prometheus之前安装配置过，见：Grafana+Prometheus打造全方位立体监控系统 MySql安装 MySql的地位和重要性就不言而喻了，作为开源产品深受广大中小企业以及互联网企业喜爱，所以这里我们也有必要对其进行相应的监控。

架构

1

grafana和prometheus之前安装配置过，见：Grafana+Prometheus打造全方位立体监控系统

MySql安装

MySql的地位和重要性就不言而喻了，作为开源产品深受广大中小企业以及互联网企业喜爱，所以这里我们也有必要对其进行相应的监控。

由于最近更换了CentOS7，这里对MySql重新安装一遍，顺便做个记录，CentOS7的yum源中默认好像是没有mysql的。为了解决这个问题，我们要先下载mysql的repo源。

列出所有版本信息：

lsb_release -a
下载mysql的repo源：

wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
安装mysql-community-release-el7-5.noarch.rpm包：

rpm -ivh mysql-community-release-el7-5.noarch.rpm
安装mysql：

 yum install mysql-server -y
修改权限，否则会报错：

chown -R root:root /var/lib/mysql
重启mysql服务：

service mysqld restart
登录并重置密码：

## 直接回车进入mysql控制台
mysql -u root
mysql > use mysql;
mysql > update user set password=password('123456') where user='root';
mysql > exit;
mysqld_exporter安装

下载并解压：

https://github.com/prometheus/mysqld_exporter/releases/download/v0.10.0/mysqld_exporter-0.10.0.linux-amd64.tar.gz

tar -xvf mysqld_exporter-0.10.0.linux-amd64.tar.gz
mysqld_exporter需要连接Mysql，首先为它创建用户并赋予所需的权限：

 GRANT REPLICATION CLIENT, PROCESS ON *.* TO 'exporter'@'localhost' identified by '123456';
 GRANT SELECT ON performance_schema.* TO 'exporter'@'localhost';
 flush privileges;
创建.my.cnf文件 vi .my.cnf：

[client]
user=exporter
password=123456
运行mysqld_exporter：

./mysqld_exporter -config.my-cnf=".my.cnf" &
Prometheus配置

修改prometheus.yml加入MySql节点：

global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:

  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']
        labels:
          instance: prometheus

  - job_name: linux1
    static_configs:
      - targets: ['192.168.1.120:9100']
        labels:
          instance: sys1

  - job_name: linux2
    static_configs:
      - targets: ['192.168.1.130:9100']
        labels:
          instance: sys2

  - job_name: redis1
    static_configs:
      - targets: ['192.168.1.120:9121']
        labels:
          instance: redis1

  - job_name: mysql
    static_configs:
      - targets: ['192.168.1.120:9104']
        labels:
          instance: db1
保存以后重启Prometheus，查看targets：

2

最后登录grafana查看MySql监控信息:

3

参考文档：
https://github.com/prometheus/mysqld_exporter

作者： 小柒

出处： https://blog.52itstyle.com

分享是快乐的，也见证了个人成长历程，文章大多都是工作经验总结以及平时学习积累，基于自身认知不足之处在所难免，也请大家指正，共同进步。