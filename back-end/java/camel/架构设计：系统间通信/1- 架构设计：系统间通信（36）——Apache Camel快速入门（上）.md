架构设计：系统间通信（36）——Apache Camel快速入门（上） - JAVA入门中 - CSDN博客 http://blog.csdn.net/yinwenjie/article/details/51692340

1、本专题主旨

1-1、关于技术组件

在这个专题中，我们介绍了相当数量技术组件：Flume、Kafka、ActiveMQ、Rabbitmq、Zookeeper、Thrift 、Netty、DUBBO等等，还包括本文要进行介绍的Apache Camel。有的技术组件讲得比较深入，有的技术组件则是点到为止。于是一些读者朋友发来信息向我提到，这个专题的文章感觉就像一个技术名词的大杂烩，并不清楚作者的想要通过这个专题表达什么思想。

提出这个质疑的朋友不在少数，所以我觉得有必要进行一个统一的说明。这个专题的名字叫做“系统间通讯”，在这个专题中我的讲解主要是围绕自己在实际工作中所总结的理论结构。从系统间通讯最基本的网络IO模型、消息格式、协议标准开始，再到搭建在其上的通讯组件，然后再关注更上层的进行通讯过程协调、统一通讯过程的中间件。这就是本专题的主旨。要说到本专题中笔者介绍的每一个技术组件，如果要做更深入的研究都可以再开新的专题，行业内各自都有很多的著作进行专门介绍。

那么为什么本专题中还要介绍这些技术组件呢？无非有三个原因：其一，是为了说清楚理论结构而服务。介绍JAVA对BIO、NIO和AIO三种网络IO模型的支持，是为了让读者对这三种网络模型的工作过程从感性过渡到理性；介绍RMI、Thrift是为了实例化笔者介绍的，搭建在网络IO模型上的RPC协议。其二，是笔者认为一些技术组件的设计思路，可以为各位架构师朋友在实际工作中所借鉴，例如笔者对DUBBO中一些功能模块的设计进行讲解、对Apache Thrift中序列化方式进行详细讲解就是出于第二个原因。其三，是因为本专题中设计的实战内容需要对将要用到的技术组件预先进行讲解。在本专题中，我们基于Thrift、Zookeeper自己设计了一个服务治理框架；我们还基于ActiveMQ、Kafka和Flume阐述了不同场景的日志系统设计方案。所以为了让更多的读者能够看懂这些技术方案，最好的方式就是将它们快速的介绍一下。

感谢那些在本专题中为了点“赞”的朋友，感谢那些在留言中向我提出修改意见、指出错误的朋友，特别是RMI的那篇文章犯的错误，太低级了。有你们的支持，让我觉得付出是有收获的；另外，目前这个系列的35片文章一共收到了7个“踩”，点“踩”的朋友能否在留言中为我指出文章的错误和不足，帮助我重新整理自己的思路，修正知识点的问题。谢谢。
1-2、关于代码示例

本专题中笔者贴出了占文章相当篇幅的代码片段，贴出这些代码片段主要也有三种可能的情况。其一，是为了各位读者快速了解某一种技术组件的基本使用；其二，是为了实现文章中描述的设计思路；其三，是为了进行技术验证，例如《架构设计：系统间通信（29）——Kafka及场景应用（中2）》文章中4-4-5小节列出的代码，是为了验证2013年2月2日，Kafka的主要参与者Neha Narkhede发表的一篇讲解Kafka Replication过程的技术文档。

有的读者向我提出，这些代码片段过于冗长，甚至有故意加长文章篇幅的目的。这个问题可能是我写作经验不足，给大家造成了困扰。不过，在文章中的贴出的代码为了达到相应的目的，都配有比较详细的注释说明，也为了避免各位读者在阅读代码时打瞌睡^_^。另外，我将在对这个专题文章的第二次整理时，会去掉类似于get/set这种性质的代码片段——它们确实有“占篇幅”之嫌。

1-3、关于抄袭

最后笔者认为抄袭是最卑劣的行为，所以本专题中的内容均是来源于笔者对键盘做功，涉及到的图例也是笔者一个一个画出来的，所有引用的图片、说明均注明出处。笔者欢迎转载，但未经授权请勿用于商业用途。

2、Apache Camel 快速入门

那么这里我们为什么又要花两篇文章的篇幅来介绍Apache Camel呢？因为后续文章中，在我们进行一款简单的ESB中间件设计时，我们将会依靠Apache Camel提供的协议转换、消息路由等核心能力。那么，就让我们开始吧！

2-1、Apache Camel介绍

Apache Camel的官网地址是http://camel.apache.org/，在本篇文章成文时最新的版本是V2.17.1，您可以通过多种手段进行下载。Apache Camel的官网并没有把Camel定义成一个ESB中间件服务，因为Camel并不是服务：

Camel empowers you to define routing and mediation rules in a variety of domain-specific languages, including a Java-based Fluent API, Spring or Blueprint XML Configuration files, and a Scala DSL. This means you get smart completion of routing rules in your IDE, whether in a Java, Scala or XML editor.

Apache Camel uses URIs to work directly with any kind of Transport or messaging model such as HTTP, ActiveMQ, JMS, JBI, SCA, MINA or CXF, as well as pluggable Components and Data Format options. Apache Camel is a small library with minimal dependencies for easy embedding in any Java application. Apache Camel lets you work with the same API regardless which kind of Transport is used - so learn the API once and you can interact with all the Components provided out-of-box.

Apache Camel provides support for Bean Binding and seamless integration with popular frameworks such as CDI, Spring, Blueprint and Guice. Camel also has extensive support for unit testing your routes.
以上引用是Apache Camel官方对它的定义。domain-specific languages指代的是DSL（领域特定语言），首先Apache Camel支持DSL，这个问题已经在上一篇文章中说明过了。Apache Camel支持使用JAVA语言和Scala语言进行DSL规则描述，也支持使用XML文件进行的规则描述。这里提一下，JBOSS提供了一套工具“Tools for Apache Camel”可以图形化Apache Camel的规则编排过程。

Apache Camel在编排模式中依托URI描述规则，实现了传输协议和消息格式的转换：HTTP, ActiveMQ, JMS, JBI, SCA, MINA or CXF等等。Camel还可以嵌入到任何java应用程序中：看到了吧，Apache Camel不是ESB中间件服务，它需要依赖于相应的二次开发才能被当成ESB服务的核心部分进行使用。

2-2、快速使用示例

说了那么多，那么我们来看看Apache Camel最简单的使用方式吧：

package com.yinwenjie.test.cameltest.helloworld;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

import org.apache.camel.Exchange;
import org.apache.camel.ExchangePattern;
import org.apache.camel.Message;
import org.apache.camel.Processor;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.http.HttpMessage;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.model.ModelCamelContext;

/**
 * 郑重其事的写下 helloworld for Apache Camel
 * @author yinwenjie
 */
public class HelloWorld extends RouteBuilder {
    public static void main(String[] args) throws Exception {
        // 这是camel上下文对象，整个路由的驱动全靠它了。
        ModelCamelContext camelContext = new DefaultCamelContext();
        // 启动route
        camelContext.start();
        // 将我们编排的一个完整消息路由过程，加入到上下文中
        camelContext.addRoutes(new HelloWorld());

        /* 
         * ==========================
         * 为什么我们先启动一个Camel服务
         * 再使用addRoutes添加编排好的路由呢？
         * 这是为了告诉各位读者，Apache Camel支持动态加载/卸载编排的路由
         * 这很重要，因为后续设计的Broker需要依赖这种能力
         * ==========================
         * */

        // 通用没有具体业务意义的代码，只是为了保证主线程不退出
        synchronized (HelloWorld.class) {
            HelloWorld.class.wait();
        }
    }

    @Override
    public void configure() throws Exception {
        // 在本代码段之下随后的说明中，会详细说明这个构造的含义
        from("jetty:http://0.0.0.0:8282/doHelloWorld")
        .process(new HttpProcessor())
        .to("log:helloworld?showExchangeId=true");
    }

    /**
     * 这个处理器用来完成输入的json格式的转换
     * @author yinwenjie
     */
    public class HttpProcessor implements Processor {

        /* (non-Javadoc)
         * @see org.apache.camel.Processor#process(org.apache.camel.Exchange)
         */
        @Override
        public void process(Exchange exchange) throws Exception {
            // 因为很明确消息格式是http的，所以才使用这个类
            // 否则还是建议使用org.apache.camel.Message这个抽象接口
            HttpMessage message = (HttpMessage)exchange.getIn();
            InputStream bodyStream =  (InputStream)message.getBody();
            String inputContext = this.analysisMessage(bodyStream);
            bodyStream.close();

            // 存入到exchange的out区域
            if(exchange.getPattern() == ExchangePattern.InOut) {
                Message outMessage = exchange.getOut();
                outMessage.setBody(inputContext + " || out");
            }
        }

        /**
         * 从stream中分析字符串内容
         * @param bodyStream
         * @return
         */
        private String analysisMessage(InputStream bodyStream) throws IOException {
            ByteArrayOutputStream outStream = new ByteArrayOutputStream();
            byte[] contextBytes = new byte[4096];
            int realLen;
            while((realLen = bodyStream.read(contextBytes , 0 ,4096)) != -1) {
                outStream.write(contextBytes, 0, realLen);
            }

            // 返回从Stream中读取的字串
            try {
                return new String(outStream.toByteArray() , "UTF-8");
            } finally {
                outStream.close();
            }
        }
    }
}
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
以上代码可以直接拿来使用，它展示了一个简单的可以实际运行的消息路由规则：首先from语句中填写的“jetty:http://0.0.0.0:8282/doHelloWorld”表示这个编排好的路由的消息入口：使用http传输协议，访问本物理节点上任何IP（例如127.0.0.1或者192.168.1.1），在端口8282上的请求，都可以将HTTP携带的消息传入这个路由。

接下来消息会在HttpProcessor这个自定义的处理器中被进行转换。为了让各位读者看清楚原理，HttpProcessor 中的消息转换很简单：在HTTP传入的json字符串的末尾，加上一个” || out”并进行字符串输出。Apache Camel中自带了很多处理器，并且可以自行实现Processor接口来实现自己的处理逻辑。

最后，消息被传输到最后一个endPoint控制端点，这个endPoint控制端点的URI描述（log:helloworld?showExchangeId=true）表明它是一个Log4j的实现，所以消息最终会以Log日志的方式输出到控制台上。到此，整个编排的路由就执行完成了。

2-3、EIP

Camel supports most of the Enterprise Integration Patterns from the excellent book by Gregor Hohpe and Bobby Woolf.
EIP的概念在之前的文章中已经进行了介绍，它来源于Gregor Hohpe 和Bobby Woolf合著的一本书《Enterprise Integration Patterns》。在书中Gregor Hohpe 和Bobby Woolf阐述了如何对企业内的各个业务系统集成进行设计，包括：如何进行路由设计、如何进行消息传递等等。Apache Camel的设计方案就源于这本书中提出的解决思路，下面我们就对Camel中的重点要素进行讲解。

3、Camel要素

3-1、Endpoint 控制端点

Apache Camel中关于Endpoint最直白的解释就是，Camel作为系统集成的基础服务组件，在已经编排好的路由规则中，和其它系统进行通信的设定点。这个“其它系统”，可以是存在于本地或者远程的文件系统，可以是进行业务处理的订单系统，可以是消息队列服务，可以是提供了访问地址、访问ip、访问路径的任何服务。Apache Camel利用自身提供的广泛的通信协议支持，使这里的“通信”动作可以采用大多数已知的协议，例如各种RPC协议、JMS协议、FTP协议、HTTP协议。。。

Camel中的Endpoint控制端点使用URI的方式描述对目标系统的通信。例如以下URI描述了对外部MQ服务的通信，消息格式是Stomp：

// 以下代码表示从名为test的MQ队列中接收消息，消息格式为stomp
// 用户名为username，监听本地端口61613
from("stomp:queue:test?tcp://localhost:61613&login=username")

// 以下代码表示将消息发送到名为test的MQ队列中，消息格式为stomp
to("stomp:queue:test?tcp://localhost:61613&login=username");
1
2
3
4
5
6
更多的stomp控制端点的说明可参见Camel中的说明：http://camel.apache.org/stomp.html。再例如，我们可以使用Http协议和某一个外部系统进行通信，更多关于Http控制端点的说明也可参见Camel中的说明：http://camel.apache.org/http.html：

// 主动向http URI描述的路径发出请求（http的URI笔者不需要再介绍了吧）
from("http://localhost:8080/dbk.manager.web/queryOrgDetailById")

// 将上一个路由元素上Message Out中消息作为请求内容，
// 向http URI描述的路径发出请求
// 注意，Message Out中的Body内容将作为数据流映射到Http Request Body中
to("http://localhost:8080/dbk.manager.web/queryOrgDetailById")
1
2
3
4
5
6
7
以上的示例中，请注意“from”部分的说明。它并不是等待某个Http请求匹配描述的URI发送到路由路径上，而是主动向http URI描述的路径发送请求。如果想要达到前者的效果，请使用Jetty/Servlet开头的相关通信方式：http://camel.apache.org/servlet.html 和 http://camel.apache.org/jetty.html。而通过Apache Camel官网中 http://camel.apache.org/uris.html 路径可以查看大部分Camel通过URI格式所支持的Endpoint。

Camel makes extensive use of URIs to allow you to refer to endpoints which are lazily created by a Component if you refer to them within Routes.
1
以上引用是Apache Camel官方文档中，关于endpoint和URI之间关系的描述。从这段官方描述可以看出，不同的endpoint都是通过URI格式进行描述的，并且通过Camel中的org.apache.camel.Component（endpoint构建器）接口的响应实现进行endpoint实例的创建。需要注意的是，Camel通过plug方式提供对某种协议的endpoint支持，所以如果读者需要使用某种Camel的endpoint，就必须确定自己已经在工程中引入了相应的plug。例如，如果要使用Camel对Netty4-Endpoint的支持，就需要在工程中引入Camel对Netty4的支持，如下：

<dependency>
    <groupId>org.apache.camel</groupId>
    <artifactId>camel-netty4</artifactId>
    <version>x.x.x</version>
</dependency>
1
2
3
4
5
在这个camel-plug引用中，就包含了Netty4对Endpoint的实现和Netty4对Component的实现：org.apache.camel.component.netty4.NettyEndpoint、org.apache.camel.component.netty4.NettyComponent。

3-2、Exchange和Message消息格式

消息在我们已经编排好的业务路径上进行传递，通过我们自定义的消息转换方式或者Apache Camel提供的消息转换方式进行消息格式转换。那么为了完成这些消息传递、消息转换过程Camel中的消息必须使用统一的消息描述格式，并且保证路径上的控制端点都能存取消息。

Camel提供的Exchange要素帮助开发人员在控制端点到处理器、处理器到处理器的路由过程中完成消息的统一描述。一个Exchange元素的结构如下图所示：

这里写图片描述

3-2-1、Exchange中的基本属性

ExchangeID
一个Exchange贯穿着整个编排的路由规则，ExchangeID就是它的唯一编号信息，同一个路由规则的不同实例（对路由规则分别独立的两次执行），ExchangeID不相同。

fromEndpoint
表示exchange实例初始来源的Endpoint控制端点（类的实例），一般来说就是开发人员设置路由时由“from”关键字所表达的Endpoint。例如本文2-2小节中的代码示例，from关键字填写的URI信息就是”jetty:http://0.0.0.0:8282/doHelloWorld“，而实现Jetty协议头支持的org.apache.camel.Endpoint接口实现类就是org.apache.camel.component.jetty.JettyHttpEndpoint。所以在2-2小节中，Exchange对象中的fromEndpoint属性就是JettyHttpEndpoint类的一个实例化对象。

properties
Exchange对象贯穿整个路由执行过程中的控制端点、处理器甚至还有表达式、路由条件判断。为了让这些元素能够共享一些开发人员自定义的参数配置信息，Exchange以K-V结构提供了这样的参数配置信息存储方式。在org.apache.camel.impl.DefaultExchange类中，对应properties的实现代码如下所示：

......
public Map<String, Object> getProperties() {
    if (properties == null) {
        properties = new ConcurrentHashMap<String, Object>();
    }
    return properties;
}
......
1
2
3
4
5
6
7
8
Pattern
Exchange中的pattern属性非常重要，它的全称是：ExchangePattern（交换器工作模式）。其实现是一个枚举类型：org.apache.camel.ExchangePattern。可以使用的值包括：InOnly, RobustInOnly, InOut, InOptionalOut, OutOnly, RobustOutOnly, OutIn, OutOptionalIn。从Camel官方已公布的文档来看，这个属性描述了Exchange中消息的传播方式。

例如Event Message类型的消息，其ExchangePattern默认设置为InOnly。Request/Reply Message类型的消息，其ExchangePattern设置为InOut。但是笔者通过代码排查，发现并不是ExchangePattern都被Camel-Core核心实现部分所使用（并不能说明没有被诸如 Camel-CXF这些pluin所使用），而且Camel的官方文档对于它们的介绍也只有寥寥数笔（http://camel.apache.org/exchange-pattern.html）。例如RobustOutOnly、OutOptionalIn、OutOnly这些枚举值就没有在Camel-Core实现部分发现引用。

Exception
如果在处理器Processor的处理过程中，开发人员需要抛出异常并终止整个消息路由的执行过程，可以通过设置Exchange中的exception属性来实现。

3-2-2、Exchange中的Message

Exchange中还有两个重要属性inMessage和outMessage。这两个属性分别代表Exchange在某个处理元素（处理器、表达式等）上的输入消息和输出消息。

当控制端点和处理器、处理器和处理器间的Message在Exchange中传递时（虽然ExchangePattern枚举中存在isInCapable()、isInCapable()这样的判断方法，但是通过代码排查，笔者并没有发现在camel-core中有关于这些方法的任何使用），Exchange会自动将上一个元素的输出值作为作为这个元素的输入值进行使用。但是如果在上一个处理器中，开发人员没有在Exchange中设置任何out message内容（即Excahnge中out属性为null），那么上一个处理器中的in message内容将作为这个处理器的in message内容。

这里需要注意一个问题，在DefaultExchange类中关于getOut()方法的实现，有这样的代码片段：

......
public Message getOut() {
    // lazy create
    if (out == null) {
        out = (in != null && in instanceof MessageSupport)
            ? ((MessageSupport)in).newInstance() : new DefaultMessage();
        configureMessage(out);
    }
    return out;
}
......
1
2
3
4
5
6
7
8
9
10
11
所以，在处理器中对out message属性的赋值，并不需要开发人员明确的“new”一个Message对象。只需要调用getOut()方法，就可以完成out message属性赋值。以下路由代码片段在fromEndpoint后，连续进入两个Processor处理器，且Exchange的ExchangePattern为InOut。我们来观察从第一个处理处理完后，到第二个处理收到消息时Exchange对象中的各个属性产生的变化：

......
from("jetty:http://0.0.0.0:8282/doHelloWorld")
.process(new HttpProcessor())
.process(new OtherProcessor())
......
1
2
3
4
5
第一个HttpProcessor执行末尾时，Exchange中的属性
这里写图片描述

上图显示了当前内存区域中，Exchange对象的id为452，fromEndpoint属性是一个JettyHttpEndpoint的实例，对象id为479。注意两个重要的inMessage和outMessage，它们分别是HttpMessage的实例（对象id467）和DefaultMessage的实例（对象id476），这里说明一下无论是HttpMessage还是DefaultMessage，它们都是org.apache.camel.Message接口的实现。

outMessage中的body部分存储了一个字符串信息，我们随后验证一下信息在下一个OtherProcessor处理器中的记录方式。

第二个OtherProcessor开始执行时，Exchange中的属性
这里写图片描述

可以看到HttpProcessor处理器中outMessage的Message对象作为了这个OtherProcessor处理器的inMessage属性，对象的id编号都是476，说明他们使用的内存区域都是相同的，是同一个对象。Excahnge对象的其它信息也从HttpProcessor处理器原封不动的传递到了OtherProcessor处理器。

每一个Message（无论是inMessage还是outMessage）对象主要包括四个属性：MessageID、Header、Body和Attachment。

MessageID
在系统开发阶段，提供给开发人员使用的标示消息对象唯一性的属性，这个属性可以没有值。

Header
消息结构中的“头部”信息，在这个属性中的信息采用K-V的方式进行存储，并可以随着Message对象的传递将信息带到下一个参与路由的元素中。

主要注意的是在org.apache.camel.impl.DefaultMessage中对headers属性的实现是一个名叫org.apache.camel.util.CaseInsensitiveMap的类。看这个类的名字就知道：headers属性的特点是忽略大小写。也就是说：

......
outMessage.setHeader("testHeader", "headerValue");
outMessage.setHeader("TESTHEADER", "headerValue");
outMessage.setHeader("testheader", "HEADERVALUE");
......
1
2
3
4
5
以上代码片段设置后，Message中的Headers属性中只有一个K-V键值对信息，且以最后一次设置的testheader为准。

Body
Message的业务消息内容存放在这里

Attachment
Message中使用attachment属性存储各种文件内容信息，以便这些文件内容在Camel路由的各个元素间进行流转。attachment同样使用K-V键值对形式进行文件内容的存储。但不同的是，这里的V是一个javax.activation.DataHandler类型的对象。

===================================== 
（接下文）