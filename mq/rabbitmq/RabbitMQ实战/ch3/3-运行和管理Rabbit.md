

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
  * 访问控制条目无法跨越vhost 

./rabbitmqctl set_permissions -p sycamore cashing-tier ".*" ".*" ".*"
                              ^           ^            ^    ^    ^
                              应用vhost    用户         配置 写    读

./rabbitmqctl set_permissions -p oak -s all cashing-tier "" "checks-.*" ".*"
                                                         ^   ^           ^
                                            不匹配队列和交换器 只匹配      匹配任何                

* 验证权限                                  
  ./rabbitmqctl list_permissions -p oak
* 查看用户在vhost上的权限
  ./rabbitmqctl list_user_permissions cashing-tier
* 移除权限
  * 移除用户在指定vhost上的所有权限
    ./rabbitmqctl clear_permissions -p oak cashing-tier

## 3.3　检查

### 3.3.1　查看数据统计

* -p
  * 指明虚拟主机或者路径信息
* php-amqplib
  * https://github.com/videlavaro/php-amqplib
  * wget --no-check-certificate
* 列出队列
  * 默认
    ./rabbitmqctl list_queues
  * 指定vhost
    ./rabbitmqctl list_queues -p sycamore
  * 列出名字、消息数目或者消费者数目、内存使用情况
    ./rabbitmqctl list_queues name messages consumers memory
  * 名称、是否持久、自动删除
    ./rabbitmqctl list_queues name durable auto_delete
* 查看交换器和绑定
  * 交换器信息
    ./rabbitmqctl list_exchanges
  * 查看交换器选项
    ./rabbitmqctl list_exchanges name type durable auto_delete
  * 绑定信息
    ./rabbitmqctl list_bindings

### 3.3.2　理解RabbitMQ 日志

* 日志
  * 可以使用AMQP交换器、队列和绑定实时获得所有这些数据
* 在文件系统中读日志
  * LOG_BASE=/var/log/rabbitmq
    * RABBITMQ_NODENAME-sasl.log
      * SASL (System Application Support Libraries，系统应用程序支持库)
      * 记录Erlang相关信息，在此文件中找到Erlang的崩溃报告
    * RABBITMQ_NODENAME.log
      * 服务器正在发生的事件
      * tail -f rabbit.log
      * 连接是否正常，是否有未经允许的IP地址
* 轮换日志
  * 重新创建日志文件并在旧的文件后面添加一个数字
    ./rabbitmqctl rotate_logs .1
* 通过AMQP实时访问日志
  * 通过传统的文件日志
  * AMQP交换器，过滤日志变得更加简单

## 3.4　修复Rabbit：疑难解答

* Erlang cookie
  * badrpc和nodedown错误
  * rabbitmqctl启动Erlang节点，使用Erlang分布式系统尝试连接RabbitMQ节点
    * 合适的Erlang cookie
    * 合适的节点名称
  * Erlang节点通过交换作为秘密令牌的Erlang cookie以获得认证
    * 令牌存储
      cat ~/.erlang.cookie
* Erlang节点
  * 节点名
    * name
    * sname (short)：启动RabbitMQ的默认方式
* Mnesia和主机名
  * Mnesia
    * Erlang数据库
    * RabbitMQ使用Mnesia存储队列、交换器、绑定等信息
  * 运行RabbitMQ的用户需要对该文件夹的写权限
  * Mnesia会基于机器的主机名创建数据库schema
  * RabbitMQ使用rabbit这个单词作为节点名
* Erlang故障排除技巧
  * 短名启动RabbitMQ
    erl -sname test
  * 节点名称
    node()
  * 其他节点
    * net_adm:names().
  * epmd
    * Erlang Port Mapper Daemon
    * 启动分布式Erlang节点时，会用epmd进程进行注册，提供OS内核分配的地址和端口
  * ping
    * net_adm:ping('rabbit@mrhyde')
    * 尝试对其他节点的连接
  * rpc:call
    * 在远程rabbit节点上执行一个函数
      rpc:call('rabbit@mrhyde', erlang, system_info, [process_count])
    * 在远程rabbit节点上运行着的Mnesia系统的信息
      rpc:call('rabbit@mrhyde', mnesia, info, [])
    * q()，退出
      