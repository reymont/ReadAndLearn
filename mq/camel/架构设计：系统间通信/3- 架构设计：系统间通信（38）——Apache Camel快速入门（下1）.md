架构设计：系统间通信（38）——Apache Camel快速入门（下1） - JAVA入门中 - CSDN博客 http://blog.csdn.net/yinwenjie/article/details/51769820

（接上文《架构设计：系统间通信（37）——Apache Camel快速入门（中）》）

3-5-2-3循环动态路由 Dynamic Router

动态循环路由的特点是开发人员可以通过条件表达式等方式，动态决定下一个路由位置。在下一路由位置处理完成后Exchange将被重新返回到路由判断点，并由动态循环路由再次做出新路径的判断。如此循环执行直到动态循环路由不能再找到任何一条新的路由路径为止。下图来源于官网（http://camel.apache.org/dynamic-router.html），展示了动态循环路由的工作效果：

这里写图片描述

这里可以看出动态循环路由（dynamicRouter）和之前介绍的动态路由（recipientList）在工作方式上的差异。dynamicRouter一次选择只能确定一条路由路径，而recipientList只进行一次判断并确定多条路由分支路径；dynamicRouter确定的下一路由在执行完成后，Exchange对象还会被返回到dynamicRouter中以便开始第二次循环判断，而recipientList会为各个分支路由复制一个独立的Exchange对象，并且各个分支路由执行完成后Exchange对象也不会返回到recipientList；下面我们还是通过源代码片段，向各位读者展示dynamicRouter的使用方式。在代码中，我们编排了三个路由DirectRouteA主要负责通过Http协议接收处理请求，并执行dynamicRouter。DirectRouteB和DirectRouteC两个路由是可能被dynamicRouter选择的分支路径：

DirectRouteA
/**
 * 第一个路由，主要用于定义整个路由的起点
 * 通过Http协议接收处理请求
 * @author yinwenjie
 */
public class DirectRouteA extends RouteBuilder {

    /* (non-Javadoc)
     * @see org.apache.camel.builder.RouteBuilder#configure()
     */
    @Override
    public void configure() throws Exception {
        from("jetty:http://0.0.0.0:8282/dynamicRouterCamel")
        // 使用dynamicRouter，进行“动态路由”循环，
        // 直到指定的下一个元素为null为止
        .dynamicRouter().method(this, "doDirect")
        .process(new OtherProcessor());
    }

    /**
     * 该方法用于根据“动态循环”的次数，确定下一个执行的Endpoint
     * @param properties 通过注解能够获得的Exchange中properties属性，可以进行操作，并反映在整个路由过程中
     * @return 
     */
    public String doDirect(@Properties Map<String, Object> properties) {
        // 在Exchange的properties属性中，取出Dynamic Router的循环次数
        AtomicInteger time = (AtomicInteger)properties.get("time");
        if(time == null) {
            time = new AtomicInteger(0);
            properties.put("time", time);
        } else {
            time = (AtomicInteger)time;
        }
        LOGGER.info("这是Dynamic Router循环第：【" + time.incrementAndGet() + "】次执行！执行线程：" + Thread.currentThread().getName());

        // 第一次选择DirectRouteB
        if(time.get() == 1) {
            return "direct:directRouteB";
        }
        // 第二次选择DirectRouteC
        else if(time.get() == 2) {
            return "direct:directRouteC";
        }
        // 第三次选择一个Log4j-Endpoint执行
        else if(time.get() == 3) {
            return "log:DirectRouteA?showExchangeId=true&showProperties=ture&showBody=false";
        }

        // 其它情况返回null，终止 dynamicRouter的执行
        return null;
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
在DirectRouteA中我们使用“通过一个method方法返回信息”的方式确定dynamicRouter“动态循环路由”的下一个Endpoint。当然在实际使用中，开发人员还可以有很多方式向dynamicRouter“动态循环路由”返回指定的下一Endpoint。例如使用JsonPath指定JSON格式数据中的某个属性值，或者使用XPath指定XML数据中的某个属性值，又或者使用header方法指定Exchange中Header部分的某个属性。但是无论如何请开发人员确定一件事情：向dynamicRouter指定下一个Endpoint的方式中是会返回null进行循环终止的，否则整个dynamicRouter会无限的执行下去。

以上doDirect方法中，我们将一个计数器存储在了Exchange对象的properties区域，以便在同一个Exchange对象执行doDirect方法时进行计数操作。当同一个Exchange对象第一次执行动态循环路由判断时，选择directRouteB最为一下路由路径；当Exchange对象第二次执行动态循环路由判断时，选择DirectRouteC作为下一路由路径；当Exchange对象第三次执行时，选择一个Log4j-Endpoint作为下一个路由路径；当Exchange对象第四次执行时，作为路由路径判断的方法doDirect返回null，以便终止dynamicRouter的执行。

不能在DirectRouteA类中定义一个全局变量作为循环路由的计数器，因为由Jetty-HttpConsumer生成的线程池中，线程数量和线程对象是固定的，并且Camel也不是为每一个Exchange对象的运行创建新的DirectRouteA对象实例。所以如果在DirectRouteA类中定义全局变量作为循环路由的计数器，各位读者自己想想会发生什么样的结果吧。别骂娘……

DirectRouteB 和 DirectRouteC
/**
 * 这是另一条路由分支
 * @author yinwenjie
 */
public class DirectRouteC extends RouteBuilder {
    @Override
    public void configure() throws Exception {
        from("direct:directRouteC")
        .to("log:DirectRouteC?showExchangeId=true&showProperties=ture&showBody=false");
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
由于DirectRouteB和DirectRouteC两个路由定义的代码非常类似，所以这里只贴出其中一个。

启动Camel应用程序，并将路由加入CamelContext
......
public static void main(String[] args) throws Exception { 
    // 这是camel上下文对象，整个路由的驱动全靠它了。
    ModelCamelContext camelContext = new DefaultCamelContext();
    // 启动route
    camelContext.start();
    // 将我们编排的一个完整消息路由过程，加入到上下文中
    DynamicRouterCamel dynamicRouterCamel = new DynamicRouterCamel();
    camelContext.addRoutes(dynamicRouterCamel.new DirectRouteA());
    camelContext.addRoutes(dynamicRouterCamel.new DirectRouteB());
    camelContext.addRoutes(dynamicRouterCamel.new DirectRouteC());

    // 通用没有具体业务意义的代码，只是为了保证主线程不退出
    synchronized (DynamicRouterCamel.class) {
        DynamicRouterCamel.class.wait();
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
18
运行效果
[2016-06-27 20:44:52] INFO  qtp1392999621-16 这是Dynamic Router循环第：【1】次执行！执行线程：qtp1392999621-16 (DynamicRouterCamel.java:105)

[2016-06-27 20:44:56] INFO  qtp1392999621-16 Exchange[Id: ID-yinwenjie-240-57818-1467030193866-0-3, ExchangePattern: InOut, BodyType: org.apache.camel.converter.stream.InputStreamCache] (MarkerIgnoringBase.java:96)

[2016-06-27 20:44:56] INFO  qtp1392999621-16 这是Dynamic Router循环第：【2】次执行！执行线程：qtp1392999621-16 (DynamicRouterCamel.java:105)

[2016-06-27 20:44:56] INFO  qtp1392999621-16 Exchange[Id: ID-yinwenjie-240-57818-1467030193866-0-3, ExchangePattern: InOut, BodyType: org.apache.camel.converter.stream.InputStreamCache] (MarkerIgnoringBase.java:96)

[2016-06-27 20:44:56] INFO  qtp1392999621-16 这是Dynamic Router循环第：【3】次执行！执行线程：qtp1392999621-16 (DynamicRouterCamel.java:105)

[2016-06-27 20:44:56] INFO  qtp1392999621-16 Exchange[Id: ID-yinwenjie-240-57818-1467030193866-0-3, ExchangePattern: InOut, BodyType: org.apache.camel.converter.stream.InputStreamCache] (MarkerIgnoringBase.java:96)

[2016-06-27 20:44:56] INFO  qtp1392999621-16 这是Dynamic Router循环第：【4】次执行！执行线程：qtp1392999621-16 (DynamicRouterCamel.java:105)

[2016-06-27 20:44:56] INFO  qtp1392999621-16 最后exchangeID = ID-yinwenjie-240-57818-1467030193866-0-3 | org.apache.camel.converter.stream.InputStreamCache@2abaa89c || 被OtherProcessor处理 | time = 4 (DynamicRouterCamel.java:150)
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
从以上执行效果看，无论dynamicRouter执行的是第几次循环判断，Exchange都是同一个（ID号为【ID-yinwenjie-240-57818-1467030193866-0-3】）。

3-6、Service与生命周期

在Apache Camel中有一个比Endpoint、Component、CamelContext等元素更基础的概念元素：Service。Camel官方文档中对Service的解释是：

Camel uses a simple lifecycle interface called Service which has a single start() and stop() method.

Various classes implement Service such as CamelContext along with a number of Component and Endpoint classes.

When you use Camel you typically have to start the CamelContext which will start all the various components and endpoints and activate the routing rules until the context is stopped again.

......
1
2
3
4
5
6
7
包括Endpoint、Component、CamelContext等元素在内的大多数工作在Camel中的元素，都是一个一个的Service。例如，我们虽然定义了一个JettyHttpComponent（就是在代码中使用DSL定义的”jetty:http://0.0.0.0:8282/directCamel“头部所表示的Component），但是我们想要在Camel应用程序运行阶段使用这个Component，就需要利用start方法将这个Component启动起来。

实际上通过阅读org.apache.camel.component.jetty.JettyHttpComponent的源代码，读者可以发现JettyHttpComponent的启动过程起始大多数情况下什么都不会做，只是在org.apache.camel.support.ServiceSupport中更改了JettyHttpComponent对象的一些状态属性。倒是HttpConsumer这个Service，在启动的过程中启动了JettyHttpComponent对象的连接监听，并建立了若干个名为【qtp-*】的处理线程。下图为读者展示了org.apache.camel.Service接口的主要继承/实现体系：

这里写图片描述

Service有且只有两个接口方法定义：start()和stop()，这两个方法的含义显而易见，启动服务和终止服务。另外继承自Service的另外两个子级接口SuspendableService、ShutdownableService分别还定义了另外几个方法：suspend()、resume()和shutdown()方法，分别用来暂停服务、恢复服务和彻底停止服务（彻底停止服务意味着在Camel应用程序运行的有生之年不能再次启动了）。

Camel应用程序中的每一个Service都是独立运行的，各个Service的关联衔接通过CamelContext上下文对象完成。每一个Service通过调用start()方法被激活并参与到Camel应用程序的工作中，直到它的stop()方法被调用。也就是说，每个Service都有独立的生命周期。（http://camel.apache.org/lifecycle.html）

那么问题来了，既然每个Service都有独立的生命周期，我们启动Camel应用程序时就要启动包括Route、Endpoint、Component、Producer、Consumer、LifecycleStrategy等概念元素在内的无数多个Service实现，那么作为开发人员不可能编写代码一个一个的Service来进行启动（大多数开发人员不了解Camel的内部结构，也根本不知道要启动哪些Service）。那么作为Camel应用程序肯定需要提供一个办法，在应用程序启动时分析应用程序所涉及到的所有的Service，并统一管理这些Service启动和停止的动作。这就是CamelContext所设计的另一个功能。

4、CamelContext上下文

CamelContext从英文字面上理解，是Camel服务上下文的意思。CamelContext在Apache Camel中的重要性，就像ApplicationContext之于Spring、ServletContext之于Servlet…… 但是包括Camel官方文档在内的，所有读者能够在互联网上找到的资料对于CamelContext的介绍都只有聊聊数笔。

The context component allows you to create new Camel Components from a CamelContext with a number of routes which is then treated as a black box, allowing you to refer to the local endpoints within the component from other CamelContexts.

First you need to create a CamelContext, add some routes in it, start it and then register the CamelContext into the Registry (JNDI, Spring, Guice or OSGi etc).

………
以上是Camel官方文档（http://camel.apache.org/context.html）对于CamelContext作用的一些说明，大致的意思是说CamelContext横跨了Camel服务的整个生命周期，并且为Camel服务的工作环境提供支撑。

4-1、CamelContext实现结构

那么CamelContext中到底存储了哪些重要的元素，又是如何工作的呢？看样子官方的使用手册中并没有说明，我们还是通过分析CamelContext的源代码来看看它的一些什么内容吧。下面我们应用已经讲解过的Apache Camel相关知识，对org.apache.camel.CamelContext接口以及它的主要实现类进行分析，以便尽可能的去理解为什么CamelContext非常重要：

这里写图片描述

上图是Apache Camel中实现了org.apache.camel.CamelContext接口的主要类。其中有两个实现类需要特别说明一下：SpringCamelContext和DefaultCamelContext。Camel可以和Spring框架进行无缝集成，例如可以将您的某个Processor处理器以Spring Bean的形式注入到Spring Ioc容器中，然后Camel服务就可以通过在Spring Ioc容器中定义的bean id（XML方式或者注解方式都行）取得这个Processor处理器的实例。

为了实现以上描述的功能，需要Camel服务能够从Spring的ApplicationContext取得Bean，而SpringCamelContext可以帮助Camel服务完成这个关键动作：通过SpringCamelContext中重写的createRegistry方法创建一个ApplicationContextRegistry实例，并通过后者从ApplicationContext的“getBean”方法中获取Spring Ioc容器中符合指定的Bean id的实例。这就是Camel服务和Spring进行无缝集成的一个关键点，如以下代码片段所示：

public class SpringCamelContext extends DefaultCamelContext implements InitializingBean, DisposableBean, ApplicationContextAware {
    ......
     @Override
    protected Registry createRegistry() {
        return new ApplicationContextRegistry(getApplicationContext());
    }
    ......
}

public class ApplicationContextRegistry implements Registry {
    ......

    @Override
    public Object lookupByName(String name) {
        try {
            return applicationContext.getBean(name);
        } catch (NoSuchBeanDefinitionException e) {
            return null;
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
22
另外一个需要说明的是DefaultCamelContext类，这个类是我们在前文涉及到Camel示例代码时使用最多的CamelContext实现。而我们将要分析的CamelContext工作原理也基本上是在这个类中进行了完整的实现——其子类只是根据不同的Camel运行环境重写了其中某些方法（例如之前提到的createRegistry方法）。

4-2、DefaultCamelContext结构和启动过程

如果我们翻阅DefaultCamelContext的源代码，首先就会发现在其中定义了许多全局变量，数量在70个左右（实际上根据《代码大全》的描述，一个类中不应该有这么多全局变量。究竟这个类的作者当时是怎样的想法，就不清楚了）。其中一些变量负责记录CamelContext的状态属性、一些负责引用辅助工具还有一些记录关联的顶层工作对象（例如Endpoint、Servcie、Routes、）Components等等）。很明显我们无法对这些变量逐一进行深入分析讲解，但是经过前两篇文章的介绍至少以下变量信息我们是需要理解其作用的：

public class DefaultCamelContext extends ServiceSupport implements ModelCamelContext, SuspendableService {
    ......

    // java的基础概念：类加载器，一般进行线程操作时会用到它
    private ClassLoader applicationContextClassLoader;
    // 已定义的endpoint URI（完整的）和Endpoint对象的映射关系
    private Map<EndpointKey, Endpoint> endpoints;
    // 已使用的组件名称（即Endpoint URI头所代表的组件名称）和组件对象的对应关系
    private final Map<String, Component> components = new HashMap<String, Component>();
    // 针对原始路由编排所分析出的路由对象，路由对象是作为CamelContext从路由中的一个元素传递到下一个元素的依据
    //  路由对象中还包含了，将路由定义中各元素连接起来的其它Service。例如DefaultChannel
    private final Set<Route> routes = new LinkedHashSet<Route>();
    // 由DSL或者XML描述的原始路由编排。每一个RouteDefinition元素中都包含了参与这个路由的所有Service定义。
    private final List<RouteDefinition> routeDefinitions = new ArrayList<RouteDefinition>();
    // 生命周期策略，实际上是一组监听，文章后面的内容会重点讲到
    private List<LifecycleStrategy> lifecycleStrategies = new CopyOnWriteArrayList<LifecycleStrategy>();
    // 这是一个计数器，记录当前每一个不同的Routeid中正在运行的的Exchange数量
    private InflightRepository inflightRepository = new DefaultInflightRepository();
    // 服务停止策略
    private ShutdownStrategy shutdownStrategy = new DefaultShutdownStrategy(this);
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
22
看来CamelContext是挺重要的，它基本将Camel应用程序运行所需要的所有基本信息都记录在案。另外，Apache Camel中还有一个名叫org.apache.camel.CamelContextAware的接口，只要实现该接口的就必须实现这个接口定义的两个方法：setCamelContext和getCamelContext。而实际上在Camel中的大多数元素都实现了这个接口，所以我们在阅读代码时可以发现DefaultCamelContext在一边启动各个Service的时候，顺便将自己所为参数赋给了正在启动的Service，最终实现了各个Service之间的共享上下文信息的效果：

// 这是CamelContextAware接口的定义
public interface CamelContextAware {
    /**
     * Injects the {@link CamelContext}
     *
     * @param camelContext the Camel context
     */
    void setCamelContext(CamelContext camelContext);

    /**
     * Get the {@link CamelContext}
     *
     * @return camelContext the Camel context
     */
    CamelContext getCamelContext();
}

............

// 这是DefaultCamelContext的doAddService方法中
// 对实现了CamelContextAware接口的Service
// 进行CamelContext设置的代码
private void doAddService(Object object, boolean closeOnShutdown) throws Exception {
    ......
    if (object instanceof CamelContextAware) {
        CamelContextAware aware = (CamelContextAware) object;
        aware.setCamelContext(this);
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
为了和本文3-6小节的内容向呼应，这里我们着重分析一下DefaultCamelContext的启动过程：DefaultCamelContext是如何帮助整个Camel应用程序中若干Service完成启动过程的？首先说明DefaultCamelContext 也是一个Service，所以它必须实现Service接口的start()方法和stop()方法。而DefaultCamelContext对于start()方法的实现就是“启动其它已知的Service”。

更具体的来说，DefaultCamelContext将所有需要启动的Service按照它们的作用类型进行区分，例如负责策略管理的Service、负责Components组件描述的Service、负责注册管理的Service等等，然后再按照顺序启动这些Service。以下代码片段提取自DefaultCamelContext的doStartCamel()私有方法，并加入了笔者的中文注释（原有作者的注释依然保留），这个私有方法由DefaultCamelContext中的start()方法间接调用，用于完成上述各Service启动操作。

// 为了调用该私有方法，之前的方法执行栈分别为：
// start()
// super.start()
// doStart()
......
private void doStartCamel() throws Exception {
    // 获取classloader是有必要的，这样保证了Camel服务中的classloader和环境中的其他组件（例如spring）一致
    if (applicationContextClassLoader == null) {
       // Using the TCCL as the default value of ApplicationClassLoader
        ClassLoader cl = Thread.currentThread().getContextClassLoader();
        if (cl == null) {
            // use the classloader that loaded this class
            cl = this.getClass().getClassLoader();
        }
        setApplicationContextClassLoader(cl);
    }

    ......

    // 首先启动的是ManagementStrategy策略管理器，它的默认实现是DefaultManagementStrategy。
    // 还记得我们在分析DUBBO时提到的Java spi机制吧，Camel-Core也使用了这个机制，并进行了二次封装。详见org.apache.camel.spi代码包。
    // 启动ManagementStrategy，可以帮助Camel实现第三方组件包（例如Camel-JMS）的动态加载
    // start management strategy before lifecycles are started
    ManagementStrategy managementStrategy = getManagementStrategy();
    // inject CamelContext if aware
    if (managementStrategy instanceof CamelContextAware) {
        ((CamelContextAware) managementStrategy).setCamelContext(this);
    }
    ServiceHelper.startService(managementStrategy);

    ......
    // 然后启动的是 生命周期管理策略 
    // 这个lifecycleStrategies变量是一个LifecycleStrategy泛型的List集合。
    // 实际上LifecycleStrategy是指是一组监听，详见代码片段后续的描述
    ServiceHelper.startServices(lifecycleStrategies);

    ......
    // 接着做一系列的Service启动动作
    // 首先是Endpoint注册管理服务，要进行重点介绍的是org.apache.camel.util.LRUSoftCache
    // 它使用了java.lang.ref.SoftReference进行实现，这是Java提供的
    endpoints = new EndpointRegistry(this, endpoints);
        addService(endpoints);

    ......
    // 启动线程池管理策略和一些列其它服务
    // 基本上这些Service已经在上文中提到过
    doAddService(executorServiceManager, false);
    addService(producerServicePool);
    addService(inflightRepository);
    addService(shutdownStrategy);
    addService(packageScanClassResolver);
    addService(restRegistry);

    ......
    // start components
    startServices(components.values());
    // 启动路由定义，路由定义RouteDefinition本身并不是Service，但是其中包含了参与路由的各种元素，例如Endpoint。
    // start the route definitions before the routes is started
    startRouteDefinitions(routeDefinitions);

    ......
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
以上代码片段已经做了比较详细的注释。下文中，我们将以上代码片段中无法用几句话在代码注释中表达的关键知识点再进行说明：

======================== 
（接下文）

4-2-1、LifecycleStrategy 
4-2-2、CopyOnWriteArrayList与监听者模式 
4-2-3、LRUSoftCache和SoftReference

