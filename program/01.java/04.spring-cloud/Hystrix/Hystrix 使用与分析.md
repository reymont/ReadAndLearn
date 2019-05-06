

Hystrix 使用与分析 - CSDN博客 
http://blog.csdn.net/findmyself_for_world/article/details/54378540

转载请注明出处哈:http://hot66hot.iteye.com/admin/blogs/2155036

一:为什么需要Hystrix?
在大中型分布式系统中，通常系统很多依赖(HTTP,hession,Netty,Dubbo等)，如下图:

 
在高并发访问下,这些依赖的稳定性与否对系统的影响非常大,但是依赖有很多不可控问题:如网络连接缓慢，资源繁忙，暂时不可用，服务脱机等.
如下图：QPS为50的依赖 I 出现不可用，但是其他依赖仍然可用.

 
当依赖I 阻塞时,大多数服务器的线程池就出现阻塞(BLOCK),影响整个线上服务的稳定性.如下图:

 
在复杂的分布式架构的应用程序有很多的依赖，都会不可避免地在某些时候失败。高并发的依赖失败时如果没有隔离措施，当前应用服务就有被拖垮的风险。
 
Java代码  收藏代码
例如:一个依赖30个SOA服务的系统,每个服务99.99%可用。  
99.99%的30次方 ≈ 99.7%  
0.3% 意味着一亿次请求 会有 3,000,00次失败  
换算成时间大约每月有2个小时服务不稳定.  
随着服务依赖数量的变多，服务不稳定的概率会成指数性提高.  
 解决问题方案:对依赖做隔离,Hystrix就是处理依赖隔离的框架,同时也是可以帮我们做依赖服务的治理和监控.
 
Netflix 公司开发并成功使用Hystrix,使用规模如下:
 
Java代码  收藏代码
The Netflix API processes 10+ billion HystrixCommand executions per day using thread isolation.   
Each API instance has 40+ thread-pools with 5-20 threads in each (most are set to 10).  
二:Hystrix如何解决依赖隔离
1:Hystrix使用命令模式HystrixCommand(Command)包装依赖调用逻辑，每个命令在单独线程中/信号授权下执行。
2:可配置依赖调用超时时间,超时时间一般设为比99.5%平均时间略高即可.当调用超时时，直接返回或执行fallback逻辑。
3:为每个依赖提供一个小的线程池（或信号），如果线程池已满调用将被立即拒绝，默认不采用排队.加速失败判定时间。
4:依赖调用结果分:成功，失败（抛出异常），超时，线程拒绝，短路。 请求失败(异常，拒绝，超时，短路)时执行fallback(降级)逻辑。
5:提供熔断器组件,可以自动运行或手动调用,停止当前依赖一段时间(10秒)，熔断器默认错误率阈值为50%,超过将自动运行。
6:提供近实时依赖的统计和监控
Hystrix依赖的隔离架构,如下图:

三:如何使用Hystrix
1:使用maven引入Hystrix依赖
 
Html代码  收藏代码
<!-- 依赖版本 -->  
<hystrix.version>1.3.16</hystrix.version>  
<hystrix-metrics-event-stream.version>1.1.2</hystrix-metrics-event-stream.version>   
   
<dependency>  
     <groupId>com.netflix.hystrix</groupId>  
     <artifactId>hystrix-core</artifactId>  
     <version>${hystrix.version}</version>  
 </dependency>  
     <dependency>  
     <groupId>com.netflix.hystrix</groupId>  
     <artifactId>hystrix-metrics-event-stream</artifactId>  
     <version>${hystrix-metrics-event-stream.version}</version>  
 </dependency>  
<!-- 仓库地址 -->  
<repository>  
     <id>nexus</id>  
     <name>local private nexus</name>  
     <url>http://maven.oschina.net/content/groups/public/</url>  
     <releases>  
          <enabled>true</enabled>  
     </releases>  
     <snapshots>  
          <enabled>false</enabled>  
     </snapshots>  
</repository>  
2:使用命令模式封装依赖逻辑
 
Java代码  收藏代码
public class HelloWorldCommand extends HystrixCommand<String> {  
    private final String name;  
    public HelloWorldCommand(String name) {  
        //最少配置:指定命令组名(CommandGroup)  
        super(HystrixCommandGroupKey.Factory.asKey("ExampleGroup"));  
        this.name = name;  
    }  
    @Override  
    protected String run() {  
        // 依赖逻辑封装在run()方法中  
        return "Hello " + name +" thread:" + Thread.currentThread().getName();  
    }  
    //调用实例  
    public static void main(String[] args) throws Exception{  
        //每个Command对象只能调用一次,不可以重复调用,  
        //重复调用对应异常信息:This instance can only be executed once. Please instantiate a new instance.  
        HelloWorldCommand helloWorldCommand = new HelloWorldCommand("Synchronous-hystrix");  
        //使用execute()同步调用代码,效果等同于:helloWorldCommand.queue().get();   
        String result = helloWorldCommand.execute();  
        System.out.println("result=" + result);  
   
        helloWorldCommand = new HelloWorldCommand("Asynchronous-hystrix");  
        //异步调用,可自由控制获取结果时机,  
        Future<String> future = helloWorldCommand.queue();  
        //get操作不能超过command定义的超时时间,默认:1秒  
        result = future.get(100, TimeUnit.MILLISECONDS);  
        System.out.println("result=" + result);  
        System.out.println("mainThread=" + Thread.currentThread().getName());  
    }  
       
}  
    //运行结果: run()方法在不同的线程下执行  
    // result=Hello Synchronous-hystrix thread:hystrix-HelloWorldGroup-1  
    // result=Hello Asynchronous-hystrix thread:hystrix-HelloWorldGroup-2  
    // mainThread=main  
 note:异步调用使用 command.queue()get(timeout, TimeUnit.MILLISECONDS);同步调用使用command.execute() 等同于 command.queue().get();
3:注册异步事件回调执行
 
Java代码  收藏代码
//注册观察者事件拦截  
Observable<String> fs = new HelloWorldCommand("World").observe();  
//注册结果回调事件  
fs.subscribe(new Action1<String>() {  
    @Override  
    public void call(String result) {  
         //执行结果处理,result 为HelloWorldCommand返回的结果  
        //用户对结果做二次处理.  
    }  
});  
//注册完整执行生命周期事件  
fs.subscribe(new Observer<String>() {  
            @Override  
            public void onCompleted() {  
                // onNext/onError完成之后最后回调  
                System.out.println("execute onCompleted");  
            }  
            @Override  
            public void onError(Throwable e) {  
                // 当产生异常时回调  
                System.out.println("onError " + e.getMessage());  
                e.printStackTrace();  
            }  
            @Override  
            public void onNext(String v) {  
                // 获取结果后回调  
                System.out.println("onNext: " + v);  
            }  
        });  
/* 运行结果 
call execute result=Hello observe-hystrix thread:hystrix-HelloWorldGroup-3 
onNext: Hello observe-hystrix thread:hystrix-HelloWorldGroup-3 
execute onCompleted 
*/  
4:使用Fallback() 提供降级策略

 
Java代码  收藏代码
//重载HystrixCommand 的getFallback方法实现逻辑  
public class HelloWorldCommand extends HystrixCommand<String> {  
    private final String name;  
    public HelloWorldCommand(String name) {  
        super(Setter.withGroupKey(HystrixCommandGroupKey.Factory.asKey("HelloWorldGroup"))  
                /* 配置依赖超时时间,500毫秒*/  
                .andCommandPropertiesDefaults(HystrixCommandProperties.Setter().withExecutionIsolationThreadTimeoutInMilliseconds(500)));  
        this.name = name;  
    }  
    @Override  
    protected String getFallback() {  
        return "exeucute Falled";  
    }  
    @Override  
    protected String run() throws Exception {  
        //sleep 1 秒,调用会超时  
        TimeUnit.MILLISECONDS.sleep(1000);  
        return "Hello " + name +" thread:" + Thread.currentThread().getName();  
    }  
    public static void main(String[] args) throws Exception{  
        HelloWorldCommand command = new HelloWorldCommand("test-Fallback");  
        String result = command.execute();  
    }  
}  
/* 运行结果:getFallback() 调用运行 
getFallback executed 
*/  
 
NOTE: 除了HystrixBadRequestException异常之外，所有从run()方法抛出的异常都算作失败，并触发降级getFallback()和断路器逻辑。
          HystrixBadRequestException用在非法参数或非系统故障异常等不应触发回退逻辑的场景。
5:依赖命名:CommandKey
 
Java代码  收藏代码
public HelloWorldCommand(String name) {  
        super(Setter.withGroupKey(HystrixCommandGroupKey.Factory.asKey("ExampleGroup"))  
                /* HystrixCommandKey工厂定义依赖名称 */  
                .andCommandKey(HystrixCommandKey.Factory.asKey("HelloWorld")));  
        this.name = name;  
    }  
 NOTE: 每个CommandKey代表一个依赖抽象,相同的依赖要使用相同的CommandKey名称。依赖隔离的根本就是对相同CommandKey的依赖做隔离.
6:依赖分组:CommandGroup
命令分组用于对依赖操作分组,便于统计,汇总等.
Java代码  收藏代码
//使用HystrixCommandGroupKey工厂定义  
public HelloWorldCommand(String name) {  
    Setter.withGroupKey(HystrixCommandGroupKey.Factory.asKey("HelloWorldGroup"))  
}  
 NOTE: CommandGroup是每个命令最少配置的必选参数，在不指定ThreadPoolKey的情况下，字面值用于对不同依赖的线程池/信号区分.
7:线程池/信号:ThreadPoolKey
Java代码  收藏代码
public HelloWorldCommand(String name) {  
        super(Setter.withGroupKey(HystrixCommandGroupKey.Factory.asKey("ExampleGroup"))  
                .andCommandKey(HystrixCommandKey.Factory.asKey("HelloWorld"))  
                /* 使用HystrixThreadPoolKey工厂定义线程池名称*/  
                .andThreadPoolKey(HystrixThreadPoolKey.Factory.asKey("HelloWorldPool")));  
        this.name = name;  
    }  
 NOTE: 当对同一业务依赖做隔离时使用CommandGroup做区分,但是对同一依赖的不同远程调用如(一个是redis 一个是http),可以使用HystrixThreadPoolKey做隔离区分.
           最然在业务上都是相同的组，但是需要在资源上做隔离时，可以使用HystrixThreadPoolKey区分.
8:请求缓存 Request-Cache
Java代码  收藏代码
public class RequestCacheCommand extends HystrixCommand<String> {  
    private final int id;  
    public RequestCacheCommand( int id) {  
        super(HystrixCommandGroupKey.Factory.asKey("RequestCacheCommand"));  
        this.id = id;  
    }  
    @Override  
    protected String run() throws Exception {  
        System.out.println(Thread.currentThread().getName() + " execute id=" + id);  
        return "executed=" + id;  
    }  
    //重写getCacheKey方法,实现区分不同请求的逻辑  
    @Override  
    protected String getCacheKey() {  
        return String.valueOf(id);  
    }  
   
    public static void main(String[] args){  
        HystrixRequestContext context = HystrixRequestContext.initializeContext();  
        try {  
            RequestCacheCommand command2a = new RequestCacheCommand(2);  
            RequestCacheCommand command2b = new RequestCacheCommand(2);  
            Assert.assertTrue(command2a.execute());  
            //isResponseFromCache判定是否是在缓存中获取结果  
            Assert.assertFalse(command2a.isResponseFromCache());  
            Assert.assertTrue(command2b.execute());  
            Assert.assertTrue(command2b.isResponseFromCache());  
        } finally {  
            context.shutdown();  
        }  
        context = HystrixRequestContext.initializeContext();  
        try {  
            RequestCacheCommand command3b = new RequestCacheCommand(2);  
            Assert.assertTrue(command3b.execute());  
            Assert.assertFalse(command3b.isResponseFromCache());  
        } finally {  
            context.shutdown();  
        }  
    }  
}  
 NOTE:请求缓存可以让(CommandKey/CommandGroup)相同的情况下,直接共享结果，降低依赖调用次数，在高并发和CacheKey碰撞率高场景下可以提升性能.
Servlet容器中，可以直接实用Filter机制Hystrix请求上下文
Java代码  收藏代码
public class HystrixRequestContextServletFilter implements Filter {  
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)   
     throws IOException, ServletException {  
        HystrixRequestContext context = HystrixRequestContext.initializeContext();  
        try {  
            chain.doFilter(request, response);  
        } finally {  
            context.shutdown();  
        }  
    }  
}  
<filter>  
      <display-name>HystrixRequestContextServletFilter</display-name>  
      <filter-name>HystrixRequestContextServletFilter</filter-name>  
      <filter-class>com.netflix.hystrix.contrib.requestservlet.HystrixRequestContextServletFilter</filter-class>  
    </filter>  
    <filter-mapping>  
      <filter-name>HystrixRequestContextServletFilter</filter-name>  
      <url-pattern>/*</url-pattern>  
   </filter-mapping>  
9:信号量隔离:SEMAPHORE
  隔离本地代码或可快速返回远程调用(如memcached,redis)可以直接使用信号量隔离,降低线程隔离开销.
Java代码  收藏代码
public class HelloWorldCommand extends HystrixCommand<String> {  
    private final String name;  
    public HelloWorldCommand(String name) {  
        super(Setter.withGroupKey(HystrixCommandGroupKey.Factory.asKey("HelloWorldGroup"))  
                /* 配置信号量隔离方式,默认采用线程池隔离 */  
                .andCommandPropertiesDefaults(HystrixCommandProperties.Setter().withExecutionIsolationStrategy(HystrixCommandProperties.ExecutionIsolationStrategy.SEMAPHORE)));  
        this.name = name;  
    }  
    @Override  
    protected String run() throws Exception {  
        return "HystrixThread:" + Thread.currentThread().getName();  
    }  
    public static void main(String[] args) throws Exception{  
        HelloWorldCommand command = new HelloWorldCommand("semaphore");  
        String result = command.execute();  
        System.out.println(result);  
        System.out.println("MainThread:" + Thread.currentThread().getName());  
    }  
}  
/** 运行结果 
 HystrixThread:main 
 MainThread:main 
*/  
10:fallback降级逻辑命令嵌套
 
  适用场景:用于fallback逻辑涉及网络访问的情况,如缓存访问。
 
Java代码  收藏代码
public class CommandWithFallbackViaNetwork extends HystrixCommand<String> {  
    private final int id;  
   
    protected CommandWithFallbackViaNetwork(int id) {  
        super(Setter.withGroupKey(HystrixCommandGroupKey.Factory.asKey("RemoteServiceX"))  
                .andCommandKey(HystrixCommandKey.Factory.asKey("GetValueCommand")));  
        this.id = id;  
    }  
   
    @Override  
    protected String run() {  
        // RemoteService.getValue(id);  
        throw new RuntimeException("force failure for example");  
    }  
   
    @Override  
    protected String getFallback() {  
        return new FallbackViaNetwork(id).execute();  
    }  
   
    private static class FallbackViaNetwork extends HystrixCommand<String> {  
        private final int id;  
        public FallbackViaNetwork(int id) {  
            super(Setter.withGroupKey(HystrixCommandGroupKey.Factory.asKey("RemoteServiceX"))  
                    .andCommandKey(HystrixCommandKey.Factory.asKey("GetValueFallbackCommand"))  
                    // 使用不同的线程池做隔离，防止上层线程池跑满，影响降级逻辑.  
                    .andThreadPoolKey(HystrixThreadPoolKey.Factory.asKey("RemoteServiceXFallback")));  
            this.id = id;  
        }  
        @Override  
        protected String run() {  
            MemCacheClient.getValue(id);  
        }  
   
        @Override  
        protected String getFallback() {  
            return null;  
        }  
    }  
}  
 NOTE:依赖调用和降级调用使用不同的线程池做隔离，防止上层线程池跑满，影响二级降级逻辑调用.
 11:显示调用fallback逻辑,用于特殊业务处理

 
Java代码  收藏代码
public class CommandFacadeWithPrimarySecondary extends HystrixCommand<String> {  
    private final static DynamicBooleanProperty usePrimary = DynamicPropertyFactory.getInstance().getBooleanProperty("primarySecondary.usePrimary", true);  
    private final int id;  
    public CommandFacadeWithPrimarySecondary(int id) {  
        super(Setter  
                .withGroupKey(HystrixCommandGroupKey.Factory.asKey("SystemX"))  
                .andCommandKey(HystrixCommandKey.Factory.asKey("PrimarySecondaryCommand"))  
                .andCommandPropertiesDefaults(  
                        HystrixCommandProperties.Setter()  
                                .withExecutionIsolationStrategy(ExecutionIsolationStrategy.SEMAPHORE)));  
        this.id = id;  
    }  
    @Override  
    protected String run() {  
        if (usePrimary.get()) {  
            return new PrimaryCommand(id).execute();  
        } else {  
            return new SecondaryCommand(id).execute();  
        }  
    }  
    @Override  
    protected String getFallback() {  
        return "static-fallback-" + id;  
    }  
    @Override  
    protected String getCacheKey() {  
        return String.valueOf(id);  
    }  
    private static class PrimaryCommand extends HystrixCommand<String> {  
        private final int id;  
        private PrimaryCommand(int id) {  
            super(Setter  
                    .withGroupKey(HystrixCommandGroupKey.Factory.asKey("SystemX"))  
                    .andCommandKey(HystrixCommandKey.Factory.asKey("PrimaryCommand"))  
                    .andThreadPoolKey(HystrixThreadPoolKey.Factory.asKey("PrimaryCommand"))  
                    .andCommandPropertiesDefaults(  
                            // we default to a 600ms timeout for primary  
                            HystrixCommandProperties.Setter().withExecutionTimeoutInMilliseconds(600)));  
            this.id = id;  
        }  
        @Override  
        protected String run() {  
            // perform expensive 'primary' service call  
            return "responseFromPrimary-" + id;  
        }  
    }  
    private static class SecondaryCommand extends HystrixCommand<String> {  
        private final int id;  
        private SecondaryCommand(int id) {  
            super(Setter  
                    .withGroupKey(HystrixCommandGroupKey.Factory.asKey("SystemX"))  
                    .andCommandKey(HystrixCommandKey.Factory.asKey("SecondaryCommand"))  
                    .andThreadPoolKey(HystrixThreadPoolKey.Factory.asKey("SecondaryCommand"))  
                    .andCommandPropertiesDefaults(  
                            // we default to a 100ms timeout for secondary  
                            HystrixCommandProperties.Setter().withExecutionTimeoutInMilliseconds(100)));  
            this.id = id;  
        }  
        @Override  
        protected String run() {  
            // perform fast 'secondary' service call  
            return "responseFromSecondary-" + id;  
        }  
    }  
    public static class UnitTest {  
        @Test  
        public void testPrimary() {  
            HystrixRequestContext context = HystrixRequestContext.initializeContext();  
            try {  
                ConfigurationManager.getConfigInstance().setProperty("primarySecondary.usePrimary", true);  
                assertEquals("responseFromPrimary-20", new CommandFacadeWithPrimarySecondary(20).execute());  
            } finally {  
                context.shutdown();  
                ConfigurationManager.getConfigInstance().clear();  
            }  
        }  
        @Test  
        public void testSecondary() {  
            HystrixRequestContext context = HystrixRequestContext.initializeContext();  
            try {  
                ConfigurationManager.getConfigInstance().setProperty("primarySecondary.usePrimary", false);  
                assertEquals("responseFromSecondary-20", new CommandFacadeWithPrimarySecondary(20).execute());  
            } finally {  
                context.shutdown();  
                ConfigurationManager.getConfigInstance().clear();  
            }  
        }  
    }  
}  
 NOTE:显示调用降级适用于特殊需求的场景,fallback用于业务处理，fallback不再承担降级职责，建议慎重使用，会造成监控统计换乱等问题.
12:命令调用合并:HystrixCollapser
命令调用合并允许多个请求合并到一个线程/信号下批量执行。
执行流程图如下:

Java代码  收藏代码
public class CommandCollapserGetValueForKey extends HystrixCollapser<List<String>, String, Integer> {  
    private final Integer key;  
    public CommandCollapserGetValueForKey(Integer key) {  
        this.key = key;  
    }  
    @Override  
    public Integer getRequestArgument() {  
        return key;  
    }  
    @Override  
    protected HystrixCommand<List<String>> createCommand(final Collection<CollapsedRequest<String, Integer>> requests) {  
        //创建返回command对象  
        return new BatchCommand(requests);  
    }  
    @Override  
    protected void mapResponseToRequests(List<String> batchResponse, Collection<CollapsedRequest<String, Integer>> requests) {  
        int count = 0;  
        for (CollapsedRequest<String, Integer> request : requests) {  
            //手动匹配请求和响应  
            request.setResponse(batchResponse.get(count++));  
        }  
    }  
    private static final class BatchCommand extends HystrixCommand<List<String>> {  
        private final Collection<CollapsedRequest<String, Integer>> requests;  
        private BatchCommand(Collection<CollapsedRequest<String, Integer>> requests) {  
                super(Setter.withGroupKey(HystrixCommandGroupKey.Factory.asKey("ExampleGroup"))  
                    .andCommandKey(HystrixCommandKey.Factory.asKey("GetValueForKey")));  
            this.requests = requests;  
        }  
        @Override  
        protected List<String> run() {  
            ArrayList<String> response = new ArrayList<String>();  
            for (CollapsedRequest<String, Integer> request : requests) {  
                response.add("ValueForKey: " + request.getArgument());  
            }  
            return response;  
        }  
    }  
    public static class UnitTest {  
        HystrixRequestContext context = HystrixRequestContext.initializeContext();  
        try {  
            Future<String> f1 = new CommandCollapserGetValueForKey(1).queue();  
            Future<String> f2 = new CommandCollapserGetValueForKey(2).queue();  
            Future<String> f3 = new CommandCollapserGetValueForKey(3).queue();  
            Future<String> f4 = new CommandCollapserGetValueForKey(4).queue();  
            assertEquals("ValueForKey: 1", f1.get());  
            assertEquals("ValueForKey: 2", f2.get());  
            assertEquals("ValueForKey: 3", f3.get());  
            assertEquals("ValueForKey: 4", f4.get());  
            assertEquals(1, HystrixRequestLog.getCurrentRequest().getExecutedCommands().size());  
            HystrixCommand<?> command = HystrixRequestLog.getCurrentRequest().getExecutedCommands().toArray(new HystrixCommand<?>[1])[0];  
            assertEquals("GetValueForKey", command.getCommandKey().name());  
            assertTrue(command.getExecutionEvents().contains(HystrixEventType.COLLAPSED));  
            assertTrue(command.getExecutionEvents().contains(HystrixEventType.SUCCESS));  
        } finally {  
         context.shutdown();  
        }     
    }  
}  
 NOTE:使用场景:HystrixCollapser用于对多个相同业务的请求合并到一个线程甚至可以合并到一个连接中执行，降低线程交互次和IO数,但必须保证他们属于同一依赖.
四:监控平台搭建Hystrix-dashboard
1:监控dashboard介绍
dashboard面板可以对依赖关键指标提供实时监控,如下图:
 
2:实例暴露command统计数据
Hystrix使用Servlet对当前JVM下所有command调用情况作数据流输出
配置如下:
 
Xml代码  收藏代码
<servlet>  
    <display-name>HystrixMetricsStreamServlet</display-name>  
    <servlet-name>HystrixMetricsStreamServlet</servlet-name>  
    <servlet-class>com.netflix.hystrix.contrib.metrics.eventstream.HystrixMetricsStreamServlet</servlet-class>  
</servlet>  
<servlet-mapping>  
    <servlet-name>HystrixMetricsStreamServlet</servlet-name>  
    <url-pattern>/hystrix.stream</url-pattern>  
</servlet-mapping>  
<!--  
    对应URL格式 : http://hostname:port/application/hystrix.stream 
-->  
 
3:集群模式监控统计搭建
1)使用Turbine组件做集群数据汇总
结构图如下;

2)内嵌jetty提供Servlet容器,暴露HystrixMetrics
Java代码  收藏代码
public class JettyServer {  
    private final Logger logger = LoggerFactory.getLogger(this.getClass());  
    private int port;  
    private ExecutorService executorService = Executors.newFixedThreadPool(1);  
    private Server server = null;  
    public void init() {  
        try {  
            executorService.execute(new Runnable() {  
                @Override  
                public void run() {  
                    try {  
                        //绑定8080端口,加载HystrixMetricsStreamServlet并映射url  
                        server = new Server(8080);  
                        WebAppContext context = new WebAppContext();  
                        context.setContextPath("/");  
                        context.addServlet(HystrixMetricsStreamServlet.class, "/hystrix.stream");  
                        context.setResourceBase(".");  
                        server.setHandler(context);  
                        server.start();  
                        server.join();  
                    } catch (Exception e) {  
                        logger.error(e.getMessage(), e);  
                    }  
                }  
            });  
        } catch (Exception e) {  
            logger.error(e.getMessage(), e);  
        }  
    }  
    public void destory() {  
        if (server != null) {  
            try {  
                server.stop();  
                server.destroy();  
                logger.warn("jettyServer stop and destroy!");  
            } catch (Exception e) {  
                logger.error(e.getMessage(), e);  
            }  
        }  
    }  
}  
 
3)Turbine搭建和配置
  a:配置Turbine Servlet收集器
Java代码  收藏代码
<servlet>  
   <description></description>  
   <display-name>TurbineStreamServlet</display-name>  
   <servlet-name>TurbineStreamServlet</servlet-name>  
   <servlet-class>com.netflix.turbine.streaming.servlet.TurbineStreamServlet</servlet-class>  
 </servlet>  
 <servlet-mapping>  
   <servlet-name>TurbineStreamServlet</servlet-name>  
   <url-pattern>/turbine.stream</url-pattern>  
 </servlet-mapping>  
   b:编写config.properties配置集群实例
Java代码  收藏代码
#配置两个集群:mobil-online,ugc-online  
turbine.aggregator.clusterConfig=mobil-online,ugc-online  
#配置mobil-online集群实例  
turbine.ConfigPropertyBasedDiscovery.mobil-online.instances=10.10.*.*,10.10.*.*,10.10.*.*,10.10.*.*,10.10.*.*,10.10.*.*,10.16.*.*,10.16.*.*,10.16.*.*,10.16.*.*  
#配置mobil-online数据流servlet  
turbine.instanceUrlSuffix.mobil-online=:8080/hystrix.stream  
#配置ugc-online集群实例  
turbine.ConfigPropertyBasedDiscovery.ugc-online.instances=10.10.*.*,10.10.*.*,10.10.*.*,10.10.*.*#配置ugc-online数据流servlet  
turbine.instanceUrlSuffix.ugc-online=:8080/hystrix.stream  
 
  c:使用Dashboard配置连接Turbine
  如下图 :

 
五:Hystrix配置与分析
1:Hystrix 配置
1):Command 配置
Command配置源码在HystrixCommandProperties,构造Command时通过Setter进行配置
具体配置解释和默认值如下
Java代码  收藏代码
//使用命令调用隔离方式,默认:采用线程隔离,ExecutionIsolationStrategy.THREAD  
private final HystrixProperty<ExecutionIsolationStrategy> executionIsolationStrategy;   
//使用线程隔离时，调用超时时间，默认:1秒  
private final HystrixProperty<Integer> executionIsolationThreadTimeoutInMilliseconds;   
//线程池的key,用于决定命令在哪个线程池执行  
private final HystrixProperty<String> executionIsolationThreadPoolKeyOverride;   
//使用信号量隔离时，命令调用最大的并发数,默认:10  
private final HystrixProperty<Integer> executionIsolationSemaphoreMaxConcurrentRequests;  
//使用信号量隔离时，命令fallback(降级)调用最大的并发数,默认:10  
private final HystrixProperty<Integer> fallbackIsolationSemaphoreMaxConcurrentRequests;   
//是否开启fallback降级策略 默认:true   
private final HystrixProperty<Boolean> fallbackEnabled;   
// 使用线程隔离时，是否对命令执行超时的线程调用中断（Thread.interrupt()）操作.默认:true  
private final HystrixProperty<Boolean> executionIsolationThreadInterruptOnTimeout;   
// 统计滚动的时间窗口,默认:5000毫秒circuitBreakerSleepWindowInMilliseconds  
private final HystrixProperty<Integer> metricsRollingStatisticalWindowInMilliseconds;  
// 统计窗口的Buckets的数量,默认:10个,每秒一个Buckets统计  
private final HystrixProperty<Integer> metricsRollingStatisticalWindowBuckets; // number of buckets in the statisticalWindow  
//是否开启监控统计功能,默认:true  
private final HystrixProperty<Boolean> metricsRollingPercentileEnabled;   
// 是否开启请求日志,默认:true  
private final HystrixProperty<Boolean> requestLogEnabled;   
//是否开启请求缓存,默认:true  
private final HystrixProperty<Boolean> requestCacheEnabled; // Whether request caching is enabled.  
 
2):熔断器（Circuit Breaker）配置
Circuit Breaker配置源码在HystrixCommandProperties,构造Command时通过Setter进行配置,每种依赖使用一个Circuit Breaker
Java代码  收藏代码
// 熔断器在整个统计时间内是否开启的阀值，默认20秒。也就是10秒钟内至少请求20次，熔断器才发挥起作用  
private final HystrixProperty<Integer> circuitBreakerRequestVolumeThreshold;   
//熔断器默认工作时间,默认:5秒.熔断器中断请求5秒后会进入半打开状态,放部分流量过去重试  
private final HystrixProperty<Integer> circuitBreakerSleepWindowInMilliseconds;   
//是否启用熔断器,默认true. 启动  
private final HystrixProperty<Boolean> circuitBreakerEnabled;   
//默认:50%。当出错率超过50%后熔断器启动.  
private final HystrixProperty<Integer> circuitBreakerErrorThresholdPercentage;  
//是否强制开启熔断器阻断所有请求,默认:false,不开启  
private final HystrixProperty<Boolean> circuitBreakerForceOpen;   
//是否允许熔断器忽略错误,默认false, 不开启  
private final HystrixProperty<Boolean> circuitBreakerForceClosed;  
 
3):命令合并(Collapser)配置
Command配置源码在HystrixCollapserProperties,构造Collapser时通过Setter进行配置
Java代码  收藏代码
//请求合并是允许的最大请求数,默认: Integer.MAX_VALUE  
private final HystrixProperty<Integer> maxRequestsInBatch;  
//批处理过程中每个命令延迟的时间,默认:10毫秒  
private final HystrixProperty<Integer> timerDelayInMilliseconds;  
//批处理过程中是否开启请求缓存,默认:开启  
private final HystrixProperty<Boolean> requestCacheEnabled;  
 
4):线程池(ThreadPool)配置
Java代码  收藏代码
/** 
配置线程池大小,默认值10个. 
建议值:请求高峰时99.5%的平均响应时间 + 向上预留一些即可 
*/  
HystrixThreadPoolProperties.Setter().withCoreSize(int value)  
/** 
配置线程值等待队列长度,默认值:-1 
建议值:-1表示不等待直接拒绝,测试表明线程池使用直接决绝策略+ 合适大小的非回缩线程池效率最高.所以不建议修改此值。 
当使用非回缩线程池时，queueSizeRejectionThreshold,keepAliveTimeMinutes 参数无效 
*/  
HystrixThreadPoolProperties.Setter().withMaxQueueSize(int value)  
2:Hystrix关键组件分析
 1):Hystrix流程结构解析

流程说明:
1:每次调用创建一个新的HystrixCommand,把依赖调用封装在run()方法中.
2:执行execute()/queue做同步或异步调用.
3:判断熔断器(circuit-breaker)是否打开,如果打开跳到步骤8,进行降级策略,如果关闭进入步骤.
4:判断线程池/队列/信号量是否跑满，如果跑满进入降级步骤8,否则继续后续步骤.
5:调用HystrixCommand的run方法.运行依赖逻辑
5a:依赖逻辑调用超时,进入步骤8.
6:判断逻辑是否调用成功
6a:返回成功调用结果
6b:调用出错，进入步骤8.
7:计算熔断器状态,所有的运行状态(成功, 失败, 拒绝,超时)上报给熔断器，用于统计从而判断熔断器状态.
8:getFallback()降级逻辑.
  以下四种情况将触发getFallback调用：
 (1):run()方法抛出非HystrixBadRequestException异常。
 (2):run()方法调用超时
 (3):熔断器开启拦截调用
 (4):线程池/队列/信号量是否跑满
8a:没有实现getFallback的Command将直接抛出异常
8b:fallback降级逻辑调用成功直接返回
8c:降级逻辑调用失败抛出异常
9:返回执行成功结果
2):熔断器:Circuit Breaker 
Circuit Breaker 流程架构和统计

每个熔断器默认维护10个bucket,每秒一个bucket,每个blucket记录成功,失败,超时,拒绝的状态，
默认错误超过50%且10秒内超过20个请求进行中断拦截. 
3)隔离(Isolation)分析
Hystrix隔离方式采用线程/信号的方式,通过隔离限制依赖的并发量和阻塞扩散.
(1):线程隔离
         把执行依赖代码的线程与请求线程(如:jetty线程)分离，请求线程可以自由控制离开的时间(异步过程)。
   通过线程池大小可以控制并发量，当线程池饱和时可以提前拒绝服务,防止依赖问题扩散。
   线上建议线程池不要设置过大，否则大量堵塞线程有可能会拖慢服务器。

(2):线程隔离的优缺点
线程隔离的优点:
[1]:使用线程可以完全隔离第三方代码,请求线程可以快速放回。
[2]:当一个失败的依赖再次变成可用时，线程池将清理，并立即恢复可用，而不是一个长时间的恢复。
[3]:可以完全模拟异步调用，方便异步编程。
线程隔离的缺点:
[1]:线程池的主要缺点是它增加了cpu，因为每个命令的执行涉及到排队(默认使用SynchronousQueue避免排队)，调度和上下文切换。
[2]:对使用ThreadLocal等依赖线程状态的代码增加复杂性，需要手动传递和清理线程状态。
NOTE: Netflix公司内部认为线程隔离开销足够小，不会造成重大的成本或性能的影响。
Netflix 内部API 每天100亿的HystrixCommand依赖请求使用线程隔，每个应用大约40多个线程池，每个线程池大约5-20个线程。
(3):信号隔离
      信号隔离也可以用于限制并发访问，防止阻塞扩散, 与线程隔离最大不同在于执行依赖代码的线程依然是请求线程（该线程需要通过信号申请）,
   如果客户端是可信的且可以快速返回，可以使用信号隔离替换线程隔离,降低开销.
   信号量的大小可以动态调整, 线程池大小不可以.
线程隔离与信号隔离区别如下图:
