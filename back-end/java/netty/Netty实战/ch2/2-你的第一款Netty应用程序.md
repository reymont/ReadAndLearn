
# 第2章　你的第一款Netty应用程序

* 通过ChannelHandler来构建应用程序的逻辑

## 2.1  设置开发环境

### 2.1.1  获取并安装Java开发工具包

### 2.1.2  下载并安装IDE

### 2.1.3  下载和安装Apache Maven

### 2.1.4  配置工具集

## 2.2  Netty客户端/服务器概览

## 2.3  编写Echo服务器

* Netty服务器
  * ChannelHandler实现服务器处理客户端的数据
  * 引导：配置服务器的启动代码，将监听连接请求的端口

### 2.3.1  ChannelHandler和业务逻辑

* @Sharable标示一个ChannelHandler可以被多个Channel安全地共享
* ChannelHandler
  * 接口族的父接口
  * 实现负责接收并响应事件通知
* ChannelInboundHandler
  * channelRead()对于每个传入的消息都要调用
  * channelReadComplete()
  * exceptionCaught()
* 关键点
  * 针对不同类型的事件来调用ChannelHandler
  * ChannelHandler有助于保持业务逻辑与网络处理代码的分离

### 2.3.2  引导服务器

* 引导过程中步骤
  * 创建一个ServerBootstrap的实例以引导和绑定服务器
  * 创建并分配一个NioEventLoopGroup实例以进行事件的处理
  * 指定服务器绑定的本地InetSocketAddress
  * 使用一个EchoServerHandler的实例初始化每一个新的Channel
  * 调用ServerBootstrap.bind()方法以绑定服务器

## 2.4  编写Echo客户端

* 编写客户端两个主要代码：业务逻辑和引导

### 2.4.1  通过ChannelHandler实现客户端逻辑

* SimpleChannelInboundHandler
  * channelActive()建立服务器连接
  * channelRead0()服务器接收到一条消息
    * 由服务器发送的消息可能会被分块接收
  * exceptionCaught()

### 2.4.2  引导客户端

* 引导客户端的要点
  * 初始化客户端，创建Bootstrap实例
  * 为进行事件处理分配NioEventLoopGroup实例
  * 为服务器连接创建InetSocketAddress实例
  * 调动Bootstrap.connect()方法连接到远程节点

## 2.5  构建和运行Echo服务器和客户端

mvn clean package
mvn exec:java