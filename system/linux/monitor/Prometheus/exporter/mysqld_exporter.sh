#QPS Query per second，QPS = Questions(or Queries) / Seconds
#每秒查询量。Queries 是系统状态值--总查询次数
increase(mysql_global_status_queries[1m])
increase(mysql_global_status_queries[10s])
#已执行语句（由客户端发出）计数
increase(mysql_global_status_questions[1h])
#TPS：Transaction per second，每秒事务量 Com_commit事务提交数，Com_rollback事务回滚数
sum(mysql_global_status_commands_total{command="rollback"})+sum(mysql_global_status_commands_total{command="commit"})
sum(rate(mysql_global_status_commands_total{command=~"(commit|rollback)"}[5m])) without (command)
#打开表数
mysql_global_status_open_tables
#执行select数
increase(mysql_global_status_commands_total{command="select"}[1h])
increase(mysql_global_status_commands_total{command="select"}[1m])
increase(mysql_global_status_commands_total{command="delete"}[1h])
increase(mysql_global_status_commands_total{command="insert"}[1h])
increase(mysql_global_status_commands_total{command="update"}[1h])
#Innodb_rows_inserted
increase(mysql_global_status_innodb_row_ops_total{operation="inserted"}[1h])
increase(mysql_global_status_innodb_row_ops_total{operation="deleted"}[1h])
increase(mysql_global_status_innodb_row_ops_total{operation="read"}[1h])
increase(mysql_global_status_innodb_row_ops_total{operation="updated"}[1h])
#查询MySQL每小时接受到的字节数
increase(mysql_global_status_bytes_received[1h])
#发送字节数
mysql_global_status_bytes_sent
#立即释放表锁数
mysql_global_status_table_locks_immediate
#需要等待的表锁数
mysql_global_status_table_locks_waited
#获得行的锁定次数
increase(mysql_global_status_innodb_row_lock_waits[1h])
mysql_global_status_innodb_row_lock_waits
#脏页数
mysql_global_status_buffer_pool_pages{state="dirty"}
#要求清空的缓冲池页数
mysql_global_status_buffer_pool_page_changes_total{operation="flushed"}
#Innodb 写入日志字节数
mysql_global_status_innodb_os_log_written
#缓冲池命中率
1-(mysql_global_status_innodb_buffer_pool_reads/mysql_global_status_innodb_buffer_pool_read_requests)
#缓冲池大小
mysql_global_variables_innodb_buffer_pool_size
#慢查询相关
mysql_global_variables_long_query_time
mysql_global_status_slow_queries
#最大连接数占上限连接数的85％左右
mysql_global_status_max_used_connections/mysql_global_variables_max_connections
#线程数
mysql_global_status_threads_connected
#最大连接数
mysql_global_variables_max_connections
#空闲连接数
mysql_global_variables_max_connections-mysql_global_status_threads_connected
#连接失败用户数
mysql_global_status_aborted_clients
#空闲缓存池
mysql_global_status_buffer_pool_pages{state="free"}
#按数据分类表的大小M
sum(mysql_info_schema_table_size/1024/1024) by (schema)
