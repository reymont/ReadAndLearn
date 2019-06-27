华为微服务框架ServiceComb的简要介绍 - 简书 https://www.jianshu.com/p/ba432eae0a8f

华为微服务框架ServiceComb的简要介绍

话说菊花厂真的对开源不是很上心，很多时候都仅仅是受限于GPL而开源。不过今天介绍的项目不同，此项目由2012架构部专家亲自编写，并已经在内部商用，质量很好，值得一读。

目前我所接触的微服务框架

阿里的Dubbo: 基于SpringScheme+zk实现，是比较重的框架（一堆XML配置），是国内中小企业事实上的SOA标准，阿里内部新版未开源。自己没环境折腾，只大致看了下源码。
HW的BDF框架: 原理基本同上，内部使用，闭源项目不展开介绍。我个人认为这个更加先进一些，因为它还支持FAAS函数调用。
HW的ServiceComb框架: HWCloud在6月发布开源的一款微服务框架，基于Go/YAML进行配置，部署特别快，源码量也小，可以轻松地在一台机子上分析与断点。
今天主要来介绍一下HW分布式框架的ServiceComb的注册发布实现，文章还是老套路(编译、Log与断点)

分享一下当前微服务的一些热点信息
对ServiceComb搭建演示进行简要介绍
对生产者与消费者的调用流程进行源码分析(编译、Log与断点)
关键词: SOA, MicroService, ServiceDiscovery, NamingService, Golang

1. 为什么要微服务化？

微服务看起来似乎还是很先进，很学术的概念，实际上在当前已经有70%的组织使用了微服务。它将单体应用分解为多个，并分别部署到独立的容器上，通过RPC(比如MQ、HTTP或者私有TCP实现)开放接口。这样做有如下作用

降低开发耦合度，减小部门墙: 所有业务通信全部通过文档/DSL进行规范，白纸黑字大家都认可，接口还可抓包定位谁的责任。
小组内定制能力加强: 通过将单体分解为小组件，小组内部可以自己选择工具、语言、DevOpts实践，提高自由度。
改造已有的系统，通过微服务将所有子业务进行整合。
当然，微服务也有一些坑

架构依赖专家单点水平: 如果搞出一个全局的、互相依赖的服务，那么整个架构就是一团麻绳(特别是公共模块，万一设计不完善，后期要加倍还)。
定位部署较复杂: 由于业务横向部署到集群组网中，生产环境的日志，断点，错误信息很难找出来。
我个人的观点还是和以前文章一样：随着PAAS等全面云化的发展，后端的技术方向要么是精通各种基础中间件架构，要么能解决领域问题(CRM, ERP, NPI等，它们业务学习曲线高，需要年限)，否则后期统统34岁会被干掉。

微服务还可以引申出更多的知识，可以参考两本书《SpringBoot揭秘》与《大型网站技术架构》
本文需要准备的工具

Intellij: 用于分析断点ServiceComb的Java侧代码
Gogland: 用于分析断点ServiceComb的Go语言写的注册发现服务
WireShark: 用于抓取注册发现时在本地环境(localhost)间的HTTP报文
POSTMAN: 用于测试与MockRESTful接口
ServiceComb的Java/Go源码: 用于分析代码
etcd: 用Go语言写的zk，在本文作为数据库，默认端口是2379与2380
2. ServiceComb框架简析

ServiceComb是HW云使用Go/Java语言开发的一款开源的PAAS中间件，作者在SyBase、TW等公司都是资深专家，后来被HW给挖过去了，具体介绍胶片可以看这里。大致看了一下源码，虽然目前Star不多，但是代码质量还是可以的，推荐学习。

2.1. 打通主流程

具体详见这里 ，如果你不想折腾Go编译的话，可以下载Windows现成的包，然后配置虚拟机端口

在分析Java代码时，建议开启Java EE: bean Validation Support插件
配置etcd

# 默认etcd启动命令
etcd --name my-etcd-1 --data-dir ./etcd-data --listen-client-urls http://127.0.0.1:2379 --advertise-client-urls http://127.0.0.1:2379 --listen-peer-urls http://127.0.0.1:2380 --initial-advertise-peer-urls http://127.0.0.1:2380
配置注册中心

git clone https://github.com/ServiceComb/service-center.git $GOPATH/src/github.com/servicecomb/service-center
cd $GOPATH/src/github.com/servicecomb/service-center
go get github.com/FiloSottile/gvt
# 此处不需要重复调用，也不要Ctrl-C，一次下载后就不用折腾了
gvt restore
go build -o service-center
# 测试执行，注意
# httpaddr,httpport为本地监听端口(默认127.0.0.1:9980)
# manager_cluster 为 etcd 缓存地址(listen-client-urls,默认127.0.0.1:2379)
cp -r ./etc/conf .
./service-center
使用IDEA导入项目后，分别运行

io/servicecomb/demo/pojo/server/PojoServer.java
io/servicecomb/demo/pojo/client/PojoClient.java
不出意外的话，现在已经成功调用了服务，那么就可以通过日志，断点进行进一步分析了。

2.2. 消费者侧的动态代理

我们从消费者侧开始分析，发现调用的是注解过的接口，老套路了，和Retrofit框架差不多。

有关动态代理，以前文章已经讲过了，动态代理的本质就是通过DSL生成InvocationHandler的一个Parser。

通过打断点得知，在启动时

在Spring的AbstractAutowireCapableBeanFactory中，调用了CseBeanPostProcessor的postProcessBeforeInitialization方法
扫描了所有class，并过滤出有@RpcReference注解的Field
通过@RpcReference注解构造Invoker对象，内部实现了基于Socket/HTTP的RPC调用
通过Proxy.newProxyInstance(consumerIntf.getClassLoader(), [consumerIntf], invoker)实例化接口
在被调用时

调用Invoker的invoke方法，并路由到Invocation并进行链式调用
分析就写这么多吧，涉及到Spring扫描Class，元数据(注解)解析，动态代理等技术，说白了就是一个注解的Parser，基本上是在干累活。

yaml文件是通过Swagger描述的微服务DSL，它将在启动时被反序列化为Microservice对象
2.3. Invoker链式调用

此处架构是本框架的精华，使用了Reactor设计，如果你没有定制过RxJava/Akka/Stream的操作符，或者没有【闭包也可以作为参数】前提的话，这部分代码是有一定分析难度的。

本部分代码如此少，以至于我可以把它贴出来

// 一个定制了 CountDownLatch 的 Executor
// 当计数为0时，主线程才由park变为run
SyncResponseExecutor respExecutor = new SyncResponseExecutor();
invocation.setResponseExecutor(respExecutor);
// 调用栈 next->handle->next->handle...
invocation.next(resp -> {
  respExecutor.setResponse(resp);
});
// 占位符: 当CountDownLatch计数为0时
// 主线程开始执行Runnable(来自TransportClient)
return respExecutor.waitResponse();
其中在第一步，初始化调用getHandlerChain构造完成了List<HandlerChain>，一共有4个

ShutdownHookHandler
ConsumerBizkeeperHandler
LoadbalanceHandler
TransportClientHandler
我们首先在它们的handle方法中打上断点，并在handle的next的λ表达式中也加入断点，并时刻注意线程是否变化。如果你不习惯λ表达式的话，可以通过IDE把它换成匿名Class

Java的Closure是通过接口模拟出来的，λ表达式简写特性我也非常不推荐，因为对于新接触代码的人来说就是噩梦，举个例子

invocation.next(resp -> {
  // 此处丢失了重要的信息，handle方法名没了
  respExecutor.setResponse(resp);
});
把它还原，它其实是一个拥有handle方法的匿名Class

invocation.next(new AsyncResponse() {
  @Override
  public void handle(Response resp) {
    respExecutor.setResponse(resp);
  }
});
通过重新改写为匿名Class，在后面调用rsp.handle(xx)时就不会一脸懵逼为何断点来回跳转了，此处代码风格比较类似Groovy中Closure.apply()方法，但是还是要强调Java的闭包只是模拟出来的
主线程请求调用链

这部分只要跟着断点走，next, handle,next,handle,next,handle,next,handle 看着代码，就可以一路下一步断点出来，最终通过VertX发送了Socket

NIO事件循环回掉

主线程使用VertX发送Socket后，会在NioEventLoop线程(基于Netty的Select调用)中onReply，通过CountDownLatch机制唤醒主线程，处理应答

tcpClientPool.send(tcpClient, clientPackage, ar -> {
    // 此时是在NioEventLoop网络线程中onReply，需要转换线程
    // 执行了 SyncResponseExecutor 的 run 方法，将 CountDownLatch 计数变为0时
    invocation.getResponseExecutor().execute(() -> {
        // 主线程wakeup后，才会调用下面的代码
        if (ar.failed()) {
            // 只会是本地异常
            asyncResp.consumerFail(ar.cause());
            return;
        }

        // 处理应答
        try {
            Response response =
                HighwayCodec.decodeResponse(invocation,
                        operationProtobuf,
                        ar.result(),
                        tcpClient.getProtobufFeature());
            // 调用next中的闭包
            asyncResp.complete(response);
        } catch (Throwable e) {
            asyncResp.consumerFail(e);
        }
    });
});
主线程反向消费handle闭包

主线程由于CountDownLatch计数为0，由park状态重新启动，开始执行decode操作，并反向消费next中的闭包，类似于andThen操作。如果你看过Akka的书籍，就可以发现这里本质上就是定制了各种消息处理器

TransportClientHandler(send)
LoadbalanceHandler
ConsumerBizkeeperHandler
ShutdownHookHandler
此部分断点非常难打，读者需要明白一点，基于消息的多线程与闭包混在一起时，一定要广撒网打断点

本项目中的链式回掉类似于栈的结构，而RxJava中的回掉类似于管道，本部分代码我觉得还有逻辑优化的空间，第一次看代码很难搞明白
2.4. RPC通信传输

此部分基于HTTP/私有Socket协议(HighWay)进行实现，HTTP基于JSON，比较简单。下面以自研Highway协议为例

传输语法: Protobuf(开源组件，二进制编码比文本更快)
抽象语法: 对OutputStream进行定制(HighwayCodec)，定制了报文的Header，Body与Length
Socket框架: Vert.x，并封装了连接池ClientPoolManager，线程池
有意向替换HTTP为私有Socket的开发者，可以尝试一下这种方案
连接池部分设计了一个Map<ThreadId,[CLIENT_POOL]>，实现了线程一对多，有点类似于RxJava中的ComputationScheduler

本部分的连接池是一个亮点，本文再写就超字数了，后续将详细分析

2.5. Provider的路由与消费

路由: 在NioEventLoop网络线程中通过Map<URL,Handler>进行路由
消费: 在新的线程池上进行链式调用invocation，最终通过ProducerOperationHandler进行Method.invoke反射调用
3. 基于etcd的ServiceDiscovery

etcd的简介

etcd是CoreOS开发的基于Go语言的分布式配置框架，etc就是linux中的/etc路径，一般用于放配置，而d是分布式的意思，它们俩加起来就是分布式配置。如果你用过Redis与Zookeeper，那么你看一遍etcd的文档就基本会折腾这个框架了

etcd在本项目中用于维护一个树，你可以把它看成一个远程的注册表，并支持监听目录变化
etcd支持HTTP/GRPC通信，比ZK/Redis的纯Socket稍微友好一点
性能比zk更加优秀，单文件(30M左右)，免JVM，部署方便
不要把它当作Redis来用，它不支持复杂的数据结构，而且使用场景是多写少读。
4. 总结

PAAS云化是趋势，处在传统软件的码农要跟上时代
ServiceComb用YAML(Swagger)与Java注解这种DSL代替了繁琐的XML，微服务的配置与开发变得更加简单了，以后将有更多的这类DSL，难怪很多人自嘲为XML工程师:)
Go语言在平台中间件软件中很有潜力，定位也很明确(Better C，虽然我个人觉得Go语法过于Shell风格了)
TODO

Go语言侧的分析
etcd的实现
Netty与vertx的分析(Socket开发)
5. 扩展阅读

一些其它的开源框架(go/java)，国内折腾的不多，有兴趣可以看下源码

一个分布式监控框架, http://riemann.io/
一个分布式鉴权框架, https://github.com/jepsen-io/jepsen
一个啥都能干的框架, http://vertx.io
官方公众号: servicecomb
胶片: http://servicecomb.io/slides/

作者：BlackSwift
链接：https://www.jianshu.com/p/ba432eae0a8f
來源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。