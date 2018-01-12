分布式跟踪系统（一）：Zipkin的背景和设计 - CSDN博客 http://blog.csdn.net/manzhizhen/article/details/52811600

2010年谷歌发表了其内部使用的分布式跟踪系统Dapper的论文（http://static.googleusercontent.com/media/research.google.com/zh-CN//archive/papers/dapper-2010-1.pdf，译文地址：http://bigbully.github.io/Dapper-translation/），讲述了Dapper在谷歌内部两年的演变和设计、运维经验，Twitter也根据该论文开发了自己的分布式跟踪系统Zipkin，并将其开源，但不知为啥没有贡献给Apache。其实还有很多的分布式跟踪系统，比如Apache的HTrace，阿里的鹰眼Tracing、京东的Hydra、新浪的Watchman等。

      大型互联网公司为什么需要分布式跟踪系统？为了支撑日益增长的庞大业务量，我们会把服务进行整合、拆分，使我们的服务不仅能通过集群部署抵挡流量的冲击，又能根据业务在其上进行灵活的扩展。一次请求少则经过三四次服务调用完成，多则跨越几十个甚至是上百个服务节点。如何动态展示服务的链路？如何分析服务链路的瓶颈并对其进行调优？如何快速进行服务链路的故障发现？这就是服务跟踪系统存在的目的和意义。

     即使作为分布式系统的开发者，也很难清楚的说出某个服务的调用链路，况且服务调用链路还是动态变化的，这时候只能咬咬牙翻代码了。接下来，我们看看Zipkin是如何做到这一点的。在这之前，我们先来简单讨论一下分布式跟踪系统的设计要点，第一点：对应用透明、低侵入。为什么说这一点最重要？因为分布式系统面对的客户是开发者，如果他们的系统需要花费较大的改造才能接入你的分布式跟踪系统，除非你是他的老板，否则他会直接和你说：No！！没人用是最惨的结果。那么怎么才能做到对业务系统最低的侵入性呢？Dapper给出的建议是在公共库和中间件上做文章。没错，分布式系统之间的通讯靠的都是RPC、MQ等中间件系统，即使是内部使用的线程池或者数据库连接池，大多也是使用经过公司包装公共库，这就给服务跟踪带来了机会，我只要对中间件和公共库进行改造，就几乎可以做到全方位跟踪，当然，这也是有难度的；第二点：低开销、高稳定。大多数应用不愿意接入监控系统的原因是怕影响线上服务器的性能，特别是那些对性能特别敏感的应用，所以，分布式跟踪系统一定要轻量级，不能有太复杂的逻辑和外部依赖，甚至需要做到根据服务的流量来动态调整采集密度。第三点：可扩展。随着接入的分布式系统的增多，压力也将不断增长，分布式跟踪系统是否能动态的扩展来支撑不断接入的业务系统，这也是设计时需要考虑的。可以看出，这三点并没有什么特别，对于服务降级系统、分布式跟踪系统和业务监控系统等，这三点都是必须的。

     回到主题，Zipkin的设计，一般的分布式跟踪系统数据流主要分为三个步骤：采集、发送和落盘分析，我们来看Zipkin官网给出的设计图：

 

Zipkin结构(图1)

 

      这里埋怨一下，Zipkin官网的内容太过简单（难道是因为懒才懒得去Apache孵化？），也许Twitter认为有谷歌Dapper那边文章就足够了吧。我们看上图，其中的S表示的是发送跟踪数据的客户端SDK还是Scribe的客户端(因为Twitter内部采用的就是Scribe来采集跟踪数据)？效果都一样，总而言之我们看到的就是各个应用、中间件甚至是数据库将跟踪数据发送到Zipkin服务器。

       总体设计没什么特别，我们看下内部的数据模型是怎么设计的。一般的调用链都可以展现成一颗树，比如下面的简单调用：


简单的服务调用(图2)

 

        上图描述的服务调用场景应该是很常见也很简单的调用场景了，一个请求通过Gateway服务路由到下游的Service1，然后Service1先调用服务Service2，拿到结果后再调用服务Service3，最后组合Service2和Service3服务的结果，通过Gateway返回给用户。我们用①②③④⑤⑥表示了RPC的顺序，那么，什么是span？span直译过来是"跨度"，在谷歌的Dapper论文中表示跟踪树中树节点引用的数据结构体，span是跟踪系统中的基本数据单元，Dapper的论文中，并没有具体介绍span中的全部细节，但在Zipkin中，每个span中一般包含如下字段：

traceId：全局跟踪ID，用它来标记一次完整服务调用，所以和一次服务调用相关的span中的traceId都是相同的，Zipkin将具有相同traceId的span组装成跟踪树来直观的将调用链路图展现在我们面前。这里直接给出Zipkin官网中的一张Zipkin界面的图：


Zipkin界面展现的跟踪树(图3)

 

id：span的id，理论上来说，span的id只要做到一个traceId下唯一就可以，比如说阿里的鹰眼系统巧妙用span的id来体现调用层次关系（例如0，0.1，0.2，0.1.1等），但Zipkin中的span的id则没有什么实际含义。

parentId：父span的id，调用有层级关系，所以span作为调用节点的存储结构，也有层级关系，就像图3所示，跟踪链是采用跟踪树的形式来展现的，树的根节点就是调用调用的顶点，从开发者的角度来说，顶级span是从接入了Zipkin的应用中最先接触到服务调用的应用中采集的。所以，顶级span是没有parentId字段的，拿图2所展现的例子来说，顶级span由Gateway来采集，Service1的span是它的子span，而Service2和Service3的span是Service1的span的子span，很显然Service2和Service3的span是平级关系。

name：span的名称，主要用于在界面上展示，一般是接口方法名，name的作用是让人知道它是哪里采集的span，不然某个span耗时高我都不知道是哪个服务节点耗时高。

timestamp：span创建时的时间戳，用来记录采集的时刻。

duration：持续时间，即span的创建到span完成最终的采集所经历的时间，除去span自己逻辑处理的时间，该时间段可以理解成对于该跟踪埋点来说服务调用的总耗时。

annotations：基本标注列表，一个标注可以理解成span生命周期中重要时刻的数据快照，比如一个标注中一般包含发生时刻（timestamp）、事件类型（value）、端点（endpoint）等信息，这里给出一个标注的json结构：

{

            "timestamp":1476197069680000,

            "value": "cs",

            "endpoint": {

                "serviceName": "service1",

                "ipv4": "xxx.xxx.xxx.111"

            }

 }

那么，有哪些事件类型呢？答案是四种：cs（客户端/消费者发起请求）、cr（客户端/消费者接收到应答）、sr（服务端/生产者接收到请求）和ss（服务端/生产者发送应答）。可以看出，这四种事件类型的统计都应该是Zipkin提供客户端来做的，因为这些事件和业务无关，这也是为什么跟踪数据的采集适合放到中间件或者公共库来做的原因。

binaryAnnotations：业务标注列表，如果某些跟踪埋点需要带上部分业务数据（比如url地址、返回码和异常信息等），可以将需要的数据以键值对的形式放入到这个字段中。

说到这里，大家对span的印象可能还是有点模糊不清，于是我们继续拿图2的服务调用来举例，如果我们将图2的应用接入Zipkin，将会是下图的效果：


接入Zipkin后(图4)

 

         这里我们看到，Gateway、Service1、Service2和Service3都在往Zipkin发送跟踪数据，你一定会感觉奇怪，Gateway作为服务调用的起点，难道不是由Service1、Service2和Service3把各自的跟踪数据传回Gateway然后再由Gateway统计并整理好一并发往Zipkin服务端吗？认真想想就知道这种设计的弊端，如果一次完整的服务请求调用链路特长，比如设计上百个服务节点的通讯，那么将各服务节点的span信息传回给顶级span和将跟踪数据汇总并发送到Zipkin将带来巨大的网络开销，这是不值当的，还不如将跟踪数据组装的任务直接交给Zipkin来做，这样Zipkin的客户端SDK不需要有过于复杂的逻辑，也节省了大量的网络带宽资源，可扩展性大大提高。

       需要注意的是，并不是每个span上都会完整的发生cs、cr、sr和ss这四种事件，比如图4中Gateway上的span只会有cs和cr，因为Gateway没有上游应用，Service2和Service3上的span有sr和ss，但不会有cs和cr，因为对于此次服务调用来说，Service2和Service3并不依赖下游任何应用服务。但对于Service1来说就复杂得多，它将产生三个Span，接收和应答Gateway是一个span，调用和接收Service2是一个span，调用和接收Service3是第三个span，注意，一个span只能用于记录两个应用之间的服务调用，所以不能将这三个span信息合成一个。由cs、cr、sr和ss事件的时间，可以得出很多时间数据，例如：

请求总耗时 =Gateway.cr - Gateway.cs

①的网络耗时 = Service1.sr - Gateway.cs

Service1的调用Service2的耗时 = Service1.cr - Service1.cs （图4中Service1节点上的第二个span中的cr和cs）

Service1的调用Service3的耗时 = Service1.cr - Service1.cs （图4中Service1节点上的第三个span中的cr和cs）

④的网络耗时 = Service3.sr - Service1.cs （图4中Service1节点上的第三个span中的cs）

可以这样说，如果采集到这些span，几乎所有阶段的耗时都可以计算出来。

        如果要推广Zipkin，除了Zipkin服务端要有出色的扩展性和友好丰富的数据展示界面外，提供多种类型的客户端SDK也是很重要的，因为跟踪数据的采集都是有中间件和公共库做的，所以SDK不应该太过复杂，最理想的做法是官方给一些著名开发语言和中间件提供默认的SDK实现，目前根据Zipkin的官方说明，已经给Go（zipkin-go-opentracing）、Java（brave）、JavaScript（zipkin-js）、Ruby（zipkin-ruby）和Scala（zipkin-finagle）提供了官方的库，社区方面也很给力，提供了多种方案的库实现，详见：http://zipkin.io/pages/existing_instrumentations.html。

       

     分布式跟踪系统（二）：Zipkin的Span模型 :  http://blog.csdn.net/manzhizhen/article/details/53865368

       

       最后，给出图4四个服务采集的span数据样例：

# Gateway的span

{

    "traceId":"daaed0921874ebc3",

    "id":"daaed0921874ebc3",

    "name": "get",

    "timestamp": 1476197067420000,

    "duration": 4694000,

    "annotations": [

        {

            "timestamp":1476197067420000,

            "value": "cs",

            "endpoint": {

                "serviceName":"gateway",

                "ipv4": "xxx.xxx.xxx.110"

            }

        },

        {

            "timestamp":1476197072114000,

            "value": "cr",

            "endpoint": {

                "serviceName":"gateway",

                "ipv4": "xxx.xxx.xxx.110"

            }

        }

    ],

    "binaryAnnotations": [

        {

            "key":"http.url",

            "value": "http://localhost:8080/service1",

            "endpoint": {

                "serviceName":"gateway",

                "ipv4": "xxx.xxx.xxx.110"

            }

        }

    ]

}

 

# Service1的三个span

{

    "traceId":"daaed0921874ebc3",

    "id":"411d4c32c102a974",

    "name": "get",

    "parentId":"daaed0921874ebc3",

    "timestamp": 1476197069680000,

    "duration": 1168000,

    "annotations": [

        {

            "timestamp":1476197069680000,

            "value": "cs",

            "endpoint": {

                "serviceName":"service1",

                "ipv4": "xxx.xxx.xxx.111"

            }

        },

        {

            "timestamp":1476197070848000,

            "value": "cr",

            "endpoint": {

                "serviceName":"service1",

                "ipv4": "xxx.xxx.xxx.111"

            }

        }

    ],

    "binaryAnnotations": [

        {

            "key":"http.url",

            "value": "http://localhost:8089/service2",

            "endpoint": {

                "serviceName":"service1",

                "ipv4": "xxx.xxx.xxx.111"

            }

        }

    ]

}

 

{

    "traceId":"daaed0921874ebc3",

    "id":"7c0d7d897a858217",

    "name": "get",

    "parentId":"daaed0921874ebc3",

    "timestamp": 1476197070850000,

    "duration": 1216000,

    "annotations": [

        {

            "timestamp":1476197070850000,

            "value": "cs",

            "endpoint": {

                "serviceName":"service1",

                "ipv4": "xxx.xxx.xxx.111"

            }

        },

        {

            "timestamp":1476197072066000,

            "value": "cr",

            "endpoint": {

                "serviceName":"service1",

                "ipv4": "xxx.xxx.xxx.111"

            }

        }

    ],

    "binaryAnnotations": [

        {

            "key":"http.url",

            "value": "http://localhost:8090/service3",

            "endpoint": {

                "serviceName":"service1",

                "ipv4": "xxx.xxx.xxx.111"

            }

        }

    ]

}

 

{

    "traceId":"daaed0921874ebc3",

    "id":"daaed0921874ebc3",

    "name": "get",

    "timestamp": 1476197067623000,

    "duration": 4479000,

    "annotations": [

        {

            "timestamp":1476197067623000,

            "value": "sr",

            "endpoint": {

                "serviceName":"service1",

                "ipv4": "xxx.xxx.xxx.111"

            }

        },

        {

            "timestamp":1476197072102000,

            "value": "ss",

            "endpoint": {

                "serviceName":"service1",

                "ipv4": "xxx.xxx.xxx.111"

            }

        }

    ],

    "binaryAnnotations": [

        {

            "key":"http.status_code",

            "value": "200",

            "endpoint": {

                "serviceName":"service1",

                "ipv4": "xxx.xxx.xxx.111"

            }

        },

        {

            "key":"http.url",

            "value":"/service1",

            "endpoint": {

                "serviceName":"service1",

                "ipv4": "xxx.xxx.xxx.111"

            }

        }

    ]

}

 

# Service2 的span

{

    "traceId":"daaed0921874ebc3",

    "id":"411d4c32c102a974",

    "name": "get",

    "parentId":"daaed0921874ebc3",

    "timestamp": 1476197069806000,

    "duration": 1040000,

    "annotations": [

        {

            "timestamp":1476197069806000,

            "value": "sr",

            "endpoint": {

                "serviceName": "service2",

                "ipv4": "xxx.xxx.xxx.112"

            }

        },

        {

            "timestamp":1476197070846000,

            "value": "ss",

            "endpoint": {

                "serviceName": "service2",

                "ipv4": "xxx.xxx.xxx.112"

            }

        }

    ],

    "binaryAnnotations": [

        {

            "key":"http.status_code",

            "value": "200",

            "endpoint": {

                "serviceName": "service2",

                "ipv4": "xxx.xxx.xxx.112"

            }

        },

        {

            "key":"http.url",

            "value":"/service2",

            "endpoint": {

                "serviceName": "service2",

                "ipv4": "xxx.xxx.xxx.112"

            }

        }

    ]

}

 

# Service3的span

{

    "traceId":"daaed0921874ebc3",

    "id":"7c0d7d897a858217",

    "name": "get",

    "parentId":"daaed0921874ebc3",

    "timestamp": 1476197071011000,

    "duration": 1059000,

    "annotations": [

        {

            "timestamp":1476197071011000,

            "value": "sr",

            "endpoint": {

                "serviceName": "service3",

                "ipv4": "xxx.xxx.xxx.113"

            }

        },

        {

            "timestamp":1476197072070000,

            "value": "ss",

            "endpoint": {

                "serviceName": "service3",

                "ipv4": "xxx.xxx.xxx.113"

            }

        }

    ],

    "binaryAnnotations": [

        {

            "key":"http.status_code",

            "value": "200",

            "endpoint": {

                "serviceName": "service3",

                "ipv4": "xxx.xxx.xxx.113"

            }

        },

        {

            "key":"http.url",

            "value":"/service3",

            "endpoint": {

                "serviceName": "service3",

                "ipv4": "xxx.xxx.xxx.113"

            }

        }

    ]

}

版权声明：本文为博主manzhizhen的原创文章，未经博主允许不得转载。