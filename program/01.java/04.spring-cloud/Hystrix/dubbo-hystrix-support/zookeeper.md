

# http://blog.csdn.net/gaohuanjie/article/details/37736939

tickTime：用于定义ZooKeeper服务器之间或客户端与服务器之间维持心跳的时间间隔，即每隔tickTime毫秒就会发送一个心跳。上面设置的是2000毫秒。
initLimit：用来设置ZooKeeper服务器集群中连接到Leader的Follower服务器最长能能接受（"设定值"*tickTime）毫秒时间的心跳。超过该时间后ZooKeeper服务器集群中的Follower服务器还没有返回信息，那么表明该Follower服务器连接失败。上面设置的是（10*2000）毫秒。该属性是针对ZooKeeper为集群模式或伪集群模式时使用的参数
syncLimit：用于设置ZooKeeper服务器集群中Leader服务器与Follower服务器之间发送消息时请求和应答的最大时长，其时间长度为（"设定值"*tickTime）毫秒。上面设置的是（5*2000）毫秒。该属性是针对ZooKeeper为集群模式或伪集群模式时使用的参数
dataDir：ZooKeeper保存数据的目录，默认情况下，ZooKeeper将写数据的日志文件也保存在这个目录里。注意：该目录不能是/tmp
clientPort：客户端连接ZooKeeper服务器的端口，Zookeeper监听该端口并通过该端口接受客户端的访问请求

```conf
# The number of milliseconds of each tick  
tickTime=2000  
# The number of ticks that the initial   
# synchronization phase can take  
# initLimit=10  
# The number of ticks that can pass between   
# sending a request and getting an acknowledgement  
# syncLimit=5  
# the directory where the snapshot is stored.  
# do not use /tmp for storage, /tmp here is just   
# example sakes.  
dataDir=C:/resources/zookeeper/zookeeper-3.4.11/data  
# the port at which the clients will connect  
clientPort=2181  
#  
# Be sure to read the maintenance section of the   
# administrator guide before turning on autopurge.  
#  
# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance  
#  
# The number of snapshots to retain in dataDir  
#autopurge.snapRetainCount=3  
# Purge task interval in hours  
# Set to "0" to disable auto purge feature  
#autopurge.purgeInterval=1  
```