

# 第三十一章 Mysql复制 

* 复制
  * 将主数据库的DDL和DML操作通过二进制日志传到复制服务器上
  * 在从库上对这些日志重新执行（`重做`），从而使得主从一致
* MySQL复制的3个优点
  * 主从数据库快速切换
  * 在从库上执行查询操作，降低主库的访问压力
  * 在从库上执行备份
* MySQL实现的是异步的复制，所有主从库之间存在一定的差距

## 31.1 复制概述

* 复制原理
  * MySQL主库在事务提交时把数据变更记录在二进制日志文件Binlog中
    * sync_binlog参数控制Binlog日志刷新到磁盘
  * 主库推送二进制日志文件Binlog中的事件到从库的中继日志Relay Log
  * 从库根据中继日志Relay Log重做数据变更操作
* 3个线程
  * 主库：Binlog Dump
  * 从库：I/O线程
  * 从库：SQL线程
* 过程
  * 从库启动，创建I/O线程连接主库
  * 主库创建Binlog Dump线程读取数据库事件并发送给I/O线程
  * I/O线程获取到事件数据后更新到从库的中继日志Relay Log中去
  * 从库上的SQL线程读取中继日志Relay Log中更新的数据库事件并应用
* MySQL的复制是`主库主动推送日志`到从库去的
* SHOW PROCESSLIST查看三个线程的状态

### 31.1.1 复制中的各类文件

* 复制过程中两类日志文件
  * 二进制日志文件Binlog
    * 记录所有数据修改操作
    * 不记录Select操作
    * show variables like '%binlog_format%'
      * Statement
      * Row
      * Mixed
  * 中继日志文件Relay Log
    * 文件格式、内容与Binlog一样
    * SQL线程在执行完Relay Log中的事件后，会删除Relay Log
    * 复制的进度
      * master.info：I/O线程读取主库Binlog的进度
      * relay-log.info：SQL线程应用Relay Log的进度
      * SHOW SLAVE STATUS查看当前从库复制的状态

### 31.1.2 三种复制方式

* Binlog的3种格式
  * Statement：每条修改数据的SQL都会保存到Binlog里
  * Row：每行数据的变化都记录到Binlog，日志量比Statement大
  * Mixed：默认采用Statement，某些情况切换到Row
* 3中复制技术
  * binlog_format=Statement：Statement-Based Replication, SBR
  * binlog_format=Row：Row-Based Replication, RBR
  * binlog_format=Mixed：
* SHOW BINLOG EVENTS
  * 查看操作对应的开始位置
  * show binlog events in 'ip83-bin.000003' from 6912\G
  * mysqlbinlog工具分析对应的Binlog日志 
* binlog_format
  * SESSION级：set binlog_format = 'ROW';
  * show variables like '%binlog%format%';
  * 全局：set global binlog_format = 'ROW';
  * 设置ROW后，mysqlbinlog需要Base64解码
    * mysqlbinlog -vv ip83-bin.000003 --base64-output=DECODE-ROWS --start-pos=7169
* ROW格式
  * MySQL在Binlog中逐行记录数据的变更
  * ROW格式比Statement格式更能保证从库数据的一致性
  * ROW格式下的Binlog的日志量会增大很多

### 31.1.3 复制的3种常见架构

* 一主多从复制架构
  * 把大量对实时性要求不高的读请求通过负载均衡分布到多个从库
  * 每个从库都会在主库上有一个独立的Binlog Dump线程来发送事件
* 多级复制架构
  * 解决一主多从场景下，主库的I/O负载和网络压力
  * 经过两次复制，数据延时比一主多从要大
  * Master2选择BLACKHOLE降低多级复制的延时
    * 写入数据不会写回磁盘
    * 仅在Binlog中记录事件
* 双主复制Dual Master架构
  * 主库Master1和Master2互为主从

## 31.2 复制搭建过程

### 31.2.1 异步复制

* 主从复制配置
  * 主从库安装相同版本的数据库
  * 在主库上，设置复制使用账户，并授予REPLICATION SLAVE
    * GRANT REPLICATION SLAVE ON *.* to 'rep1'@'192.168.7.200' IDENTIFIED BY '1234test';
  * 修改主数据库my.conf，开启BINLOG，并设置server-id；重启数据库服务
  * 设置主库读锁定
    * flush tables with read lock;
  * 获取主库当前的二进制日志名和偏移量值
    * show master status;
  * 停止更新操作后，生成主库的备份
    * mysqldump
    * ibbackup
    * 停止数据库，直接复制数据库文件
  * 主库备份完毕，恢复写操作
    * unlock tables;
  * 将主数据库的一致性备份恢复到从数据库上
  * 修改从库my.cnf，增加唯一的server-id参数，不能与主库的配置相同
  * 从库，使用--skip-slave-start启动
  * 配置从库，指定复制用户，主库IP、端口，开始执行复制的日志文件和位置等
  * 启动slave
    * start salve;
    * show processlist观察进程
* 复制的3个线程Binlog Dump、I/O、SQL之间都是独立的
* 数据库的完整性完全依赖于主库的Binlog的不丢失
* 主库宕机
  * 手工通过mysqlbinlog访问宕机之前正在写的Binlog抽取缺失的日志并同步到从库
  * 配置高可用MHA架构自动抽取缺失部分
  * 启用MySQL 5.6的global transaction identifiers(GTID)特性自动抽取缺失Binlog
* Binlog
  * 支持事务的引擎，每个事务提交时都需要些Binlog
  * 不支持事务的引擎，每个SQL语句执行完成后，都需要写Binlog
* sync_binlog
  * 控制Binlog刷新到磁盘的频率
  * show variables like '%sync_binlog%';
  * sync_binlog=0，MySQL不控制，由文件系统控制
  * sync_binlog>0
    * 每sync_binlog次事务提交，MySQL调用文件系统的刷新操作
    * sync_binlog=1
      * 尽最大可能保证数据安全
      * 多事务并发提交影响性能

### 31.2.2 半同步复制

* 半同步复制
  * 主库在每次事务成功提交后
  * 等待其中一个从库接收到Binlog事务并成功写入中继日志后
  * 主库返回Commit操作成功给客户端
  * 在传送Binlog日志到从库时，从库宕机
    * 从库事务会等待一段时间
    * 如果在这段时间内都无法成功推送到从库
    * MySQL自动调整复制为异步模式
    * 事务正常返回提交结果给客户端
  * 往返时延RTT(Round-Trip Time)
    * 从发送端发送数据开始到发送端接收到接收端的确认的总时长
  * 主库和从库的Binlog日志是同步的
  * 主库并不等待从库应用这部分日志就返回提交结果