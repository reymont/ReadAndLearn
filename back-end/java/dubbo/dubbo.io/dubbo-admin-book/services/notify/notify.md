

27. Dubbo原理解析-管理控制台 - CSDN博客 http://blog.csdn.net/quhongwei_zhanqiu/article/details/41896943

3）RegistryServerSync这个bean用来订阅同步注册中心数据
RegistryServerSync实现了InitializingBean接口，这个接口是spring提供的一个回调在spring初始化bean的时当bean的参数都被设置的时候调用，这个的方法实现为：registryService.subscribe(SUBSCRIBE,this); 向注册中心订阅

同时RegistryServerSync实现了NotifyListener接口，这个接口用来当注册中心数据发生变化后回调订阅用户更新信息，是注册中心反向推送的实现。
RegistryServerSync的notify(urls)实现主要是分类缓存注册中心信息，供页面是使用