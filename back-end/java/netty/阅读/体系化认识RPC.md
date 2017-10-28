

* [体系化认识RPC ](http://www.infoq.com/cn/articles/get-to-know-rpc)
* [neo时刻准备着 ](http://neoremind.com/)

* RPC
  * RPC（Remote Procedure Call），即远程过程调用
  * RPC 最核心要解决的问题就是在分布式系统间，如何执行另外一个地址空间上的函数、方法，就仿佛在本地调用一样
* 传输(Transport)
  * TCP的关键词
    * 面向连接的，全双工，可靠传输（按序、不重、不丢、容错），流量控制（滑动窗口）
  * RPC中的嵌套header+body
    * 协议栈每一层都包含了下一层协议的全部数据，只不过包一个头而已
    * RPC传输的message也就是TCP body中的数据。body通常叫做payload
    * TCP就是可靠的把数据在不同的地址空间上搬运
* I/O模型(I/O Model)
  * 种类
    * 传统的阻塞I/O
    * 非阻塞I/O
    * I/O多路复用
    * 异步I/O
* I/O多路复用
  * 基于内核，建立在epoll或者kqueue上实现
  * 用户在一个线程内同时处理多个Socket的I/O请求
  * 通过一个线程监听全部的TCP连接，有任何时间发生就通知用户态处理
* 协议结构
  * Frame、Packete、Segment映射为数据链路层、IP层和TCP层的数据包
  * TCP粘包和半包
    * 解决方法
      * 分隔符
      * 换行符
      * 固定长度