

* [如何让网站不下线而从 Redis 2 迁移到 Redis 3 ](http://mp.weixin.qq.com/s/WFJZVLfcbC4xOlQOk-GcpA)

* 背景
  * 一分钟登陆20,000
  * SSO令牌用于70台Apache HTTPD服务器
  * 使用Redis 3.2原生集群
* 升级之前
  * keepalive确保有一个主节点监听浮动IP floating IP地址
* 新的设计
  * 要求
    * 共享内存缓存
    * 无单点故障
    * 减少人为干预
  * 方案
    * Redis Sentinel，代理Redis连接，twemproxy
    * Redis 3.2内置原生集群，消除单一sentinel集群需要
    * Node.js的Redis的集群发现驱动程序
  * 自动
    * 分片数据
    * 故障转移
    * 故障恢复
* 迁移
  * 数十亿字节数据迁移
  * 将数据同时写入旧Redis和新Redis集群
  * 逐渐转向新的集群