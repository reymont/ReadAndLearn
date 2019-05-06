

* [【Consul】Consul实践指导-健康检查（Checks） - CSDN博客 ](http://blog.csdn.net/younger_china/article/details/52243759)

* Consul健康检查
  * 系统级：监控整个节点
  * 应用级：与某个服务关联
* 5种检查方法
  * Script+ Interval：执行外部应用进行检查
  * HTTP+ Interval：发出HTTP GET请求。根据HTTP响应判断：2XX正常，4XX异常
  * TCP+ Interval
    * 将按照预设的时间间隔与指定的IP/Hostname和端口创建一个TCP连接
    * 服务的状态依赖于TCP连接是否成功——如果连接成功，则状态是“success”；否则状态是“critical”
  * Timeto Live（TTL）：
  * Docker+ interval：docker Exec API，shell