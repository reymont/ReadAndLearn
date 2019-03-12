
// http://www.jianshu.com/p/b21b42d02bd8
// C:\workspace\java\elasticsearch\core\src\main\java\org\elasticsearch\discovery\DiscoveryModule.java

// discovery的实例

Map<String, Supplier<Discovery>> discoveryTypes = new HashMap<>();
discoveryTypes.put("zen",
    () -> new ZenDiscovery(settings, threadPool, transportService, namedWriteableRegistry, masterService, clusterApplier,
        clusterSettings, hostsProvider, allocationService, Collections.unmodifiableCollection(joinValidators)));
discoveryTypes.put("single-node", () -> new SingleNodeDiscovery(settings, transportService, masterService, clusterApplier));
for (DiscoveryPlugin plugin : plugins) {
    plugin.getDiscoveryTypes(threadPool, transportService, namedWriteableRegistry,
        masterService, clusterApplier, clusterSettings, hostsProvider, allocationService).entrySet().forEach(entry -> {
        if (discoveryTypes.put(entry.getKey(), entry.getValue()) != null) {
            throw new IllegalArgumentException("Cannot register discovery type [" + entry.getKey() + "] twice");
        }
    });
}