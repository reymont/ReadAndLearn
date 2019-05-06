

Dubbo源码分析（四）：Dubbo之Registry - CSDN博客 http://blog.csdn.net/flashflight/article/details/44529805

服务注册
对于服务提供方，它需要发布服务，而且由于应用系统的复杂性，服务的数量、类型也不断膨胀；对于服务消费方，它最关心如何获取到它所需要的服务，而面对复杂的应用系统，需要管理大量的服务调用。而且，对于服务提供方和服务消费方来说，他们还有可能兼具这两种角色，即既需要提供服务，有需要消费服务。
通过将服务统一管理起来，可以有效地优化内部应用对服务发布/使用的流程和管理。服务注册中心可以通过特定协议来完成服务对外的统一。Dubbo提供的注册中心有如下几种类型可供选择：
Multicast注册中心
Zookeeper注册中心
Redis注册中心
Simple注册中心
    服务首先暴露在服务端，然后调用Registry的register方法在注册中心（它是一个服务协调中心，dubbo以外的独立服务端，dubbo提供了客户端实现）注册服务，然后用户通过配置文件中配置的service的url去subscribe(订阅服务)，Registry接收到订阅消息后会往url对应的的List<NotifyListener>中塞入当前NotifyListener，反之从这个list中移除listener就是取消订阅。registry会调用据consumer的订阅情况调用notify方法推送服务列表给Consumer。这里我们以Zookeeper注册中心来说明：
 ZookeeperRegistry.java的构造函数，创建Zookeeper客户端：
[java] view plain copy
public ZookeeperRegistry(URL url, ZookeeperTransporter zookeeperTransporter) {  
        super(url);  
        //如果provider的url是“0.0.0.0”或者在参数中带anyHost=true则抛出异常注册地址不存在  
        if (url.isAnyHost()) {  
            throw new IllegalStateException("registry address == null");  
        }  
        //服务分组（默认“dubbo”）  
        String group = url.getParameter(Constants.GROUP_KEY, DEFAULT_ROOT);  
        //在group头补齐“/”  
        if (! group.startsWith(Constants.PATH_SEPARATOR)) {  
            group = Constants.PATH_SEPARATOR + group;  
        }  
        //服务分组根地址  
        this.root = group;  
        //创建Zookeeper客户端  
        zkClient = zookeeperTransporter.connect(url);  
        //添加状态监听器  
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
ZookeeperRegistry的doRegister方法：
[java] view plain copy
protected void doRegister(URL url) {  
        try {  
            //连接注册中心注册  
            zkClient.create(toUrlPath(url), url.getParameter(Constants.DYNAMIC_KEY, true));  
        } catch (Throwable e) {  
            throw new RpcException("Failed to register " + url + " to zookeeper " + getUrl() + ", cause: " + e.getMessage(), e);  
        }  
    }  

    Provider初始化时会调用doRegister方法向注册中心发起注册。那么客户端又是怎么subscribe在注册中心订阅服务的呢？答案是服务消费者在初始化ConsumerConfig时会调用RegistryProtocol的refer方法进一步调用RegistryDirectory的subscribe方法最终调用ZookeeperRegistry的subscribe方法向注册中心订阅服务。
com.alibaba.dubbo.registry.support.FailBackRegistry的subscribe方法：
[java] view plain copy
@Override  
    public void subscribe(URL url, NotifyListener listener) {  
        super.subscribe(url, listener);  
        removeFailedSubscribed(url, listener);  
        try {  
            // 向服务器端发送订阅请求  
            doSubscribe(url, listener);  
        } catch (Exception e) {  
            Throwable t = e;  
  
            List<URL> urls = getCacheUrls(url);  
            if (urls != null && urls.size() > 0) {  
                notify(url, listener, urls);  
                logger.error("Failed to subscribe " + url + ", Using cached list: " + urls + " from cache file: " + getUrl().getParameter(Constants.FILE_KEY, System.getProperty("user.home") + "/dubbo-registry-" + url.getHost() + ".cache") + ", cause: " + t.getMessage(), t);  
            } else {  
                // 如果开启了启动时检测，则直接抛出异常  
                boolean check = getUrl().getParameter(Constants.CHECK_KEY, true)  
                        && url.getParameter(Constants.CHECK_KEY, true);  
                boolean skipFailback = t instanceof SkipFailbackWrapperException;  
                if (check || skipFailback) {  
                    if(skipFailback) {  
                        t = t.getCause();  
                    }  
                    throw new IllegalStateException("Failed to subscribe " + url + ", cause: " + t.getMessage(), t);  
                } else {  
                    logger.error("Failed to subscribe " + url + ", waiting for retry, cause: " + t.getMessage(), t);  
                }  
            }  
  
            // 将失败的订阅请求记录到失败列表，定时重试  
            addFailedSubscribed(url, listener);  
        }  
    }  
com.alibaba.dubbo.registry.zookeeper.Zookeeper的doSubscribe方法：
[java] view plain copy
protected void doSubscribe(final URL url, final NotifyListener listener) {  
        try {  
            //如果provider的service的接口配置的是“*”  
            if (Constants.ANY_VALUE.equals(url.getServiceInterface())) {  
                //获取服务分组根路径  
                String root = toRootPath();  
                //获取服务的NotifyListener  
                ConcurrentMap<NotifyListener, ChildListener> listeners = zkListeners.get(url);  
                if (listeners == null) {  
                    //如果没有则创建一个  
                    zkListeners.putIfAbsent(url, new ConcurrentHashMap<NotifyListener, ChildListener>());  
                    listeners = zkListeners.get(url);  
                }  
                ChildListener zkListener = listeners.get(listener);  
                //如果没有子监听器则创建一个  
                if (zkListener == null) {  
                    listeners.putIfAbsent(listener, new ChildListener() {  
                        public void childChanged(String parentPath, List<String> currentChilds) {  
                            for (String child : currentChilds) {  
                                child = URL.decode(child);  
                                if (! anyServices.contains(child)) {  
                                    anyServices.add(child);  
                                    subscribe(url.setPath(child).addParameters(Constants.INTERFACE_KEY, child,   
                                            Constants.CHECK_KEY, String.valueOf(false)), listener);  
                                }  
                            }  
                        }  
                    });  
                    zkListener = listeners.get(listener);  
                }  
                //向服务器订阅服务，注册中心会调用NotifyListener的notify函数返回服务列表  
                zkClient.create(root, false);  
                //获取服务地址列表  
                List<String> services = zkClient.addChildListener(root, zkListener);  
                if (services != null && services.size() > 0) {  
                    //如果存在服务  
                    for (String service : services) {  
                        service = URL.decode(service);  
                        anyServices.add(service);  
                        //如果serviceInterface是“*”则从分组根路径遍历service并订阅所有服务  
                        subscribe(url.setPath(service).addParameters(Constants.INTERFACE_KEY, service,   
                                Constants.CHECK_KEY, String.valueOf(false)), listener);  
                    }  
                }  
            } else {  
                //如果serviceInterface不是“*”则创建Zookeeper客户端索取服务列表，并通知（notify）消费者（consumer）这些服务可以用了  
                List<URL> urls = new ArrayList<URL>();  
                //获取类似于http：//xxx.xxx.xxx.xxx/context/com.service.xxxService/consumer的地址  
                for (String path : toCategoriesPath(url)) {  
                    //获取例如com.service.xxxService对应的NotifyListener map  
                    ConcurrentMap<NotifyListener, ChildListener> listeners = zkListeners.get(url);  
                    if (listeners == null) {  
                        zkListeners.putIfAbsent(url, new ConcurrentHashMap<NotifyListener, ChildListener>());  
                        listeners = zkListeners.get(url);  
                    }  
                    //获取ChildListener  
                    ChildListener zkListener = listeners.get(listener);  
                    if (zkListener == null) {  
                        listeners.putIfAbsent(listener, new ChildListener() {  
                            public void childChanged(String parentPath, List<String> currentChilds) {  
                                ZookeeperRegistry.this.notify(url, listener, toUrlsWithEmpty(url, parentPath, currentChilds));  
                            }  
                        });  
                        zkListener = listeners.get(listener);  
                    }  
                    //创建Zookeeper客户端  
                    zkClient.create(path, false);  
                    List<String> children = zkClient.addChildListener(path, zkListener);  
                    if (children != null) {  
                        urls.addAll(toUrlsWithEmpty(url, path, children));  
                    }  
                }  
                //提醒消费者  
                notify(url, listener, urls);  
            }  
        } catch (Throwable e) {  
            throw new RpcException("Failed to subscribe " + url + " to zookeeper " + getUrl() + ", cause: " + e.getMessage(), e);  
        }  
    }  

    至此，Dubbo的源码解析结束，以后还会对一些细节进行补充。特别在此建议看官使用apache的开源项目Zookeeper作注册中心，来完成分布式服务的协调调用。
