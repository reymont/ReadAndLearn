


* [MaxTenuringThreshold 和 TargetSurvivorRatio参数说明 - ZERO - CSDN博客 ](http://blog.csdn.net/zero__007/article/details/52797684)

-XX:MaxTenuringThreshold 
  晋升年龄最大阈值，默认15。在新生代中对象存活次数(经过YGC的次数)后仍然存活，就会晋升到老年代。每经过一次YGC，年龄加1，当survivor区的对象年龄达到TenuringThreshold时，表示该对象是长存活对象，就会直接晋升到老年代。

-XX:TargetSurvivorRatio 
  设定survivor区的目标使用率。默认50，即survivor区对象目标使用率为50%。
  JVM会将每个对象的年龄信息、各个年龄段对象的总大小记录在“age table”表中。基于“age table”、survivor区大小、survivor区目标使用率（-XX:TargetSurvivorRatio）、晋升年龄阈值（-XX:MaxTenuringThreshold），JVM会动态的计算tenuring threshold的值。一旦对象年龄达到了tenuring threshold就会晋升到老年代。

  为什么要动态的计算tenuring threshold的值呢？假设有很多年龄还未达到TenuringThreshold的对象依旧停留在survivor区，这样不利于新对象从eden晋升到survivor。因此设置survivor区的目标使用率，当使用率达到时重新调整TenuringThreshold值，让对象尽早的去old区。

  如果希望跟踪每次新生代GC后，survivor区中对象的年龄分布，可在启动参数上增加-XX:+PrintTenuringDistribution。