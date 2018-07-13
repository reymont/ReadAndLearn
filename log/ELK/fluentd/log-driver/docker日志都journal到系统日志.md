

Kubernetes Fluentd＋Elasticsearch＋Kibana统一日志管理平台搭建的填坑指南 - ericnie - 博客园 
http://www.cnblogs.com/ericnie/p/6897348.html


终于发现问题, 原来都是通过/var/lib/docker/containers/目录去找，然而我的docker下面容器没有任何log文件。

 仔细研究了一下docker,原来所有的docker日志都journal到系统日志 /var/log/messages下了.为什么呢？ 因为经常有人说docker日志太多导致container容器增长比较快，所以都通过系统的journal进行统一处理。

修改/etc/sysconfig/docker配置文件，把原来的journal改回到当前json.log方式.

#OPTIONS='--selinux-enabled --log-driver=journald --signature-verification=false'
OPTIONS='--selinux-enabled --log-driver=json-file --signature-verification=false'
改完后就发现container下面有很多log文件了.