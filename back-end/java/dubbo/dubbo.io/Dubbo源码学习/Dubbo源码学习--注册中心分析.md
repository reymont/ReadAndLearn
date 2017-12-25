

Dubbo源码学习--注册中心分析 - JavaNoob - 博客园 http://www.cnblogs.com/javanoob/p/dubbo_registry.html

相关文章：

Dubbo源码学习文章目录

注册中心

关于注册中心，Dubbo提供了多个实现方式，有比较成熟的使用zookeeper 和 redis 的实现，也有实验性质的Multicast实现。

Zookeeper是Apacahe Hadoop的子项目，是一个树型的目录服务，支持变更推送，适合作为Dubbo服务的注册中心，工业强度较高，可用于生产环境，
所以Zookeeper注册中心也是Dubbo推荐使用也是使用度比较高的注册中心。

Zookeeper注册中心支持以下功能：

当提供者出现断电等异常停机时，注册中心能自动删除提供者信息。
当注册中心重启时，能自动恢复注册数据，以及订阅请求。
当会话过期时，能自动恢复注册数据，以及订阅请求。
当设置 check="false" 时，记录失败注册和订阅请求，后台定时重试。
可通过 username="admin" password="1234" 设置zookeeper登录信息。
可通过 group="dubbo" 设置zookeeper的根节点，不设置将使用无根树。
支持号通配符 group="" version="*" ，可订阅服务的所有分组和所有版本的提供者。

源码

zookeeper注册中心的源码为com.alibaba.dubbo.registry.zookeeper.ZookeeperRegistry。
ZookeeperRegistry 类继承自 FailbackRegistry，FailbackRegistry 又继承自 AbstractRegistry，AbstractRegistry实现了 RegistryService 接口。

因此我们阅读源码顺序为：RegistryService -> AbstractRegistry -> FailbackRegistry -> ZookeeperRegistry

RegistryService 接口

关于RegistryService接口RegistryService，Dubbo提供了详细的注释。

public interface RegistryService {

    /**
     * 注册数据，比如：提供者地址，消费者地址，路由规则，覆盖规则，等数据。
     * 
     * 注册需处理契约：<br>
     * 1. 当URL设置了check=false时，注册失败后不报错，在后台定时重试，否则抛出异常。<br>
     * 2. 当URL设置了dynamic=false参数，则需持久存储，否则，当注册者出现断电等情况异常退出时，需自动删除。<br>
     * 3. 当URL设置了category=routers时，表示分类存储，缺省类别为providers，可按分类部分通知数据。<br>
     * 4. 当注册中心重启，网络抖动，不能丢失数据，包括断线自动删除数据。<br>
     * 5. 允许URI相同但参数不同的URL并存，不能覆盖。<br>
     * 
     * @param url 注册信息，不允许为空，如：dubbo://10.20.153.10/com.alibaba.foo.BarService?version=1.0.0&application=kylin
     */
    void register(URL url);

    /**
     * 取消注册.
     * 
     * 取消注册需处理契约：<br>
     * 1. 如果是dynamic=false的持久存储数据，找不到注册数据，则抛IllegalStateException，否则忽略。<br>
     * 2. 按全URL匹配取消注册。<br>
     * 
     * @param url 注册信息，不允许为空，如：dubbo://10.20.153.10/com.alibaba.foo.BarService?version=1.0.0&application=kylin
     */
    void unregister(URL url);

    /**
     * 订阅符合条件的已注册数据，当有注册数据变更时自动推送.
     * 
     * 订阅需处理契约：<br>
     * 1. 当URL设置了check=false时，订阅失败后不报错，在后台定时重试。<br>
     * 2. 当URL设置了category=routers，只通知指定分类的数据，多个分类用逗号分隔，并允许星号通配，表示订阅所有分类数据。<br>
     * 3. 允许以interface,group,version,classifier作为条件查询，如：interface=com.alibaba.foo.BarService&version=1.0.0<br>
     * 4. 并且查询条件允许星号通配，订阅所有接口的所有分组的所有版本，或：interface=*&group=*&version=*&classifier=*<br>
     * 5. 当注册中心重启，网络抖动，需自动恢复订阅请求。<br>
     * 6. 允许URI相同但参数不同的URL并存，不能覆盖。<br>
     * 7. 必须阻塞订阅过程，等第一次通知完后再返回。<br>
     * 
     * @param url 订阅条件，不允许为空，如：consumer://10.20.153.10/com.alibaba.foo.BarService?version=1.0.0&application=kylin
     * @param listener 变更事件监听器，不允许为空
     */
    void subscribe(URL url, NotifyListener listener);

    /**
     * 取消订阅.
     * 
     * 取消订阅需处理契约：<br>
     * 1. 如果没有订阅，直接忽略。<br>
     * 2. 按全URL匹配取消订阅。<br>
     * 
     * @param url 订阅条件，不允许为空，如：consumer://10.20.153.10/com.alibaba.foo.BarService?version=1.0.0&application=kylin
     * @param listener 变更事件监听器，不允许为空
     */
    void unsubscribe(URL url, NotifyListener listener);

    /**
     * 查询符合条件的已注册数据，与订阅的推模式相对应，这里为拉模式，只返回一次结果。
     * 
     * @see com.alibaba.dubbo.registry.NotifyListener#notify(List)
     * @param url 查询条件，不允许为空，如：consumer://10.20.153.10/com.alibaba.foo.BarService?version=1.0.0&application=kylin
     * @return 已注册信息列表，可能为空，含义同{@link com.alibaba.dubbo.registry.NotifyListener#notify(List<URL>)}的参数。
     */
    List<URL> lookup(URL url);

}
AbstractRegistry 抽象类

从构造函数可以看出 AbstractRegistry 抽象类主要是提供了对注册中心数据的文件缓存。

    String filename = url.getParameter(Constants.FILE_KEY, System.getProperty("user.home") + "/.dubbo/dubbo-registry-" + url.getHost() + ".cache");
        File file = null;
        if (ConfigUtils.isNotEmpty(filename)) {
            file = new File(filename);
            if(! file.exists() && file.getParentFile() != null && ! file.getParentFile().exists()){
                if(! file.getParentFile().mkdirs()){
                    throw new IllegalArgumentException("Invalid registry store file " + file + ", cause: Failed to create directory " + file.getParentFile() + "!");
                }
            }
        }
Dubbo会在用户目录创建./dubbo文件夹及缓存文件，以windows为例，生成的缓存文件为：C:\Users\你的登录用户名/.dubbo/dubbo-registry-127.0.0.1.cache

FailbackRegistry 抽象类

FailbackRegistry 顾名思义是主要提供的是失败自动恢复，同样看一下构造函数，在构造函数中会通过 ScheduledExecutorService 一直执行Retry方法进行重试。

    public FailbackRegistry(URL url) {
        super(url);
        int retryPeriod = url.getParameter(Constants.REGISTRY_RETRY_PERIOD_KEY, Constants.DEFAULT_REGISTRY_RETRY_PERIOD);
        this.retryFuture = retryExecutor.scheduleWithFixedDelay(new Runnable() {
            public void run() {
                try {
                    retry();
                } catch (Throwable t) { 
                    logger.error("Unexpected error occur at failed retry, cause: " + t.getMessage(), t);
                }
            }
        }, retryPeriod, retryPeriod, TimeUnit.MILLISECONDS);
    }
retry()方法主要的从各个操作中的失败列表取出失败的操作进行重试。

  protected void retry() {
        if (! failedRegistered.isEmpty()) {
            Set<URL> failed = new HashSet<URL>(failedRegistered);
            if (failed.size() > 0) {
                if (logger.isInfoEnabled()) {
                    logger.info("Retry register " + failed);
                }
                try {
                    for (URL url : failed) {
                        try {
                            doRegister(url);
                            failedRegistered.remove(url);
                        } catch (Throwable t) { // 忽略所有异常，等待下次重试
                            logger.warn("Failed to retry register " + failed + ", waiting for again, cause: " + t.getMessage(), t);
                        }
                    }
                } catch (Throwable t) { // 忽略所有异常，等待下次重试
                    logger.warn("Failed to retry register " + failed + ", waiting for again, cause: " + t.getMessage(), t);
                }
            }
        }
        if(! failedUnregistered.isEmpty()) {
             //......
             doUnregister(url);
             failedUnregistered.remove(url);
             //.....
        }
        if (! failedSubscribed.isEmpty()) {
             //.....
        }
        if (! failedUnsubscribed.isEmpty()) {
            //.......
        }
        if (! failedNotified.isEmpty()) {
            //.......
        }
    }
同时提供了几个抽象方法



ZookeeperRegistry 类



ZookeeperRegistry流程

服务提供者启动时
向/dubbo/com.foo.BarService/providers目录下写入自己的URL地址。

服务消费者启动时
订阅/dubbo/com.foo.BarService/providers目录下的提供者URL地址。
并向/dubbo/com.foo.BarService/consumers目录下写入自己的URL地址。

监控中心启动时
订阅/dubbo/com.foo.BarService目录下的所有提供者和消费者URL地址。

ZookeeperRegistry 主要是实现了FailbackRegistry的那几个抽象方法。本次也主要分析 doRegister(),doSubscribe()这两个方法。

doRegister()

    protected void doRegister(URL url) {
        try {
            zkClient.create(toUrlPath(url), url.getParameter(Constants.DYNAMIC_KEY, true));
        } catch (Throwable e) {
            throw new RpcException("Failed to register " + url + " to zookeeper " + getUrl() + ", cause: " + e.getMessage(), e);
        }
    }

    public void create(String path, boolean ephemeral) {
        int i = path.lastIndexOf('/');
        if (i > 0) {
            create(path.substring(0, i), false);
        }
        if (ephemeral) {
            createEphemeral(path);
        } else {
            createPersistent(path);
        }
    }
}
doRegister() 主要是调用zkClient创建一个节点。 create（）以递归的方式创建节点，通过判断Url中dynamic=false 判断创建的是持久化节点还是临时节点。
创建的结果为：


doSubscribe()

doSubscribe() 订阅Zookeeper节点是通过创建ChildListener来实现的具体调用的方法是 addChildListener()
addChildListener()又调用 AbstractZookeeperClient.addTargetChildListener()然后调用subscribeChildChanges()
最后调用ZkclientZookeeperClient ZkClientd.watchForChilds()

    protected void doSubscribe(final URL url, final NotifyListener listener) {
        //....
        List<String> children = zkClient.addChildListener(path, zkListener);
        //.....
    }
    public List<String> addChildListener(String path, final ChildListener listener) {
        //......
        return addTargetChildListener(path, targetListener);
    }
    ```java
    public List<String> addTargetChildListener(String path, final IZkChildListener listener) {
        return client.subscribeChildChanges(path, listener);
    }
    public List<String> subscribeChildChanges(String path, IZkChildListener listener) {
        //.....
        return watchForChilds(path);
    }
分类: Dubbo
标签: SOA, Dubbo