


Java HotSpot(TM) 64-Bit Server VM warning: NewSize (1536k) is greater than the MaxNewSize (1024k). A new max generation size of 1536k will be used.

* [JVM系列三:JVM参数设置、分析 - redcreen - 博客园 ](http://www.cnblogs.com/redcreen/archive/2011/05/04/2037057.html)


* [Java 堆内存 新生代 （转） - JUN王者 - 博客园 ](http://www.cnblogs.com/junwangzhe/p/6282550.html)

默认的，新生代 ( Young ) 与老年代 ( Old ) 的比例的值为 1:2 ( 该值可以通过参数 –XX:NewRatio 来指定 )，即：新生代 ( Young ) = 1/3 的堆空间大小。

老年代 ( Old ) = 2/3 的堆空间大小。其中，新生代 ( Young ) 被细分为 Eden 和 两个 Survivor 区域，这两个 Survivor 区域分别被命名为 from 和 to，以示区分。

默认的，Edem : from : to = 8 : 1 : 1 ( 可以通过参数 –XX:SurvivorRatio 来设定 )，即： Eden = 8/10 的新生代空间大小，from = to = 1/10 的新生代空间大小。

JVM 每次只会使用 Eden 和其中的一块 Survivor 区域来为对象服务，所以无论什么时候，总是有一块 Survivor 区域是空闲着的。

因此，新生代实际可用的内存空间为 9/10 ( 即90% )的新生代空间。

* [Home: Java Platform, Standard Edition (Java SE) 8 Release 8 ](http://docs.oracle.com/javase/8/)
* [Java Language and Virtual Machine Specifications ](https://docs.oracle.com/javase/specs/index.html)