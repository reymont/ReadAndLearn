

研究之dubbo-registry模块 - CSDN博客 http://blog.csdn.net/hxpjava1/article/details/78106742

dubbo-registry注册中心模块，基于注册中心下发地址的集群方式，以及对各种注册中心的抽象。 
   registry模块顶层接口为RegistryService和NotifyListener以及一个工厂接口RegistryFactory。 
   RegistryService接口包含4个方法。 
   void register(URL url); 注册服务 
   void unregister(URL url); 取消注册 
   void subscribe(URL url, NotifyListener listener); 订阅服务（推） 
   void unsubscribe(URL url, NotifyListener listener);取消订阅 
   List<URL> lookup(URL url); 订阅服务（拉） 
   
  Registry模块使用经典的消费者生成者模式，dubbo消费者订阅服务，dubbo服务者注册服务。 
  AbstractRegistry为RegistryService接口实现的一个抽象类，提供一些默认实现。 
 
Java代码  收藏代码
```java
public AbstractRegistry(URL url) {  
    setUrl(url);  
    // 启动文件保存定时器  
    syncSaveFile = url.getParameter(Constants.REGISTRY_FILESAVE_SYNC_KEY, false);  
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
    loadProperties();  
    notify(url.getBackupUrls());  
}  
```

   可以看出AbstractRegistry类在构建的时候，`会去本地磁盘文件读取文件，转成properties对象`。文件默认路径是`user.home/.dubbo/dubbo-registry-host.cache`
   读取完之后会把这个url存到本地缓存文件里面去，但是该方法并非递增修改，而且是全部重写文件。 
 
Java代码  收藏代码
```java
public void doSaveProperties(long version) {  
     if(version < lastCacheChanged.get()){  
         return;  
     }  
     if (file == null) {  
         return;  
     }  
     Properties newProperties = new Properties();  
     // 保存之前先读取一遍，防止多个注册中心之间冲突  
     InputStream in = null;  
     try {  
         if (file.exists()) {  
             in = new FileInputStream(file);  
             newProperties.load(in);  
         }  
     } catch (Throwable e) {  
         logger.warn("Failed to load registry store file, cause: " + e.getMessage(), e);  
     } finally {  
         if (in != null) {  
             try {  
                 in.close();  
             } catch (IOException e) {  
                 logger.warn(e.getMessage(), e);  
             }  
         }  
     }       
  // 保存  
     try {  
newProperties.putAll(properties);  
         File lockfile = new File(file.getAbsolutePath() + ".lock");  
         if (!lockfile.exists()) {  
            lockfile.createNewFile();  
         }  
         RandomAccessFile raf = new RandomAccessFile(lockfile, "rw");  
         try {  
             FileChannel channel = raf.getChannel();  
             try {  
                 FileLock lock = channel.tryLock();  
                if (lock == null) {  
                     throw new IOException("Can not lock the registry cache file " + file.getAbsolutePath() + ", ignore and retry later, maybe multi java process use the file, please config: dubbo.registry.file=xxx.properties");  
                 }  
                // 保存  
                 try {  
                    if (! file.exists()) {  
                         file.createNewFile();  
                     }  
                     FileOutputStream outputFile = new FileOutputStream(file);    
                     try {  
                         newProperties.store(outputFile, "Dubbo Registry Cache");  
                     } finally {  
                        outputFile.close();  
                     }  
                 } finally {  
                    lock.release();  
                 }  
             } finally {  
                 channel.close();  
             }  
         } finally {  
             raf.close();  
         }  
     } catch (Throwable e) {  
         if (version < lastCacheChanged.get()) {  
             return;  
         } else {  
             registryCacheExecutor.execute(new SaveProperties(lastCacheChanged.incrementAndGet()));  
         }  
         logger.warn("Failed to save registry store file, cause: " + e.getMessage(), e);  
     }  
 }  
```
  `如果是两个不同的注册中心，不能使用一个缓存文件。 `

  值得注意一点的是，多个dubbo服务公用一个cache文件的时候，如果一起启动，可能会出现Failed to load registry store File 这类异常信息，这是因为当时该文件其他服务占用了。这种情况开发环境比较多，可以无视掉。因为会重复去注册的，下面会说明，但是尽量还是手动指定注册缓存文件比较好。尽量不使用同一个缓存文件。 
 
Java代码  收藏代码
<dubbo:registry address="${zookeeper.address}" file=".cache/dubbo-registry-car.cache" />  

这样指定的话，缓存文件会在当前工程目录下。 
RegistryService接口的所有方法参数都有URL对象，说明dubbo服务最终是转成URL来注册的。通过URL来表示服务的全部信息。 
FailbackRegistry是AbstractRegistry类的子类，通过模式设计模式扩展，重写了AbstractRegistry类一些实现，并新增模板方法，交个子类去实现。 
Java代码  收藏代码
```java
public FailbackRegistry(URL url) {  
      super(url);  
      int retryPeriod = url.getParameter(Constants.REGISTRY_RETRY_PERIOD_KEY, Constants.DEFAULT_REGISTRY_RETRY_PERIOD);  
      this.retryFuture = retryExecutor.scheduleWithFixedDelay(new Runnable() {  
          public void run() {  
              // 检测并连接注册中心  
              try {  
                  retry();  
              } catch (Throwable t) { // 防御性容错  
                  logger.error("Unexpected error occur at failed retry, cause: " + t.getMessage(), t);  
              }  
          }  
      }, retryPeriod, retryPeriod, TimeUnit.MILLISECONDS);  
  }  
```
  FailbackRegistry构建的时候通过ScheduledExecutorService来延迟执行连接注册中心，默认延迟周期为5秒。 
  其中retry()方法从set集合里面取出注册失败的url，然后不断去重新注册。如果注册中心当机了，但是只要注册中心重新启动之后，dubbo还是会去重新注册的。 
 
Java代码  收藏代码
@Override  
 public void register(URL url) {  
     super.register(url);  
     failedRegistered.remove(url);  
     failedUnregistered.remove(url);  
     try {  
         // 向服务器端发送注册请求  
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

  register方法把具体的注册实现交给子类的doRegister实现。注册失败的都会记录到失败的set集合里面去，值得注意一个check 配置，当设置<dubbo:registry check="false" />时，记录失败注册和订阅请求，后台定时重试。 
  zookeeper注册中心是dubbo推荐使用的注册中心，本身zookeeper的基于是Paxos，一个分布式一致性算法。 
  
 
  流程： 
1.服务提供者启动时向/dubbo/com.foo.BarService/providers目录下写入URL 
2.服务消费者启动时订阅/dubbo/com.foo.BarService/providers目录下的URL向/dubbo/com.foo.BarService/consumers目录下写入自己的URL 
3.监控中心启动时订阅/dubbo/com.foo.BarService目录下的所有提供者和消费者URL 
  dubbo如何通过注册中心来实现服务治理，则下篇文章博文单独讲解。 