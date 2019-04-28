# 1. JVM的内存模型
https://www.deanwangpro.com/2017/01/31/ali-interview/

内存空间（Runtime Data Area）中可以按照是否线程共享分成两块，线程共享的是方法区（Method Area）和堆（Heap），线程独享的是Java栈（Java Stack），本地方法栈（Native Method Stack）和PC寄存器（Program Counter Register）。

当然从1.8开始有一些变化，按照我的理解，原来常量池等信息都储存方法区，现在都移到堆里了。

1.8中-XX:PermSize 和 -XX:MaxPermSize 已经失效，取而代之的是一个新的区域 —— Metaspace（元数据区）。

在 JDK 1.7 及以往的 JDK 版本中，Java 类信息、常量池、静态变量都存储在 Perm（永久代）里。类的元数据和静态变量在类加载的时候分配到 Perm，当类被卸载的时候垃圾收集器从 Perm 处理掉类的元数据和静态变量。当然常量池的东西也会在 Perm 垃圾收集的时候进行处理。

JDK 1.8 的对 JVM 架构的改造将类元数据放到本地内存中，另外，将常量池和静态变量放到 Java 堆里。HotSopt VM 将会为类的元数据明确分配和释放本地内存。在这种架构下，类元信息就突破了原来 -XX:MaxPermSize 的限制，现在可以使用更多的本地内存。这样就从一定程度上解决了原来在运行时生成大量类的造成经常 Full GC 问题，如运行时使用反射、代理等。

所以升级以后Java堆空间可能会增加。