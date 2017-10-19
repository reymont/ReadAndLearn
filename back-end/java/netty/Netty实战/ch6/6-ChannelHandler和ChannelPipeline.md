

# 第6章　ChannelHandler和 ChannelPipeline

* ChannelPipeline中将ChannelHandler链接在一起以组织处理逻辑

## 6.1  ChannelHandler家族

### 6.1.1  Channel的生命周期

* Channel的生命周期
  * ChannelUnregistered：Channel已被创建，未注册到EventLoop
  * ChannelRegistered：Channel注册到EventLoop
  * ChannelActive：处于活动状态，可以接收和发送数据
  * ChannelInactive：没有连接到远程节点

### 6.1.2  ChannelHandler的生命周期

* ChannelHandler的生命周期
  * 将ChannelHandler从ChannelPipeline中添加或移除时调用
  * 生命周期方法
    * handlerAdded
    * handlerRemoved
    * exceptoinCaught

### 6.1.3  ChannelInboundHandler接口

* ChannelInboundHandler
  * 数据被接收时或状态发生改变时
  * 方法
    * channelRegistered：注册到EventLoop并能够处理IO
    * channelUnregistered：从EventLoop注销并无法处理IO
    * channelActive：已连接、已就绪
    * channelInactive：离开活动状态，不再连接远程节点
    * channelReadComplete：读操作完成
    * channelRead：读取数据时
    * ChannelWritabilityChanged：可写状态发生改变时被调用
    * useEventTriggered：fireUserEventTriggered()调用时被调用
  * 资源
    * ReferenceCountUtil.release()显式的释放与池化的ByteBuf实例相关的内存
    * SimpleChannelInboundHandler会自动释放资源

### 6.1.4  ChannelOutboundHandler接口

* ChannelOutboundHandler
  * 按需推迟操作或事件
  * 方法
    * bind()：当请求绑定本地地址时调用
    * connect()：连接到远程节点时调用
    * disconnect()：远程节点断开时调用
    * close()：请求关闭Channel时调用
    * deregister()：从EventLoop注销时调用
    * read()：读取数据时调用
    * flush()：入队数据冲刷到远程节点时调用
    * write()：数据写到远程节点时调用
  * ChannelPromise
    * 操作完成时得到通知
    * 是ChannelFuture的子类

### 6.1.5  ChannelHandler适配器

* ChannelHandlerAdapter
  * isShareable()，@Sharable
  * true，可被添加到多个ChannelPipeline中

### 6.1.6  资源管理

* 资源管理
  * Netty使用引用计数来处理池化的ByteBuf
  * ResourceLeakDetector对应用程序的缓冲区分配做1%的采样来检测内存泄露
* 4种泄露检测级别
  * DISABLE：禁用泄露检测
  * SIMPLE：使用1%的默认采样检测，报告任何发现的的泄露
  * ADVANCE：使用1%的默认采样检测，报告任何发现的的泄露以及对应消息被访问的位置
  * PARANOID：对每次访问都进行采样，性能影响大
* java -Dio.netty.leakDetectionLevel=ADVANCED
* 一个消息被消费或丢弃，则需调用ReferenceCountUtil.release()

## 6.2  ChannelPipeline接口

* ChannelPipeline
  * 每一个新创建的Channel都将会被分配一个新的ChannelPipline
  * 关联是永久性的，Channel既不能附加另外一个ChannelPipeline，不能分离其当前的
* ChannelHandlerContext
  * 使ChannelHandler与ChannelPipeline以及其他的ChannelHandler交互

### 6.2.1  修改ChannelPipeline

* ChannelPipeline
  * ChannelHandler可以通过添加、删除或者替换其他的ChannelHandler来实时的修改ChannelPipeline的布局
  * 布局
    * AddFirst、addBefore、addAfter、addLast
    * remove
    * replace
* ChannelHandler的执行和阻塞
  * ChannelPipeline中的每一个ChannelHandler都是通过EventLoop来处理

### 6.2.2  触发事件

* ChannelPipeline
  * 保存与Channel相关联的ChannelHandler
  * 添加或删除ChannelHandler来动态修改
  * 响应入站和出站事件

## 6.3  ChannelHandlerContext接口

