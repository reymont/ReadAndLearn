

// http://www.jianshu.com/p/b21b42d02bd8
// C:\workspace\java\elasticsearch\core\src\main\java\org\elasticsearch\node\Node.java


// 在Node.java的start（）里，discovery代码有4行

Discovery discovery = injector.getInstance(Discovery.class);
  clusterService.getMasterService().setClusterStatePublisher(discovery::publish);
  // start after transport service so the local disco is known
  discovery.start(); // start before cluster service so that it can set initial state on ClusterApplierService
  discovery.startInitialJoin();

// Node中调用 DiscoveryModule，而 DiscoveryModule 产生 discoveryTypes这个Map 
final DiscoveryModule discoveryModule = new DiscoveryModule(this.settings, threadPool, transportService, namedWriteableRegistry,
    networkService, clusterService.getMasterService(), clusterService.getClusterApplierService(),
    clusterService.getClusterSettings(), pluginsService.filterPlugins(DiscoveryPlugin.class),
    clusterModule.getAllocationService());

// 新增Discovery与discoveryModule.getDiscovery()的绑定
ModulesBuilder modules = new ModulesBuilder();
modules.add(b -> {
    b.bind(Discovery.class).toInstance(discoveryModule.getDiscovery());
}

// ModulesBuilder 将映射关系添加到modules数组中
// C:\workspace\java\elasticsearch\core\src\main\java\org\elasticsearch\common\inject\ModulesBuilder.java
private final List<Module> modules = new ArrayList<>();
public ModulesBuilder add(Module... newModules) {
    Collections.addAll(modules, newModules);
    return this;
}

// modules创建injector 
injector = modules.createInjector();

// C:\workspace\java\elasticsearch\core\src\main\java\org\elasticsearch\common\inject\ModulesBuilder.java
public Injector createInjector() {
    Injector injector = Guice.createInjector(modules);
    ((InjectorImpl) injector).clearCache();
    // in ES, we always create all instances as if they are eager singletons
    // this allows for considerable memory savings (no need to store construction info) as well as cycles
    ((InjectorImpl) injector).readOnlyAllSingletons();
    return injector;
}
