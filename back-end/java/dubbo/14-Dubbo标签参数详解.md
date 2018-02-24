Dubbo标签参数详解 - CSDN博客 http://blog.csdn.net/mingdry0304/article/details/72356449

1)  启动时检查 ( check )
        Dubbo缺省会在启动时检查依赖的服务是否可用，不可用时会抛出异常，阻止Spring初始化完成，以便上线时，能及早发现问题，默认check=true。
       1、 关闭某个服务的启动时检查
        <dubbo:reference interface="com.foo.BarService" check="false" />
        2、关闭所有服务的启动时检查
        <dubbo:consumer check="false" />
    3、关闭注册中心启动时检查
        <dubbo:registry check="false" />

2) 集群容错 ( cluster )
    在集群调用失败时，Dubbo提供了多种容错方案，缺省为failover重试。
集群容错模式：
        Failover Cluster
                1、失败自动切换，当出现失败，重试其它服务器。(缺省)
                2、通常用于读操作，但重试会带来更长延迟。
                3、可通过retries="2"来设置重试次数(不含第一次)。
<dubbo:service retries="2" />
<!-- 或 -->
<dubbo:reference retries="2" />
        Failfast Cluster
                1、快速失败，只发起一次调用，失败立即报错。
                2、通常用于非幂等性的写操作，比如新增记录。
        Failsafe Cluster
                1、失败安全，出现异常时，直接忽略。
                2、通常用于写入审计日志等操作。
        Failback Cluster
                1、失败自动恢复，后台记录失败请求，定时重发。
                2、通常用于消息通知操作。
        Forking Cluster
                1、并行调用多个服务器，只要一个成功即返回。
                2、通常用于实时性要求较高的读操作，但需要浪费更多服务资源。
                3、可通过forks="2"来设置最大并行数。
        Broadcast Cluster
                1、广播调用所有提供者，逐个调用，任意一台报错则报错。(2.1.0开始支持)
                2、通常用于通知所有提供者更新缓存或日志等本地资源信息。
<dubbo:service cluster="failsafe" />
<!-- 或 -->
<dubbo:reference cluster="failsafe" />

3) 负载均衡 ( LoadBalance )
        在集群负载均衡时，Dubbo提供了多种均衡策略，缺省为random随机调用。
    负载均衡方式：
        Random LoadBalance
                1、随机，按权重设置随机概率。
                2、在一个截面上碰撞的概率高，但调用量越大分布越均匀，而且按概率使用权重后也比较均匀，有利于动态调整提供者权重。
        RoundRobin LoadBalance
                1、轮循，按公约后的权重设置轮循比率。
                2、存在慢的提供者累积请求问题，比如：第二台机器很慢，但没挂，当请求调到第二台时就卡在那，久而久之，所有请求都卡在调到第二台上。
        LeastActive LoadBalance
                1、最少活跃调用数，相同活跃数的随机，活跃数指调用前后计数差。
                2、使慢的提供者收到更少请求，因为越慢的提供者的调用前后计数差会越大。
        ConsistentHash LoadBalance
                1、一致性Hash，相同参数的请求总是发到同一提供者。
                2、当某一台提供者挂时，原本发往该提供者的请求，基于虚拟节点，平摊到其它提供者，不会引起剧烈变动。
                3、缺省只对第一个参数Hash，如果要修改，请配置<dubbo:parameter key="hash.arguments" value="0,1" />
                4、缺省用160份虚拟节点，如果要修改，请配置<dubbo:parameter key="hash.nodes" value="320" />
<dubbo:service interface="..." loadbalance="roundrobin" />
<!-- 或 -->
<dubbo:reference interface="..." loadbalance="roundrobin" />
<!-- 或 -->
<dubbo:service interface="...">
    <dubbo:method name="..." loadbalance="roundrobin"/>
</dubbo:service>
<!-- 或 -->
<dubbo:reference interface="...">
    <dubbo:method name="..." loadbalance="roundrobin"/>
</dubbo:reference>

4) 线程模型( Dispatcher / ThreadPool)
        1、如果事件处理的逻辑能迅速完成，并且不会发起新的IO请求，比如只是在内存中记个标识，则直接在IO线程上处理更快，因为减少了线程池调度。
        2、但如果事件处理逻辑较慢，或者需要发起新的IO请求，比如需要查询数据库，则必须派发到线程池，否则IO线程阻塞，将导致不能接收其它请求。
        3、如果用IO线程处理事件，又在事件处理过程中发起新的IO请求，比如在连接事件中发起登录请求，会报“可能引发死锁”异常，但不会真死锁。
        Dispatcher
  all -- 所有消息都派发到线程池，包括请求，响应，连接事件，断开事件，心跳等。
            direct -- 所有消息都不派发到线程池，全部在IO线程上直接执行。
            message -- 只有请求响应消息派发到线程池，其它连接断开事件，心跳等消息，直接在IO线程上执行。
            execution -- 只请求消息派发到线程池，不含响应，响应和其它连接断开事件，心跳等消息，直接在IO线程上执行。
            connection -- 在IO线程上，将连接断开事件放入队列，有序逐个执行，其它消息派发到线程池。
        ThreadPool
            fixed -- 固定大小线程池，启动时建立线程，不关闭，一直持有。(缺省)
            cached -- 缓存线程池，空闲一分钟自动删除，需要时重建。
            limited -- 可伸缩线程池，但池中的线程数只会增长不会收缩。(为避免收缩时突然来了大流量引起的性能问题)。
<dubbo:protocol name="dubbo" dispatcher="all" threadpool="fixed" threads="100" />

5) 只订阅不注册
        让服务提供者开发方，只订阅服务(开发的服务可能依赖其它服务)，而不注册正在开发的服务，通过直连测试正在开发的服务。
<dubbo:registry address="10.20.153.10:9090" register="false" />
<!-- 或 -->
<dubbo:registry address="10.20.153.10:9090?register=false" />

6) 只注册不订阅
        让服务提供者方，只注册服务到另一注册中心，而不从另一注册中心订阅服务。
<dubbo:registry id="hzRegistry" address="10.20.153.10:9090" />
<dubbo:registry id="qdRegistry" address="10.20.141.150:9090" subscribe="false" />

7) 多注册中心
    1、多注册中心注册
    <!-- 多注册中心配置 -->
    <dubbo:registry id="beijingRegistry" address="10.20.141.150:9090" />
    <dubbo:registry id="shanghaiRegistry" address="10.20.141.151:9010" default="false" />
 
    <!-- 向多个注册中心注册 -->
    <dubbo:service interface="com.alibaba.hello.api.HelloService" version="1.0.0" ref="helloService" registry="beijingRegistry,shanghaiRegistry" />
    2、不同服务使用不同注册中心
    <!-- 多注册中心配置 -->
    <dubbo:registry id="chinaRegistry" address="10.20.141.150:9090" />
    <dubbo:registry id="intlRegistry" address="10.20.154.177:9010" default="false" />
 
    <!-- 向中文站注册中心注册 -->
    <dubbo:service interface="com.alibaba.hello.api.HelloService" version="1.0.0" ref="helloService" registry="chinaRegistry" />
 
    <!-- 向国际站注册中心注册 -->
    <dubbo:service interface="com.alibaba.hello.api.DemoService" version="1.0.0" ref="demoService" registry="intlRegistry" />
    3、多注册中心引用
    <!-- 多注册中心配置 -->
    <dubbo:registry id="chinaRegistry" address="10.20.141.150:9090" />
    <dubbo:registry id="intlRegistry" address="10.20.154.177:9010" default="false" />
 
    <!-- 引用中文站服务 -->
    <dubbo:reference id="chinaHelloService" interface="com.alibaba.hello.api.HelloService" version="1.0.0" registry="chinaRegistry" />
 
    <!-- 引用国际站站服务 -->
    <dubbo:reference id="intlHelloService" interface="com.alibaba.hello.api.HelloService" version="1.0.0" registry="intlRegistry" />

8) 服务分组
        当一个接口有多种实现时，可以用group区分。
<dubbo:service group="feedback" interface="com.xxx.IndexService" />
<dubbo:service group="member" interface="com.xxx.IndexService" />
<!-- 或 -->
<dubbo:reference id="feedbackIndexService" group="feedback" interface="com.xxx.IndexService" />
<dubbo:reference id="memberIndexService" group="member" interface="com.xxx.IndexService" />
任意组：(2.2.0以上版本支持，总是只调一个可用组的实现)
<dubbo:reference id="barService" interface="com.foo.BarService" group="*" />


9) 多版本
        当一个接口实现，出现不兼容升级时，可以用版本号过渡，版本号不同的服务相互间不引用。
<dubbo:service interface="com.foo.BarService" version="1.0.0" />
<dubbo:service interface="com.foo.BarService" version="2.0.0" />
<dubbo:reference id="barService" interface="com.foo.BarService" version="1.0.0" />
<dubbo:reference id="barService" interface="com.foo.BarService" version="2.0.0" />
不区分版本 (2.2.0以上版本支持)
<dubbo:reference id="barService" interface="com.foo.BarService" version="*" />

地址：http://dubbo.io/User+Guide-zh.htm#UserGuide-zh-%E8%83%8C%E6%99%AF