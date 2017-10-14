
# MHA原理

* [MHA原理 - stefan.liu - 博客园 ](http://www.cnblogs.com/stefan-liu/p/5446263.html)

* MHA工作原理
  * 主库挂了，但是主库的binlog都被全部从库接收，此时会选中应用binlog最全的一台从库作为新的主库，其他从主只需要重新指定一下主库即可(因为此时,所有从库都是一致的，所以只需要重新指定一下从库即可)。
  * 主库挂了，所有的binlog都已经被从库接收了，但是，主库上有几条记录还没有sync到binlog中，所以从库也没有接收到这个event，如果此时做切换，会丢失这个event。此时，如果主库还可以通过ssh访问到，binlog文件可以查看，那么先copy该event到所有的从库上，最后再切换主库。如果使用半同步复制，可以极大的减少此类风险。
  * 主库挂了，从库上有部分从库没有接收到所有的events，选择出最新的slave，从中拷贝其他从所缺少的events。
* 问题
  * 如何确定哪些event没有成功接收。
  * 如何让所有从库保持一致。

导致复制问题的原因是因为MySQL采用异步复制，并不保证所有事件被从库接收，对于此类问题的解决方案:
1、Heartbeat + DRBD
  代价：额外的被动master，并且不处理任何流量。
  性能：为了保证事件被及时写入，innodb_flush_log_at_trx_commit=1,sync_binlog=1. 这样就会导致性能急速下降。
2、MySQL Cluster
  真正的高可用，但是只支持InnoDB。
3、Semi_synchronous Replication (5.5+)
  半同步复制极大减少了`binlog事件只存在于master上`的风险。保证至少有一台从库接收到了提交的binlog事件。其他的从可能没有接收，但是不影响提交了。
4、Global Transaction ID
由谷歌开发的插件。