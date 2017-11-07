

# 第3章　运行和管理Rabbit

* 管理
  * 限制内存消耗
  * Erlang运作的背景，Erlang cookie
  * 权限系统控制用户访问
  * 使用命令行工具查看虚拟机、队列、交换机和绑定的状态
  * 排除Erlang错误消息
  * 如何解读RabbitMQ日志文件

## 3.1　服务器管理

* Erlang的简单分布式
  * Erlang能让应用程序无须知道对方是否在同一台机器上即可互相通信
  * 让集群和可靠的消息路由变得简单
  * 概念
    * Erlang节点
    * Erlang应用程序

### 3.1.1　启动节点

* 节点
  * 一个Erlang节点运行着一个Erlang应用程序
  * Erlang虚拟机的每个实例称之为节点
  * 多个Erlang应用程序可以运行在同一个节点之上
  * 节点之间可以进行本地通信，不管它们是否真的在同一台服务器上
  * 如果应用程序由于某些原因崩溃了，Erlang节点会自动尝试重启应用程序
* 日志
  * /var/log/rabbitmq/rabbit@[hostname].log
* 后台运行
  * ./rabbitmq-server -detached

### 3.1.2　停止节点

* 停止
  * 停止的两种方式
    * 干净的方式
    * 肮脏的方式
  * ./sbin/rabbitmqctl stop
    * rabbitmqctl会和本地节点通信并指示其干净的关闭
    * -n rabbit@[hostname]远程节点

### 3.1.3　关闭和重启应用程序：有何差别

* 重启
  * rabbitmq-server同时启动了节点和应用程序
  * RabbitMQ应用程序预先配置成独立运行模式
  * ./rabbitmqctl stop_app

### 3.1.4　Rabbit 配置文件

* 配置文件
  * /etc/rabbitmq/rabbitmq.config
  * 本质上是原始的Erlang数据结构
  * mnesia指的是Mnesia数据库配置选项，用来存储交换器和队列元数据的
  * rabbit指的是RabbitMQ特定的配置选项的
* Mnesia
  * 内建在Erlang的非SQL型数据库
  * RabbitMQ中的每个队列、交换器和绑定的元数据都是保存到Mnesia
  * 将RabbitMQ元数据首先写入一个仅限追加的日志文件，以确保其完整性
  * 定期将日志内容转储到真实的Mnesia数据库文件中

dump_log_write_threshold
tcp_listeners
ssl_listeners
vm_memory_high_watermark
msg_store_file_size_limit
queue_index_max_journal_entries

* 配置文件无法做到`对RabbitMQ的访问控制`
* RabbitMQ拥有整个专业子系统专门负责权限

## 3.2　请求许可

* 权限类型
  * 读、写、配置
  * 单个用户可以跨越多个vhost进行授权

### 3.2.1　管理用户

* 管理用户
  * 用户是访问控制的基本单元
  * 针对一到多个vhost，其可以被赋予不同级别的访问权限
  * rabbitmqctl add_user cashing-tier cashMel
  * rabbitmqctl delete_user cashing-tier
    * 删除用户时，与用户相关的访问控制条目也会一并被删除
  * rabbitmqctl list_users
  * rabbitmqctl change_password cashing-tier compl3xPassword

### 3.2.2　Rabbit 的权限系统

* 访问控制列表ACL
  * 权限
    * 读：有关消费消息的任何操作，包括“清除”整个队列，需要绑定
    * 写：发布消息，需要绑定
    * 配置：队列和交换器的创建和删除
  * 每一条访问控制条目由以下四部分组成：
    * 被授予访问权限的用户
    * 权限控制应用的vhost
    * 需要授予的度/写/配置权限的组合
    * 权限范围
      *     


