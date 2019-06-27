

分布式跟踪系统（二）：Zipkin的Span模型 - 开源软件 - ITeye资讯 http://www.iteye.com/news/32002


在《分布式跟踪系统（一）：Zipkin的背景和设计》一文中，已经初步的介绍了Zipkin的设计和数据模型，本文将详细介绍Zipkin的Span模型，以及其他“另类”Span模型的设计。
          这里多一句嘴，其实专业点的叫法应该是分布式追踪系统——Distributed Tracing System，跟踪比较适合用于人的场景，比如某人被跟踪了，而追踪更适合用于计算机领域。然并卵？本文将继续使用“跟踪”。
        Zipkin的Span模型几乎完全仿造了Dapper中Span模型的设计，我们知道，Span用来描述一次RPC调用，所以一个RPC调用只应该关联一个spanId（不算父spanId），Zipkin中的Span主要包含三个数据部分：
基础数据：用于跟踪树中节点的关联和界面展示，包括traceId、spanId、parentId、name、timestamp和duration，其中parentId为null的Span将成为跟踪树的根节点来展示，当然它也是调用链的起点，为了节省一次spanId的创建开销，让顶级Span变得更明显，顶级Span中spanId将会和traceId相同。timestamp用于记录调用的起始时间，而duration表示此次调用的总耗时，所以timestamp+duration将表示成调用的结束时间，而duration在跟踪树中将表示成该Span的时间条的长度。需要注意的是，这里的name用于在跟踪树节点的时间条上展示。

# Annotation

Annotation数据主要用于用户点击一个Span节点时展示具体的Span信息。

Annotation记录关键事件
* cs（Client Send）
* sr（Server Receive）
* ss（Server Send）
* cr（Client Receive）

每种关键事件包含value、timestamp和endpoint
* value就是cs、sr、ss和cr中的一种
* timestamp表示发生的时间
* endpoint用于记录发生的机器（ip）和服务名称（serviceName）。
  * cs和cr、sr和ss的机器名称是相同的。

# BinaryAnnotation

BinaryAnnotation数据：绑定一些业务数据（日志）

* ca: client address
* sa: server address
      
现在我们已经了解了一个Span的内部结构，但这是Span的最终形态，也就是说这是Zipkin在收集完数据并展现给用户锁看到的最终形态。Span的产生是“不完整”的，Zipkin服务端需要将搜集的有同一个traceId和spanId的Span组装成最终完整的Span，也就是上面说到的Span。可能这样说不太直观，我们沿用下图来举例说明：
 
上图在我的第一篇Zipkin博文中已经用到过，这里不再详细阐述，我们直接看该图对应的内部Span细节图：

span数据流转（图2）

注意，上图并没有显示Span的所有细节（比如name和binaryAnnotation等），但这并不影响我们分析问题。上图的①和⑥是一次完整的RPC调用，它发生在服务器0和服务器1之间，显而易见的是，用于描述该RPC调用的Span的spanId是1000，所以，这是同一个Span的，只是它的数据来源于两台不同的服务器（应用）：服务器0和服务器1。往低层说，该Span由两条跟踪日志表示，一条在服务器0上被采集，另一条在服务器1上被采集，他们的Span的traceId、spanId和parentSpanId都是一样的！而且该Span将成为跟踪树中的顶节点，因为他们的parentSpanId为null。对于步骤①来说，服务器1上的sr减去服务器0上的cs的时间就是约等于网络耗时（这里忽略不同服务器时钟的差异），同理，对于其他步骤，sr-cs和cr-ss得到的都是网络耗时。我们接着看请求步骤②和④，从跟踪树的层次来说他们属于①下的子调用，所以它们的parentSpanId就是①的1000。步骤②和④都会分别产生一个spanId（上面的1001和1002），所以如上图，看似一次简单的RPC过程，其实共产生了6条Span日志，它们将在Zipkin服务端组装成3个Span。

那么，问题来了，此次调用在服务器1上出现了3个spanId：1000、1001和1002，如果我想记录服务器1上和此次调用的业务数据（通过BinaryAnnotation来记录），是将这些数据绑定到哪个Span上呢？如果让我们选择，我们肯定选择1000，因为服务器1上此次请求中调用下游的服务是不确定的（虽然图中只画了服务器2和服务器3），有可能它会调用下游的十几个服务，产生十几个spanId，相对而将业务数据言绑定到这些Span的父Span（1000）上似乎更合理。并且在产生业务日志时，有可能还没开始进行下游调用，所以也只能绑定在1000上。

我们先来看看图2中的Span在Zipkin的跟踪树中大概会显示成什么样子，如下图：

Zipkin跟踪树（图3）
当然，部分数据会和图2中的不一样（比如timestamp和duration），但并不影响我们分析问题。可以看出，在Zipkin中最小的时间单位是微秒（千分之一毫秒），所以图3中展现的此次RPC总耗时为96.2ms，有人刚开始看肯定会疑问，为啥经历过四个服务器的RPC调用在图中的跟踪树中只有三个节点？因为在跟踪树中， 一个Span（准确的说是一个spanId）只会展现成一个树节点，比如树节点Service1表示了Gateway（服务器0）调用Service1（服务器1）的过程，树节点Service2表示Service1（服务器1）调用Service2（服务器2）的过程。有人肯定会问，对于树节点Service1，我们记录了cs、sr、ss和cr四个时间，但时间条的显示只用到了cs和cr（耗时duration=cr-cs），那么sr和ss去哪了（别忘了我们可以通过sr-cs和cr-ss计算网络耗时）？我们可以单击Serice1节点，于是打开了Span的详细信息（Span的annotation和binaryAnnotation数据），如下图：

Span详细信息（图4）
Relative Time 是相对时间，表示此事件（cs、sr、ss、cr）已经发生了多久（相对起始时间点），因为Service1是顶级节点，所以第一行的Relative Time是空的，于是乎，该请求的网络耗时（Gateway请求Service1）为10ms，应答的网络耗时（Service1应答Gateway）为96.3-94.3=2ms，所以，从Zipkin目前的页面设计来看，网络耗时只能通过点树节点的详细信息页面来看，而且还需要做简单的计算，并不直观。淘宝的鹰眼系统通过在时间条上分为两种颜色来显示，使用了cs、sr、ss和cr四个时间戳，更加直观。
          
可能大多数人觉得对于跨四个系统的RPC调用却只显示三个节点，有些别扭。对于图1的调用，我们更希望是Gateway的节点下挂着一个Service1节点，表示Gateway调用了Service1，而Service1节点下挂着Service2和Service3两个节点，表示Service1调用了Service2和Service3，这样更容易理解。于是我们想到了在RPC链路中经过某个节点（服务器应用），那么这个节点就产生几个spanId，这样的话，在图中RPC经过Gateway、Service1、Service2和Service3各一次，所以一共将产生4个spanId（Zipkin在图2中只产生3个spanId），这样就变成了spanId和节点个数一致（前提是RPC链路中只经过每个节点各一次，也就是节点之间没有相互依赖）。这样设计Span数据的流转如下图：

修改过的Span数据流转（图5）
图5中可以很明显的看出，还是6条Span的日志，每个服务器节点上会产生一个spanId（1000、1001、1002和1003），而不是像原有图2一样只有3个spanId。这样还有一个好处，就是RPC调用时只需要传递traceId和spanId，而不是像Zipkin的设计那样，需要传递traceId、spanId还有parentSpanId。但立马我们就发现了问题，在图5的服务器1的节点上，1001的spanId记录了两套cs和cr，则也导致了无法区分哪个对应的是调用服务器2，哪个对应的是调用服务器3，所以，这种设计方案直接被否决了。
        于是我们换一种思路，不采用spanId和parentSpanId，换成spanId和childSpanId，childSpanId由父亲节点生成并传递给子节点，如下图：

新的Span数据流转（图6）
<!--StartFragment--> <!--EndFragment-->
从图6可以看到明显的变化，不再有parentSpanId，而使用了childSpanId，这样RPC之间传递的就是traceId和childSpanId，这也直接解决了图5中所遇到的问题。虽然图5和图6的设计违背了一次RPC调用由一个spanId的数据来进行维护的设计理念，但确实在跟踪树的界面展示上更容易让人接受和理解（树节点和服务器节点对应），而且还减少了RCP间的数据传送，何乐而不为？