

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
* MySQL的复制是主库主动推送日志到从库去的
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
  * set binlog_format = 'ROW';
  * show variables like '%binlog%format%';