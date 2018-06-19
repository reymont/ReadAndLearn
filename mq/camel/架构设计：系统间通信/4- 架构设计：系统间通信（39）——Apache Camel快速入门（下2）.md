架构设计：系统间通信（39）——Apache Camel快速入门（下2） - JAVA入门中 - CSDN博客 http://blog.csdn.net/yinwenjie/article/details/51818352




（接上文：《架构设计：系统间通信（38）——Apache Camel快速入门（下1）》）

4-2-1、LifecycleStrategy

LifecycleStrategy接口按照字面的理解是一个关于Camel中元素生命周期的规则管理器，但实际上LifecycleStrategy接口的定义更确切的应该被描述成一个监听器：

这里写图片描述

当Camel引用程序中发生诸如Route加载、Route移除、Service加载、Serivce移除、Context启动或者Context移除等事件时，DefaultCamelContext中已经被添加到集合“lifecycleStrategies”（java.util.List<LifecycleStrategy>）的LifecycleStrategy对象将会做相应的事件触发。

读者还应该注意到“lifecycleStrategies”集合是一个CopyOnWriteArrayList，我们随后对这个List的实现进行讲解。以下代码展示了在DefaultCamelContext添加Service时，DefaultCamelContext内部是如何触发“lifecycleStrategies”集合中已添加的监听的：

......
private void doAddService(Object object, boolean closeOnShutdown) throws Exception {
    ......

    // 只有以下条件成立，才需要将外部来源的Object作为一个Service处理
    if (object instanceof Service) {
        Service service = (Service) object;

        // 依次连续触发已注册的监听
        for (LifecycleStrategy strategy : lifecycleStrategies) {
            // 如果是一个Endpoint的实现，则触发onEndpointAdd方法
            if (service instanceof Endpoint) {
                // use specialized endpoint add
                strategy.onEndpointAdd((Endpoint) service);
            } 
            // 其它情况下，促发onServiceAdd方法
            else {
               strategy.onServiceAdd(this, service, null);
            }
       }

       // 其它后续处理
       ......
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
19
20
21
22
23
24
25
26
4-2-2、CopyOnWriteArrayList与监听者模式

正如上一小节讲到的，已在DefaultCamelContext中注册的LifecycleStrategy对象存放于一个名叫“lifecycleStrategies”的集合中，后者是CopyOnWriteArrayList容器的实现，这是一个从JDK 1.5+ 版本开始提供的容器结构。

各位读者可以设想一下这样的操作：某个线程在对容器进行写操作的同时，还有另外的线程对容器进行读取操作。如果上述操作过程是在没有“线程安全”特性的容器中进行的，那么可能出现的情况就是：开发人员原本想读取容器中 i 位置的元素X，可这个元素已经被其它线程删除了，开发人员最后读取的 i 位置的元素变成了Y。但是在具有“写线程安全”特性的容器中进行这样的操作就不会有问题：因为写操作在另一个副本容器中进行，原容器中的数据大小、数据位置都不会受到影响。

如果上述操作过程是在有“线程安全”特性的容器中进行的，那么以上脏读的情况是可以避免的。但是又会出现另外一个问题：由于容器的各种读写操作都会加上锁（无论是悲观锁还是乐观锁），所以容器的读写性能又会收到影响。如果采用的是乐观锁，那么对性能的影响可能还不会太大，但是如果采用的是悲观锁，那么对性能的影响就有点具体了。

CopyOnWriteArrayList为我们提供了另一种线程安全的容器操作方式。CopyOnWriteArrayList的工作效果类似于java.util.ArrayList，但是它通过ReentrantLock实现了容器中写操作的线程安全性。CopyOnWriteArrayList最大的特点是：当进行容器中元素的修改操作时，它会首先将容器中的原有元素克隆到一个副本容器中，然后对副本容器中的元素进行修改操作。待这些操作完成后，再将副本中的元素集合重新会写到原有的容器中完成整个修改操作。这种工作机制称为Copy-On-Write（COW）。这样做的最主要目的是分离容器的读写操作。CopyOnWriteArrayList会对所有的写操作加锁，但是不会对任何容器的读操作加锁（因为写操作在一个副本中进行）。

另外CopyOnWriteArrayList还重新实现了一个新的迭代器：COWIterator。它是做什么的呢？举例说明：在ArrayList中我们如果在进行迭代时同时进行容器的写操作，那么就可能会因为下标超界等原因出现程序异常：

List<?> list = new ArrayList<?>();
// 省略了添加元素部分的代码
......

// ArrayList不支持这样的操作方式，会报错
for(Object item : list){
    list.remove(item);
}
1
2
3
4
5
6
7
8
但如果使用CopyOnWriteArrayList中重写的COWIterator迭代器，就不会出现的情况（开发人员还可以使用JDK 1.5+ 提供的另一个线程安全COW容器：CopyOnWriteArraySet）：

List<?> list = new CopyOnWriteArrayList<?>();
// 省略了添加元素部分的代码
......

// COWIterator迭代器支持一边迭代一边进行容器的写操作
for(Object item : list){
    list.remove(item);
}
1
2
3
4
5
6
7
8
那么CopyOnWriteArrayList和监听器模式有什么关系呢？在书本上我们学到的监听器容器基本上都不是线程安全的，这基本上是出于两方面的考虑。首先对于设计模式的初学者来说最重要的理解模式所代表的设计思想，而非实现细节；另外，在这些示例中，设计模式的实现和操作一般为单一线程，不会出现多其它线程同时操作容器的情况。以下是我们常看到的监听者模式（代码片段）：

/**
 * 为事件监听携带的业务对象
 * @author yinwenjie
 */
public class BusinessEventObject extends EventObject {
    public BusinessEventObject(Object source) {
        super(source);
    }
}

/**
 * 监听器，其中只有一个事件方法
 * @author yinwenjie
 */
public interface BusinessEventListener extends EventListener {
    public void onBusinessStart(BusinessEventObject eventObject);
}

/**
 * 业务级别的代码
 * @author yinwenjie
 */
public class BusinessOperation {

    /**
     * 已注册的监听器放在这里
     */
    private List<BusinessEventListener> listeners = new ArrayList<BusinessEventListener>();

    public void registeListener(BusinessEventListener eventListener) {
        this.listeners.add(eventListener);
    }

    ......  

    public void doOp() {
        //业务代码在这里运行后，接着促发监听
        for (BusinessEventListener businessEventListener : listeners) {
            businessEventListener.onBusinessStart(new BusinessEventObject(this));
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
以上代码无需做太多说明。请注意，由于我们使用ArrayList这样的非线程安全容器作为已注册监听的存储容器，所以开发人员在使用这个容器触发监听事件时需要格外小心：确保同一时间只会有一个线程对容器进行写操作、确保在一个迭代器内没有容器的写操作、还要确保每个监听器的具体实现不会把当前线程锁死（次要）——但作为开发人员真的能随时保证这些事情吗？

4-2-3、SoftReference

我们都知道JVM的内存是有上限的，JVM的垃圾回收线程进行工作时会将当前没有任何引用可达性的对象区域进行回收，以便保证JVM的内存空间能够被循环利用。当JVM的可用内存达到上限，且垃圾回收线程又无法找到任何可以回收的对象时，应用程序就会报错。JVM中某个线程的堆栈状态可能如下图所示：

这里写图片描述 
（图A）

上图中线程Thread1在执行时，在栈内存中创建了一个变量X。变量X指向堆内存为A类实例化对象分配的内存空间（后文称之为A对象）。注意，A对象中还对同样存在于堆内存区域中的B类、C类的实例化对象（后文称为B对象、C对象）有引用关系。那么如果JVM垃圾回收策略要对A对象、B对象、C对象三个内存区域进行回收，除非针对这些区域的引用可达性全部消失，否则以上所说到的对内存区域都不会被回收。这样的对象间引用方式被称为强引用（Strong Reference）：JVM宁愿抛出OutOfMemoryError也不会在还存在引用可及性的情况下回收内存区域。

引用可达性，是JVM垃圾回收策略中确认哪些内存区域可以进行回收的判断算法。大致的定义是：从某个根引用开始进行引用图结构的深度遍历扫描，当遍历完成时那些没有被扫描到的一个（或者多个）内存区域就是失去引用可达性的区域。
JAVA JDK1.2+开始还提供一种称为“软引用”（Soft Reference）的对象间引用方式。在这种方式下，对象间的引用关系通过一个命名为java.lang.ref.SoftReference的工作类进行间接托管，目的是当JVM内存空间不足，垃圾回收策略被主动触发时 进行以下回收策略操作：扫面当前堆内存中只建立了“软引用”的内存区域，无论这些“软引用”是否依然存在引用可达性，都强制对这些建立了“软引用”的对象进行回收，以便腾出内存空间。下面我们对图A中的对象间引用关系进行如下图所示的调整：

这里写图片描述

上如所示的引用关系和图A中的引用关系类似，只是我们在A对B、C的引用关系上都增加了一个SoftReference对象进行间接关联。代码片段如下所示：

package com.test;

import java.lang.ref.SoftReference;

public class A {
    /**
     * 软引用 B
     */
    private SoftReference<B> paramB;

    /**
     * 软引用 C
     */
    private SoftReference<C> paramC;

    /**
     * 构造函数中，建立和B、C的软引用
     * @param paramB
     * @param paramC
     */
    public A(B paramB , C paramC) {
        this.paramB = new SoftReference<B>(paramB);
        this.paramC = new SoftReference<C>(paramC);
    }

    /**
     * @return the paramB
     */
    public B getParamB() {
        return paramB.get();
    }

    /**
     * @return the paramC
     */
    public C getParamC() {
        return paramC.get();
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
当出现“软引用”对象被垃圾回收线程回收时，例如B对象被回收时，A对象中的getB()方法将会返回null。那么原来进行B对象间接引用动作的SoftReference对象该怎么处理呢？要知道如果B对象被回收了，那么承载这个“软引用”的SoftReference对象就没有什么用处了。还好JDK中帮我们准备了名叫ReferenceQueue的队列，当SoftReference对象所承载的“软引用”对象被回收后，这个Reference对象将被送入ReferenceQueue中（当然你也可以不指定，如果不指定的话SoftReference对象会以“强引用”的回收策略被回收，不过SoftReference对象所占用的内存空间不大），开发人员可以随时扫描ReferenceQueue，并对其中的Reference对象进行清除。

注意，一个对象同一时间并不一定只被另一个对象引用，而是可能被若干个对象同时引用。只要对这个对象的引用中有一个没有使用“软引用”特性，那么垃圾回收策略对它的回收就不会采用“软引用”的回收策略进行。如下图所示：

这里写图片描述

上图中，有两个对象元素同时对B对象进行了引用（注意是同一个B对象，而不是对B类分别new了两次）。其中A对象对B对象的依赖通过“软引用”（SoftReference）间接完成，D对象对B对象的引用却是通过传统的“硬引用”完成的。当垃圾回收策略开始工作时它会发现这样的情况，并且即使在内存空间不够的情况下，也不会对B对象进行回收，直到针对B对象的所有引用可达性消失。

在JAVA中还有弱引用、虚引用两个概念（Camel中的LRUWeakCache就是基于弱引用实现的）。但是由于他们至少和我们重点说明的DefaultCamelContext没有太多关系，所以这里笔者就不再发散性的讲下去了。对这块还不太了解的读者可以自行参考JDK官方文档。
4-2-4、LRU算法简介

LRU的全称是Least Recently Used（最近最少使用），它是一种选择算法，有的文章中也把LRU算法称为“缓存淘汰算法”。在计算机技术实践中它被广泛用于缓存功能的开发，例如处理内存分页与虚拟内存的置换问题，或者又像Camel那样用于计算选择Endpoint对象将从缓存结构中被移除。下图的结构说明了LRU算法的大致工作过程：

这里写图片描述

上图中，我们可以看到几个关键点：

整个队列有一个阀值用于限制能够存放于队列容器中的最大元素个数，这个阀值我们暂且称为maxCacheSize。

当队列中的元素还没有达到这个maxCacheSize时，进入队列的元素将被放置在队列的最前面，队列会保持这种处理策略直到队列中的元素达到maxCacheSize为止。

当队列中的某个元素被选择时（一般来说，队列允许开发人员在选择元素时传入一个Key，队列会依据这个Key进行元素选择），被命中的元素又会重新排列到队列的最前面。这样一来，队列最尾部的元素就是近期使用最少的一个元素。

一旦当队列中的元素达到maxCacheSize后（不可能超过），新进入队列中的元素将会把队列最尾部的元素挤出队列，而它自己会排列到队列的最顶部。

4-2-5、Camel中的LRUSoftCache

那么我们介绍的SoftReference、LRU和我们本节正在讲述的DefaultCamelContext有什么联系呢？在DefaultCamelContext中，用来进行Endpoint注册存储管理的类称为EndpointRegistry，它就是依据LRU算法原则决定哪些Endpoint定义应该存放在缓存中。具体来说，EndpointRegistry中使用“软引用”方式，通过ConcurrentLinkedHashMap提供的既有LRU技术支持实现了存在于内存中的高效缓存。它在DefaultCamelContext的变量定义如下：

......
private Map<EndpointKey, Endpoint> endpoints = new EndpointRegistry(this, endpoints);
......
1
2
3
EndpointRegistry和它继承的父类LRUSoftCache，以及它更高层的父类LRUCache的主要结构如下所示：

这里写图片描述

LRUCache的主要结构
/**
 * A Least Recently Used Cache.
 * If this cache stores org.apache.camel.Service then this implementation will on eviction
 * invoke the {org.apache.camel.Service#stop()} method, to auto-stop the service.
 */
public class LRUCache<K, V> implements Map<K, V>, EvictionListener<K, V>, Serializable {
    // 这个值记录LRU队列的最大值
    private int maxCacheSize = 10000;
    // 一个布尔型，表示如果LRU队列中的元素被消除时，是否试着执行Service的stop方法
    // 因为存储在这个LRU中的元素一般来说是实现了Service接口的元素
    private boolean stopOnEviction;
    // 这个计数器用于统计LRU中元素的命中次数
    private final AtomicLong hits = new AtomicLong();
    // 这个计数器用于统计LRU中元素的未命中次数
    private final AtomicLong misses = new AtomicLong();
    // 这个计数器用于统计LRU中元素的移除数量
    private final AtomicLong evicted = new AtomicLong();
    // 由Google实现的一个数据结构，后文详细介绍
    private ConcurrentLinkedHashMap<K, V> map;

    ......
    // 这个构造函数有三个参数，分别是：
    // initialCapacity：LRU队列的初始化大小
    // maximumCacheSize：LRU队列的最大元素大小
    // stopOnEviction：这个布尔值表示是否试图对可能的Service元素进行stop操作
    public LRUCache(int initialCapacity, int maximumCacheSize, boolean stopOnEviction) {
        // 构造函数主要的作用就是初始化ConcurrentLinkedHashMap对象
        map = new ConcurrentLinkedHashMap.Builder<K, V>()
                .initialCapacity(initialCapacity)
                .maximumWeightedCapacity(maximumCacheSize)
                .listener(this).build();
        this.maxCacheSize = maximumCacheSize;
        this.stopOnEviction = stopOnEviction;
    }
    ......

    /**
     * 该方法在元素被从LRU队列中注销时被触发。
     * 其中调用的stopService方法，将会试图停止service的运行，如果value实现了Service接口的话
     * */
    @Override
    public void onEviction(K key, V value) {
        evicted.incrementAndGet();
        LOG.trace("onEviction {} -> {}", key, value);
        // 如果条件则开始stop动作
        if (stopOnEviction) {
            try {
                // stop service as its evicted from cache
                ServiceHelper.stopService(value);
            } catch (Exception e) {
                LOG.warn("Error stopping service: " + value + ". This exception will be ignored.", e);
            }
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
ConcurrentLinkedHashMap是Google提供的一个数据结构，其使用特性和java.util.LinkedHashMap一致，但是它是线程安全的。更重要的是ConcurrentLinkedHashMap的工作方式就是一个已经实现好的LRU的算法。

LRUSoftCache的主要结构
/**
 * A Least Recently Used Cache which uses SoftReference. 
 *
 * This implementation uses java.lang.ref.SoftReference for stored values in the cache
 * to support the JVM when it wants to reclaim objects when it's running out of memory.
 * Therefore this implementation does not support all the java.util.Map methods. 
 * */
public class LRUSoftCache<K, V> extends LRUCache<K, V> {

    ......
    /**
     * 构造函数
     * */
    public LRUSoftCache(int initialCapacity, int maximumCacheSize, boolean stopOnEviction) {
        // 这是调用父级LRUCache的构造函数
        super(initialCapacity, maximumCacheSize, stopOnEviction);
    }
    ......

    /**
     * SoftReference是LRUSoftCache最关键的地方，后文介绍
     * */
    @Override
    @SuppressWarnings("unchecked")
    public V put(K key, V value) {
        SoftReference<V> put = new SoftReference<V>(value);
        SoftReference<V> prev = (SoftReference<V>) super.put(key, (V) put);
        return prev != null ? prev.get() : null;
    }

    ......

    /**
     * 取出Key所对应的“软引用”，并且从“软引用”中视图获取value本身
     * */
    @Override
    @SuppressWarnings("unchecked")
    public V get(Object o) {
        SoftReference<V> ref = (SoftReference<V>) super.get(o);
        return ref != null ? ref.get() : null;
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
SoftReference是LRUSoftCache最关键的地方，请注意以上代码片段中的put方法。该方法就是向ConcurrentLinkedHashMap送入一个新的K-V的元素，但是注意了，该方法并不是把Value直接送入ConcurrentLinkedHashMap，而是创建一个针对Value的“软引用”SoftReference，并将其作为Value送入ConcurrentLinkedHashMap。通过get方法获取Key对应的Value时，也是从ConcurrentLinkedHashMap中首先获取“软引用”对象。需要注意的是，这时的“软引用”中是否还存在真实的值并不清楚，所以要进行一下判断再进行返回。

EndpointRegistry的主要结构
......
/**
 * Endpoint registry which is a based on a {@link org.apache.camel.util.LRUSoftCache}.
 * <p/>
 * We use a soft reference cache to allow the JVM to re-claim memory if it runs low on memory.
 */
public class EndpointRegistry extends LRUSoftCache<EndpointKey, Endpoint> implements StaticService {
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
实际上EndpointRegistry在代码结构中最主要的作用就是确定K-V的泛型结构，因为主要的LRU结构已经通过LRUCache实现了，另外基于“软引用”的技术逻辑也都已经通过LRUSoftCache实现了。所以我们用一句话总结整个EndpointRegistry的实现：通过LRUCache保证已经注册并且最近使用频繁的Endpoint对象一定存在于缓存中，通过LRUSoftCache保证所有已保存在内存中Endpoint对象不会导致JVM内存溢出。

5、使用XML形式编排路由

除了上文中我们一直使用的DSL进行路由编排的操作方式以外，Apache Camel也支持使用XML文件描述进行路由编排。通过XML文件开发人员还可以将Camel和Spring结合起来使用——两者本来就可以进行无缝集成。下面我们对这种方式的使用大致进行一下介绍。首先我们创建一个XML文件，和Spring结合使用的：

<?xml version="1.0" encoding="UTF-8"?>

<beans xmlns="http://www.springframework.org/schema/beans" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:context="http://www.springframework.org/schema/context"
    xmlns:camel="http://camel.apache.org/schema/spring" 
    xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd
        http://camel.apache.org/schema/spring http://camel.apache.org/schema/spring/camel-spring-2.14.1.xsd ">

    <camel:camelContext xmlns="http://camel.apache.org/schema/spring">
        <camel:endpoint id="jetty_from" uri="jetty:http://0.0.0.0:8282/directCamel"/>
        <camel:endpoint id="log_to" uri="log:helloworld2?showExchangeId=true"/>

        <camel:route>
            <camel:from ref="jetty_from"/>
            <camel:to ref="log_to"/>
        </camel:route>
    </camel:camelContext>

    ......
</beans>
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
以上xml文件中我们定义了一个Camel路由过程。请注意xml文件中所使用的schema xsd路径，不同的Apache Camel版本所使用的xsd路径是不一样的，这在Camel的官方文档中有详细说明：http://camel.apache.org/xml-reference.html。在示例代码中笔者使用的Camel版本是V2.14.1。

XML文件描述中，笔者定义了两个endpoint：id为“jetty_from”的Endpoint将作为route的入口，接着传来的Http协议信息将到达id为“log_to”endpoint中。后者是一个Log4j的操作，最终Exchange中的In Message Body信息将打印在控制台上。接下来我们启动测试程序：

......
/**
* 日志
 */
private static final Log LOGGER = LogFactory.getLog(SpringXML.class);

public static void main(String[] args) throws Exception {
    /*
     * 这里是测试代码
     * 作为架构师，您应该知道在应用程序中如何进行Spring的加载、如果在Web程序中进行加载、如何在OSGI中间件中进行加载
     * 
     * Camel会以SpringCamelContext类作为Camel上下文对象
     * */
    ApplicationContext ap = new ClassPathXmlApplicationContext("application-config.xml");
    SpringXML.LOGGER.info("初始化....." + ap);

    // 没有具体的业务含义，只是保证主线程不退出
    synchronized (SpringXML.class) {
        SpringXML.class.wait();
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
19
20
21
22
那么在Camel中如何使用Spring中业已存在的Bean对象呢？我们再将本小计中以上示例进行深入，在Route中加入一个由Spring托管的处理器对象（Processor），并在Processor中引用Spring托管的另一个Bean对象：DoSomethingService。

这是一个由Spring容器管理的Bean。书写方式就像您某个Spring工程中书写一个Spring Bean一样：
/**
 * 这是一个服务层接口定义
 * @author yinwenjie
 */
public interface DoSomethingService {
    public void doSomething(String userid);
}

==================================以上是接口，下面是接口实现

/**
 * 实现了定义的DoSomethingService接口，并且交由Spring Ioc容器托管
 * @author yinwenjie
 */
@Component("DoSomethingServiceImpl")
public class DoSomethingServiceImpl implements DoSomethingService {
    /**
     * 日志
     */
    private static final Log LOGGER = LogFactory.getLog(DoSomethingServiceImpl.class);

    /* (non-Javadoc)
     * @see com.yinwenjie.test.cameltest.helloworld.spring.DoSomethingService#doSomething(java.lang.String)
     */
    @Override
    public void doSomething(String userid) {
        DoSomethingServiceImpl.LOGGER.info("doSomething(String userid) ...");
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
自定义的Processor处理器，交给Spring托管。可以看到和之前大家书写的Processor没有太大区别。无非是多出了一个Spring提供的“Component”注解标记：
/**
 * 自定义的处理器，处理器本身交由Spring Ioc容器管理
 * 并且其中注入了一个DoSomethingService接口的实现
 * @author yinwenjie
 */
@Component("defineProcessor")
public class DefineProcessor implements Processor {
    /**
     * 日志
     */
    private static final Log LOGGER = LogFactory.getLog(DefineProcessor.class);

    @Autowired
    private DoSomethingService somethingService;

    @Override
    public void process(Exchange exchange) throws Exception {
        // 调用somethingService，说明它正常工作
        this.somethingService.doSomething("yinwenjie");
        // 这里在控制台打印一段日志，证明这个Processor正常工作了，就行
        DefineProcessor.LOGGER.info("process(Exchange exchange) ... ");
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
接下来我们就可以在原来的XML文件中修改Route的编排，加入这个被Spring Ioc容器托管的Processor处理器。以上代码已经明示，这个自定义的Processor处理器在Spring Ioc容器中的id为“defineProcessor”：
......
<camel:camelContext xmlns="http://camel.apache.org/schema/spring">
    <camel:endpoint id="jetty_from" uri="jetty:http://0.0.0.0:8282/directCamel"/>
    <camel:endpoint id="log_to" uri="log:helloworld2?showExchangeId=true"/>

    <camel:route>
        <camel:from ref="jetty_from"/>
        <camel:to ref="log_to"/>

        <!-- 这是新加的processor处理器 -->
        <camel:process ref="defineProcessor"></camel:process>
    </camel:route>
</camel:camelContext>
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
以下为控制台显示的执行效果：
[2016-07-11 19:37:36] INFO  qtp405711462-19 Exchange[Id: ID-yinwenjie-240-55321-1468237049924-0-1, ExchangePattern: InOut, BodyType: org.apache.camel.converter.stream.InputStreamCache, Body: [Body is instance of org.apache.camel.StreamCache]] (MarkerIgnoringBase.java:96)

[2016-07-11 19:37:36] INFO  qtp405711462-19 doSomething(String userid) ... (DoSomethingServiceImpl.java:24)

[2016-07-11 19:37:36] INFO  qtp405711462-19 process(Exchange exchange) ...  (DefineProcessor.java:31)
1
2
3
4
5
注意控制台打印的第一句日志还是由原来的Log4j-endpoint打印的，接着路由会执行defineProcessor处理器中的somethingService.doSomething()方法，打印出第二句日志。最后由defineProcessor中的Log4j打印出最后一句——整个由Camel和Spring集成的Route工作是正常的。