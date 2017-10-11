

# Netty系列之Netty高性能之道

* [Netty系列之Netty高性能之道 ](http://www.infoq.com/cn/articles/netty-high-performance)
* [Netty系列之Netty百万级推送服务设计要点 ](http://www.infoq.com/cn/articles/netty-million-level-push-service-design-points/)

* Netty
  * 高性能、异步事件驱动的NIO框架
  * 通过Future-Listener机制，用户可以主动获取或者通过通知机制获得IO操作结果
* Netty高性能之道
  * RPC调用的性能模型分析
    * 传统RPC调用性能差的三宗罪
      * 采用同步阻塞IO
      * BIO通信模式
        * 一个独立的Acceptor线程负责监听客户端的连接
        * 接收到客户端连接，创建一个新的线程处理请求
        * 服务端的线程个数和并发访问数成线性正比
      * Java序列化
        * 无法跨越语言使用
        * Java序列化的码流太大
        * 序列化CPU资源占用高
    * 高新能的三个主题
      * 传输：将数据发送出去的通道
      * 协议：内部私有协议
      * 线程：
    * RPC调用性能三要素
      * IO模型
      * 数据协议
      * 线程模型
  * Netty高性能之道
    * 异步非阻塞通信
      * IO多路复用：把多个IO的阻塞复用到同一个select的阻塞上
    * 零拷贝
      * 使用堆外存进行Socket读写，不需要进行字节缓冲区的二次拷贝
      * 提供组合Buffer对象，聚合多个ByteBuffer对象
      * 采用transferTo()方法，直接将文件缓冲区的数据发送到目标Channel
    * 内存池
      * 提供基于内存池的缓冲区重用机制
    * 高效的Reactor线程模型
      * 三种
        * Reactor单线程模型
        * Reactor多线程模型
        * 主从Reactor多线程模型
      * Reactor多线程模型
        * 专门的一个NIO线程-Acceptor线程用于监听服务端
    * 无锁化的串行设计理念
