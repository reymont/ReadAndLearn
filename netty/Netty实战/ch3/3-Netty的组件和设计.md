
# 第3章　Netty的组件和设计

* Netty两个领域
  * 基于Java NIO的异步的和事件驱动的实现
  * 将应用程序逻辑从网络层解耦

## 3.1  Channel、EventLoop和ChannelFuture

* Netty网络抽象
  * Channel：Socket
  * EventLoop：控制流、多线程处理、并发
  * ChannelFuture：异步通知

### 3.1.1  Channel接口

* 基本的IO操作
  * bind()
  * connect()
  * read()
  * write()

### 3.1.2  EventLoop接口

* EventLoop
  * 用于处理连接的声明周期中所发生的事件
* Channel、EventLoop、Thread以及EventLoopGroup之间的关系
  * 一个EventLoopGroup包含一个或者多个EventLoop
  * 一个EventLoop在它的生命周期内只和一个Thread绑定
  * 所有由EventLoop处理的IO事件都将在专有的Thread上处理
  * 一个Channel只注册于一个EventLoop
  * 一个EventLoop可能被分配给一个或多个Channel

### 3.1.3  ChannelFuture接口

* ChannelFuture
  * addListener()注册一个ChannelFutureListener
  * 在某个操作完成时得到通知

## 3.2  ChannelHandler和ChannelPipeline

### 3.2.1  ChannelHandler接口

* ChannelHandler充当了所有处理入站和出站数据的应用程序逻辑的容器

### 3.2.2  ChannelPipeline接口

* ChannelPipeline提供了ChannelHandler链的容器
* 入站和出站数据流之间
* 入站和出站ChannelHandler可以被安装到同一个ChannelPipline中

### 3.2.3  更加深入地了解ChannelHandler

* Netty以适配器的形式提供大量默认的ChannelHandler实现

### 3.2.4  编码器和解码器

### 3.2.5  抽象类SimpleChannelInboundHandler

## 3.3  引导

* 引导
  * Bootstrap用于客户端
    * 连接到远程节点
    * 只需要一个EventLoopGroup
  * ServerBootstrap用于服务端
    * 服务器监听端口连接
    * 需要两个EventLoopGroup可以是统一实例
      * 第一组只包含一个ServerChannel
        * 代理服务器自身的已绑定到某个本地端口的正在监听的套接字
      * 第二组包含所有用来处理传入客户端连接的Channel
