

zookeeper Curator框架简单使用 - 翟开顺 - CSDN博客 http://blog.csdn.net/T1DMzks/article/details/78463098

github： https://github.com/zhaikaishun/zookeeper_tutorial

Curator框架的目的

官网首页介绍是 Guava is to Java what Curator is to Xookeeper ，为了更好的实现java操作zookeeper服务器，后来出现了Curator框架，非常的强大，目前已经是Apache的顶级项目，里面提供了更多丰富的操作，例如session超时重连、主从选举、分布式计算器、分布式锁等等适用于各种复杂zookeeper场景的API封装。 
Maven依赖 
jar包下载 
都去官网下载，http://curator.apache.org/

Curatot框架使用(一)

Curatir框架使用链式编程风格，易读性更强，使用工程方法创建连接对象。 
1 使用CuratorFrameworkFactory的两个静态工厂方法（参数不同）来实现：

参数1： connectString，连接串
参数2： retyPolicy，重试连接策略。有四中实现分别为： 
ExponentialBackoffRetry、RetryTimes、RetryOneTimes、RetryUntilElapsed（具体参数的意思以后会讲解，也可先上网查看）
参数3：sessionTimeoutMs 会话超时时间 默认为60000ms
参数4：connectionTimeoutMs 连接超时时间，默认为15000ms 
注意：对于retryPolicy策略通过一个接口来让用户自定义实现。 
代码在package bjsxt.curator.base;
代码示例 
前面的设置

    /** zookeeper地址 */
    static final String CONNECT_ADDR = "192.168.1.31:2181,192.168.1.32:2181,192.168.1.33:2181";
    /** session超时时间 */
    static final int SESSION_OUTTIME = 5000;//ms 

    public static void main(String[] args) throws Exception {

        //1 重试策略：初试时间为1s 重试10次
        RetryPolicy retryPolicy = new ExponentialBackoffRetry(1000, 10);
        //2 通过工厂创建连接
        CuratorFramework cf = CuratorFrameworkFactory.builder()
                    .connectString(CONNECT_ADDR)
                    .sessionTimeoutMs(SESSION_OUTTIME)
                    .retryPolicy(retryPolicy)
//                  .namespace("super")
                    .build();
        //3 开启连接
        cf.start();

        System.out.println(States.CONNECTED);
        System.out.println(cf.getState());
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
Curator的基本方法

1.创建连接

2.Curator创建节点

Create方法，可选链式项：creatingParentslfNeeded、withMode、forPath、withACL等。 
例如

//4 建立节点 指定节点类型（不加withMode默认为持久类型节点）、路径、数据内容
cf.create().creatingParentsIfNeeded().withMode(CreateMode.PERSISTENT).forPath("/super/c1","c1内容".getBytes());

或者 

//      cf.create().creatingParentsIfNeeded().withMode(CreateMode.PERSISTENT).forPath("/super/c1","c1内容".getBytes());
//      cf.create().creatingParentsIfNeeded().withMode(CreateMode.PERSISTENT).forPath("/super/c2","c2内容".getBytes());
1
2
3
4
5
6
7
8
3.删除节点

delete方法，可选链式项： deletingChildrenIfNeeded、guranteed、withVersion、forPath等。 
例如

cf.delete().guaranteed().deletingChildrenIfNeeded().forPath("/super");
1
4.读取和修改数据

getData、setData方法

//读取节点
String ret1 = new String(cf.getData().forPath("/super/c2"));
System.out.println(ret1);
//修改节点
cf.setData().forPath("/super/c2", "修改c2内容".getBytes());
String ret2 = new String(cf.getData().forPath("/super/c2"));
System.out.println(ret2);   
1
2
3
4
5
6
7
5.异步回调方法。

比如创建节点时绑定一个回调函数，该回调函数可以输出服务器的状态码以及服务器事件类型。还可以加入一个线程池进行优化操作。

ExecutorService pool = Executors.newCachedThreadPool();
cf.create().creatingParentsIfNeeded().withMode(CreateMode.PERSISTENT)
.inBackground(new BackgroundCallback() {
    @Override
    public void processResult(CuratorFramework cf, CuratorEvent ce) throws Exception {
        System.out.println("code:" + ce.getResultCode());
        System.out.println("type:" + ce.getType());
        System.out.println("线程为:" + Thread.currentThread().getName());
    }
}, pool)
.forPath("/super/c3","c3内容".getBytes());
Thread.sleep(Integer.MAX_VALUE);
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
6.读取子节点方法

getChildren

List<String> list = cf.getChildren().forPath("/super");
for(String p : list){
    System.out.println(p);
}
1
2
3
4
7.判断子节点是否存在

checkExists方法

Stat stat = cf.checkExists().forPath("/super/c3");
System.out.println(stat);
1
2
讲上面异步回调的那个线程池的作用

比如某个操作一次性要创建500个节点，不可能一次用500个线程去处理。所以这里使用的是一个线程池来进行控制

CuratorWatcher

原理，使用缓存的判断的方式，不需要重复注册！！！最牛的地方，估计可以想到那个宕机订阅问题。具体的原理，建议深入了解一下，感觉挺厉害的。

1. 方法1

注意最后一个参数，这个是是否压缩 ， 注意那个cache.star的时候的那个模式 POST_INITALLZED_EVENT 
直接上代码看即可

public class CuratorWatcher1 {

    /** zookeeper地址 */
    static final String CONNECT_ADDR = "192.168.1.31:2181,192.168.1.32:2181,192.168.1.33:2181";
    /** session超时时间 */
    static final int SESSION_OUTTIME = 5000;//ms 

    public static void main(String[] args) throws Exception {

        //1 重试策略：初试时间为1s 重试10次
        RetryPolicy retryPolicy = new ExponentialBackoffRetry(1000, 10);
        //2 通过工厂创建连接
        CuratorFramework cf = CuratorFrameworkFactory.builder()
                    .connectString(CONNECT_ADDR)
                    .sessionTimeoutMs(SESSION_OUTTIME)
                    .retryPolicy(retryPolicy)
                    .build();

        //3 建立连接
        cf.start();

        //4 建立一个cache缓存
        final NodeCache cache = new NodeCache(cf, "/super", false);
        cache.start(true);
        cache.getListenable().addListener(new NodeCacheListener() {
            /**
             * <B>方法名称：</B>nodeChanged<BR>
             * <B>概要说明：</B>触发事件为创建节点和更新节点，在删除节点的时候并不触发此操作。<BR>
             * @see org.apache.curator.framework.recipes.cache.NodeCacheListener#nodeChanged()
             */
            @Override
            public void nodeChanged() throws Exception {
                System.out.println("路径为：" + cache.getCurrentData().getPath());
                System.out.println("数据为：" + new String(cache.getCurrentData().getData()));
                System.out.println("状态为：" + cache.getCurrentData().getStat());
                System.out.println("---------------------------------------");
            }
        });

        Thread.sleep(1000);
        cf.create().forPath("/super", "123".getBytes());

        Thread.sleep(1000);
        cf.setData().forPath("/super", "456".getBytes());

        Thread.sleep(1000);
        cf.delete().forPath("/super");

        Thread.sleep(Integer.MAX_VALUE);

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
输出

路径为：/super
数据为：123
状态为：38654705677,38654705677,1509971265443,1509971265443,0,0,0,0,3,0,38654705677

---------------------------------------
路径为：/super
数据为：456
状态为：38654705677,38654705678,1509971265443,1509971266479,1,0,0,0,3,0,38654705677

---------------------------------------
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
2. 方法2

注意第三个参数，表示是否接受节点数据内容，如果为false则不接受

public class CuratorWatcher2 {

    /** zookeeper地址 */
    static final String CONNECT_ADDR = "192.168.1.31:2181,192.168.1.32:2181";
    /** session超时时间 */
    static final int SESSION_OUTTIME = 10000;//ms

    public static void main(String[] args) throws Exception {

        //1 重试策略：初试时间为1s 重试10次
        RetryPolicy retryPolicy = new ExponentialBackoffRetry(1000, 10);
        //2 通过工厂创建连接
        CuratorFramework cf = CuratorFrameworkFactory.builder()
                    .connectString(CONNECT_ADDR)
                    .sessionTimeoutMs(SESSION_OUTTIME)
                    .retryPolicy(retryPolicy)
                    .build();

        //3 建立连接
        cf.start();

        //4 建立一个PathChildrenCache缓存,第三个参数为是否接受节点数据内容 如果为false则不接受
        PathChildrenCache cache = new PathChildrenCache(cf, "/super", true);
        //5 在初始化的时候就进行缓存监听
        cache.start(StartMode.POST_INITIALIZED_EVENT);
        cache.getListenable().addListener(new PathChildrenCacheListener() {
            /**
             * <B>方法名称：</B>监听子节点变更<BR>
             * <B>概要说明：</B>新建、修改、删除<BR>
             * @see org.apache.curator.framework.recipes.cache.PathChildrenCacheListener#childEvent(org.apache.curator.framework.CuratorFramework, org.apache.curator.framework.recipes.cache.PathChildrenCacheEvent)
             */
            @Override
            public void childEvent(CuratorFramework cf, PathChildrenCacheEvent event) throws Exception {
                switch (event.getType()) {
                case CHILD_ADDED:
                    System.out.println("CHILD_ADDED :" + event.getData().getPath());
                    //也可以获取内容
                    System.out.println("CHILD_ADDED 内容 :" + new String(event.getData().getData(),"utf-8"));
                    break;
                case CHILD_UPDATED:
                    System.out.println("CHILD_UPDATED :" + event.getData().getPath());
                    System.out.println("CHILD_UPDATED 内容 :" + new String(event.getData().getData(),"utf-8"));
                    break;
                case CHILD_REMOVED:
                    System.out.println("CHILD_REMOVED :" + event.getData().getPath());
                    break;
                default:
                    break;
                }
            }
        });

        //创建本身节点不发生变化
        cf.create().forPath("/super", "init".getBytes());

        //添加子节点
        Thread.sleep(1000);
        cf.create().forPath("/super/c1", "c1内容".getBytes());
        Thread.sleep(1000);
        cf.create().forPath("/super/c2", "c2内容".getBytes());

        //修改子节点
        Thread.sleep(1000);
        cf.setData().forPath("/super/c1", "c1更新内容".getBytes());

        //删除子节点
        Thread.sleep(1000);
        cf.delete().forPath("/super/c2");       

        //删除本身节点
        Thread.sleep(1000);
        cf.delete().deletingChildrenIfNeeded().forPath("/super");

        System.out.println("------end------");
        Thread.sleep(Integer.MAX_VALUE);

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
运行结果

CHILD_ADDED :/super/c1
CHILD_ADDED 内容 :c1内容
CHILD_ADDED :/super/c2
CHILD_ADDED 内容 :c2内容
CHILD_UPDATED :/super/c1
CHILD_UPDATED 内容 :c1更新内容
CHILD_REMOVED :/super/c2
CHILD_REMOVED :/super/c1
------end------
1
2
3
4
5
6
7
8
9
Curator场景应用(一)

分布式锁功能

在分布式场景中，我们为了保证数据的一致性，经常在程序运行的某一个点需要进行同步操作（java可提供synchronized或者Reentrantlock实现）比如我们看一个小示例，这个示例会出现分布式不同步的问题： 
因为我们之前所说的是再高并发下访问一个程序，现在我们则是在高并发下访问多个服务器节点（分布式） 
我们使用Curator基于Zookeeper的特性提供的分布式锁来处理分布式场景的数据一致性，zookeeper原生的写分布式比较麻烦，我们这里强烈推荐使用Curator的分布式锁！ 
Curator主要使用 InterProcessMutex 来进行分布式锁的控制

public class Lock2 {

    /** zookeeper地址 */
    static final String CONNECT_ADDR = "192.168.1.31:2181,192.168.1.32:2181";
    /** session超时时间 */
    static final int SESSION_OUTTIME = 20000;//ms

    static int count = 10;
    public static void genarNo(){
        try {
            count--;
            System.out.println(count);
        } finally {

        }
    }

    public static void main(String[] args) throws Exception {

        //1 重试策略：初试时间为1s 重试10次
        RetryPolicy retryPolicy = new ExponentialBackoffRetry(1000, 10);
        //2 通过工厂创建连接
        CuratorFramework cf = CuratorFrameworkFactory.builder()
                    .connectString(CONNECT_ADDR)
                    .sessionTimeoutMs(SESSION_OUTTIME)
                    .retryPolicy(retryPolicy)
//                  .namespace("super")
                    .build();
        //3 开启连接
        cf.start();

        //4 分布式锁
        final CountDownLatch countdown = new CountDownLatch(1);

        for(int i = 0; i < 10; i++){
            new Thread(new Runnable() {
                @Override
                public void run() {
                    InterProcessMutex lock = new InterProcessMutex(cf, "/super");
                    try {
                        countdown.await();
                        //加锁
                        lock.acquire();
                        //-------------业务处理开始
                        genarNo();
                        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss|SSS");

                        Thread.sleep(500);
                        System.out.println(Thread.currentThread().getName()+"执行此操作");
                        //-------------业务处理结束
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        try {
                            //释放
                            lock.release();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }
            },"t" + i).start();
        }
        Thread.sleep(100);
        countdown.countDown();
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
输出

9
t9执行此操作
8
t8执行此操作
7
t3执行此操作
6
t0执行此操作
5
t6执行此操作
4
t7执行此操作
3
t2执行此操作
2
t5执行此操作
1
t4执行此操作
0
t1执行此操作
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
我们可以看到，这里new了10个线程，但是每个线程里面都有各自的锁，按照道理来说，他们各部干扰，但是从结果可以看出来，这个程序还是同步的，也实现了锁的原理。（相当于不同的程序放在不同的机器上，也有类似的效果）。

分布式计数器功能

一说到分布式计数器，你可能脑海里想到了AtomicInteger这种经典的方式，如果针对一个jvm的场景当然没有问题，但是我们现在是在分布式场景下，就需要利用Curator框架的DistributedAtomicInteger了 
代码

public class CuratorAtomicInteger {

    /** zookeeper地址 */
    static final String CONNECT_ADDR = "192.168.1.31:2181,192.168.1.32:2181";
    /** session超时时间 */
    static final int SESSION_OUTTIME = 5000;//ms 

    public static void main(String[] args) throws Exception {

        //1 重试策略：初试时间为1s 重试10次
        RetryPolicy retryPolicy = new ExponentialBackoffRetry(1000, 10);
        //2 通过工厂创建连接
        CuratorFramework cf = CuratorFrameworkFactory.builder()
                    .connectString(CONNECT_ADDR)
                    .sessionTimeoutMs(SESSION_OUTTIME)
                    .retryPolicy(retryPolicy)
                    .build();
        //3 开启连接
        cf.start();
        //cf.delete().forPath("/super");


        //4 使用DistributedAtomicInteger
        DistributedAtomicInteger atomicIntger = 
                new DistributedAtomicInteger(cf, "/super", new RetryNTimes(3, 1000));
        //atomicIntger.forceSet(0);  //第一次需要有吧？

        AtomicValue<Integer> value = atomicIntger.add(1);
//      atomicIntger.increment();
//      AtomicValue<Integer> value = atomicIntger.get();
        System.out.println(value.succeeded());
        System.out.println(value.postValue());  //最新值
        System.out.println(value.preValue());   //原始值

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
第一次运行

true
1
0
1
2
3
第二次运行

true
2
1
1
2
3
第三次运行

true
3
2
1
2
3
其实这也就模拟了分布式的计数功能

barrier功能

有这样的场景，多个程序在不同的机器中，需要等待同时都准备好了，再一起运行 
有两种方式，一种是等所有的都准备好在一起跑，一种是有一个开关，这个开关打开就跑，直接看代码 
方式一： 估计不常用

public class CuratorBarrier1 {

    /** zookeeper地址 */
    static final String CONNECT_ADDR = "192.168.1.31:2181,192.168.1.32:2181";
    /** session超时时间 */
    static final int SESSION_OUTTIME = 5000;//ms 

    public static void main(String[] args) throws Exception {



        for(int i = 0; i < 5; i++){
            new Thread(new Runnable() {
                @Override
                public void run() {
                    try {
                        RetryPolicy retryPolicy = new ExponentialBackoffRetry(1000, 10);
                        CuratorFramework cf = CuratorFrameworkFactory.builder()
                                    .connectString(CONNECT_ADDR)
                                    .retryPolicy(retryPolicy)
                                    .build();
                        cf.start();

                        DistributedDoubleBarrier barrier = new DistributedDoubleBarrier(cf, "/super", 5);
                        Thread.sleep(1000 * (new Random()).nextInt(3)); 
                        System.out.println(Thread.currentThread().getName() + "已经准备");
                        barrier.enter();
                        System.out.println("同时开始运行...");
                        Thread.sleep(1000 * (new Random()).nextInt(3));
                        System.out.println(Thread.currentThread().getName() + "运行完毕");
                        barrier.leave();
                        System.out.println("同时退出运行...");
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            },"t" + i).start();
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
运行结果

t4已经准备
t2已经准备
t0已经准备
t1已经准备
t3已经准备
同时开始运行...
同时开始运行...
t2运行完毕
同时开始运行...
t4运行完毕
同时开始运行...
t0运行完毕
同时开始运行...
t3运行完毕
t1运行完毕
同时退出运行...
同时退出运行...
同时退出运行...
同时退出运行...
同时退出运行...
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
方式二： 可能用的多一些，切近实际一些 
代码如下

public class CuratorBarrier2 {

    /** zookeeper地址 */
    static final String CONNECT_ADDR = "192.168.1.31:2181,192.168.1.32:2181";
    /** session超时时间 */
    static final int SESSION_OUTTIME = 50000;//ms

    static DistributedBarrier barrier = null;

    public static void main(String[] args) throws Exception {



        for(int i = 0; i < 5; i++){
            new Thread(new Runnable() {
                @Override
                public void run() {
                    try {
                        RetryPolicy retryPolicy = new ExponentialBackoffRetry(1000, 10);
                        CuratorFramework cf = CuratorFrameworkFactory.builder()
                                    .connectString(CONNECT_ADDR)
                                    .sessionTimeoutMs(SESSION_OUTTIME)
                                    .retryPolicy(retryPolicy)
                                    .build();
                        cf.start();
                        barrier = new DistributedBarrier(cf, "/super");
                        System.out.println(Thread.currentThread().getName() + "设置barrier!");
                        barrier.setBarrier();   //设置
                        barrier.waitOnBarrier();    //等待
                        System.out.println("---------开始执行程序----------");
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            },"t" + i).start();
        }

        Thread.sleep(5000);
        barrier.removeBarrier();    //释放
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
运行结果

t0设置barrier!
t4设置barrier!
t2设置barrier!
t3设置barrier!
t1设置barrier!
---------开始执行程序----------

集群的功能

管理配置等 
注意，这个之后订阅后，宕机后再次打开，也会接受节点变更的信号。 我估计是由于缓存？ 不太明白，具体再看了。

TODO

本文大多来自于笔记，好记性不如烂笔头，烂笔头这年头比不上云笔记了