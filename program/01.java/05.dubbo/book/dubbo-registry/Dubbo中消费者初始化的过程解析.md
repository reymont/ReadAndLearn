http://cxis.me/2017/03/21/Dubbo中消费者初始化的过程解析

首先还是Spring碰到dubbo的标签之后，会使用parseCustomElement解析dubbo标签，使用的解析器是dubbo的DubboBeanDefinitionParser，解析完成之后返回BeanDefinition给Spring管理。

服务消费者端对应的是ReferenceBean，实现了ApplicationContextAware接口，Spring会在Bean的实例化那一步回调setApplicationContext方法。也实现了InitializingBean接口，接着会回调afterPropertySet方法。还实现了FactoryBean接口，实现FactoryBean可以在后期获取bean的时候做一些操作，dubbo在这个时候做初始化。另外ReferenceBean还实现了DisposableBean，会在bean销毁的时候调用destory方法。

消费者的初始化是在ReferenceBean的init方法中执行，分为两种情况：

reference标签中没有配置init属性，此时是延迟初始化的，也就是只有等到bean引用被注入到其他Bean中，或者调用getBean获取这个Bean的时候，才会初始化。比如在这里的例子里reference没有配置init属性，只有等到HelloService helloService = (HelloService) applicationContext.getBean("helloService");这句getBean的时候，才会开始调用init方法进行初始化。
另外一种情况是立即初始化，即是如果reference标签中init属性配置为true，会立即进行初始化（也就是上面说到的实现了FactoryBean接口）。
初始化开始
这里以没有配置init的reference为例，只要不注入bean或者不调用getBean获取bean的时候，就不会被初始化。HelloService helloService = (HelloService) applicationContext.getBean("helloService");

另外在ReferenceBean这个类在Spring中初始化的时候，有几个静态变量会被初始化：

private static final Protocol refprotocol = ExtensionLoader.getExtensionLoader(Protocol.class).getAdaptiveExtension();

private static final Cluster cluster = ExtensionLoader.getExtensionLoader(Cluster.class).getAdaptiveExtension();

private static final ProxyFactory proxyFactory = ExtensionLoader.getExtensionLoader(ProxyFactory.class).getAdaptiveExtension();
这几个变量的初始化是根据dubbo的SPI扩展机制动态生成的代码：

refprotocol：

import com.alibaba.dubbo.common.extension.ExtensionLoader;
public class Protocol$Adpative implements com.alibaba.dubbo.rpc.Protocol {
  public com.alibaba.dubbo.rpc.Invoker refer(java.lang.Class arg0, com.alibaba.dubbo.common.URL arg1) throws java.lang.Class {
    if (arg1 == null) throw new IllegalArgumentException("url == null");

    com.alibaba.dubbo.common.URL url = arg1;
    String extName = ( url.getProtocol() == null ? "dubbo" : url.getProtocol() );

    if(extName == null) throw new IllegalStateException("Fail to get extension(com.alibaba.dubbo.rpc.Protocol) name from url(" + url.toString() + ") use keys([protocol])");
    
    com.alibaba.dubbo.rpc.Protocol extension = (com.alibaba.dubbo.rpc.Protocol)ExtensionLoader.getExtensionLoader(com.alibaba.dubbo.rpc.Protocol.class).getExtension(extName);
    
    return extension.refer(arg0, arg1);
  }
  
  public com.alibaba.dubbo.rpc.Exporter export(com.alibaba.dubbo.rpc.Invoker arg0) throws com.alibaba.dubbo.rpc.Invoker {
    if (arg0 == null) throw new IllegalArgumentException("com.alibaba.dubbo.rpc.Invoker argument == null");
    
    if (arg0.getUrl() == null) throw new IllegalArgumentException("com.alibaba.dubbo.rpc.Invoker argument getUrl() == null");com.alibaba.dubbo.common.URL url = arg0.getUrl();
    
    String extName = ( url.getProtocol() == null ? "dubbo" : url.getProtocol() );
    
    if(extName == null) throw new IllegalStateException("Fail to get extension(com.alibaba.dubbo.rpc.Protocol) name from url(" + url.toString() + ") use keys([protocol])");
    
    com.alibaba.dubbo.rpc.Protocol extension = (com.alibaba.dubbo.rpc.Protocol)ExtensionLoader.getExtensionLoader(com.alibaba.dubbo.rpc.Protocol.class).getExtension(extName);
    
    return extension.export(arg0);
  }
  
  public void destroy() {
  	throw new UnsupportedOperationException("method public abstract void com.alibaba.dubbo.rpc.Protocol.destroy() of interface com.alibaba.dubbo.rpc.Protocol is not adaptive method!");
  }
  
  public int getDefaultPort() {
  	throw new UnsupportedOperationException("method public abstract int com.alibaba.dubbo.rpc.Protocol.getDefaultPort() of interface com.alibaba.dubbo.rpc.Protocol is not adaptive method!");
  }
}
cluster：

import com.alibaba.dubbo.common.extension.ExtensionLoader;
public class Cluster$Adpative implements com.alibaba.dubbo.rpc.cluster.Cluster {

  public com.alibaba.dubbo.rpc.Invoker join(com.alibaba.dubbo.rpc.cluster.Directory arg0) throws com.alibaba.dubbo.rpc.cluster.Directory {
    if (arg0 == null) throw new IllegalArgumentException("com.alibaba.dubbo.rpc.cluster.Directory argument == null");
    
    if (arg0.getUrl() == null) throw new IllegalArgumentException("com.alibaba.dubbo.rpc.cluster.Directory argument getUrl() == null");com.alibaba.dubbo.common.URL url = arg0.getUrl();
    
    String extName = url.getParameter("cluster", "failover");
    if(extName == null) throw new IllegalStateException("Fail to get extension(com.alibaba.dubbo.rpc.cluster.Cluster) name from url(" + url.toString() + ") use keys([cluster])");
    
    com.alibaba.dubbo.rpc.cluster.Cluster extension = (com.alibaba.dubbo.rpc.cluster.Cluster)ExtensionLoader.getExtensionLoader(com.alibaba.dubbo.rpc.cluster.Cluster.class).getExtension(extName);
    
    return extension.join(arg0);
  }
}
proxyFactory：


import com.alibaba.dubbo.common.extension.ExtensionLoader;
public class ProxyFactory$Adpative implements com.alibaba.dubbo.rpc.ProxyFactory {

  public java.lang.Object getProxy(com.alibaba.dubbo.rpc.Invoker arg0) throws com.alibaba.dubbo.rpc.Invoker {
    if (arg0 == null) throw new IllegalArgumentException("com.alibaba.dubbo.rpc.Invoker argument == null");
    
    if (arg0.getUrl() == null) throw new IllegalArgumentException("com.alibaba.dubbo.rpc.Invoker argument getUrl() == null");com.alibaba.dubbo.common.URL url = arg0.getUrl();
    
    String extName = url.getParameter("proxy", "javassist");
    if(extName == null) throw new IllegalStateException("Fail to get extension(com.alibaba.dubbo.rpc.ProxyFactory) name from url(" + url.toString() + ") use keys([proxy])");
    
    com.alibaba.dubbo.rpc.ProxyFactory extension = (com.alibaba.dubbo.rpc.ProxyFactory)ExtensionLoader.getExtensionLoader(com.alibaba.dubbo.rpc.ProxyFactory.class).getExtension(extName);
    
    return extension.getProxy(arg0);
  }
  
  public com.alibaba.dubbo.rpc.Invoker getInvoker(java.lang.Object arg0, java.lang.Class arg1, com.alibaba.dubbo.common.URL arg2) throws java.lang.Object {
    if (arg2 == null) throw new IllegalArgumentException("url == null");
    
    com.alibaba.dubbo.common.URL url = arg2;
    String extName = url.getParameter("proxy", "javassist");
    
    if(extName == null) throw new IllegalStateException("Fail to get extension(com.alibaba.dubbo.rpc.ProxyFactory) name from url(" + url.toString() + ") use keys([proxy])");
    
    com.alibaba.dubbo.rpc.ProxyFactory extension = (com.alibaba.dubbo.rpc.ProxyFactory)ExtensionLoader.getExtensionLoader(com.alibaba.dubbo.rpc.ProxyFactory.class).getExtension(extName);
    
    return extension.getInvoker(arg0, arg1, arg2);
  }
}
初始化入口
初始化的入口在ReferenceConfig的get()方法：

1
2
3
4
5
6
7
8
9
public synchronized T get() {
  if (destroyed){
  	throw new IllegalStateException("Already destroyed!");
  }
  if (ref == null) {
  	init();
  }
  return ref;
}
init()方法会先检查初始化所有的配置信息，然后调用ref = createProxy(map);创建代理，消费者最终得到的是服务的代理。初始化主要做的事情就是引用对应的远程服务，大概的步骤：

监听注册中心
连接服务提供者端进行服务引用
创建服务代理并返回
文档上关于Zookeeper作为注册中心时，服务消费者启动时要做的事情有：

订阅/dubbo/com.foo.BarService/providers目录下的提供者URL地址。
并向/dubbo/com.foo.BarService/consumers目录下写入自己的URL地址。

创建代理
引用远程服务
创建代理
init()中createProxy方法：

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
private T createProxy(Map<String, String> map) {
	//先判断是否是本地服务引用injvm
    //判断是否是点对点直连
    //判断是否是通过注册中心连接
    //然后是服务的引用
    //这里url为
    //registry://127.0.0.1:2181/com.alibaba.dubbo.registry.RegistryService?
    //application=dubbo-consumer&dubbo=2.5.3&pid=12272&
    //refer=application%3Ddubbo-consumer%26dubbo%3D2.5.3%26
    //interface%3Ddubbo.common.hello.service.HelloService%26
    //methods%3DsayHello%26pid%3D12272%26side%3D
    //consumer%26timeout%3D100000%26timestamp%3D1489318676447&
    //registry=zookeeper&timestamp=1489318676641
    //引用远程服务由Protocol的实现来处理
    refprotocol.refer(interfaceClass, url);
    //最后返回服务代理
     return (T) proxyFactory.getProxy(invoker);
}
这里refprotocol是上面生成的代码，会根据协议不同选择不同的Protocol协议。

引用远程服务
对于服务引用refprotocol.refer(interfaceClass, url)会首先进入ProtocolListenerWrapper的refer方法，然后在进入ProtocolFilterWrapper的refer方法，然后再进入RegistryProtocol的refer方法，这里的url协议是registry，所以上面两个Wrapper中不做处理，直接进入了RegistryProtocol，看下RegistryProtocol中：

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
public <T> Invoker<T> refer(Class<T> type, URL url) throws RpcException {
	//这里获得的url是
    //zookeeper://127.0.0.1:2181/com.alibaba.dubbo.registry.RegistryService?
    //application=dubbo-consumer&dubbo=2.5.3&pid=12272&
    //refer=application%3Ddubbo-consumer%26dubbo%3D2.5.3%26
    //interface%3Ddubbo.common.hello.service.HelloService%26
    //methods%3DsayHello%26pid%3D12272%26side%3D
    //consumer%26timeout%3D100000%26
    //timestamp%3D1489318676447&timestamp=1489318676641
    url = url.setProtocol(url.getParameter(Constants.REGISTRY_KEY, Constants.DEFAULT_REGISTRY)).removeParameter(Constants.REGISTRY_KEY);
    //根据url获取Registry对象
    //先连接注册中心，把消费者注册到注册中心
    Registry registry = registryFactory.getRegistry(url);
    //判断引用是否是注册中心RegistryService，如果是直接返回刚得到的注册中心服务
    if (RegistryService.class.equals(type)) {
        return proxyFactory.getInvoker((T) registry, type, url);
    }
	//以下是普通服务，需要进入注册中心和集群下面的逻辑
    // group="a,b" or group="*"
    //获取ref的各种属性
    Map<String, String> qs = StringUtils.parseQueryString(url.getParameterAndDecoded(Constants.REFER_KEY));
    //获取分组属性
    String group = qs.get(Constants.GROUP_KEY);
    //先判断引用服务是否需要合并不同实现的返回结果
    if (group != null && group.length() > 0 ) {
        if ( ( Constants.COMMA_SPLIT_PATTERN.split( group ) ).length > 1
                || "*".equals( group ) ) {
                //使用默认的分组聚合集群策略
            return doRefer( getMergeableCluster(), registry, type, url );
        }
    }
    //选择配置的集群策略（cluster="failback"）或者默认策略
    return doRefer(cluster, registry, type, url);
}
获取注册中心

连接注册中心Registry registry = registryFactory.getRegistry(url);首先会到AbstractRegistryFactory的getRegistry方法：

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
public Registry getRegistry(URL url) {
	//这里url是
    //zookeeper://127.0.0.1:2181/com.alibaba.dubbo.registry.RegistryService?
    //application=dubbo-consumer&dubbo=2.5.3&
    //interface=com.alibaba.dubbo.registry.RegistryService&
    //pid=12272&timestamp=1489318676641
    url = url.setPath(RegistryService.class.getName())
            .addParameter(Constants.INTERFACE_KEY, RegistryService.class.getName())
            .removeParameters(Constants.EXPORT_KEY, Constants.REFER_KEY);
    //这里key是
    //zookeeper://127.0.0.1:2181/com.alibaba.dubbo.registry.RegistryService
    String key = url.toServiceString();
    // 锁定注册中心获取过程，保证注册中心单一实例
    LOCK.lock();
    try {
        Registry registry = REGISTRIES.get(key);
        if (registry != null) {
            return registry;
        }
        //这里用的是ZookeeperRegistryFactory
        //返回的Registry中封装了已经连接到Zookeeper的zkClient实例
        registry = createRegistry(url);
        if (registry == null) {
            throw new IllegalStateException("Can not create registry " + url);
        }
        //放到缓存中
        REGISTRIES.put(key, registry);
        return registry;
    } finally {
        // 释放锁
        LOCK.unlock();
    }
}
ZookeeperRegistryFactory的createRegistry方法：

1
2
3
4
5
public Registry createRegistry(URL url) {
	//直接返回一个新的ZookeeperRegistry实例
    //这里的zookeeperTransporter代码在下面，动态生成的适配类
    return new ZookeeperRegistry(url, zookeeperTransporter);
}
zookeeperTransporter代码：

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
package com.alibaba.dubbo.remoting.zookeeper;
import com.alibaba.dubbo.common.extension.ExtensionLoader;
public class ZookeeperTransporter$Adpative implements com.alibaba.dubbo.remoting.zookeeper.ZookeeperTransporter {
    public com.alibaba.dubbo.remoting.zookeeper.ZookeeperClient connect(com.alibaba.dubbo.common.URL arg0) {
        if (arg0 == null) throw new IllegalArgumentException("url == null");
        
        com.alibaba.dubbo.common.URL url = arg0;
        String extName = url.getParameter("client", url.getParameter("transporter", "zkclient"));
        
        if(extName == null) throw new IllegalStateException("Fail to get extension(com.alibaba.dubbo.remoting.zookeeper.ZookeeperTransporter) name from url(" + url.toString() + ") use keys([client, transporter])");
        
        com.alibaba.dubbo.remoting.zookeeper.ZookeeperTransporter extension = (com.alibaba.dubbo.remoting.zookeeper.ZookeeperTransporter)ExtensionLoader.getExtensionLoader(com.alibaba.dubbo.remoting.zookeeper.ZookeeperTransporter.class).getExtension(extName);
        
        return extension.connect(arg0);
    }
}
上面代码中可以看到，如果我们没有指定Zookeeper的client属性，默认使用zkClient，所以上面的zookeeperTransporter是ZkclientZookeeperTransporter。

继续看new ZookeeperRegistry(url, zookeeperTransporter);：

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
public ZookeeperRegistry(URL url, ZookeeperTransporter zookeeperTransporter) {
	//这里会先经过AbstractRegistry的处理，然后经过FailbackRegistry的处理（解释在下面）
    super(url);
    if (url.isAnyHost()) {
        throw new IllegalStateException("registry address == null");
    }
    //服务分组，默认dubbo
    String group = url.getParameter(Constants.GROUP_KEY, DEFAULT_ROOT);
    if (! group.startsWith(Constants.PATH_SEPARATOR)) {
        group = Constants.PATH_SEPARATOR + group;
    }
    //注册中心的节点
    this.root = group;
    //ZkclientZookeeperTransporter的connect方法
    //直接返回一个ZkclientZookeeperClient实例
    //具体的步骤是，new一个ZkClient实例，然后订阅了一个状态变化的监听器
    zkClient = zookeeperTransporter.connect(url);
    //添加一个状态改变的监听器
    zkClient.addStateListener(new StateListener() {
        public void stateChanged(int state) {
            if (state == RECONNECTED) {
                try {
                    recover();
                } catch (Exception e) {
                    logger.error(e.getMessage(), e);
                }
            }
        }
    });
}
AbstractRegistry的处理：

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
public AbstractRegistry(URL url) {
	//设置registryUrl
    setUrl(url);
    // 启动文件保存定时器
    syncSaveFile = url.getParameter(Constants.REGISTRY_FILESAVE_SYNC_KEY, false);
    //会先去用户主目录下的.dubbo目录下加载缓存注册中心的缓存文件比如：dubbo-registry-127.0.0.1.cache
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
    this.file = file;
    //缓存文件存在的话就把文件读进内存中
    loadProperties();
    //先获取backup url
    //然后通知订阅
    notify(url.getBackupUrls());
}
获取注册中心时的通知方法

notify方法：

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
protected void notify(List<URL> urls) {
    if(urls == null || urls.isEmpty()) return;
	//getSubscribed()方法获取订阅者列表
    for (Map.Entry<URL, Set<NotifyListener>> entry : getSubscribed().entrySet()) {
        URL url = entry.getKey();

        if(! UrlUtils.isMatch(url, urls.get(0))) {
            continue;
        }

        Set<NotifyListener> listeners = entry.getValue();
        if (listeners != null) {
            for (NotifyListener listener : listeners) {
                try {
                	//通知每个监听器
                    notify(url, listener, filterEmpty(url, urls));
                } catch (Throwable t) { }
            }
        }
    }
}
notify(url, listener, filterEmpty(url, urls));代码：

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
protected void notify(URL url, NotifyListener listener, List<URL> urls) {
    Map<String, List<URL>> result = new HashMap<String, List<URL>>();
    for (URL u : urls) {
        if (UrlUtils.isMatch(url, u)) {
        	//分类
            String category = u.getParameter(Constants.CATEGORY_KEY, Constants.DEFAULT_CATEGORY);
            List<URL> categoryList = result.get(category);
            if (categoryList == null) {
                categoryList = new ArrayList<URL>();
                result.put(category, categoryList);
            }
            categoryList.add(u);
        }
    }
    if (result.size() == 0) {
        return;
    }
    Map<String, List<URL>> categoryNotified = notified.get(url);
    if (categoryNotified == null) {
        notified.putIfAbsent(url, new ConcurrentHashMap<String, List<URL>>());
        categoryNotified = notified.get(url);
    }
    for (Map.Entry<String, List<URL>> entry : result.entrySet()) {
        String category = entry.getKey();
        List<URL> categoryList = entry.getValue();
        categoryNotified.put(category, categoryList);
        saveProperties(url);
        //通知
        listener.notify(categoryList);
    }
}
AbstractRegistry构造完，接着是FailbackRegistry的处理：

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
public FailbackRegistry(URL url) {
    super(url);
    int retryPeriod = url.getParameter(Constants.REGISTRY_RETRY_PERIOD_KEY, Constants.DEFAULT_REGISTRY_RETRY_PERIOD);
    //启动失败重试定时器
    this.retryFuture = retryExecutor.scheduleWithFixedDelay(new Runnable() {
        public void run() {
            // 检测并连接注册中心
            try {
            	//重试方法由每个具体子类实现
                //获取到注册失败的，然后尝试注册
                retry();
            } catch (Throwable t) { // 防御性容错 }
        }
    }, retryPeriod, retryPeriod, TimeUnit.MILLISECONDS);
}
这里会启动一个新的定时线程，主要是有连接失败的话，会进行重试连接retry()，启动完之后返回ZookeeperRegistry中继续处理。接下来下一步是服务的引用。

引用远程服务

继续看ref方法中最后一步，服务的引用，返回的是一个Invoker，return doRefer(cluster, registry, type, url)；

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
private <T> Invoker<T> doRefer(Cluster cluster, Registry registry, Class<T> type, URL url) {
	//初始化Directory
    //组装Directory，可以看成一个消费端的List，可以随着注册中心的消息推送而动态的变化服务的Invoker
    //封装了所有服务真正引用逻辑，覆盖配置，路由规则等逻辑
    //初始化时只需要向注册中心发起订阅请求，其他逻辑均是异步处理，包括服务的引用等
    //缓存接口所有的提供者端Invoker以及注册中心接口相关的配置等
    RegistryDirectory<T> directory = new RegistryDirectory<T>(type, url);
    directory.setRegistry(registry);
    directory.setProtocol(protocol);
    //此处的subscribeUrl为
    //consumer://192.168.1.100/dubbo.common.hello.service.HelloService?
    //application=dubbo-consumer&dubbo=2.5.3&
    //interface=dubbo.common.hello.service.HelloService&
    //methods=sayHello&pid=16409&
    //side=consumer&timeout=100000&timestamp=1489322133987
    URL subscribeUrl = new URL(Constants.CONSUMER_PROTOCOL, NetUtils.getLocalHost(), 0, type.getName(), directory.getUrl().getParameters());
    if (! Constants.ANY_VALUE.equals(url.getServiceInterface())
            && url.getParameter(Constants.REGISTER_KEY, true)) {
            //到注册中心注册服务
            //此处regist是上面一步获得的registry，即是ZookeeperRegistry，包含zkClient的实例
            //会先经过AbstractRegistry的处理，然后经过FailbackRegistry的处理（解析在下面）
        registry.register(subscribeUrl.addParameters(Constants.CATEGORY_KEY, Constants.CONSUMERS_CATEGORY,
                Constants.CHECK_KEY, String.valueOf(false)));
    }
    //订阅服务
    //有服务提供的时候，注册中心会推送服务消息给消费者，消费者再进行服务的引用。
    directory.subscribe(subscribeUrl.addParameter(Constants.CATEGORY_KEY, 
            Constants.PROVIDERS_CATEGORY 
            + "," + Constants.CONFIGURATORS_CATEGORY 
            + "," + Constants.ROUTERS_CATEGORY));
    //服务的引用与变更全部由Directory异步完成
    //集群策略会将Directory伪装成一个Invoker返回
    //合并所有相同的invoker
    return cluster.join(directory);
}
注册中心接收到消费者发送的订阅请求后，会根据提供者注册服务的列表，推送服务消息给消费者。消费者端接收到注册中心发来的提供者列表后，进行服务的引用。触发Directory监听器的可以是订阅请求，覆盖策略消息，路由策略消息。

注册到注册中心

AbstractRegistry的register方法：

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
public void register(URL url) {
	//此时url是
    //consumer://192.168.1.100/dubbo.common.hello.service.HelloService?
    //application=dubbo-consumer&
    //category=consumers&check=false&dubbo=2.5.3&
    //interface=dubbo.common.hello.service.HelloService&methods=sayHello
    //&pid=16409&side=consumer&timeout=100000&timestamp=1489322133987
    if (url == null) {
        throw new IllegalArgumentException("register url == null");
    }
    if (logger.isInfoEnabled()){
        logger.info("Register: " + url);
    }
    registered.add(url);
}
上面只是把url添加到registered这个set中。

接着看FailbackRegistry的register方法：

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
public void register(URL url) {
    super.register(url);
    failedRegistered.remove(url);
    failedUnregistered.remove(url);
    try {
        // 向服务器端发送注册请求
        //这里调用的是ZookeeperRegistry中的doRegister方法
        doRegister(url);
    } catch (Exception e) {
        Throwable t = e;

        // 如果开启了启动时检测，则直接抛出异常
        boolean check = getUrl().getParameter(Constants.CHECK_KEY, true)
                && url.getParameter(Constants.CHECK_KEY, true)
                && ! Constants.CONSUMER_PROTOCOL.equals(url.getProtocol());
        boolean skipFailback = t instanceof SkipFailbackWrapperException;
        if (check || skipFailback) {
            if(skipFailback) {
                t = t.getCause();
            }
            throw new IllegalStateException("Failed to register " + url + " to registry " + getUrl().getAddress() + ", cause: " + t.getMessage(), t);
        } else {
            logger.error("Failed to register " + url + ", waiting for retry, cause: " + t.getMessage(), t);
        }

        // 将失败的注册请求记录到失败列表，定时重试
        failedRegistered.add(url);
    }
}
接着看下doRegister(url);方法，向服务器端发送注册请求，在ZookeeperRegistry中：

1
2
3
4
5
6
7
8
protected void doRegister(URL url) {
    try {
    	//直接调用create，在AbstractZookeeperClient类中
        zkClient.create(toUrlPath(url), url.getParameter(Constants.DYNAMIC_KEY, true));
    } catch (Throwable e) {
        throw new RpcException("Failed to register " + url + " to zookeeper " + getUrl() + ", cause: " + e.getMessage(), e);
    }
}
zkClient.create()方法：

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
//path为
///dubbo/dubbo.common.hello.service.HelloService/consumers/
//consumer%3A%2F%2F192.168.1.100%2F
//dubbo.common.hello.service.HelloService%3Fapplication%3D
//dubbo-consumer%26category%3Dconsumers%26check%3Dfalse%26
//dubbo%3D2.5.3%26interface%3D
//dubbo.common.hello.service.HelloService%26
//methods%3DsayHello%26pid%3D28819%26
//side%3Dconsumer%26timeout%3D100000%26timestamp%3D1489332839677
public void create(String path, boolean ephemeral) {
    int i = path.lastIndexOf('/');
    if (i > 0) {
        create(path.substring(0, i), false);
    }
    //循环完得到的path为/dubbo
    //dynamic=false 表示该数据为持久数据，当注册方退出时，数据依然保存在注册中心
    if (ephemeral) {
    	//创建临时的节点
        createEphemeral(path);
    } else {
    	//创建持久的节点，/dubbo/dubbo.common.hello.service.HelloService/consumers/
        //consumer%3A%2F%2F192.168.110.197%2F
        //dubbo.common.hello.service.HelloService%3Fapplication%3Ddubbo-consumer%26
        //category%3Dconsumers%26check%3Dfalse%26
        //dubbo%3D2.5.3%26interface%3D
        //dubbo.common.hello.service.HelloService%26
        //methods%3DsayHello%26pid%3D6370%26side%3D
        //consumer%26timeout%3D100000%26timestamp%3D1489367959659
        createPersistent(path);
    }
}
经过上面create之后，Zookeeper中就存在了消费者需要订阅的服务的节点：

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
/dubbo
	/dubbo.common.hello.service.HelloService
    	/consumers
        	/http://0.0.0.0:4550/?path=dubbo%2F
            dubbo.common.hello.service.HelloService%2F
            consumers%2Fconsumer%253A%252F%252F192.168.110.197%252F
            dubbo.common.hello.service.HelloService%253F
            application%253Ddubbo-consumer%2526category%253D
            consumers%2526check%253Dfalse%2526
            dubbo%253D2.5.3%2526interface%253D
            dubbo.common.hello.service.HelloService%2526
            methods%253DsayHello%2526pid%253D22392%2526side%253D
            consumer%2526timeout%253D100000%2526timestamp%253D1490063394184
订阅服务提供者

消费者自己注册到注册中心之后，接着是订阅服务提供者，directory.subscribe()：

1
2
3
4
5
6
public void subscribe(URL url) {
	//设置消费者url
    setConsumerUrl(url);
    //这里的registry是ZookeeperRegistry
    registry.subscribe(url, this);
}
看下registry.subscribe(url, this);，这里registry是ZookeeperRegistry，会先经过AbstractRegistry的处理，然后是FailbackRegistry的处理。

在AbstractRegistry中：

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
//此时url为consumer://192.168.1.100/dubbo.common.hello.service.HelloService?application=dubbo-consumer&
//category=providers,configurators,routers&dubbo=2.5.3&interface=dubbo.common.hello.service.HelloService&methods=
//sayHello&pid=28819&side=consumer&timeout=100000&timestamp=1489332839677
public void subscribe(URL url, NotifyListener listener) {
	//先根据url获取已注册的监听器
    Set<NotifyListener> listeners = subscribed.get(url);
    //没有监听器，就创建，并添加进去
    if (listeners == null) {
        subscribed.putIfAbsent(url, new ConcurrentHashSet<NotifyListener>());
        listeners = subscribed.get(url);
    }
    //有监听器，直接把当前RegistryDirectory添加进去
    listeners.add(listener);
}
然后是FailbackRegistry中：

1
2
3
4
5
6
7
8
public void subscribe(URL url, NotifyListener listener) {
    super.subscribe(url, listener);
    removeFailedSubscribed(url, listener);
    try {
        // 向服务器端发送订阅请求
        doSubscribe(url, listener);
    } catch (Exception e) {...}
}
继续看doSubscribe(url, listener);向服务端发送订阅请求，在ZookeeperRegistry中：

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
protected void doSubscribe(final URL url, final NotifyListener listener) {
    try {
        if (Constants.ANY_VALUE.equals(url.getServiceInterface())) {... } else {
            List<URL> urls = new ArrayList<URL>();
            for (String path : toCategoriesPath(url)) {
                ConcurrentMap<NotifyListener, ChildListener> listeners = zkListeners.get(url);
                if (listeners == null) {
                    zkListeners.putIfAbsent(url, new ConcurrentHashMap<NotifyListener, ChildListener>());
                    listeners = zkListeners.get(url);
                }
                //将zkClient的事件IZkChildListener转换到registry事件NotifyListener
                ChildListener zkListener = listeners.get(listener);
                if (zkListener == null) {
                    listeners.putIfAbsent(listener, new ChildListener() {
                        public void childChanged(String parentPath, List<String> currentChilds) {
                            ZookeeperRegistry.this.notify(url, listener, toUrlsWithEmpty(url, parentPath, currentChilds));
                        }
                    });
                    zkListener = listeners.get(listener);
                }
                //创建三个节点
                // /dubbo/dubbo.common.hello.service.HelloService/providers/
                // /dubbo/dubbo.common.hello.service.HelloService/configurators/
                // /dubbo/dubbo.common.hello.service.HelloService/routers/
                //上面三个路径会被消费者端监听，当提供者，配置，路由发生变化之后，
                //注册中心会通知消费者刷新本地缓存。
                zkClient.create(path, false);
                List<String> children = zkClient.addChildListener(path, zkListener);
                if (children != null) {
                    urls.addAll(toUrlsWithEmpty(url, path, children));
                }
            }
            notify(url, listener, urls);
        }
    } catch (Throwable e) {
        throw new RpcException("Failed to subscribe " + url + " to zookeeper " + getUrl() + ", cause: " + e.getMessage(), e);
    }
}
服务订阅完之后的通知

服务订阅完成之后，接着就是notify(url, listener, urls);：

会先经过FailbackRegistry将失败的通知请求记录到失败列表，定时重试。

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
protected void notify(URL url, NotifyListener listener, List<URL> urls) {
    try {
        doNotify(url, listener, urls);
    } catch (Exception t) {
        // 将失败的通知请求记录到失败列表，定时重试
        Map<NotifyListener, List<URL>> listeners = failedNotified.get(url);
        if (listeners == null) {
            failedNotified.putIfAbsent(url, new ConcurrentHashMap<NotifyListener, List<URL>>());
            listeners = failedNotified.get(url);
        }
        listeners.put(listener, urls);
        logger.error("Failed to notify for subscribe " + url + ", waiting for retry, cause: " + t.getMessage(), t);
    }
}
doNotify(url, listener, urls);：

1
2
3
4
protected void doNotify(URL url, NotifyListener listener, List<URL> urls) {
	//父类实现
    super.notify(url, listener, urls);
}
AbstractRegistry中的doNotify实现：

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
protected void notify(URL url, NotifyListener listener, List<URL> urls) {
    Map<String, List<URL>> result = new HashMap<String, List<URL>>();
    for (URL u : urls) {
        if (UrlUtils.isMatch(url, u)) {
        	//不同类型的数据分开通知，providers，consumers，routers，overrides
            //允许只通知其中一种类型，但该类型的数据必须是全量的，不是增量的。
            String category = u.getParameter(Constants.CATEGORY_KEY, Constants.DEFAULT_CATEGORY);
            List<URL> categoryList = result.get(category);
            if (categoryList == null) {
                categoryList = new ArrayList<URL>();
                result.put(category, categoryList);
            }
            categoryList.add(u);
        }
    }
    if (result.size() == 0) {
        return;
    }
    Map<String, List<URL>> categoryNotified = notified.get(url);
    if (categoryNotified == null) {
        notified.putIfAbsent(url, new ConcurrentHashMap<String, List<URL>>());
        categoryNotified = notified.get(url);
    }
    //对这里得到的providers，configurators，routers分别进行通知
    for (Map.Entry<String, List<URL>> entry : result.entrySet()) {
        String category = entry.getKey();
        List<URL> categoryList = entry.getValue();
        categoryNotified.put(category, categoryList);
        saveProperties(url);
        //这里的listener是RegistryDirectory
        listener.notify(categoryList);
    }
}
到RegistryDirectory中查看notify方法：

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
public synchronized void notify(List<URL> urls) {
    List<URL> invokerUrls = new ArrayList<URL>();
    List<URL> routerUrls = new ArrayList<URL>();
    List<URL> configuratorUrls = new ArrayList<URL>();
    for (URL url : urls) {
        String protocol = url.getProtocol();
        String category = url.getParameter(Constants.CATEGORY_KEY, Constants.DEFAULT_CATEGORY);
        if (Constants.ROUTERS_CATEGORY.equals(category) 
                || Constants.ROUTE_PROTOCOL.equals(protocol)) {
            routerUrls.add(url);
        } else if (Constants.CONFIGURATORS_CATEGORY.equals(category) 
                || Constants.OVERRIDE_PROTOCOL.equals(protocol)) {
            configuratorUrls.add(url);
        } else if (Constants.PROVIDERS_CATEGORY.equals(category)) {
            invokerUrls.add(url);
        } else {
            logger.warn("Unsupported category " + category + " in notified url: " + url + " from registry " + getUrl().getAddress() + " to consumer " + NetUtils.getLocalHost());
        }
    }
    // configurators 更新缓存的服务提供方配置
    if (configuratorUrls != null && configuratorUrls.size() >0 ){
        this.configurators = toConfigurators(configuratorUrls);
    }
    // routers//更新缓存的路由规则配置
    if (routerUrls != null && routerUrls.size() >0 ){
        List<Router> routers = toRouters(routerUrls);
        if(routers != null){ // null - do nothing
            setRouters(routers);
        }
    }
    List<Configurator> localConfigurators = this.configurators; // local reference
    // 合并override参数
    this.overrideDirectoryUrl = directoryUrl;
    if (localConfigurators != null && localConfigurators.size() > 0) {
        for (Configurator configurator : localConfigurators) {
            this.overrideDirectoryUrl = configurator.configure(overrideDirectoryUrl);
        }
    }
    // providers
    //重建invoker实例
    refreshInvoker(invokerUrls);
}
重建invoker实例

refreshInvoker(invokerUrls);：

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
/**
 * 根据invokerURL列表转换为invoker列表。转换规则如下：
 * 1.如果url已经被转换为invoker，则不在重新引用，直接从缓存中获取，注意如果url中任何一个参数变更也会重新引用
 * 2.如果传入的invoker列表不为空，则表示最新的invoker列表
 * 3.如果传入的invokerUrl列表是空，则表示只是下发的override规则或route规则，需要重新交叉对比，决定是否需要重新引用。
 * @param invokerUrls 传入的参数不能为null
 */
private void refreshInvoker(List<URL> invokerUrls){
    if (invokerUrls != null && invokerUrls.size() == 1 && invokerUrls.get(0) != null
            && Constants.EMPTY_PROTOCOL.equals(invokerUrls.get(0).getProtocol())) {
        this.forbidden = true; // 禁止访问
        this.methodInvokerMap = null; // 置空列表
        destroyAllInvokers(); // 关闭所有Invoker
    } else {
        this.forbidden = false; // 允许访问
        Map<String, Invoker<T>> oldUrlInvokerMap = this.urlInvokerMap; // local reference
        if (invokerUrls.size() == 0 && this.cachedInvokerUrls != null){
            invokerUrls.addAll(this.cachedInvokerUrls);
        } else {
            this.cachedInvokerUrls = new HashSet<URL>();
            this.cachedInvokerUrls.addAll(invokerUrls);//缓存invokerUrls列表，便于交叉对比
        }
        if (invokerUrls.size() ==0 ){
            return;
        }
        //会重新走一遍服务的引用过程
        //给每个提供者创建一个Invoker
        Map<String, Invoker<T>> newUrlInvokerMap = toInvokers(invokerUrls) ;// 将URL列表转成Invoker列表
        Map<String, List<Invoker<T>>> newMethodInvokerMap = toMethodInvokers(newUrlInvokerMap); // 换方法名映射Invoker列表
        // state change
        //如果计算错误，则不进行处理.
        if (newUrlInvokerMap == null || newUrlInvokerMap.size() == 0 ){
            logger.error(new IllegalStateException("urls to invokers error .invokerUrls.size :"+invokerUrls.size() + ", invoker.size :0. urls :"+invokerUrls.toString()));
            return ;
        }
        //服务提供者Invoker保存在这个map中
        this.methodInvokerMap = multiGroup ? toMergeMethodInvokerMap(newMethodInvokerMap) : newMethodInvokerMap;
        this.urlInvokerMap = newUrlInvokerMap;
        try{
            destroyUnusedInvokers(oldUrlInvokerMap,newUrlInvokerMap); // 关闭未使用的Invoker
        }catch (Exception e) {
            logger.warn("destroyUnusedInvokers error. ", e);
        }
    }
}
toInvokers(invokerUrls) 方法：

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
private Map<String, Invoker<T>> toInvokers(List<URL> urls) {
    Map<String, Invoker<T>> newUrlInvokerMap = new HashMap<String, Invoker<T>>();
    if(urls == null || urls.size() == 0){
        return newUrlInvokerMap;
    }
    Set<String> keys = new HashSet<String>();
    String queryProtocols = this.queryMap.get(Constants.PROTOCOL_KEY);
    for (URL providerUrl : urls) {
    	//此时url是dubbo://192.168.110.197:20880/dubbo.common.hello.service.HelloService?anyhost=true&
        //application=dubbo-provider&application.version=1.0&dubbo=2.5.3&environment=product&
        //interface=dubbo.common.hello.service.HelloService&methods=sayHello&organization=china&
        //owner=cheng.xi&pid=5631&side=provider&timestamp=1489367571986
        //从注册中心获取到的携带提供者信息的url
        //如果reference端配置了protocol，则只选择匹配的protocol
        if (queryProtocols != null && queryProtocols.length() >0) {
            boolean accept = false;
            String[] acceptProtocols = queryProtocols.split(",");
            for (String acceptProtocol : acceptProtocols) {
                if (providerUrl.getProtocol().equals(acceptProtocol)) {
                    accept = true;
                    break;
                }
            }
            if (!accept) {
                continue;
            }
        }
        if (Constants.EMPTY_PROTOCOL.equals(providerUrl.getProtocol())) {
            continue;
        }
        if (! ExtensionLoader.getExtensionLoader(Protocol.class).hasExtension(providerUrl.getProtocol())) {
            logger.error(new IllegalStateException("Unsupported protocol " + providerUrl.getProtocol() + " in notified url: " + providerUrl + " from registry " + getUrl().getAddress() + " to consumer " + NetUtils.getLocalHost() 
                    + ", supported protocol: "+ExtensionLoader.getExtensionLoader(Protocol.class).getSupportedExtensions()));
            continue;
        }
        URL url = mergeUrl(providerUrl);

        String key = url.toFullString(); // URL参数是排序的
        if (keys.contains(key)) { // 重复URL
            continue;
        }
        keys.add(key);
        // 缓存key为没有合并消费端参数的URL，不管消费端如何合并参数，如果服务端URL发生变化，则重新refer
        Map<String, Invoker<T>> localUrlInvokerMap = this.urlInvokerMap; // local reference
        Invoker<T> invoker = localUrlInvokerMap == null ? null : localUrlInvokerMap.get(key);
        if (invoker == null) { // 缓存中没有，重新refer
            try {
                boolean enabled = true;
                if (url.hasParameter(Constants.DISABLED_KEY)) {
                    enabled = ! url.getParameter(Constants.DISABLED_KEY, false);
                } else {
                    enabled = url.getParameter(Constants.ENABLED_KEY, true);
                }
                if (enabled) {
                	//根据扩展点加载机制，这里使用的protocol是DubboProtocol
                    invoker = new InvokerDelegete<T>(protocol.refer(serviceType, url), url, providerUrl);
                }
            } catch (Throwable t) {
                logger.error("Failed to refer invoker for interface:"+serviceType+",url:("+url+")" + t.getMessage(), t);
            }
            if (invoker != null) { // 将新的引用放入缓存
                newUrlInvokerMap.put(key, invoker);
            }
        }else {
            newUrlInvokerMap.put(key, invoker);
        }
    }
    keys.clear();
    return newUrlInvokerMap;
}
创建invoker invoker = new InvokerDelegete<T>(protocol.refer(serviceType, url), url, providerUrl);：

先使用DubboProtocol的refer方法，这一步会依次调用ProtocolFIlterListenerWrapper，ProtocolFilterWrapper，DubboProtocol中的refer方法。经过两个Wrapper中，会添加对应的InvokerListener并构建Invoker Filter链，在DubboProtocol中会创建一个DubboInvoker对象，该Invoker对象持有服务Class，providerUrl，负责和服务提供端通信的ExchangeClient。
接着使用得到的Invoker创建一个InvokerDelegete
创建invoker

在DubboProtocol中创建DubboInvoker的时候代码如下：

1
2
3
4
5
6
7
public <T> Invoker<T> refer(Class<T> serviceType, URL url) throws RpcException {
    // create rpc invoker.
    //这里有一个getClients方法
    DubboInvoker<T> invoker = new DubboInvoker<T>(serviceType, url, getClients(url), invokers);
    invokers.add(invoker);
    return invoker;
}
查看getClients方法：

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
private ExchangeClient[] getClients(URL url){
    //是否共享连接
    boolean service_share_connect = false;
    int connections = url.getParameter(Constants.CONNECTIONS_KEY, 0);
    //如果connections不配置，则共享连接，否则每服务每连接
    if (connections == 0){
        service_share_connect = true;
        connections = 1;
    }

    ExchangeClient[] clients = new ExchangeClient[connections];
    for (int i = 0; i < clients.length; i++) {
        if (service_share_connect){
        	//这里没有配置connections，就使用getSharedClient
            //getSharedClient中先去缓存中查找，没有的话就会新建，也是调用initClient方法
            clients[i] = getSharedClient(url);
        } else {
            clients[i] = initClient(url);
        }
    }
    return clients;
}
直接看initClient方法：

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
//创建新连接
private ExchangeClient initClient(URL url) {
        
    // client type setting.
    String str = url.getParameter(Constants.CLIENT_KEY, url.getParameter(Constants.SERVER_KEY, Constants.DEFAULT_REMOTING_CLIENT));

    String version = url.getParameter(Constants.DUBBO_VERSION_KEY);
    boolean compatible = (version != null && version.startsWith("1.0."));
    url = url.addParameter(Constants.CODEC_KEY, Version.isCompatibleVersion() && compatible ? COMPATIBLE_CODEC_NAME : DubboCodec.NAME);
    //默认开启heartbeat
    url = url.addParameterIfAbsent(Constants.HEARTBEAT_KEY, String.valueOf(Constants.DEFAULT_HEARTBEAT));

    // BIO存在严重性能问题，暂时不允许使用
    if (str != null && str.length() > 0 && ! ExtensionLoader.getExtensionLoader(Transporter.class).hasExtension(str)) {
        throw new RpcException("Unsupported client type: " + str + "," +
                " supported client type is " + StringUtils.join(ExtensionLoader.getExtensionLoader(Transporter.class).getSupportedExtensions(), " "));
    }

    ExchangeClient client ;
    try {
    	//如果lazy属性没有配置为true（我们没有配置，默认为false）ExchangeClient会马上和服务端建立连接
        //设置连接应该是lazy的 
        if (url.getParameter(Constants.LAZY_CONNECT_KEY, false)){
            client = new LazyConnectExchangeClient(url ,requestHandler);
        } else {
        	//立即和服务端建立连接
            client = Exchangers.connect(url ,requestHandler);
        }
    } catch (RemotingException e) {
        throw new RpcException("Fail to create remoting client for service(" + url
                + "): " + e.getMessage(), e);
    }
    return client;
}
和服务端建立连接，Exchangers.connect(url ,requestHandler);，其实最后使用的是HeaderExchanger，Exchanger目前只有这一个实现：

1
2
3
4
5
6
7
public ExchangeClient connect(URL url, ExchangeHandler handler) throws RemotingException {
	//先经过HeaderExchangeHandler包装
    //然后是DecodeHandler
    //然后是Transporters.connect
    //返回一个HeaderExchangerClient，这里封装了client，channel，启动心跳的定时器等
    return new HeaderExchangeClient(Transporters.connect(url, new DecodeHandler(new HeaderExchangeHandler(handler))));
}
Transporters.connect中也是根据SPI扩展获取Transport的具体实现，这里默认使用NettyTransporter.connect()，在NettyTransporter的connect方法中直接返回一个NettyClient(url, listener);，下面看下具体的NettyClient初始化细节，会先初始化AbstractPeer这里只是吧url和handler赋值；然后是AbstractEndpoint初始化：

1
2
3
4
5
6
7
public AbstractEndpoint(URL url, ChannelHandler handler) {
    super(url, handler);
    //获取编解码器，这里是DubboCountCodec
    this.codec = getChannelCodec(url);
    this.timeout = url.getPositiveParameter(Constants.TIMEOUT_KEY, Constants.DEFAULT_TIMEOUT);
    this.connectTimeout = url.getPositiveParameter(Constants.CONNECT_TIMEOUT_KEY, Constants.DEFAULT_CONNECT_TIMEOUT);
}
接着是AbstractClient的初始化：

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
public AbstractClient(URL url, ChannelHandler handler) throws RemotingException {
    super(url, handler);
    send_reconnect = url.getParameter(Constants.SEND_RECONNECT_KEY, false);
    shutdown_timeout = url.getParameter(Constants.SHUTDOWN_TIMEOUT_KEY, Constants.DEFAULT_SHUTDOWN_TIMEOUT);
    //默认重连间隔2s，1800表示1小时warning一次.
    reconnect_warning_period = url.getParameter("reconnect.waring.period", 1800);

    try {
    	//具体实现在子类中
        doOpen();
    } catch (Throwable t) {。。。 }
    try {
        // 连接
        connect();
    } catch (RemotingException t) {。。。} 
	// TODO暂没理解
    executor = (ExecutorService) ExtensionLoader.getExtensionLoader(DataStore.class)
        .getDefaultExtension().get(Constants.CONSUMER_SIDE, Integer.toString(url.getPort()));
    ExtensionLoader.getExtensionLoader(DataStore.class)
        .getDefaultExtension().remove(Constants.CONSUMER_SIDE, Integer.toString(url.getPort()));
}
看下在NettyClient中doOpen()的实现：

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
protected void doOpen() throws Throwable {
    NettyHelper.setNettyLoggerFactory();
    bootstrap = new ClientBootstrap(channelFactory);
    // config
    // @see org.jboss.netty.channel.socket.SocketChannelConfig
    bootstrap.setOption("keepAlive", true);
    bootstrap.setOption("tcpNoDelay", true);
    bootstrap.setOption("connectTimeoutMillis", getTimeout());
    final NettyHandler nettyHandler = new NettyHandler(getUrl(), this);
    bootstrap.setPipelineFactory(new ChannelPipelineFactory() {
        public ChannelPipeline getPipeline() {
            NettyCodecAdapter adapter = new NettyCodecAdapter(getCodec(), getUrl(), NettyClient.this);
            ChannelPipeline pipeline = Channels.pipeline();
            pipeline.addLast("decoder", adapter.getDecoder());
            pipeline.addLast("encoder", adapter.getEncoder());
            pipeline.addLast("handler", nettyHandler);
            return pipeline;
        }
    });
}
这里是Netty3中的客户端连接的一些常规步骤，暂不做具体解析。open之后，就是真正连接服务端的操作了，connect()：

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
protected void connect() throws RemotingException {
    connectLock.lock();
    try {
        if (isConnected()) {
            return;
        }
        //初始化重连的线程
        initConnectStatusCheckCommand();
        //连接，在子类中实现
        doConnect();
        reconnect_count.set(0);
        reconnect_error_log_flag.set(false);
    } catch (RemotingException e) {。。。} finally {
        connectLock.unlock();
    }
}
NettyClient中的doConnect方法：

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
protected void doConnect() throws Throwable {
    long start = System.currentTimeMillis();
    //消费者端开始连接，这一步的时候，服务提供者端就接到了连接请求，开始处理了
    ChannelFuture future = bootstrap.connect(getConnectAddress());
    try{
        boolean ret = future.awaitUninterruptibly(getConnectTimeout(), TimeUnit.MILLISECONDS);
        if (ret && future.isSuccess()) {
            Channel newChannel = future.getChannel();
            newChannel.setInterestOps(Channel.OP_READ_WRITE);
            try {
                // 关闭旧的连接
                Channel oldChannel = NettyClient.this.channel; // copy reference
                if (oldChannel != null) {
                    try {
                        oldChannel.close();
                    } finally {
                        NettyChannel.removeChannelIfDisconnected(oldChannel);
                    }
                }
            } finally {
                if (NettyClient.this.isClosed()) {
                    try {
                        newChannel.close();
                    } finally {
                        NettyClient.this.channel = null;
                        NettyChannel.removeChannelIfDisconnected(newChannel);
                    }
                } else {
                    NettyClient.this.channel = newChannel;
                }
            }
        } else if (future.getCause() != null) { throw。。。  } else {throw 。。。 }
    }finally{
        if (! isConnected()) {
            future.cancel();
        }
    }
}
这里连接的细节都交给了netty。

NettyClient初始化完成之后，返回给Transporters，再返回给HeaderExchanger，HeaderExchanger中将NettyClient包装成HeaderExchangeClient返回给DubboProtocol的initClient方法中，到此在getSharedClient中就获取到了一个ExchangeClient，然后包装一下返回client = new ReferenceCountExchangeClient(exchagneclient, ghostClientMap);。

到这里在DubboProtocol的refer方法中这句DubboInvoker<T> invoker = new DubboInvoker<T>(serviceType, url, getClients(url), invokers);创建DubboInvoker就已经解析完成，创建过程中连接了服务端，包含一个ExchangeClient等：

1
2
3
4
5
6
7
8
public <T> Invoker<T> refer(Class<T> serviceType, URL url) throws RpcException {
    // create rpc invoker.
    DubboInvoker<T> invoker = new DubboInvoker<T>(serviceType, url, getClients(url), invokers);
    //将invoker缓存
    invokers.add(invoker);
    //返回invoker
    return invoker;
}
接着返回ProtocolFilterWrapper的refer方法，在这里会构建invoker链：

1
2
3
4
5
6
public <T> Invoker<T> refer(Class<T> type, URL url) throws RpcException {
    if (Constants.REGISTRY_PROTOCOL.equals(url.getProtocol())) {
        return protocol.refer(type, url);
    }
    return buildInvokerChain(protocol.refer(type, url), Constants.REFERENCE_FILTER_KEY, Constants.CONSUMER);
}
接着再返回到ProtocolListenerWrapper的refer方法，这里会初始化监听器，包装：

1
2
3
4
5
6
7
8
9
public <T> Invoker<T> refer(Class<T> type, URL url) throws RpcException {
    if (Constants.REGISTRY_PROTOCOL.equals(url.getProtocol())) {
        return protocol.refer(type, url);
    }
    return new ListenerInvokerWrapper<T>(protocol.refer(type, url), 
            Collections.unmodifiableList(
                    ExtensionLoader.getExtensionLoader(InvokerListener.class)
                    .getActivateExtension(url, Constants.INVOKER_LISTENER_KEY)));
}
接着在返回到toInvokers方法，然后返回refreshInvoker方法的Map<String, Invoker<T>> newUrlInvokerMap = toInvokers(invokerUrls) ;这就获得了Invoker，接着就是方法名映射Invoker列表：Map<String, List<Invoker<T>>> newMethodInvokerMap = toMethodInvokers(newUrlInvokerMap);这里将invokers列表转成与方法的映射关系。到这里refreshInvoker方法就完成了，在往上就返回到AbstractRegistry的notify方法，到这里也完成了。

创建服务代理
到这里有关消费者端注册到注册中心和订阅注册中心就完事儿了，这部分是在RegistryProtocol.doRefer方法中，这个方法最后一句是return cluster.join(directory);，这里由Cluster组件创建一个Invoker并返回，这里的cluster默认是用FailoverCluster，最后返回的是经过MockClusterInvoker包装过的FailoverCluster。继续返回到ReferenceConfig中createProxy方法，这时候我们已经完成了消费者端引用服务的Invoker。然后最后返回的是根据我们得到的invoker创建的服务代理return (T) proxyFactory.getProxy(invoker);。这里proxyFactory是我们在最上面列出的动态生成的代码。

首先经过AbstractProxyFactory的处理：

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
public <T> T getProxy(Invoker<T> invoker) throws RpcException {
    Class<?>[] interfaces = null;
    String config = invoker.getUrl().getParameter("interfaces");
    if (config != null && config.length() > 0) {
        String[] types = Constants.COMMA_SPLIT_PATTERN.split(config);
        if (types != null && types.length > 0) {
            interfaces = new Class<?>[types.length + 2];
            interfaces[0] = invoker.getInterface();
            interfaces[1] = EchoService.class;
            for (int i = 0; i < types.length; i ++) {
                interfaces[i + 1] = ReflectUtils.forName(types[i]);
            }
        }
    }
    if (interfaces == null) {
        interfaces = new Class<?>[] {invoker.getInterface(), EchoService.class};
    }
    //这里默认使用的是JavassistProxyFactory的实现
    return getProxy(invoker, interfaces);
}
然后经过StubProxyFactoryWrapper的处理：

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
public <T> T getProxy(Invoker<T> invoker) throws RpcException {
    T proxy = proxyFactory.getProxy(invoker);
    if (GenericService.class != invoker.getInterface()) {
        String stub = invoker.getUrl().getParameter(Constants.STUB_KEY, invoker.getUrl().getParameter(Constants.LOCAL_KEY));
        if (ConfigUtils.isNotEmpty(stub)) {
            Class<?> serviceType = invoker.getInterface();
            if (ConfigUtils.isDefault(stub)) {
                if (invoker.getUrl().hasParameter(Constants.STUB_KEY)) {
                    stub = serviceType.getName() + "Stub";
                } else {
                    stub = serviceType.getName() + "Local";
                }
            }
            try {
                Class<?> stubClass = ReflectUtils.forName(stub);
                if (! serviceType.isAssignableFrom(stubClass)) {
                    throw new IllegalStateException("The stub implemention class " + stubClass.getName() + " not implement interface " + serviceType.getName());
                }
                try {
                    Constructor<?> constructor = ReflectUtils.findConstructor(stubClass, serviceType);
                    proxy = (T) constructor.newInstance(new Object[] {proxy});
                    //export stub service
                    URL url = invoker.getUrl();
                    if (url.getParameter(Constants.STUB_EVENT_KEY, Constants.DEFAULT_STUB_EVENT)){
                        url = url.addParameter(Constants.STUB_EVENT_METHODS_KEY, StringUtils.join(Wrapper.getWrapper(proxy.getClass()).getDeclaredMethodNames(), ","));
                        url = url.addParameter(Constants.IS_SERVER_KEY, Boolean.FALSE.toString());
                        try{
                            export(proxy, (Class)invoker.getInterface(), url);
                        }catch (Exception e) {
                            LOGGER.error("export a stub service error.", e);
                        }
                    }
                } catch (NoSuchMethodException e) {
                    throw new IllegalStateException("No such constructor \"public " + stubClass.getSimpleName() + "(" + serviceType.getName() + ")\" in stub implemention class " + stubClass.getName(), e);
                }
            } catch (Throwable t) {
                LOGGER.error("Failed to create stub implemention class " + stub + " in consumer " + NetUtils.getLocalHost() + " use dubbo version " + Version.getVersion() + ", cause: " + t.getMessage(), t);
                // ignore
            }
        }
    }
    return proxy;
}
返回代理。到此HelloService helloService = (HelloService) applicationContext.getBean("helloService");就解析完成了，得到了服务的代理，代理会被注册到Spring容器中，可以调用服务方法了。接下来的方法调用过程，是消费者发送请求，提供者处理，然后消费者接受处理结果的请求。

初始化的过程：主要做了注册到注册中心，监听注册中心，连接到服务提供者端，创建代理。这些都是为了下面消费者和提供者之间的通信做准备。

