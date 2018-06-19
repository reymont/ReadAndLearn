Camel In Action 第八章 企业集成模式 - CSDN博客 http://blog.csdn.net/daydaylearn/article/details/52994289

第八章 企业集成模式 
本章包括 
Aggregator(聚合器)企业集成模式 
Splitter(分流器)企业集成模式 
Routing Slip企业集成模式 
Dynamic Router企业集成模式 
Load Balancer企业集成模式 

今天，大部分企业运行的信息系统不再是一个单独的系统，而是拥有多个独立的系统。这些系统相互集成的需求以及与外部业务伙伴系统和政府系统相互集成的需求在不断增长。 
虽然集成是困难的，让我们面对它。为了解决这些复杂的集成问题，出现了许多企业集成模式(EIP),这些集成模式已经成为描述、解决这些复杂集成问题的标准方式。在本书中我们只会讨论一小部分的集成模式，如果你要学习更多的集成模式，请访问企业集成模式网站 http://www.enterpriseintegrationpatterns.com/.

8.1 企业集成模式简介 
Camel实现了这些集成模式，因为企业集成模式的基本构建都是通过Camel的路由实现的，所以在本书中，从第二章开始，你已经碰到了企业集成模式。在本书中学习Camel提供的所有模式是不可能的，因为目前已经有60多个模式了。本章只会讲解5个最常使用的集成模式。本章讨论的模式见表8.1： 

8.1.1企业集成模式：Aggregator(聚合器)和Splitter(分流器) 
表8.1中的前两个模式是有关联的。分流器可以将一个消息分解为多个子消息；聚合器可以见这些子消息合并为一个消息，他们是两个相反的模式。 
企业集成模式允许你构建LEGO风格的模式，这意味着模式可以组合在一起,形成新的模式。例如你可以联合聚合器和分流器两个模式组成一个被称为Composed Message Processor的模式，如图8.1所示: 

聚合器模式可能是Camel实现的集成模式中最复杂、最先进的集成模式。它有许多用例,如竞标拍卖或股票报价。 

8.1.2 The Routing Slip and Dynamic Router EIPs 
在Camel邮件列表中，经常有人问这样一个问题：如何动态路由消息？答案是使用Recipient List, Routing Slip,和Dynamic Router等集成模式。第二章中我们学习了Recipient List模式，本章中我们学习Routing Slip,和Dynamic Router两个模式。 

8.1.3 The Load Balancer EIP 
企业集成模式一书中没有列出这个模式，在Camel中实现了这个模式。假设你路由一些包含PDF文件的消息到网络上的打印机上打印，如果远程打印机不可用，你可以使用这个模式来发送PDF消息到另一个打印机上。 

8.2 The Aggregator EIP聚合器模式 
聚合器模式是一个重要且复杂的集成模式，所以我们将详细学习他。如果刚开始你不理解的话，不要灰心。 
聚合器模式将输入的相关消息合并成一个消息，见图8.2： 
聚合器接收到一些消息，并辨识出相关消息，接着将他们合并为一个联合消息。完成后，联合消息被输出，被进一步处理，在下一节中我们详细讨论这个处理过程。 

聚合器的使用例子 
聚合器集成模式有多种使用方式，例如，EIP一书中的贷款代理的例子，贷款者向多个银行发送贷款请求，然后将回复聚合，以决定最佳贷款方式。 
你也可以在一个拍卖系统中使用聚合器模式，聚合当前报价。想象一个股票市场系统,不断收到的股票报价,你想每5秒发布一次最新报价。可以通过使用聚合器选择的最新消息,从而每5秒触发一次完成条件。 


当使用聚合器时,你必须注意以下三个配置项的设置，这三个配置项必须进行设置。如果不做设置，Camel将启动失败，报告一个配置项没有配置的错误。 
Correlation identifier---一个表达式，用来决定哪些输入消息属于一类； 
Completion condition---一个谓词或基于时间的条件，用于确定什么时候结果消息应该发送出去； 
Aggregation strategy---一个聚合策略，声明如何将多个消息聚合为一个消息。 
在本节中,我们将看一个简单的字母聚合的例子，如A，B，C。这将会让事情变得简单,使其更容易理解。聚合器也可以处理大负载的消息，这一点我们在学完基础概念后再看。 

8.2.1 Aggregator 企业集成模式简介 
假设你想收集任何三个消息,把它们组合到一起。如三个消息分别包含A B C，让聚合器将他们合并为一个包含"ABC"的消息。 
图8.3展示了工作方式。当第一个标示符为1的消息到达，聚合器会初始化一个聚合消息，将标示符为1的消息存储到聚合消息中。本例中，完成条件是三个消息被聚合，所以此时聚合没有完成。当第二个标示符为1的消息到达，聚合器将其添加到已经被创建的聚合消息中。当第三个标示符为2的消息到达时，聚合器会初始化一个新聚合消息用来存储这个标示符为2的消息。第四个标示符为1的消息到达时，现在聚合器聚合了三个标示符为1的消息，完成条件被触发。结果，聚合器将这个聚合消息标记为完成，作为结果消息输出。 
如前所述，当使用聚合器模式时，有三个配置项要设置： correlation identifier, completion condition,和aggregation strategy。为了理解这三个配置项如何设置以及他们是如何工作的，让我们先看下下面的Camel路由中的粗体部分： 
public void configure() throws Exception { 
from("direct:start") 
.log("Sending ${body} with correlation key ${header.myId}") 
.aggregate(header("myId"), new MyAggregationStrategy()) 
.completionSize(3) 
.log("Sending out ${body}") 
.to("mock:result"); 
其中correlation identifier为header("myId")，它是Camel中的表达式，返回key为myId的头部值。第二个配置元素是AggregationStrategy，它是一个类。稍后我们将详细学习这个类。最后，completion condition是基于数量的(表8.3中列出了5中完成条件)。它只是指出,当三个信息聚合后,完成条件应该触发。 
同样的例子在Spring XML中的实现： 
<bean id="myAggregationStrategy" 
class="camelinaction.MyAggregationStrategy"/> 
<camelContext xmlns="http://camel.apache.org/schema/spring"> 
<route> 
<from uri="direct:start"/> 
<log message="Sending ${body} with key ${header.myId}"/> 
<aggregate strategyRef="myAggregationStrategy" completionSize="3"> 
<correlationExpression> 
<header>myId</header> 
</correlationExpression> 
<log message="Sending out ${body}"/> 
<to uri="mock:result"/> 
</aggregate> 
</route> 
</camelContext> 
Spring XML与Java DSL有一些不同，使用<aggregate>标签中的strategyRef属性定义了AggregationStrategy，他引用了一个spring bean。同样完成条件也被定义为completionSize属性。最值得注意的是 correlation identifier的定义方式。在 Spring XML中，使用<correlationExpression>标签来定义，此标签有一个子标签，包含了表达式的定义。 
这本书包含了这个例子的源代码，在chapter8/aggregator目录中。 
可以运行一下命令来测试： 
mvn test -Dtest=AggregateABCTest 
mvn test -Dtest=SpringAggregateABCTest 
单元测试的示例使用以下方法: 
public void testABC() throws Exception { 
MockEndpoint mock = getMockEndpoint("mock:result"); 
mock.expectedBodiesReceived("ABC"); 
template.sendBodyAndHeader("direct:start", "A", "myId", 1); 
template.sendBodyAndHeader("direct:start", "B", "myId", 1); 
template.sendBodyAndHeader("direct:start", "F", "myId", 2); 
template.sendBodyAndHeader("direct:start", "C", "myId", 1); 
assertMockEndpointsSatisfied(); 
} 
这个单元测试发送了如图8.3所示的相同的消息---总共四个消息。 
当您运行测试时,您将看到在控制台输出: 
INFO route1 - Sending A with correlation key 1 
INFO route1 - Sending B with correlation key 1 
INFO route1 - Sending F with correlation key 2 
INFO route1 - Sending C with correlation key 1 
INFO route1 - Sending out ABC 
注意控制台输出的消息顺序与图8.3中匹配。如你所见，标示符为1的消息完成了，因为他们符合了完成条件。最后一行是输出消息，包含内容"ABC"。 
那么F消息会怎么样呢？他没有符合完成条件，所以他在聚合消息中等待。你可以修改这个测试方法，发送另外两个消息： 
template.sendBodyAndHeader("direct:start", "G", "myId", 2); 
template.sendBodyAndHeader("direct:start", "H", "myId", 2); 

现在让我们看下聚合器模式是如何聚合消息的，它是如何使A B C三个消息合并为了一个消息。这就是AggregationStrategy存在的意义。 
使用AGGREGATIONSTRATEGY 
AggregationStrategy类位于org.apache.camel.processor.aggregation包中，只定义了一个方法： 
public interface AggregationStrategy { 
Exchange aggregate(Exchange oldExchange, Exchange newExchange); 
} 
是否似曾相识呢？第三章中的Content Enricher企业集成模式中用到了AggregationStrategy。 
代码清单8.1展示了前面例子中用到的AggregationStrategy 
import org.apache.camel.Exchange; 
import org.apache.camel.processor.aggregate.AggregationStrategy; 
public class MyAggregationStrategy implements AggregationStrategy { 
public Exchange aggregate(Exchange oldExchange, Exchange newExchange) { 
if (oldExchange == null) { 
return newExchange; 
} 
String oldBody = oldExchange.getIn() 
.getBody(String.class); 
String newBody = newExchange.getIn() 
.getBody(String.class); 
String body = oldBody + newBody; 
oldExchange.getIn().setBody(body); 
return oldExchange; 
} 
}
在运行时，每当一个新消息到达时，aggregate方法都会被调用。在本例中，这个方法将会被调用四次，分别为到达的A B F C四个消息。为了更好理解其工作过程，表8.2中列出了调用的顺序： 

注意，表8.2中有两个时刻，oldExchange参数的值为null。这种情况发生在一个新的关联组创建的时候(目前还没有相同的相关标识符的消息到达)。在这种情况下，你只需要返回当前消息即可，因为此时没有其他消息与其合并。 
在随后的聚合中，参数将都不会是null，你需要将其数据合并到一个Exchange中。在本例中，你获取了消息体并将其合并在一起。接着，用合并后的消息体更新了oldExchange的现有消息体。 
注意：聚合器EIP使用的是同步方式，以保证AggregationStrategy是线程安全的---在任意时刻只有一个线程调用aggregate方法。同时也保证了消息聚合的顺序与发送消息到Aggregator的顺序相同。 
现在,您应该了解聚合器是如何工作的。从消息聚合器中发出的消息，必须满足完成条件。在下一节中，我们将学习Camel提供的开箱即用的一系列完成条件。 

### 8.2.2 Aggregator的完成条件 
完成条件在Aggregator中扮演了一个可能比你想象中还要重要的角色。想象一种情况，完成条件从未被触发，造成聚合的消息不能被发出。例如，8.2.1节中的例子中，假如C消息从未到达。为了处理这种情况，你可以添加一个超时条件，如果在一定时间内如果不能聚合所有消息，超时条件触发。 
为了能够处理各种情况，Camel提供了5中不同的完成条件，如表8.3所示，你可以混合使用它们以匹配你的需求。 
表8.3 聚合器模式提供了完成条件 
条件 
completionSize 
描述 
定义一个基于聚合消息数量的条件，你可以使用一个固定值(int)或者使用一个表达式(Exception)在运行时动态确定数值。 

条件 
completionTimeout 
描述 
定义一个基于超时时间的完成条件。如果超过指定的时间周期，相关消息仍无法满足完成条件，此条件被触发。每一个消息关联组都可以触发超时完成条件，即超时条件可以被周期性触发。你可以使用一个固定值(long)或者使用一个表达式(Exception)在运行时动态确定超时时间。时间单位为毫秒。你不能同时使用completionInterval完成条件。 

条件 
completionInterval 
描述 
定义一个基于指定的时间间隔的完成条件。此条件被周期性触发。所有的关联消息组只有一个时间间隔完成条件，即所有的关键消息组在同一时刻完成。时间单位为毫秒。你不能同时使用completionTimeout完成条件。 

条件 
completionPredicate 
描述 
定义一个基于谓词的完成条件。参见表8.5中的eagerCheckCompletion配置选项。 

条件 
completionFromBatchConsumer 
描述 
定义一个基于Exchange是否来自同一个BatchConsumer的完成条件(http://camel.apache.org/batch-consumer.html)。在本书写作时，下列组件支持这个完成条件：File, FTP, Mail, iBatis, 和JPA。 

Aggregator支持同时使用多个完成条件，例如同时使用completionSize和completionTimeout两个完成条件。当有多个条件时，关联消息组只需满足其一即可。在本书包含的源代码chapter8/aggregator目录中，有所有条件的示例，你可以通过他们来了解进一步的细节。还可以参看Aggregator的在线文档： http://camel.apache.org/aggregator2.
现在我们将看看如何使用多个完成条件。 

使用多个完成条件 
你可以运行上面提到的源代码中的示例： 
mvn test -Dtest=AggregateXMLTest 
mvn test -Dtest=SpringAggregateXMLTest 
Java DSL形式的路由定义如下： 
import static org.apache.camel.builder.xml.XPathBuilder.xpath; 
public void configure() throws Exception { 
from("direct:start") 
.log("Sending ${body}") 
.aggregate(xpath("/order/@customer"), new MyAggregationStrategy()) 
.completionSize(2).completionTimeout(5000) 
.log("Sending out ${body}") 
.to("mock:result"); 
} 
从代码completionSize(2).completionTimeout(5000)可以看出使用第二个完成条件的方式。 
上述例子的Spring XML形式如下： 
<bean id="myAggregationStrategy" 
class="camelinaction.MyAggregationStrategy"/> 
<camelContext xmlns="http://camel.apache.org/schema/spring"> 
<route> 
<from uri="direct:start"/> 
<log message="Sending ${body}"/> 
<aggregate strategyRef="myAggregationStrategy" 
completionSize="2" completionTimeout="5000"> 
<correlationExpression> 
<xpath>/order/@customer</xpath> 
</correlationExpression> 
<log message="Sending out ${body}"/> 
<to uri="mock:result"/> 
</aggregate> 
</route> 
</camelContext> 
如果你运行这个例子,它将使用下列测试方法： 
public void testXML() throws Exception { 
MockEndpoint mock = getMockEndpoint("mock:result"); 
mock.expectedMessageCount(2); 
template.sendBody("direct:start", 
"<order name=\"motor\" amount=\"1000\" customer=\"honda\"/>"); 
template.sendBody("direct:start", 
"<order name=\"motor\" amount=\"500\" customer=\"toyota\"/>"); 
template.sendBody("direct:start", 
"<order name=\"gearbox\" amount=\"200\" customer=\"toyota\"/>"); 
assertMockEndpointsSatisfied(); 
} 
这个例子应该导致聚合器发布两个输出消息，正如下面的控制台输出所示，一个为本田，一个为丰田： 
09:37:35 - Sending <order name="motor" amount="1000" customer="honda"/> 
09:37:35 - Sending <order name="motor" amount="500" customer="toyota"/> 
09:37:35 - Sending <order name="gearbox" amount="200" customer="toyota"/> 
09:37:35 - Sending out 
<order name="motor" amount="500" customer="toyota"/> 
<order name="gearbox" amount="200" customer="toyota"/> 
09:37:41 - Sending out 
<order name="motor" amount="1000" customer="honda"/> 
如果你仔细观察测试方法和控制台的输出，你应该注意到,本田的订单首先到达，但他是最后一个发布出去的。这是因为他触发了超时完成条件。而丰田订单触发了completionSize完成条件，首先被发布。 

如果你想确保聚合信息最终被发布，使用多个完成条件很有意义。例如,超时条件确保经过一段时间，不活动的消息将被发布。在这方面,您可以使用超时条件作为后备条件。假设您预期的是两条消息聚合成一个,但你只收到一个消息;在下一节中演示了如何告诉Camel某个条件触发了完成。 

AGGREGATED EXCHANGE PROPERTIES 

表8.4 Exchange中与aggregation相关的属性


通过表8.4中列出的信息，你可以知道有多少消息别合并了，一个消息是如何完成聚合被发布的。例如，你可以将完成条件属性打印到控制台上：
.log("Completed by ${property.CamelAggregatedCompletedBy}")
当你需要知道是否所有的消息都被聚合的时候，这些信息可能会派上用场。通过检查AGGREGATED_COMPLETED_BY属性，如果属性值为size,那么所有的消息都被聚合了，如果属性值为timeout，那么发生了超时，并不是所有的预期消息都实现了聚合。
聚合器有额外的配置选项,您可能会用到。例如，你可以设置当收到一个标识不合法的消息，做出相应的响应。

额外配置选项
聚合器是Camel中最复杂的EIP实现。表8.5列出了额外的配置选项，可以利用这些配置，是聚合器符合你的需求。



### 8.2.3 聚合器的持久性 
聚合器是一个有状态的EIP,因为它可以对正在聚合的消息进行存储,直到完成条件发生，聚合信息发布。默认情况下，聚合器只会将状态保存在内存中。如果应用关闭或者主机崩溃，状态会丢失。 
为了解决这个问题，你需要将状态持久化。Camel提供了一个可插拔的特性：你可以为其设置你选择的存储库。有两种形式： 
1、AggregationRepository---一个定义了聚合库常用操作的接口，例如从库中添加数据或者删除数据。默认情况，Camel使用MemoryAggregationRepository，这只是一个内存存储库。 
2、RecoverableAggregationRepository---一个定义了额外操作的接口，支持数据恢复。Camel在camel-hawtdb组件中提供了这样一个开箱即用的存储库。我们在8.2.4节讨论数据恢复。 

关于HawtDB 
HawtDB是一个轻量级的、嵌入式的、基于文件的key/value形式的数据库。它为Camel的各种特性提供了持久化的能力，例如聚合器。未来，Camel的其他特性将会使用HawtDB。 
在其网站上，你可以找到更多关于HawtDB的信息：http://hawtdb.fusesource.org.

我们来看看如何使用HawtDB作为一个持久存储库。 

使用CAMEL-HAWTDB 
为了掩饰在聚合器中如何使用HawtDB，我们将返回到ABC例子中。本质上，你所需要做的就是设置聚合器使用HawtDBAggregationRepository作为其存储库。 

不过,首先你必须设置HawtDB，方式如下： 
AggregationRepository myRepo = new HawtDBAggregationRepository("myrepo", "data/myrepo.dat"); 
在Spring XML中： 
<bean id="myRepo" 
class="org.apache.camel.component.hawtdb.HawtDBAggregationRepository"> 
<property name="repositoryName" value="myrepo"/> 
<property name="persistentFileName" value="data/myrepo.dat"/> 
</bean> 
如你所见，上述代码创建了一个HawtDBAggregationRepository实例，并提供了两个参数：存储库的名称(一个象征性的名字),和对应的物理文件名(用于持久存储)。存储库名称必须被指定,因为在同一个文件中，你可以有多个存储库。 
提示：在Camel官网上面可以找到更多有关HawtDB组件的信息：http://camel.apache.org/hawtdb。 
在路由中使用HawtDBAggregationRepository： 
代码清单8.2，java DSL版本： 
AggregationRepository myRepo = new 
HawtDBAggregationRepository("myrepo", "data/myrepo.dat"); 
from("file://target/inbox") 
.log("Consuming ${file:name}") 
.aggregate(constant(true), new MyAggregationStrategy()) 
.aggregationRepository(myRepo) 
.completionSize(3) 
.log("Sending out ${body}") 
.to("mock:result"); 

代码清单8.3，Spring XML版本： 
<bean id="myAggregationStrategy" 
class="camelinaction.MyAggregationStrategy"/> 
<bean id="myRepo 
class="org.apache.camel.component.hawtdb.HawtDBAggregationRepository"> 
<property name="repositoryName" value="myrepo"/> 
<property name="persistentFileName" value="data/myrepo.dat"/> 
</bean> 
<camelContext xmlns="http://camel.apache.org/schema/spring"> 
<route> 
<from uri="file://target/inbox"/> 
<log message="Consuming ${file:name}"/> 
<aggregate strategyRef="myAggregationStrategy" completionSize="3" 
aggregationRepositoryRef="myRepo"> 
<correlationExpression> 
<constant>true</constant> 
</correlationExpression> 
<log message="Sending out ${body}"/> 
</aggregate> 
</route> 
</camelContext> 

代码清单8.3中，通过定义一个id为myRepo的spring bean，设置了持久化库AggregationRepository。存储库名称和物理文件通过bean的属性进行了配置。在Camel路由中，使用aggregationRepository属性引用了这个spring bean。 

这本书包含了这个例子的源代码，在chapter8/aggregator目录中： 
mvn test -Dtest=AggregateABCHawtDBTest 
mvn test -Dtest=SpringAggregateABCHawtDBTest 

### 8.2.4 聚合器恢复
上一节中的例子专注于确保消息在聚合过程中被持久化。但是有一个地方可能会发生消息丢失：聚合器中发布的消息有可能在下一步的路由中失败。
为了解决这个问题，你可以使用下面两种方式之一：
1、Camel错误处理(第五章已讨论)---提供了返还和死信通道功能。
2、HawtDB组件---HawtDBAggregationRepository提供了恢复、返还、死信通道和事务等能力。
Camel错误处理程序并不与聚合器紧密耦合，所以消息处理本身就在错误处理程序控制下。如果消息一再失败,错误处理的方式只是重试、放弃，将消息移到死信通道。

注意：RecoverableAggregationRepository接口继承了AggregationRepository接口，提供了恢复、重试、死信通道等特性。 HawtDBAggregationRepository实现了这个接口。

另一方面， HawtDBAggregationRepository紧密集成到了聚合器中，从而获得了额外的好处，如利用持久化库实现恢复、事务等能力。确保了发布出去的消息失败后，可以被恢复、重新发送。你可以将其看做一个JMS broker，如Apache ActiveMQ，可以将备份到JMS队列中的失败消息重新发送。

理解恢复(recovery)
为了更好理解恢复是如何工作的，我们提供了下面两个图。
图8.4展示了当一个聚合消息首次发布，在处理过程中失败时所发生的情况。当服务器在处理消息时发生崩溃就会出现这种情况。
一个聚合消息符合了完成条件，聚合器将此信号发送给RecoverableAggregationRepository，RecoverableAggregationRepository获取聚合的消息进行发布。被发布的消息接着在Camel中继续路由----假设此时路由失败，此时一个信号会从聚合器发送到RecoverableAggregationRepository，以便RecoverableAggregationRepository采取相应的动作。
现在想象一下恢复和发送相同的消息,如图8.5所示。
该聚合器使用一个后台任务，每5秒运行一次，扫描已发布的消息用于恢复。任何失败的信息会被重新发布,这样消息就可以再次路由了。这一次,消息成功处理,聚合器进行提交，存储库确认消息提交，确保它不会在随后的扫描中被恢复。
注意：此事务行为由RecoverableAggregationRepository提供，RecoverableAggregationRepositoryisn不是基于Spring的TransactionManager(第九章讨论)的，事务行为是基于HawtDB自己的事务机制。


## 8.3 Splitter企业集成模式 
集成解决方案中的消息可能包含多个元素，比如一个订单消息，可能包含多个订单项。每个订单项可能 需要不同的处理，所以你需要一种方式来分别处理订单消息中的每个订单项。解决这个问题的的方法是使用Splitter(分流器)企业集成模式，如图8.6所示。 
在本节中，我们将向你介绍有关Splitter的所有知识。我们使用一个简单的示例开始。 

8.3.1 使用Splitter 
在Camel中使用Splitter是简单的。让我们来看一个简单的例子：将一个消息分解为三个消息，每个消息分别包含字母A、B、C。代码清单8.4： 
public class SplitterABCTest extends CamelTestSupport { 
public void testSplitABC() throws Exception { 
MockEndpoint mock = getMockEndpoint("mock:split"); 
mock.expectedBodiesReceived("A", "B", "C"); 
List<String> body = new ArrayList<String>(); 
body.add("A"); 
body.add("B"); 
body.add("C"); 
template.sendBody("direct:start", body); 
assertMockEndpointsSatisfied(); 
} 
protected RouteBuilder createRouteBuilder() throws Exception { 
return new RouteBuilder() { 
public void configure() throws Exception { 
from("direct:start") 
.split(body()) 
.log("Split line ${body}") 
.to("mock:split"); 
} 
}; 
} 
} 

Spring XML中： 
<camelContext xmlns="http://camel.apache.org/schema/spring"> 
<route> 
<from uri="direct:start"/> 
<split> 
<simple>${body}</simple> 
<log message="Split line ${body}"/> 
<to uri="mock:split"/> 
</split> 
</route> 
</camelContext> 

SPLITTER是如何工作的？ 
分流器的工作像一个迭代器，遍历、处理消息中的每一项。顺序图如图8.7所示： 


当使用分流器时，你必须配置一个Expression(表达式)，消息到达时，使用表达式进行计算求值。代码清单8.4中，求值后返回的是消息体。求值的结果用于创建java.util.Iterator。 

什么可以迭代? 
当Camel创建迭代器时，它支持一系列的类型。Camel知道如何遍历以下类型：Collection, Iterator, Array, org.w3c.dom.NodeList, String(包含逗号分隔项)。任何其他类型只会迭代一次。 

然后分流器使用迭代器,直到没有更多的数据可分解。从迭代器中出来的消息都是消息的副本。消息的原消息体被迭代器分解出的部分替代。在代码清单8.4中，消息将被分为三部分：分别包含字母A、B和C。发送出的消息将被继续处理，当处理完成后，消息可能被聚合(更多信息见8.3.4节)。 
Splitter将会使用表8.8中的属性对分解出的消息进行装饰： 
你可能会发现在某些情况下你需要对消息分解进行更多的控制，比如规定一条消息应该如何分解。通过使用Java代码,你可以对分解进行全方位的控制。 

### 8.3.2 使用bean来分解 
假设您需要分解的消息包含复杂的负载。假设负载是一个Customer对象，对象中包含一个Department列表，现在你想按Department分解，如图8.8所示： 

Customer对象是一个简单的bean包含以下信息(省略了getter和setter方法)： 
public class Customer { 
private int id; 
private String name; 
private List<Department> departments; 
} 
部门对象如下： 
public class Department { 
private int id; 
private String address; 
private String zip; 
private String country; 
} 
您可能想知道,为什么你不能与前面的示例一样使用split(body())来分解消息？原因是此时的消息负载(消息体)不是一个List，而是一个Customer对象。因此你需要告诉Camel如何分解： 
public class CustomerService { 
public List<Department> splitDepartments(Customer customer) { 
return customer.getDepartments(); 
} 
} 
splitDepartments方法返回一个包含Department的List，这就是你想分解的东东。 
在java DSL中，你可以使用CustomerService这个bean来分解，告诉Camel调用bean中的splitDepartments方法： 
public void configure() throws Exception { 
from("direct:start") 
.split().method(CustomerService.class, "splitDepartments") 
.to("log:split") 
.to("mock:split"); 
} 
Spring XML中： 
<bean id="customerService" class="camelinaction.CustomerService"/> 
<camelContext xmlns="http://camel.apache.org/schema/spring"> 
<route> 
<from uri="direct:start"/> 
<split> 
<method bean="customerService" method="splitDepartments"/> 
<to uri="log:split"/> 
<to uri="mock:split"/> 
</split> 
</route> 
</camelContext> 

Splitter经常会对加载到内存中的消息进行分解，但是有一种情况，消息非常大，不适合整个加载到内存中。 
8.3.3 分解大消息 
骑士汽车配件公司有一个ERP系统,包含其所有供应商的库存信息。为了保持库存更新，每一个供应商都鼻息向骑士骑车配件公司提交更新。某些供应商每天更新一次，使用老式的文件作为运输工具，这些文件可能会非常大，所以你必须把这些文件进行分解，以避免整个文件加载到内存中。这可以通过使用IO流来实现，IO流可以使你按需读取数据。这样就解决了内存问题，因为你可以一块数据，然后进行处理，接着读取下一块数据，然后进行处理，如此而已。 
图8.9显示了骑士汽车配件公司的应用获取供应商提交的文件来更新库存的流程： 
我们将在第十章,再次重温这个例子,当我们介绍并发性的时候，更详细地讨论它。 
在Camel中实现图8.9中的路由非常容易： 
public void configure() throws Exception { 
from("file:target/inventory") 
.log("Starting to process big file: ${header.CamelFileName}") 
.split(body().tokenize("\n")).streaming() 
.bean(InventoryService.class, "csvToObject") 
.to("direct:update") 
.end() 
.log("Done processing big file: ${header.CamelFileName}"); 
from("direct:update") 
.bean(InventoryService.class, "updateInventory"); 
} 
如清单8.5中可以看到,所有你需要做的就是使用.streaming()来启用流模式。这告诉Camel不把整个负载加载到内存中,而是采用流的方式来迭代负载。注意路由中使用了end()来表明分解的结束，对应于Spring XML中的</split>。
在Spring Xml中，使用<split>标签的streaming属性来启动流模式。

<camelContext xmlns="http://camel.apache.org/schema/spring"> 
<route> 
<from uri="file:target/inventory"/> 
<log message="Processing big file: ${header.CamelFileName}"/> 
<split streaming="true"> 
<tokenize token="\n"/> 
<bean beanType="camelinaction.InventoryService" 
method="csvToObject"/> 
<to uri="direct:update"/> 
</split> 
<log message="Done processing big file: ${header.CamelFileName}"/> 
</route> 
<route> 
<from uri="direct:update"/> 
<bean beanType="camelinaction.InventoryService" 
method="updateInventory"/> 
</route> 
</camelContext>
你可能已经注意到了清单8.5和8.6的文件分割使用了分词器tokenizer。tokenizer是一个功能强大的特性,能够很好地处理流。tokenizer利用了java.util.Scanner。Scanner能够迭代,这意味着它只读取大块数据到内存中。必须提供一个令牌来表示块的边界。在前面的代码中,您使用一个换行符(\ n)的作为令牌。所以,在这个例子中,Scanner只会将文件一行一行的读取到内存中，这样就降低的内存消耗。

注意：当使用流模式时，确保你分解的消息可以分解为可以迭代的块。您可以使用tokenizer或者将消息体转换成可以迭代的类型，例如一个Iterator类型。
Camel的分流器EIP包含一个聚合功能,允许您对正在路由的分解后的消息进行重新聚合为一个输出消息。

### 8.3.4 聚合分解的消息
能够分解消息和再次聚合信息是一个强大的机制。你可以使用这个将订单分割成单个的订单行,处理它们,然后再结合成一个单一订单输出消息。此模式被称为复合消息处理器模式,我们在8.1节做了简要介绍。如图8.1所示。
Camel的Splitter提供了一个内建的聚合器，这使它很容易将分解的消息聚合为一个消息输出。图8.10使用"ABC"例子展示了这个原则。 
假设你想将每一个A、B、C消息转换为一个短语，然后将这些短语再次合并为一个消息。使用Splitter很容易做到---你所需要提供的就是聚合消息的逻辑。具体逻辑使用AggregationStrategy的实现类来创建。 
使用javaDSL实现图8.10中的Camel路由如下： 
from("direct:start") 
.split(body(), new MyAggregationStrategy()) 
.log("Split line ${body}") 
.bean(WordTranslateBean.class) 
.to("mock:split") 
.end() 
.log("Aggregated ${body}") 
.to("mock:result"); 
对应的Spring XML： 
<bean id="translate" class="camelinaction.WordTranslateBean"/> 
<bean id="myAggregationStrategy" 
class="camelinaction.MyAggregationStrategy"/> 
<camelContext xmlns="http://camel.apache.org/schema/spring"> 
<route> 
<from uri="direct:start"/> 
<split strategyRef="myAggregationStrategy"> 
<simple>body</simple> 
<log message="Split line ${body}"/> 
<bean ref="translate"/> 
<to uri="mock:split"/> 
</split> 
<log message="Aggregated ${body}"/> 
<to uri="mock:result"/> 
</route> 
</camelContext> 
使用AggregationStrategy的实现类将分解的消息聚合为单一的聚合消息： 
public class MyAggregationStrategy implements AggregationStrategy { 
public Exchange aggregate(Exchange oldExchange, Exchange newExchange) { 
if (oldExchange == null) { 
return newExchange; 
} 
String body = newExchange.getIn().getBody(String.class); 
String existing = oldExchange.getIn().getBody(String.class); 
oldExchange.getIn().setBody(existing + "+" + body); 
return oldExchange; 
} 
} 
如清单8.7中所示，你使用加号(+)将消息聚合为一个单个String类型的消息体。 
这本书包含了这个例子的源代码，在chapter8/splitter目录中运行： 
mvn test -Dtest=SplitterAggregateABCTest 
mvn test -Dtest=SpringSplitterAggregateABCTest 
本例使用了三个短语，“Aggregated Camel rocks”, “Hi mom”, 和 “Yes it works”. 当您运行这个示例,您将看到控制台最后输出的聚合信息。 
INFO route1 - Split line A 
INFO route1 - Split line B 
INFO route1 - Split line C 
INFO route1 - Aggregated Camel rocks+Hi mom+Yes it works 
在我们结束分流器的学习之前，让我们看下当一个分解消息发生异常时，会出现什么情况？ 
8.3.4 聚合分解的消息
能够分解消息和再次聚合信息是一个强大的机制。你可以使用这个将订单分割成单个的订单行,处理它们,然后再结合成一个单一订单输出消息。此模式被称为复合消息处理器模式,我们在8.1节做了简要介绍。如图8.1所示。
8.3.5 当错误发生在分解消息时
分流器处理消息,当一些业务逻辑抛出异常时这些消息可能会处理失败。在分解消息时，Camel的错误处理器是激活状态，所以在Splitter中，你必须处理的错误都是那些Camel错误处理器无法处理的错误。
在Splitter中处理错误，你有两个选择：
1、stop(停止)---Splitter按顺序分解和处理每一个消息。假设第二个消息失败了，此时，你可以立即停止处理，让异常继续传播，也可以继续分解剩下的消息，最后再让异常传播(Splitter的默认行为)。
2、Aggregate---你可以在AggregationStrategy中处理异常，决定是否将异常继续抛出。

使用STOPONEXCEPTION
如果采用第一个选择，你需要在Splitter中配置stopOnException选项：
from("direct:start")
.split(body(), new MyAggregationStrategy())
.stopOnException()
.log("Split line ${body}")
.bean(WordTranslateBean.class)
.to("mock:split")
.end()
.log("Aggregated ${body}")
.to("mock:result");
在Spring XMl中
<split strategyRef="myAggregationStrategy" stopOnException="true">
这本书包含了这个例子的源代码，在chapter8/splitter目录总运行：
mvn test -Dtest=SplitterStopOnExceptionABCTest
mvn test -Dtest=SpringSplitterStopOnExceptionABCTest

使用AGGREGATIONSTRATEGY处理异常
AGGREGATIONSTRATEGY允许你以忽略异常或者抛出异常的方式来处理异常。下面是忽略异常的方式：
public class MyIgnoreFailureAggregationStrategy implements AggregationStrategy {
public Exchange aggregate(Exchange oldExchange, Exchange newExchange) {
if (newExchange.getException() != null) {
return oldExchange;
}
if (oldExchange == null) {
return newExchange;
}
String body = newExchange.getIn().getBody(String.class);
String existing = oldExchange.getIn().getBody(String.class);
oldExchange.getIn().setBody(existing + "+" + body);
return oldExchange;
}
}
此时你可以使用newExchange的getException方法来判断是否发生了异常。本例忽略了异常，返回了oldExchange。
如果你想抛出异常(继续传播)，你可以将其存储在聚合异常中：
public class MyPropagateFailureAggregationStrategy
implements AggregationStrategy {
public Exchange aggregate(Exchange oldExchange, Exchange newExchange) {
if (newExchange.getException() != null) {
if (oldExchange == null) {
return newExchange;
} else {
oldExchange.setException(
newExchange.getException());
return oldExchange;
}
}
if (oldExchange == null) {
return newExchange;
}
String body = newExchange.getIn().getBody(String.class);
String existing = oldExchange.getIn().getBody(String.class);
oldExchange.getIn().setBody(existing + "+" + body);
return oldExchange;
}
}
正如您可以看到的,它需要做更多的工作来存储异常。第一次调用aggregate方法时，oldExchange为null,此时返回(包含异常的)newExchange。否则，你必须将异常放到oldExchange中。
警告：如果在Splitter中使用了自定义的AggregationStrategy，此时你需要知道你负责处理异常。如果此时你没有将异常向后传播，Splitter会认为你处理了异常进而忽略它。
这本书包含了这个例子的源代码，在chapter8/splitter目录中运行：
mvn test -Dtest=SplitterAggregateExceptionABCTest
mvn test -Dtest=SpringSplitterAggregateExceptionABCTest

在下面的两节，我们将学习支持动态路由的企业集成模式，先从Routing Slip模式开始。

## 8.4 Routing Slip企业集成模式
有些时候你需要动态路由消息。例如,您可能有一个架构,对传入的消息进行一系列处理步骤和业务规则验证。因为处理步骤和验证规则的不同，您可以将处理和验证的每一步都作为一个单独的过滤器。过滤器扮演了动态模型的角色，负责业务规则的验证。
此架构可以使用 Pipes、Filters、Filter三个企业集成模式来实现。但是这种情况经常出现，于是出现了一种改良的实现方式，即使用Routing Slip企业集成模式。此模式作为一个动态路由器，来决定消息的下一步处理。图8.11展示了这个规则：

Routing Slip EIP需要一个头部或者Exception作支持。也就是说在消息发送到Routing Slip之前，必须准备好初始化的slip。

8.4.1使用Routing Slip EIP
我们将从一个简单的例子开始,展示了如何使用Routing Slip模式来实现图8.11中的执行顺序。
在java DSL中，模式对应的路由很简单：
from("direct:start").routingSlip("mySlip");
在Spring XML中也很简单：
<route>
<from uri="direct:start"/>
<routingSlip>
<header>mySlip</header>
</routingSlip>
</route>
这个例子假设了输入消息都含有mySlip头部。下面的测试方法展示了如何使用这个头部：
public void testRoutingSlip() throws Exception {
getMockEndpoint("mock:a").expectedMessageCount(1);
getMockEndpoint("mock:b").expectedMessageCount(0);
getMockEndpoint("mock:c").expectedMessageCount(1);
template.sendBodyAndHeader("direct:start", "Hello World",
"mySlip", "mock:a,mock:c");
assertMockEndpointsSatisfied();
}
如你所见，头部mySlip对应的值是由逗号分隔的端点URI。逗号是默认的分隔符，但是此模式也支持自定义分隔符。例如：使用分号作为分隔符：
from("direct:start").routingSlip("mySlip", ";");

<routingSlip uriDelimiter=";">
<header>mySlip</header>
</routingSlip>
上面的例子都用了一个头部做支持，如果没有这个头部呢？如果没有，你必须用自己的方式来计算头部，在下面的例子中，我们看一下如何使用一个bean来计算头部。
8.4.2 使用bean计算routing slip的头部
简而言之，计算头部的逻辑包括两三步，见下面的方法：
public class ComputeSlip {
public String compute(String body) {
String answer = "mock:a";
if (body.contains("Cool")) {
answer += ",mock:b";
}
answer += ",mock:c";
return answer;
}
}
在Java DSL使用这个bean：
from("direct:start")
.setHeader("mySlip").method(ComputeSlip.class)
.routingSlip("mySlip");
在Spring XML中：
<route>
<from uri="direct:start"/>
<setHeader headerName="mySlip">
<method beanType="camelinaction.ComputeSlip"/>
</setHeader>
<routingSlip>
<header>mySlip</header>
</routingSlip>
</route>

8.4.3 使用Expression作为routing slip
除了设置头部，你还可以使用Expression，使用Expression改造前面的例子：
from("direct:start")
.setHeader("mySlip").method(ComputeSlip.class)
.routingSlip("mySlip");
使用Spring XML：
<route>
<from uri="direct:start"/>
<setHeader headerName="mySlip">
<method beanType="camelinaction.ComputeSlip"/>
</setHeader>
<routingSlip>
<header>mySlip</header>
</routingSlip>
</route>
8.4.4 使用@RoutingSlip注解
此注解可以将规则的bean方法变成Routing Slip模式，如下例：

public class SlipBean {
@RoutingSlip
public String slip(String body) {
String answer = "mock:a";
if (body.contains("Cool")) {
answer += ",mock:b";
}
answer += ",mock:c";
return answer;
}
}
当Camel调用slip方法时，探测到@RoutingSlip注解，就会根据Routing Slip EIP继续路由。
注意：使用了@RoutingSlip注解，在DSL中就不要再使用routingSlip方法了。否则Camel会两次调用 RoutingSlip EIP，显然这不是你所期望的。应该像下面这样做：
from("direct:start").bean(SlipBean.class);
使用Spring XML:
<bean id="myBean" class="camelinaction.SlipBean"/>
<route>
<from uri="direct:start"/>
<bean ref="myBean"/>
</route>
为什么你想使用这个注解呢?使用@RoutingSlip注解，在某种意义上，会变得更灵活，此时bean可以被看做一个endpoint URI，任一Camel的客户端和路由都能很容易向bean发送消息，并作为一个routing slip继续路由。例如，使用ProducerTemplate可以向上述bean发送消息：
ProducerTemplate template = ...
template.sendBody("bean:myBean", "Camel rocks");
消息"Camel rocks"与调用bean方法返回的结果会作为一个routing slip被继续路由，这本书包含了示例的源代码。在chapter8/routingslip目录中运行：
mvn test -Dtest=RoutingSlipSimpleTest
mvn test -Dtest=SpringRoutingSlipSimpleTest
mvn test -Dtest=RoutingSlipHeaderTest
mvn test -Dtest=SpringRoutingSlipHeaderTest
mvn test -Dtest=RoutingSlipTest
mvn test -Dtest=SpringRoutingSlipTest
mvn test -Dtest=RoutingSlipBeanTest
mvn test -Dtest=SpringRoutingSlipBeanTest

8.5 Dynamic Router(动态路由)企业集成模式 
在上一节，你学习了Routing Slip模式，此模式的路由也是动态的，那么他和动态路由EIP有什么区别呢？区别非常小：Routing Slip需要对消息头部中的slip提前计算，而动态路由器EIP在运行时计算消息下一步路由目的地。 
8.5.1 使用动态路由器模式 
像Routing Slip模式一样，动态路由器模式同样需要你提供消息路由目的地的计算逻辑。计算逻辑很容易使用java代码实现，在代码中，你有完全的自由以确定消息要去何地。例如，你可以通过查询数据库或者一个规则引擎来计算消息要去何地。 
代码清单8.10展示了例子中使用的java bean： 
public class DynamicRouterBean { 
public String route(String body,@Header(Exchange.SLIP_ENDPOINT) String previous) { 
return whereToGo(body, previous); 
} 
private String whereToGo(String body, String previous) { 
if (previous == null) { 
return "mock://a"; 
} else if ("mock://a".equals(previous)) { 
return "language://simple:Bye ${body}"; 
} else { 
return null; 
} 
} 
} 
动态路由器的思路是:让Camel一直调用route方法，直到路由调用结束，第一次调用route方法时，参数previous为null。后续的每次调用，previous参数包含了上一步的endpoint URI。 
在whereToGo方法中，你根据previous的值返回了不同的URI。当动态路由器结束时，返回null。 
使用动态路由器非常简单，在java DSL中： 
from("direct:start") 
.dynamicRouter(bean(DynamicRouterBean.class, "route")) 
.to("mock:result"); 
在Spring XML中： 
<bean id="myDynamicRouter" class="camelinaction.DynamicRouterBean"/> 
<camelContext xmlns="http://camel.apache.org/schema/spring"> 
<route> 
<from uri="direct:start"/> 
<dynamicRouter> 
<method ref="myDynamicRouter" method="route"/> 
</dynamicRouter> 
<to uri="mock:result"/> 
</route> 
</camelContext> 
这本书包含了这个例子的源代码，在目录chapter8/dynamicrouter中，运行： 
mvn test -Dtest=DynamicRouterTest 
mvn test -Dtest=SpringDynamicRouterTest 

还有一个动态路由器注解可以使用。 
8.5.2 使用@DynamicRouter注解 
为了演示@DynamicRouter的用法，让我们使用@DynamicRouter修改下前面的例子。只需在java代码中添加@DynamicRouter即可： 
@DynamicRouter 
public String route(String body, 
@Header(Exchange.SLIP_ENDPOINT) String previous) { 
... 
} 
下一步就是在路由中直接调用这个bean，java DSL： 
from("direct:start") 
.bean(DynamicRouterBean.class, "route") 
.to("mock:result"); 
在Spring XML中： 
<camelContext xmlns="http://camel.apache.org/schema/spring"> 
<route> 
<from uri="direct:start"/> 
<bean ref="myDynamicRouter" method="route"/> 
<to uri="mock:result"/> 
</route> 
</camelContext> 
警告：使用了@DynamicRouter注解，就不能在路由中同时使用dynamicRouter方法了。 
这本书包含了这个例子的源代码，在目录chapter8/dynamicrouter中，运行： 
mvn test -Dtest=DynamicRouterAnnotationTest 
mvn test -Dtest=SpringDynamicRouterAnnotationTest 
这就是动态路由模式。在下一节中,您将了解Camel内置的负载均衡器EIP，当现有的负载均衡解决方案不到位时，此模式很有用。 

8.6 Load Balancer(负载均衡器) EIP 
在IT行业，您可能已经熟悉了负载均衡的概念。负载均衡是一种技术，用于在计算机或其他资源间分发工作负载(为了得到最优的资源利用率,最大化吞吐量,减少响应时间,避免超负荷工作)[http://en.wikipedia.org/wiki/Load_balancer)]，负载均衡服务可以由硬件设备提供也可以由软件提供，例如Camel中的Load Balancer EIP。 
注意：在企业集成模式一书中没有提及负载均衡器模式，但是如果此书出第二版，那么很有可能会添加此模式。 
本节中，我们将通过一个例子来学习这个模式。在8.6.2节中，我们会看到Camel提供的开箱即用的各种类型的负载均衡器策略。在8.6.3节中，我们将注意力集中在故障恢复策略上，最后，介绍自定义负载均衡器的构建。 
8.6.1 Load Balancer EIP简介 
Camel中的负载均衡器模式是一个Processor，此Processor实现了 org.apache.camel.processor.loadbalancer.LoadBalancer接口。LoadBalancer接口提供了添加、删除参与负载均衡的Processor的方法。 

通过使用Processor来代替Endpoint，负载均衡器可以对路由中定义的一切进行负载均衡。但是，也就是说，你会经常平衡多个远程服务的调用。有这样的一个示例如图8.12所示,一个Camel应用程序需要在两个服务之间进行负载平衡。 

当使用Load Balancer EIP时,你必须选择一个平衡的策略。一个常见的和可以理解的策略是轮流调用服务---这就是所谓的轮循策略。8.6.2节,我们将看一看Camel提供的开箱即用的所有策略。 
让我们看看在负载均衡器中如何使用轮循策略。java DSL： 
from("direct:start") 
.loadBalance().roundRobin() 
.to("seda:a").to("seda:b") 
.end(); 

from("seda:a") 
.log("A received: ${body}") 
.to("mock:a"); 

from("seda:b") 
.log("B received: ${body}") 
.to("mock:b"); 
对应的Spring XML： 
<route> 
<from uri="direct:start"/> 
<loadBalance> 
<roundRobin/> 
<to uri="seda:a"/> 
<to uri="seda:b"/> 
</loadBalance> 
</route> 
<route> 
<from uri="seda:a"/> 
<log message="A received: ${body}"/> 
<to uri="mock:a"/> 
</route> 
<route> 
<from uri="seda:b"/> 
<log message="B received: ${body}"/> 
<to uri="mock:b"/> 
</route> 
在本例中，你使用了SEDA组件来模拟远程服务。在真实环境中，远程服务可能是一个webservice。 
假设你开始向这个路由发送消息，第一个消息将发送到"seda:a"端点，下一个消息将会发送到"seda:b"端点。第三个消息又被发送到"seda:a"端点，如此循环。 
这本书包含了这个例子的源代码，在chapter8/loadbalancer目录中，运行命令： 
mvn test -Dtest=LoadBalancerTest 
mvn test -Dtest=SpringLoadBalancerTest 

如果你运行这个示例,控制台输出是这样的: 
[Camel Thread 0 - seda://a] INFO route2 - A received: Hello 
[Camel Thread 1 - seda://b] INFO route3 - B received: Camel rocks 
[Camel Thread 0 - seda://a] INFO route2 - A received: Cool 
[Camel Thread 1 - seda://b] INFO route3 - B received: Bye 

8.6.2 负载均衡策略 
负载平衡策略用来规定那个Processor应该处理输入消息---由策略来选择Processor。Camel支持表8.9中列出的六个不同的策略： 

表8.9中的前四个策略很容易设置和使用。　例如,使用random策略: 
from("direct:start") 
.loadBalance().random() 
.to("seda:a").to("seda:b") 
.end(); 

对应的Spring XML： 
<route> 
<from uri="direct:start"/> 
<loadBalance> 
<random/> 
<to uri="seda:a"/> 
<to uri="seda:b"/> 
</loadBalance> 
</route> 

sticky策略需要你提供一个关联表达式，用来计算一个散列值来决定应该使用哪个Processor。假设您的消息包含一个标识不同级别的头部。此时使用sticky策略，你可以让所有的消息具有相同的级别，这样他们都会选择同一个Processor。 
在Java DSL中，你需要提供一个表达式： 
from("direct:start") 
.loadBalance().sticky(header("type")) 
.to("seda:a").to("seda:b") 
.end(); 
对应的Spring XML： 
<route> 
<from uri="direct:start"/> 
<loadBalance> 
<sticky> 
<correlationExpression> 
<header>type</header> 
</correlationExpression> 
</sticky> 
<to uri="seda:a"/> 
<to uri="seda:b"/> 
</loadBalance> 
</route> 
这本书包含的源代码中有表8.9中策略的所有例子，在目录chapter8/loadbalancer中。运行命令： 
mvn test -Dtest=RandomLoadBalancerTest 
mvn test -Dtest=SpringRandomLoadBalancerTest 
mvn test -Dtest=StickyLoadBalancerTest 
mvn test -Dtest=SpringStickyLoadBalancerTest 
mvn test -Dtest=TopicLoadBalancerTest 
mvn test -Dtest=SpringTopicLoadBalancerTest 


failover(故障恢复)策略是一个更复杂的策略,我们将在下一节中讨论。 

8.6.3 使用failover策略的负载均衡器 
负载均衡器往往用于实现故障恢复---服务失败后的延续。当异常发生时，Camel故障恢复负载均衡器检测到错误,并做出反应：让下一个Processor处理器接管处理消息。 
看下面的路由片段，故障恢复策略总是以发送消息到第一个Processor("direct:a") 开始，只在错误发生时才会让下一个Processor("direct:b")接管： 
from("direct:start") 
.loadBalance().failover() 
.to("direct:a").to("direct:b") 
.end(); 
对应的Spring XML： 
<route> 
<from uri="direct:start"/> 
<loadBalance> 
<failover/> 
<to uri="direct:a"/> 
<to uri="direct:b"/> 
</loadBalance> 
</route> 
这本书包含了这个例子的源代码，在chapter8/loadbalancer目录中运行： 
mvn test -Dtest=FailoverLoadBalancerTest 
mvn test -Dtest=SpringFailoverLoadBalancerTest 

如果你运行这个示例,它将发送4个消息。第二个消息将会进行故障恢复，由"direct:b"Processor处理。其他三个消息由"direct:a"处理。 
在本例中，故障恢复负载均衡器会对任何类型的异常做出反应，但是你可以设置其只对一定数量的异常做出反应。 
假设你只想在IOException异常抛出时进行故障恢复。其配置非常容易： 
from("direct:start") 
.loadBalance().failover(IOException.class) 
.to("direct:a").to("direct:b") 
.end(); 
对应的Spring XML： 
<route> 
<from uri="direct:start"/> 
<loadBalance> 
<failover> 
<exception>java.io.IOException</exception> 
</failover> 
<to uri="direct:a"/> 
<to uri="direct:b"/> 
</loadBalance> 
</route> 
在这个例子中,只有一个异常,但您可以指定多个异常,如下: 
from("direct:start") 
.loadBalance().failover(IOException.class, SQLException.class) 
.to("direct:a").to("direct:b") 
.end(); 
对应的SpringXML 
<route> 
<from uri="direct:start"/> 
<loadBalance> 
<failover> 
<exception>java.io.IOException</exception> 
<exception>java.sql.SQLException</exception> 
</failover> 
<to uri="direct:a"/> 
<to uri="direct:b"/> 
</loadBalance> 
</route> 

您可能已经注意到在故障恢复的例子中,它总是选择第一个处理器,只在需要进行故障恢复时才选择下一个Proc。你可以将第一个Processor看成奴隶主，其他Processor看成奴隶。但是故障恢复策略也提供了一个策略：联合轮循策略对错误提供支持。 

使用故障恢复和轮循策略 
在Camel中，轮循模式下的故障恢复策略可以让你两全其美；既可以在两个服务之间均匀地分发消息，也可以自动提供故障恢复。 
在这种情况下,你有三个配置选项来配置负载均衡器，以决定它如何运作,如表8.10所示。 
为了更好的理解表8.10中的选项和循环模式是如何工作的，我们将从一个相当简单的例子开始。 
在java DSL中你必须配置故障恢复所有的选项: 
from("direct:start") 
.loadBalance().failover(1, false, true) 
.to("direct:a").to("direct:b") 
.end(); 
在本例中，maximumFailoverAttempts配置项设置为了1，意思是最多进行故障恢复一次(当原始请求失败时，只做一次故障恢复尝试)，如果原始请求和故障恢复都失败了，Camel将会把一次传播给调用者。 
第二个参数设置为了false，意思是不继承Camel的错误处理机制。这使得在异常发生时，故障恢复负载均衡器立即进行故障恢复，而不必等待Camel错误处理程序先放弃。 
最后一个参数表明,使用轮循模式。 
在Spring XML中，使用failover标签的属性进行配置： 
<route> 
<from uri="direct:start"/> 
<loadBalance> 
<failover roundRobin="true" maximumFailoverAttempts="1"/> 
<to uri="direct:a"/> 
<to uri="direct:b"/> 
</loadBalance> 
</route> 
这本书包含了这个例子的源代码，在目录chapter8/loadbalancer中运行： 
mvn test -Dtest=FailoverLoadBalancerTest 
mvn test -Dtest=SpringFailoverLoadBalancerTest 
如果你对inheritErrorHandler配置项好奇，看一下源码中的这个例子： 
mvn test -Dtest=FailoverInheritErrorHandlerLoadBalancerTest 
mvn test -Dtest=SpringFailoverInheritErrorHandlerLoadBalancerTest 

8.6.4 使用自定义负载均衡器 
自定义负载平衡器允许您在使用是对其进行完全的控制。例如,您可以建立一个策略,从不同的服务获得负荷统计数据，选择最低的服务负载。 
让我们来看一个例子。假设你想实现一个基于优先级的策略,将重要消息发送给特定的处理器，将其余消息发给次要Processor。图8.13说明了这一原则。 

实现一个定制的负载均衡器时，你需要继承SimpleLoadBalancerSupport类，它提供了一个很好的起点。如清单8.11所示： 
import org.apache.camel.Exchange; 
import org.apache.camel.Processor; 
import org.apache.camel.processor.loadbalancer.SimpleLoadBalancerSupport; 
public class MyCustomLoadBalancer extends SimpleLoadBalancerSupport { 
public boolean process(Exchange exchange) throws Exception { 
Processor target = chooseProcessor(exchange); 
target.process(exchange); 
} 
@Override 
protected Processor chooseProcessor(Exchange exchange) { 
String type = exchange.getIn().getHeader("type", String.class); 
if ("gold".equals(type)) { 
return getProcessors().get(0); 
} else { 
return getProcessors().get(1); 
} 
} 
} 
正如你所看到的,并不需要太多的代码。在process()方法中，调用chooseProcessor()方法，其中实现了选择处理器来处理消息的策略。在本例中,如果是重要消息，它将选择第一个处理器，如果不是，选择第二个处理器。 
在Java DSL,您使用这个自定义负载平衡器： 
from("direct:start") 
.loadBalance(new MyCustomLoadBalancer()) 
.to("seda:a").to("seda:b") 
.end(); 
对应的Spring XMl： 
<bean id="myCustom" class="camelinaction.MyCustomLoadBalancer"/> 
<route> 
<from uri="direct:start"/> 
<loadBalance ref="myCustom"> 
<to uri="seda:a"/> 
<to uri="seda:b"/> 
</loadBalance> 
</route> 
这本书包含了这个例子的源代码，在目录chapter8/loadbalancer中： 
mvn test -Dtest=CustomLoadBalancerTest 
mvn test -Dtest=SpringCustomLoadBalancerTest