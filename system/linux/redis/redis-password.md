

[NoSQL之Redis高级实用命令详解--安全和主从复制 - OPEN 开发经验库 ](http://www.open-open.com/lib/view/open1389272230305.html)
[NoSQL之Redis高级实用命令详解--安全和主从复制 - liutingxu1的专栏 - CSDN博客 ](http://blog.csdn.net/liutingxu1/article/details/17116107)

# 一、安全性

为redis设置密码：设置客户端连接后进行任何其他指定前需要实用的密码。

警告：因为redis速度非常快，所以在一台较好的服务器下，一个外部用户可以在一秒钟进行150k次的密码尝试

`redis.conf`中开启`requirepass`，比如设置密码mypassword
```conf
requirepass mypassword
```

```bash
#杀死进程
pkill redis
#启动redis
redis：/usr/local/redis-2.8.1/src/redis-server /user/local/redis-2.8.1/redis.conf
#登陆后，使用指令需要验证
127.0.0.1:6379> keys *
(error) NOAUTH Authentication required.
```
## auth认证

```bash
##错误的密码test，授权失败
127.0.0.1:6379> auth test
##正确的密码，返回ok
127.0.0.1:6379> auth mypassword
```
## -a认证
```bash
sh-3.2# /usr/local/redis-2.8.1/src/redis-cli -a mypassword
```

# 二、主从复制

Redis主从复制配置和使用都非常简单。通过主从复制可以允许多个slave server拥有和master server相同的数据库副本。

## redis主从复制的特点：
1. 一台master可以拥有多个slave（1对多的关系）
2. 多个slave可以连接同一个master外，还可以连接到其他slave（这样做的原因是如果masterdown掉之后其中的一台slave立马可以充当master的角色，这样整个服务流程不受影响）
3. 主从复制不会阻塞master，在同步数据的同时，master可以继续处理client请求。
4. 提高系统的伸缩性

## redis主从复制的过程：

1. slave与master建立连接，发送sync同步命令。
2. Master会启动一个后台进程，将数据库快照保存到文件中，同时master主进程会开始收集新得写命令并缓存。
3. 后台完成保存后，将文件发送给slave
4. slave将文件保存到硬盘上

## 配置主从服务器：

配置slave服务器很简单，只需要在slave的配置文件中加入以下配置：
```
slaveof masterip masterport
```

如果主机开启了登录验证，那么还需要加入下面这句：
```
masterauth authpassword
```

然后启动从机，首先主机会发快照给从机，从机的数据库会更新到和主机相同的状态，然后往主机里写内容，从机也会随之更新。

如果我们在从机上写数据那么会报错：

(error) READONLY You can't write against a read only slave.

## info检查主从服务器信息

```bash
#证明和主机处在连接状态
role：slave
master_host:masterip
master_port:masterport
master_link_status:up
#角色
role：master
#同时连接着几台从机
connected_slaves:1
#同时可以查看连接到主机上的从机的ip和在线状态
slave0:ip=192.168.1.107,port=6379,state=online,offset=1709,lag=1
```

原文地址：http://blog.csdn.net/liutingxu1/article/details/17116107
扩展阅读
redis使用小結
学习Redis从这里开始
NoSQL数据库概览及其与SQL语法的比较
Redis使用手册 
Codis作者黄东旭细说分布式Redis架构设计和踩过的那些坑们 
为您推荐
CSS选择器
【译】60个有用CSS代码片段
jQuery选择器大全(48个代码片段+21幅图演示)
jQuery入门笔记之（一）选择器引擎
Express入门教程：一个简单的博客
更多
NoSQL
Redis
NoSQL数据库