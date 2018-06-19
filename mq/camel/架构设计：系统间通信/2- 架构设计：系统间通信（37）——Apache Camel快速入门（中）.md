架构设计：系统间通信（37）——Apache Camel快速入门（中） - JAVA入门中 - CSDN博客 http://blog.csdn.net/yinwenjie/article/details/51725807

（接上文《架构设计：系统间通信（36）——Apache Camel快速入门（上）》）

（补上文：Endpoint重要的漏讲内容）

3-1-2、特殊的Endpoint Direct

Endpoint Direct用于在两个编排好的路由间实现Exchange消息的连接，上一个路由中由最后一个元素处理完的Exchange对象，将被发送至由Direct连接的下一个路由起始位置（http://camel.apache.org/direct.html）。注意，两个被连接的路由一定要是可用的，并且存在于同一个Camel服务中。以下的例子说明了Endpoint Direct的简单使用方式。

package com.yinwenjie.test.cameltest.helloworld;

import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.model.ModelCamelContext;

/**
 * 测试两个路由的连接
 * @author yinwenjie
 */
public class DirectCamel {

    public static void main(String[] args) throws Exception {
        // 这是camel上下文对象，整个路由的驱动全靠它了。
        ModelCamelContext camelContext = new DefaultCamelContext();
        // 启动route
        camelContext.start();
        // 首先将两个完整有效的路由注册到Camel服务中
        camelContext.addRoutes((new DirectCamel()).new DirectRouteA());
        camelContext.addRoutes((new DirectCamel()).new DirectRouteB());

        // 通用没有具体业务意义的代码，只是为了保证主线程不退出
        synchronized (DirectCamel.class) {
            DirectCamel.class.wait();
        }
    }

    /**
     * DirectRouteA 其中使用direct 连接到 DirectRouteB
     * @author yinwenjie
     */
    public class DirectRouteA extends RouteBuilder {

        /* (non-Javadoc)
         * @see org.apache.camel.builder.RouteBuilder#configure()
         */
        @Override
        public void configure() throws Exception {
            from("jetty:http://0.0.0.0:8282/directCamel")
            // 连接路由：DirectRouteB
            .to("direct:directRouteB")
            .to("log:DirectRouteA?showExchangeId=true");
        }
    }

    /**
     * @author yinwenjie
     */
    public class DirectRouteB extends RouteBuilder {
        /* (non-Javadoc)
         * @see org.apache.camel.builder.RouteBuilder#configure()
         */
        @Override
        public void configure() throws Exception {
            from("direct:directRouteB")
            .to("log:DirectRouteB?showExchangeId=true");
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
以上代码片段中，我们编排了两个可用的路由（尽管两个路由都很简单，但确实是两个独立的路由）命名为DirectRouteA和DirectRouteB。其中DirectRouteA实例在最后一个Endpoint控制端点（direct:directRouteB）中使用Endpoint Direct将Exchange消息发送到DirectRouteB实例的开始位置。以下是控制台输出的内容：

[2016-06-26 09:54:38] INFO  qtp231573738-21 Exchange[Id: ID-yinwenjie-240-54473-1466906074572-0-1, ExchangePattern: InOut, BodyType: org.apache.camel.converter.stream.InputStreamCache, Body: [Body is instance of org.apache.camel.StreamCache]] (MarkerIgnoringBase.java:96)

[2016-06-26 09:54:38] INFO  qtp231573738-21 Exchange[Id: ID-yinwenjie-240-54473-1466906074572-0-1, ExchangePattern: InOut, BodyType: org.apache.camel.converter.stream.InputStreamCache, Body: [Body is instance of org.apache.camel.StreamCache]] (MarkerIgnoringBase.java:96)
1
2
3
从以上执行效果我们可以看到，被连接的两个路由使用的Exchange对象是同一个，也就是说在DirectRouteB路由中如果Exchange对象中的内容发生了变化就会在随后继续执行的DirectRouteA路由中产生影响。Endpoint Direct元素在我们实际使用Camel进行路由编排时，应用频度非常高。因为它可以把多个已编排好的路由按照业务要求连接起来，形成一个新的路由，保持原有路由的良好重用。

========================================（增补完）

3-3、Processor 处理器

Camel中另一个重要的元素是Processor处理器，它用于接收从控制端点、路由选择条件又或者另一个处理器的Exchange中传来的消息信息，并进行处理。Camel核心包和各个Plugin组件都提供了很多Processor的实现，开发人员也可以通过实现org.apache.camel.Processor接口自定义处理器（后者是通常做法）。

既然是做编码，那么我们自然可以在自定义的Processor处理器中做很多事情。这些事情可能包括处理业务逻辑、建立数据库连接去做业务数据存储、建立和某个第三方业务系统的RPC连接，但是我们一般不会那样做——那是Endpoint的工作。Processor处理器中最主要的工作是进行业务数据格式的转换和中间数据的临时存储。这样做是因为Processor处理器是Camel编排的路由中，主要进行Exchange输入输出消息交换的地方。

不过开发人员当然可以在Processor处理器中连接数据库。例如开发人员需要根据上一个Endpoint中携带的“订单编号前缀”信息，在Processor处理器中连接到一个独立的数据库中（或者缓存服务中）查找其对应的路由信息，以便动态决定下一个路由路径。由于Camel支持和JAVA语言的Spring框架无缝集成，所以要在Processor处理器中操作数据库只需要进行非常简单的配置。

以下代码片段是自定义的Processor处理器实现，其中的process(Exchange exchange)方法是必须进行实现的：

// 一个自定义处理器的实现
// 就是我们上文看到过的处理器实现了
public class OtherProcessor implements Processor {
    ......
    @Override
    public void process(Exchange exchange) throws Exception {
        Message message = exchange.getIn();
        String body = message.getBody().toString();
        //===============
        // 您可以在这里进行数据格式转换
        // 并且将结果存储到out message中
        //===============

        // 存入到exchange的out区域
        if(exchange.getPattern() == ExchangePattern.InOut) {
            Message outMessage = exchange.getOut();
            outMessage.setBody(body + " || other out");
        }
    }
    ......
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
注意，处理器Processor是和控制端点平级的概念。要看一个URI对应的实现是否是一个控制端点，最根本的就是看这个实现类是否实现了org.apache.camel.Endpoint接口；而要看一个路由中的元素是否是Processor处理器，最根本的就是看这个类是否实现了org.apache.camel.Processor接口。

3-5、Routing路由条件

在控制端点和处理器之间、处理器和处理器之间，Camel允许开发人员进行路由条件设置。例如开发人员可以拥有当Exchange In Message的内容为A的情况下将消息送入下一个处理器A，当Exchange In Message的内容为B时将消息送入下一个处理器B的处理能力。又例如，无论编排的路由中上一个元素的处理消息如何，都将携带消息的Exchange对象复制 多份，分别送入下一处理器X、Y、Z。开发人员甚至还可以通过路由规则完成Exchange到多个Endpoint的负载传输。

Camel中支持的路由规则非常丰富，包括：Message Filter、Based Router、Dynamic Router、Splitter、Aggregator、Resequencer等等。在Camel的官方文档中使用了非常形象化的图形来表示这些路由功能（http://camel.apache.org/enterprise-integration-patterns.html）：

这里写图片描述

实际上EIP规则中所描述的大部分业务集成模式，在以上页面都能找到对应的图形化表达。但由于篇幅和本专题的中心思想限制，恕笔者不能对Camel中的路由规则逐一讲解。这里我们选取两个比较有代表性的路由规则进行讲解：Content Based Router和Recipient List。希望对各位读者理解Camel中的路由规则有所帮助：

3-5-1、Content Based Router 基于内容的路由

把Content Based Router译为基于内容的路由，笔者觉得更为贴切（并不能译作基本路由，实际上你无法定义什么是基本路由）。它并不是一种单一的路由方式，而是多种基于条件和判断表达式的路由方式。其中可能包括choice语句/方法、when语句/方法、otherwise语句/方法。请看以下示例：

package com.yinwenjie.test.cameltest.helloworld;

......
/**
 * 使用条件选择进行路由编排
 * @author yinwenjie
 */
public class ChoiceCamel extends RouteBuilder {

    public static void main(String[] args) throws Exception {
        // 这是camel上下文对象，整个路由的驱动全靠它了。
        ModelCamelContext camelContext = new DefaultCamelContext();
        // 启动route
        camelContext.start();
        // 将我们编排的一个完整消息路由过程，加入到上下文中
        camelContext.addRoutes(new ChoiceCamel());

        // 通用没有具体业务意义的代码，只是为了保证主线程不退出
        synchronized (ChoiceCamel.class) {
            ChoiceCamel.class.wait();
        }
    }

    @Override
    public void configure() throws Exception {
        // 这是一个JsonPath表达式，用于从http携带的json信息中，提取orgId属性的值
        JsonPathExpression jsonPathExpression = new JsonPathExpression("$.data.orgId");
        jsonPathExpression.setResultType(String.class);

        // 通用使用http协议接受消息
        from("jetty:http://0.0.0.0:8282/choiceCamel")
        // 首先送入HttpProcessor，
        // 负责将exchange in Message Body之中的stream转成字符串
        // 当然，不转的话，下面主要的choice操作也可以运行
        // HttpProcessor中的实现和上文代码片段中的一致，这里就不再重复贴出
        .process(new HttpProcessor())
        // 将orgId属性的值存储 exchange in Message的header中，以便后续进行判断
        .setHeader("orgId", jsonPathExpression)
        .choice()
            // 当orgId == yuanbao，执行OtherProcessor
            // 当orgId == yinwenjie，执行OtherProcessor2
            // 其它情况执行OtherProcessor3
            .when(header("orgId").isEqualTo("yuanbao"))
                .process(new OtherProcessor())
            .when(header("orgId").isEqualTo("yinwenjie"))
                .process(new OtherProcessor2())
            .otherwise()
                .process(new OtherProcessor3())
        // 结束
        .endChoice();
    }

    /**
     * 这个处理器用来完成输入的json格式的转换
     * 和上一篇文章出现的HttpProcessor 内容基本一致。就不再贴出了
     * @author yinwenjie
     */
    public class HttpProcessor implements Processor {
        ......
    }

    /**
     * 另一个处理器OtherProcessor
     * @author yinwenjie
     */
    public class OtherProcessor implements Processor {

        @Override
        public void process(Exchange exchange) throws Exception {
            Message message = exchange.getIn();
            String body = message.getBody().toString();

            // 存入到exchange的out区域
            if(exchange.getPattern() == ExchangePattern.InOut) {
                Message outMessage = exchange.getOut();
                outMessage.setBody(body + " || 被OtherProcessor处理");
            }
        }
    }

    /**
     * 很简单的处理器OtherProcessor2
     * 和OtherProcessor基本相同，就不再重复贴出
     * @author yinwenjie
     */
    public class OtherProcessor2 implements Processor {
        ......
        outMessage.setBody(body + " || 被OtherProcessor2处理");
    }

    /**
     * 很简单的处理器OtherProcessor3
     * 和OtherProcessor基本相同，就不再重复贴出
     * @author yinwenjie
     */
    public class OtherProcessor3 implements Processor {
        ......
        outMessage.setBody(body + " || 被OtherProcessor3处理");
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
99
100
以上代码片段中，开发人员首先使用JsonPath表达式，从Http中携带的json信息中寻找到orgId这个属性的值，然后将这个值存储在Exchange的header区域（这样做只是为了后续方便判断，您也可以将值存储在Exchange的properties区域，还可以直接使用JsonPath表达式进行判断） 。接下来，通过判断存储在header区域的值，让消息路由进入不同的Processor处理器。由于我们设置的from-jetty-endpoint中默认的Exchange Pattern值为InOut，所以在各个Processor处理器中完成处理后 Out Message的Body内容会以Http响应结果的形式返回到from-jetty-endPoint中。最后我们将在测试页面上看到Processor处理器中的消息值。

Camel中支持绝大多数被开发人员承认和使用的表达式：正则式、XPath、JsonPath等。如果各位读者对JsonPath的语法还不熟悉的话，可以参考Google提供的说明文档（https://code.google.com/p/json-path/）。为了测试以上代码片段的工作效果，我们使用Postman工具向指定的地址发送一段json信息，并观察整个路由的执行效果。如下图所示：

这里写图片描述

当orgId的值为yuanbao时的执行效果

这里写图片描述

当orgId的值为yinwenjie时的执行效果

关于路由判断，Camel中提供了丰富的条件判断手段。除了我们在本小节中使用的isEqualTo方式还包括：isGreaterThan、isGreaterThanOrEqualTo、isLessThan、isLessThanOrEqualTo、isNotEqualTo、in（多个值）、contains、regex等等，它们的共同点是这些方法都返回某个实现了org.apache.camel.Predicate接口的类。

3-5-2、Recipient List 接收者列表

在本小节上部分的介绍中，我们说明了怎么使用条件判断向若干可能的路由路径中的某一条路径传送消息。那么如何做到根据判断条件，向若干可能的路径中的其中多条路径传送同一条消息呢？又或者向若干条可能的路径全部传输同一条消息呢？

在Camel中可能被选择的消息路由路径称为接收者，Camel提供了多种方式向路由中可能成为下一处理元素的多个接收者发送消息：静态接收者列表（Static Recipient List）、动态接收者列表（Dynamic Recipient List）和 循环动态路由（Dynamic Router）。下面我们对这几种接收者列表形式进行逐一讲解。

3-5-2-1、使用multicast处理Static Recipient List

使用multicast方式时，Camel将会把上一处理元素输出的Exchange复制多份发送给这个列表中的所有接收者，并且按顺序逐一执行（可设置为并行处理）这些接收者。这些接收者可能是通过Direct连接的另一个路由，也可能是Processor或者某个单一的Endpoint。需要注意的是，Excahnge是在Endpoint控制端点和Processor处理器间或者两个Processor处理器间唯一能够有效携带Message的元素，所以将一条消息复制多份并且让其执行不相互受到影响，那么必然就会对Exchange对象进行复制（是复制，是复制，虽然主要属性内容相同，但是这些Exchange使用的内存区域都是不一样的，ExchangeId也不一样）。以下是multicast使用的简单示例代码：

package com.yinwenjie.test.cameltest.helloworld;

......

/**
 * 测试组播路由
 * @author yinwenjie
 */
public class MulticastCamel extends RouteBuilder {

    public static void main(String[] args) throws Exception {
        // 这是camel上下文对象，整个路由的驱动全靠它了。
        ModelCamelContext camelContext = new DefaultCamelContext();
        // 启动route
        camelContext.start();
        // 将我们编排的一个完整消息路由过程，加入到上下文中
        camelContext.addRoutes(new MulticastCamel());

        // 通用没有具体业务意义的代码，只是为了保证主线程不退出
        synchronized (MulticastCamel.class) {
            MulticastCamel.class.wait();
        }
    }

    @Override
    public void configure() throws Exception {
        // 这个线程池用来进行multicast中各个路由线路的并发执行
        ExecutorService executorService = Executors.newFixedThreadPool(10);
        MulticastDefinition multicastDefinition = from("jetty:http://0.0.0.0:8282/multicastCamel").multicast();

        // multicast 中的消息路由可以顺序执行也可以并发执行
        // 这里我们演示并发执行
        multicastDefinition.setParallelProcessing(true);
        // 为并发执行设置一个独立的线程池
        multicastDefinition.setExecutorService(executorService);

        // 注意，multicast中各路由路径的Excahnge都是基于上一路由元素的excahnge复制而来
        // 无论前者Excahnge中的Pattern如何设置，其处理结果都不会反映在最初的Excahnge对象中
        multicastDefinition.to(
                    "log:helloworld1?showExchangeId=true"
                    ,"log:helloworld2?showExchangeId=true")
        // 一定要使用end，否则OtherProcessor会被做为multicast中的一个分支路由
        .end()
        // 所以您在OtherProcessor中看到的Excahnge中的Body、Header等属性内容
        // 不会有“复制的Exchange”设置的任何值的痕迹
        .process(new OtherProcessor());
    }

    /**
     * 另一个处理器
     * @author yinwenjie
     */
    public class OtherProcessor implements Processor {
        /* (non-Javadoc)
         * @see org.apache.camel.Processor#process(org.apache.camel.Exchange)
         */
        @Override
        public void process(Exchange exchange) throws Exception {
            Message message = exchange.getIn();
            LOGGER.info("OtherProcessor中的exchange" + exchange);
            String body = message.getBody().toString();

            // 存入到exchange的out区域
            if(exchange.getPattern() == ExchangePattern.InOut) {
                Message outMessage = exchange.getOut();
                outMessage.setBody(body + " || 被OtherProcessor处理");
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
以上代码片段中，我们使用multicast将原始的Exchange复制了多份，分别传送给multicast中的两个接收者，并且为了保证两个接收者的处理过程是并行的，我们还专门为multicast设置了一个线程池（不设置的话Camel将自行设置）。在以上的代码片段中，在multicast路由定义之后我们还设置了一个OtherProcessor处理器，它主要作用就是查看OtherProcessor中的Exchange对象的状态。下面的截图展示了以上代码片段的执行效果：

[2016-06-24 16:07:43] INFO  pool-1-thread-7 Exchange[Id: ID-yinwenjie-240-54110-1466755310568-0-20, ExchangePattern: InOut, BodyType: String, Body: {"data":{"orgId":"yinwenjie"},"token":"d9c33c8f-ae59-4edf-b37f-290ff208de2e","desc":""}] (MarkerIgnoringBase.java:96)

[2016-06-24 16:07:43] INFO  pool-1-thread-8 Exchange[Id: ID-yinwenjie-240-54110-1466755310568-0-19, ExchangePattern: InOut, BodyType: String, Body: {"data":{"orgId":"yinwenjie"},"token":"d9c33c8f-ae59-4edf-b37f-290ff208de2e","desc":""}] (MarkerIgnoringBase.java:96)

[2016-06-24 16:07:43] INFO  qtp1060925979-18 OtherProcessor中的exchange [id:ID-yinwenjie-240-54110-1466755310568-0-16]Exchange[Message: {"data":{"orgId":"yinwenjie"},"token":"d9c33c8f-ae59-4edf-b37f-290ff208de2e","desc":""}] (MulticastCamel.java:74)
1
2
3
4
5
通过执行结果可以看到，在multicast中的两个接收者（两个路由分支的设定）分别在我们设置的线程池中运行，线程ID分别是【pool-1-thread-7】和【pool-1-thread-8】。在multicast中的所有路由分支都运行完成后，OtherProcessor处理器的实例在【qtp1060925979-18】线程中继续运行（jetty:http-endpint对于本次请求的处理原本就在这个线程上运行）。

请各位读者特别注意以上三句日志所输出的ExchangeId，它们是完全不同的三个Exchange实例！其中在multicast的两个路由分支中承载Message的Excahnge对象，它们的Exchange-ID号分别为【ID-yinwenjie-240-54110-1466755310568-0-20】和【ID-yinwenjie-240-54110-1466755310568-0-19】，来源则是multicast对原始Exchange对象的复制，原始Exchagne对象的Exchange-ID为【ID-yinwenjie-240-54110-1466755310568-0-16】。

3-5-2-2、处理Dynamic Recipient List

在编排路由，很多情况下开发人员不能确定有哪些接收者会成为下一个处理元素：因为它们需要由Exchange中所携带的消息内容来动态决定下一个处理元素。这种情况下，开发人员就需要用到recipient方法对下一路由目标进行动态判断。以下代码示例中，我们将三个已经编排好的路由注册到Camel服务中，并通过打印在控制台上的结果观察其执行：

第一个路由 DirectRouteA
public class DirectRouteA extends RouteBuilder {

    /* (non-Javadoc)
     * @see org.apache.camel.builder.RouteBuilder#configure()
     */
    @Override
    public void configure() throws Exception {
        from("jetty:http://0.0.0.0:8282/dynamicCamel")
        .setExchangePattern(ExchangePattern.InOnly)
        .recipientList().jsonpath("$.data.routeName").delimiter(",")
        .end()
        .process(new OtherProcessor());
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
第二个和第三个路由
/**
 * @author yinwenjie
 */
public class DirectRouteB extends RouteBuilder {
    /* (non-Javadoc)
     * @see org.apache.camel.builder.RouteBuilder#configure()
     */
    @Override
    public void configure() throws Exception {
        // 第二个路由和第三个路由的代码都相似
        // 唯一不同的是类型
        from("direct:directRouteB")
        .to("log:DirectRouteB?showExchangeId=true");
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
注册到Camel服务中，并开始执行
......
public static void main(String[] args) throws Exception {
    // 这是camel上下文对象，整个路由的驱动全靠它了。
    ModelCamelContext camelContext = new DefaultCamelContext();
    // 启动route
    camelContext.start();
    // 将我们编排的一个完整消息路由过程，加入到上下文中
    camelContext.addRoutes((new DynamicCamel()).new DirectRouteA());
    camelContext.addRoutes((new DynamicCamel()).new DirectRouteB());
    camelContext.addRoutes((new DynamicCamel()).new DirectRouteC());

    // 通用没有具体业务意义的代码，只是为了保证主线程不退出
    synchronized (DynamicCamel.class) {
        DynamicCamel.class.wait();
    }
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
12
13
14
15
16
17
DirectRouteB路由和DirectRouteC路由中的代码非常简单，就是从通过direct连接到本路由的上一个路由实例中获取并打印Exchange对象的信息。所以各位读者可以看到以上代码片段只列举了DirectRouteB的代码信息。DirectRouteA路由中“ExchangePattern.InOnly”的作用在上文中已经讲过，这里就不再进行赘述了。需要重点说明的是recipientList方法，这个方法可以像multicast方法那样进行并发执行或者运行线程池的设置，但是在DirectRouteA的代码中我们并没有那样做，这是为了让读者看清除recipientList或者multicast方法的顺序执行执行效果。以下是我们启动Camel服务后，从Postman（或者其他测试工具）传入的JSON格式的信息：

{"data":{"routeName":"direct:directRouteB,direct:directRouteC"},"token":"d9c33c8f-ae59-4edf-b37f-290ff208de2e","desc":""}
1
recipientList方法将以 .data.routeName 中指定的路由信息动态决定一下个或者多个消息接收者，以上JSON片段中我们指定了两个“direct:directRouteB,direct:directRouteC”。那么recipientList会使用delimiter方法中设置的“,”作为分隔符来分别确定这两个接收者。

观察到的执行效果
[2016-06-26 10:31:53] INFO  qtp1896561093-16 Exchange[Id: ID-yinwenjie-240-55214-1466908306101-0-3, ExchangePattern: InOnly, BodyType: org.apache.camel.converter.stream.InputStreamCache, Body: [Body is instance of org.apache.camel.StreamCache]] (MarkerIgnoringBase.java:96)

[2016-06-26 10:31:53] INFO  qtp1896561093-16 Exchange[Id: ID-yinwenjie-240-55214-1466908306101-0-4, ExchangePattern: InOnly, BodyType: org.apache.camel.converter.stream.InputStreamCache, Body: [Body is instance of org.apache.camel.StreamCache]] (MarkerIgnoringBase.java:96)

[2016-06-26 10:31:53] INFO  qtp1896561093-16 OtherProcessor中的exchange [id:ID-yinwenjie-240-55214-1466908306101-0-1]Exchange[Message: [Body is instance of org.apache.camel.StreamCache]] (DynamicCamel.java:100)
1
2
3
4
5
静态路由和动态路由在执行效果上有很多相似之处。例如在两种路径选择方式中，路由分支上的接收者中使用的Exchange对象的来源都是对上一执行元素所输出的Exchange对象的复制，这些Exchange对象除了其中携带的业务内容相同外，ExchangeID是不一样，也就是说每个路由分支的Exchange对象都不相同。所以各路由分支的消息都不受彼此影响。另外动态路由和静态路由都支持对路由分支的顺序执行和并发执行，都可以为并发执行设置独立的线程池。

从以上执行效果中我们可以看到，由于我们没有设置动态路由是并发执行，所以各个需要执行的路由分支都是由名为【qtp1896561093-16】的Camel服务线程依次执行，并且每个路由分支的Exchange对象都不受彼此影响。另外，请注意以上执行结果的最后一条日志信息，它是在路由分支以外对OtherProcessor处理器的执行。由此可见无论路由分支如何执行，都不会影响路由分支以外的元素执行时所使用的Exchange对象。

=================================== 
（接下文）

3-5-2-3、循环动态路由 Dynamic Router

