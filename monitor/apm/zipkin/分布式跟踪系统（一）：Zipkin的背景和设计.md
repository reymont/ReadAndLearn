

* [分布式跟踪系统（一）：Zipkin的背景和设计 - 大步流星 - ITeye博客 ](http://manzhizhen.iteye.com/blog/2348175)

* 分布式跟踪系统
  * Twitter：Zipkin
  * naver: Pinpoint
  * Apache: HTrace
  * 阿里：鹰眼Tracing
  * 京东：Hydra
  * 新浪：Watchman
* 设计要点
  * 对应用透明、低侵入
    * 在公共库和中间件上做文章，RPC、MQ
  * 低开销、高稳定
  * 可扩展
* 系统数据流主要分三个步骤
  * 收集
  * 发送
  * 落盘分析
* span
  * 跨度，跟踪树中树节点引用的数据结构体
  * 跟踪系统中的基本数据单元
  * 字段
    * traceId
      * 全局跟踪ID，用来标记一次完整服务调用
      * 一次服务调用相关的span中的traceId都是相同的
    * id
      * span的id，一个traceId唯一
    * parentId
      * 调用层次结构
    * name
      * span的名称，一般是接口方法名
    * timestamp
    * duration
    * annotations
    * binaryAnnotations：业务标准列表
* 事件类型
  * cs：客户端/消费者发起请求
  * cr：客户端/消费者接收到应答
  * sr：服务端/生产者接收到请求
  * ss：服务端/生产者发送应答
* 跟踪数据的采集适合放到中间件或公共库来做