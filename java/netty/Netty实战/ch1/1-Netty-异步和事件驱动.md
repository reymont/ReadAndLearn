
# 第1章　Netty——异步和事件驱动

* Netty
  * 异步式
  * 事件驱动
  * 高性能
  * 面向协议
* 复杂领域
  * 网络编程
  * 多线程处理
  * 并发

## 1.1  Java网络编程

* 早期Java API
  * 支持由本地系统套接字库提供的所谓的阻塞函数
  * ServerSocket上的accept()方法将会一直阻塞到一个连接建立
  * 每个新的客户端Socket创建一个新的Thread
  * 大量的线程，上下文切换开销大

### 1.1.1  Java NIO

* NIO
  * 本地套接字库提供非阻塞调用
  * IO多路复用：使用操作系统的事件通知API注册一组非阻塞套接字

### 1.1.2  选择器

* Selector
  * java.nio.channels.Selector
  * 使用事件通知API以确定在一组非阻塞套接字中有哪些已经就绪能够进行IO相关的操作
  * 较少的线程处理多连接
  * 无IO操作，可以处理其他任务

## 1.2  Netty简介

* 复杂性
  * 直接使用底层的API暴露了复杂性，并且引入了对往往供不应求的关键性依赖
  * 用较简单的抽象隐藏底层实现的复杂性

### 1.2.1  谁在使用Netty

* Netty实现FTP、SMTP、HTTP和WebSocket以及其他的基于二进制和基于文本的协议

### 1.2.2  异步和事件驱动

* 异步和可伸缩性的联系
  * 立即返回，并且在完成后，会直接或者在稍后的某个时间点通知用户
  * 选择器通过较少的线程便可监视许多连接上的事件

## 1.3  Netty的核心组件

* 主要构件块
  * Channel
  * 回调
  * Future
  * 事件和ChannelHandler
* 资源、逻辑和通知

### 1.3.1  Channel

* Channel
  * Channel是Java NIO的一个基本构造
  * 代表一个实体的开放连接，读写操作

### 1.3.2  回调

* 回调
  * 一个方法
  * 一个指向已经被提供给另外一个方法的方法的引用
  * 在适当的时候调用前者
  * ChannelHandler

### 1.3.3  Future

* Future
  * 另一种在操作完成时通知应用程序的方式
  * ChannelFuture
  * 由ChannelFutureListener提供的通知机制消除手动检查对应的操作是否完成的必要
  * Netty的出站IO操作都将返回ChannelFuture
  * Netty完全是异步和事件驱动的
* ChannelFuture
  * connect()将会直接返回，而不会阻塞，该调用将会在后台完成
  * ChannelFutureListener
    * 连接到远程节点
    * 注册一个的ChannelFutureListener到对connect()方法的调用所返回的ChannelFuture上
    * 当该监听器被通知连接以及建立的时候，要检查对应的状态

### 1.3.4  事件和ChannelHandler

* Netty使用不同的事件来通知状态的改变或者是操作的状态

### 1.3.5  把它们放在一起

* Future、回调和ChannelHandler
  * Netty的异步编程模型是建立在Future和回调的概念之上
  * 将事件派发到ChannelHandler
  * 拦截操作
  * 高速的转换入站数据和出站数据
* 选择器、事件和EventLoop
  * 通过触发时间将Selector从应用程序中抽象出来
  * 为每个Channel分配一个EventLoop处理所有事件
  * EventLoop本身只由一个线程驱动，处理了一个Channel的所有IO事件