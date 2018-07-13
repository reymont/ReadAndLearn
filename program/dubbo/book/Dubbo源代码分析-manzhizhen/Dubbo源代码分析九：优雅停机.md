

Dubbo源代码分析九：优雅停机 - CSDN博客 http://blog.csdn.net/manzhizhen/article/details/78756370

虽然我们系统的用户体验和数据一致性不应该完全靠优雅停机来保证，但作为一流的RPC框架，优雅停机的功能必不可少，Dubbo用户手册有对优雅停机做一个简单的叙述：
 
Dubbo是通过JDK的ShutdownHook 来完成优雅停机的,所以如果用户使用 kill -9 PID 等强制关闭指令,是不会执行优雅停机的,只有通过 kill PID时,才会执行。
服务提供方：停止时,先标记为不接收新请求,新请求过来时直接报错,让客户端重试其它机器。然后,检测线程池中的线程是否正在运行,如果有,等待所有线程执行完成,除非超时,则强制关闭。
服务消费方：停止时,不再发起新的调用请求,所有新的调用在客户端即报错。然后,检测有没有请求的响应还没有返回,等待响应返回,除非超时,则强制关闭。
 
从官方的描述来看，服务提供者进行优雅停机时，将不在接收新的请求，新的请求过来将直接报错，需要客户端配置重试机制来重试其他服务器；而服务消费者进行优雅停机时，会将Dubbo调用拦截在自己这方。官方给的方案有些简单粗暴，主要依赖的是系统上游消费者的重试，但很多情况下，微服务之间为了避免雪崩或流量风暴，除了特别重要的服务，几乎都关闭了重试的功能。
 
为了形象说明，我们通过一个场景来分析Dubbo的优雅停机做法，如下图:

 
服务调用图
 
服务ABCD之间通过Dubbo来通信，假设一次RPC调用顺序经历上图①②③三个步骤，我们的目标是对B服务进行优雅停机，当然，在分布式环境，A、B、C、D服务会有多个，为简单起见，图中只画了一个B服务。
 
话不多说，我们先从源代码角度看现有的Dubbo（本文使用的是2.5.3版本）的优雅停机是如何做的。官方文档已经告诉我们，如果ShutdownHook失效，用户可以自行调用ProtocolConfig.destroyAll()来主动进行优雅停机，可见我们该从这方法入手：
 
public static voiddestroyAll() {
   // 1.关闭所有已创建注册中心
    AbstractRegistryFactory.destroyAll();
    ExtensionLoader<Protocol>loader = ExtensionLoader.getExtensionLoader(Protocol.class);
   for(StringprotocolName : loader.getLoadedExtensions()) {
       try{
           Protocol protocol = loader.getLoadedExtension(protocolName);
           if(protocol !=null) {
               // 2.关闭协议类的扩展点
               protocol.destroy();
           }
        }catch(Throwable t) {
           logger.warn(t.getMessage(),t);
        }
    }
}
 
可以看出，该方法主要做两件事情：步骤一.和注册中心断连、步骤二. 关闭协议暴露（包括provider和consumer）。
 
步骤一简单来说就是通过AbstractRegistryFactory.destroyAll()来“撤销”在所有注册中心注册的服务，一般来说我们只会用一个注册中心，比如ZooKeeper，所以此时就是去调用ZkClient客户端的close方法（使用Curator也类似）。对于上面的服务调用图来说，就是关闭ZK(注册中心)和服务B的长连接（会话Session），这样的话，“过一阵子”A服务的地址列表中将不会有B服务的地址了。理想的情况下，步骤一后就不会有新的调用请求到达B服务了。
 
步骤二是关闭自己暴露的服务和自己对下游服务的调用。假设我们使用的是dubbo协议，protocol.destroy()其实会调用DubboProtocol#destroy方法，该方法部分摘要如下：
public voiddestroy() {
        // 关闭暴露的服务
   for(String key :newArrayList<String>(serverMap.keySet())) {
       ExchangeServer server =serverMap.remove(key);
       if(server !=null) {
           // 关闭该接口暴露的服务
           server.close(getServerShutdownTimeout());
   }
    }
   
       // 关闭对下游服务的调用
   for(String key :newArrayList<String>(referenceClientMap.keySet())) {
       ExchangeClient client =referenceClientMap.remove(key);
       if(client !=null) {
            client.close();
        }
    }
   
   stubServiceMethodsMap.clear();
   super.destroy();
}
 
我们可以看到顺序，是先关闭provider，再关闭consumer，这理解起来也简单，不先关闭provider，就可能会一直有对下游服务的调用。代码中的getServerShutdownTimeout()是获取“provider服务关闭的最长等待时间”的配置，即通过dubbo.service.shutdown.wait来设置的值，单位毫秒，默认是10秒钟，为了探究关闭provider的细节，我们来分析下HeaderExchangeServer#close方法：
 
public voidclose(final inttimeout) {
   if(timeout >0) {
       finallongmax = (long) timeout;
       finallongstart = System.currentTimeMillis();
       if(getUrl().getParameter(Constants.CHANNEL_SEND_READONLYEVENT_KEY,false)){
           sendChannelReadOnlyEvent();
        }
  
      //如果还有进行中的任务并且没有到达等待时间的上限，则继续等待
       while(HeaderExchangeServer.this.isRunning()
               && System.currentTimeMillis() - start < max) {
           try{
  // 休息10毫秒再检查
                Thread.sleep(10);
           }catch(InterruptedException e) {
               logger.warn(e.getMessage(), e);
            }
        }
    }
        // 关闭心跳，停止应答
    doClose();
        // 关闭通信通道
   server.close(timeout);
}
 
其中HeaderExchangeServer.this.isRunning()是用来检测是否还有正在进行中的调用(如果读者对如何判断是否有进行中的任务，可以参看DefaultFuture)，如果没有进行中的调用或者等待时间还达到上限（上面提到的dubbo.service.shutdown.wait），则立马调用关闭provider操作（while后面的doClose()操作）。但这里会有个小问题，因为provider从注册中心撤销服务和上游consumer将其服务从服务列表中删除并不是原子操作，如果集群规模过大，可能导致上游consumer的服务列表还未更新完成，我们的provider这时发现当前没有进行中的调用就立马关闭服务暴露，导致上游consumer调用该服务失败。所以，dubbo默认的这种优雅停机方案，需要建立在上游consumer有重试机制的基础之上，但由于consumer增加重试特性会增加故障时的雪崩风险，所以大多数分布式服务不愿意增加服务内部之间的重试机制，这样就比较尴尬了，其实dubbo.service.shutdown.wait的值主要是为了防止优雅停机时的无限等待，即限制等待上限，我们也应该用一个参数来设置等待下限，这样整个分布式系统几乎不需要通过重试来保证优雅停机，只需要给与上游consumer少许时间，让他们足够有机会更新完provider的列表就行，虽然dubbo目前并不打算这么做。
我们接下来看看doClose()中做了些什么：
 
private voiddoClose() {
   if(closed) {
       return;
    }
        // 修改标记位，该标记为设置为true后，provider不再对上游请求做应答
   closed=true;
        // 取消心跳的Futrue
   stopHeartbeatTimer();
   try{
                 // 关闭心跳的线程池
       scheduled.shutdown();
   }catch(Throwable t) {
       logger.warn(t.getMessage(), t);
    }
}
 
这里最重要的是将closed设置成了true了，这样以后provider将不会向上游系统发送应答数据。当然，它还关闭了服务端的心跳。
而server.close(timeout)则主要是关闭通信资源，可以参看AbstractServer#close和NettyServer#doClose。
那么上图的B服务的consumer端（即对②③的调用）是如何关闭的？这个我们可以参看HeaderExchangeClient中的代码：
 
public voidclose() {
        // 关闭心跳
    doClose();
        // 关闭通讯资源，关闭后不能重新建立连接，也不能向下游发送请求
   channel.close();
}
 
public voidclose(inttimeout) {
    doClose();
   channel.close(timeout);
}
 
同HeaderExchangeServer一样，HeaderExchangeClient的close方法也有两个，但DubboProtocol#destroy中调用的是不带timeout的这个close（和关闭provider时相反），dubbo的新版本改成调用有timeout的方法，拿最上面的服务调用来说，在B服务的provider对上游应答关闭之前，步骤②③理想情况下应该陆续完成，如果已经走到要关闭B服务的consumer了，说明B服务对上游服务（比如A服务）的应答和服务暴露早已关闭，这时候B服务关闭自己的consumer就可以暴力些了。但如果B服务自身内部有些调度任务在处理，并且对下游Dubbo服务有依赖，那么这种情况就比较复杂了，很难做到优雅停机。
 
为了在2.5.3的版本实现不设置重试也能优雅停机，我们需要在几个关键地方加上一些等待时间。
在Constants.java中加入四个常量：
/**
 *为了让优雅停机的可用性更高，这里暴露出provider和consumer在优雅停机时的最小等待时间，单位毫秒
 * yizhenqiang 2017-12-07
 */
public static finalStringSHUTDOWN_PROVIDER_MIN_WAIT         ="provider.shutdown.min.wait";
public static finalStringSHUTDOWN_PROVIDER_MIN_WAIT_DEFAULT ="3000";
public static finalStringSHUTDOWN_CONSUMER_MIN_WAIT         ="consumer.shutdown.min.wait";
public static finalStringSHUTDOWN_CONSUMER_MIN_WAIT_DEFAULT ="2000";
 
修改ProtocolConfig.java的destroyAll()方法，加入第一个Provider的等待时间：
public static voiddestroyAll() {
   AbstractRegistryFactory.destroyAll();
 
   /**
     *为了防止上面和注册中心断开后立马结束provider暴露的服务，这里等待一小段时间
    * yizhenqiang 2017-12-07
    */
   String providerMinTimeoutStr = ConfigUtils.getProperty(Constants.SHUTDOWN_PROVIDER_MIN_WAIT,
           Constants.SHUTDOWN_PROVIDER_MIN_WAIT_DEFAULT);
    LongproviderMinTimeout;
   try{
       providerMinTimeout = Long.parseLong(providerMinTimeoutStr);
   }catch(NumberFormatException e) {
       providerMinTimeout = Long.parseLong(Constants.SHUTDOWN_PROVIDER_MIN_WAIT_DEFAULT);
    }
   try{
       TimeUnit.MILLISECONDS.sleep(providerMinTimeout);
   }catch(InterruptedException e) {
       logger.warn(e.getMessage(),e);
    }
 
   ExtensionLoader<Protocol> loader = ExtensionLoader.getExtensionLoader(Protocol.class);
 
   for(String protocolName :loader.getLoadedExtensions()) {
       try{
           Protocol protocol = loader.getLoadedExtension(protocolName);
           if(protocol !=null) {
               protocol.destroy();
            }
       }catch(Throwable t) {
           logger.warn(t.getMessage(),t);
        }
    }
}
 
因为我们使用dubbo协议，所以需要修改的是DubboInvoker.java：
先在DubboInvoker.java中加一个线程池属性，用于异步关闭client，例如：
/**
 *为了做到多个接口（一个DubboInvoker对应一个接口）能优雅停机，这里对client的关闭
 * yizhenqiang 2017-12-08
 */
private static finalExecutorServicecloseClientPool=newThreadPoolExecutor(0,100,5,
       TimeUnit.SECONDS,newSynchronousQueue<Runnable>(),newThreadFactory() {
   @Override
   publicThread newThread(Runnable r) {
       returnnewThread(r,"dubboInvokerClientClose");
    }
});
 
再修改DubboInvoker.java的destroy()，加入第二个等待时间：
public voiddestroy() {
   //防止client被关闭多次.在connect per jvm的情况下，client.close方法会调用计数器-1，当计数器小于等于0的情况下，才真正关闭
   if(super.isDestroyed()) {
       return;
   }else{
       //dubbo check ,避免多次关闭
       destroyLock.lock();
       try{
           if(super.isDestroyed()) {
               return;
            }
 
           super.destroy();
           if(invokers!=null) {
               invokers.remove(this);
            }
 
           /**
             *为了避免关闭多个DubboInvoker时都等待指定的最小时间，这里关闭client时采用异步方式
             * yizhenqiang 2017-12-08
             */
           try{
               closeClientPool.submit(newRunnable() {
                   @Override
                   public voidrun() {
                       /**
                         *当consumer收到provider变动的消息后，上面已经将失效的provider移除了，但为了让正在进行中的请求能完成，
                         *这里在下面关闭ExchangeClient前先等待一小段时间
                         * yizhenqiang2017-12-07
                         */
                       String consumerMinTimeoutStr =ConfigUtils.getProperty(Constants.SHUTDOWN_CONSUMER_MIN_WAIT,
                                Constants.SHUTDOWN_CONSUMER_MIN_WAIT_DEFAULT);
                       Long consumerMinTimeout;
                       try{
                            consumerMinTimeout= Long.parseLong(consumerMinTimeoutStr);
 
                        }catch(NumberFormatException e) {
                            consumerMinTimeout= Long.parseLong(Constants.SHUTDOWN_CONSUMER_MIN_WAIT_DEFAULT);
                       }
 
                       try{
                            TimeUnit.MILLISECONDS.sleep(consumerMinTimeout);
                        }catch(InterruptedException e) {
                           logger.warn(e.getMessage(), e);
                       }
 
                       for(ExchangeClient client :clients) {
                           try{
                                client.close();
                            }catch(Throwable t) {
                               logger.warn(t.getMessage(), t);
                            }
                       }
                   }
               });
 
           }catch(Exception e) {
               logger.warn("提交client关闭任务异常，"+  e.getMessage(), e);
            }
 
 
       }finally{
           destroyLock.unlock();
        }
    }
}
 
这样修改后，哪怕业务系统没设置重试机制，也能实现优雅停机（通过等待少许时间），如果想调整provider和consumer的等待时间，那么只需要在dubbo.properties中设置就行了：
provider.shutdown.min.wait=5000
consumer.shutdown.min.wait=2000