
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [官网](#官网)
* [dnsmasq.conf](#dnsmasqconf)
* [使用Dnsmasq搭建本地dns服务器上网](#使用dnsmasq搭建本地dns服务器上网)
	* [一、Dnsmasq安装](#一-dnsmasq安装)
	* [二、Dnsmasq配置](#二-dnsmasq配置)
	* [三、Dnsmasq启动](#三-dnsmasq启动)

<!-- /code_chunk_output -->


# 官网

* [Dnsmasq - network services for small networks. ](http://www.thekelleys.org.uk/dnsmasq/doc.html)
* [Man page of DNSMASQ ](http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html)

# dnsmasq.conf

* [dnsmasq.conf 配置 - bluesky - 博客园 ](http://www.cnblogs.com/studio313/p/6278698.html)

# 使用Dnsmasq搭建本地dns服务器上网
* [使用Dnsmasq搭建本地dns服务器上网 - 永远在学习Linux之路上 - CSDN博客 ](http://blog.csdn.net/linux_hua130/article/details/51495643)

## 一、Dnsmasq安装
安装并启动Dnsmasq
```sh
yum install -y dnsmasq
service dnsmasq start 
```
## 二、Dnsmasq配置
1、Dnsmasq的配置文件路径为：`/etc/dnsmasq.conf`
```
# ll -d /etc/dnsmasq.conf 
```
-rw-r--r-- 1 root root 21237 Feb 23 00:17 /etc/dnsmasq.conf
2、编辑`/etc/dnsmasq.conf`
```conf
resolv-file=/etc/resolv.dnsmasq.conf    //dnsmasq 会从这个文件中寻找上游dns服务器
strict-order             //去掉前面的#
addn-hosts=/etc/dnsmasq.hosts         //在这个目里面添加记录
listen-address=127.0.0.1,192.168.1.123     //监听地址
```
3、修改`/etc/resolv.conf`
```
echo 'nameserver 127.0.0.1' > /etc/resolv.conf
```
4、创建resolv.dnsmasq.conf文件并添加上游dns服务器的地址
```
touch /etc/resolv.dnsmasq.conf
echo 'nameserver 119.29.29.29' > /etc/resolv.dnsmasq.conf
```
5、创建dnsmasq.hosts文件
```
cp /etc/hosts /etc/dnsmasq.hosts
echo 'addn-hosts=/etc/dnsmasq.hosts' >> /etc/dnsmasq.conf
```
提示：resolv.dnsmasq.conf中设置的是真正的Nameserver，可以用电信、联通等公共的DNS。

## 三、Dnsmasq启动
1、设置Dnsmasq开机启动并启动Dnsmasq服务：
```
chkconfig dnsmasq on
/etc/init.d/dnsmasq restart
```
2、netstat -tunlp|grep 53 查看Dnsmasq是否正常启动：
```
# netstat -tlunp|grep 53
tcp        0      0 0.0.0.0:53                  0.0.0.0:*                   LISTEN      2491/dnsmasq        
tcp        0      0 :::53                       :::*                        LISTEN      2491/dnsmasq        
udp        0      0 0.0.0.0:53                  0.0.0.0:*                               2491/dnsmasq        
udp        0      0 :::53                       :::*                                    2491/dnsmasq 
```       
3、dig www.freehao123.com，第一次是没有缓存，所以时间是200多
Dnsmasq_01

4、第二次再次测试，因为已经有了缓存，所以查询时间已经变成了0.
Dnsmasq_2

本文转载自：http://www.linuxprobe.com/dnsmasq-builds-local-dns.html
免费提供最新Linux技术教程书籍，为开源技术爱好者努力做得更多更好：http://www.linuxprobe.com/