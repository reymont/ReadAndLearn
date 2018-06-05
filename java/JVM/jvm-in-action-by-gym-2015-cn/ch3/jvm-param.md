





* [成为Java GC专家（5）—Java性能调优原则 - ImportNew ](http://www.importnew.com/13954.html)


# JVM 几个重要的参数

[JVM 几个重要的参数 - 高级语言虚拟机 - ITeye知识库频道 ](http://hllvm.group.iteye.com/group/wiki/2870-JVM)

```bash
-server -Xmx3g -Xms3g -XX:MaxPermSize=128m 
-XX:NewRatio=1  eden/old 的比例
-XX:SurvivorRatio=8  s/e的比例 
-XX:+UseParallelGC 
-XX:ParallelGCThreads=8  
-XX:+UseParallelOldGC  这个是JAVA 6出现的参数选项 
-XX:LargePageSizeInBytes=128m 内存页的大小， 不可设置过大， 会影响Perm的大小。 
-XX:+UseFastAccessorMethods 原始类型的快速优化 
-XX:+DisableExplicitGC  关闭System.gc()
```

另外 -Xss 是线程栈的大小，小的应用，栈不是很深，128k够用。 不过，我们的应用调用深度比较大， 还需要做详细的测试。 这个选项对性能的影响比较大。 建议使用256K的大小.

例子:
```
-server -Xmx3g -Xms3g -Xmn=1g -XX:MaxPermSize=128m -Xss256k  -XX:MaxTenuringThreshold=10 -XX:+DisableExplicitGC -XX:+UseParallelGC -XX:+UseParallelOld GC -XX:LargePageSizeInBytes=128m -XX:+UseFastAccessorMethods -XX:+AggressiveOpts -XX:+UseBiasedLocking　
```

-XX:+PrintGCApplicationStoppedTime -XX:+PrintGCTimeStamps -XX:+PrintGCDetails 打印参数

## 大内存使用

另外对于大内存设置的要求:
Linux : 
Large page support is included in 2.6 kernel. Some vendors have backported the code to their 2.4 based releases. To check if your system can support large page memory, try the following:   

```sh
# cat /proc/meminfo | grep Huge
HugePages_Total: 0
HugePages_Free: 0
Hugepagesize: 2048 kB
#
```

If the output shows the three "Huge" variables then your system can support large page memory, but it needs to be configured. If the command doesn't print out anything, then large page support is not available. To configure the system to use large page memory, one must log in as root, then:
Increase SHMMAX value. It must be larger than the Java heap size. On a system with 4 GB of physical RAM (or less) the following will make all the memory sharable:

```sh
# echo 4294967295 > /proc/sys/kernel/shmmax 
```

Specify the number of large pages. In the following example 3 GB of a 4 GB system are reserved for large pages (assuming a large page size of 2048k, then 3g = 3 x 1024m = 3072m = 3072 * 1024k = 3145728k, and 3145728k / 2048k = 1536): 

```sh
# echo 1536 > /proc/sys/vm/nr_hugepages 
```

Note the /proc values will reset after reboot so you may want to set them in an init script (e.g. rc.local or sysctl.conf).



# JVM启动参数详解

[Home: Java Platform, Standard Edition (Java SE) 8 Release 8 ](http://docs.oracle.com/javase/8/)
[Java Platform, Standard Edition HotSpot Virtual Machine Garbage Collection Tuning Guide, Release 8 ](http://docs.oracle.com/javase/8/docs/technotes/guides/vm/gctuning/)
[Java Platform, Standard Edition JRockit to HotSpot Migration Guide - Contents ](http://docs.oracle.com/javacomponents/jrockit-hotspot/migration-guide/index.html)

* [Java HotSpot VM Options ](http://www.oracle.com/technetwork/java/javase/tech/vmoptions-jsp-140102.html) JDK 7 and earlier releases

* [Java Platform, Standard Edition Tools Reference for Oracle JDK on Windows, Release 8 ](http://docs.oracle.com/javase/8/docs/technotes/tools/windows/toc.html) JDK8 Release
  * [5 Create and Build Applications](http://docs.oracle.com/javase/8/docs/technotes/tools/windows/s1-create-build-tools.html#sthref31)
    * [java ](http://docs.oracle.com/javase/8/docs/technotes/tools/windows/java.html)
    * [javac ](http://docs.oracle.com/javase/8/docs/technotes/tools/windows/javac.html)

[JVM启动参数详解 - 青钲的日志 - 网易博客 ](http://zhaohe162.blog.163.com/blog/static/382167972011102111262781/)

Java HotSpot VM中-XX:的可配置参数列表进行描述；
这些参数可以被松散的聚合成三类：
行为参数（Behavioral Options）：用于改变jvm的一些基础行为；
性能调优（Performance Tuning）：用于jvm的性能调优；
调试参数（Debugging Options）：一般用于打开跟踪、打印、输出等jvm参数，用于显示jvm更加详细的信息；

## 行为参数：

|参数及其默认值|描述|
|-|-|
|-XX:-DisableExplicitGC|禁止调用System.gc()；但jvm的gc仍然有效|
|-XX:+MaxFDLimit|最大化文件描述符的数量限制|
|-XX:+ScavengeBeforeFullGC|新生代GC优先于Full GC执行|
|-XX:+UseGCOverheadLimit|在抛出OOM之前限制jvm耗费在GC上的时间比例|
|**-XX:-UseConcMarkSweepGC**|对老生代采用并发标记交换算法进行GC|
|**-XX:-UseParallelGC**|启用并行GC|
|-XX:-UseParallelOldGC|对Full GC启用并行，当-XX:-UseParallelGC启用时该项自动启用|
|**-XX:-UseSerialGC**|启用串行GC|
|-XX:+UseThreadPriorities|启用本地线程优先级|

上面表格中黑体的三个参数代表着jvm中GC执行的三种方式，即**串行、并行、并发**；
串行（**SerialGC**）是jvm的默认GC方式，一般适用于小型应用和单处理器，算法比较简单，GC效率也较高，但可能会给应用带来停顿；
并行（**ParallelGC**）是指GC运行时，对应用程序运行没有影响，GC和app两者的线程在并发执行，这样可以最大限度不影响app的运行；
并发（**ConcMarkSweepGC**）是指多个线程并发执行GC，一般适用于多处理器系统中，可以提高GC的效率，但算法复杂，系统消耗较大；

## 性能调优参数

日常性能调优中，黑体较常用
 
|参数及其默认值|描述|
|-|-|
|-XX:LargePageSizeInBytes=4m|设置用于Java堆的大页面尺寸|
|-XX:MaxHeapFreeRatio=70|GC后java堆中空闲量占的最大比例|
|**-XX:MaxNewSize=size**|新生成对象能占用内存的最大值|
|**-XX:MaxPermSize=64m**|老生代对象能占用内存的最大值|
|-XX:MinHeapFreeRatio=40|GC后java堆中空闲量占的最小比例|
|-XX:NewRatio=2|新生代内存容量与老生代内存容量的比例|
|**-XX:NewSize=2.125m**|新生代对象生成时占用内存的默认值|
|-XX:ReservedCodeCacheSize=32m|保留代码占用的内存容量|
|-XX:ThreadStackSize=512|设置线程栈大小，若为0则使用系统默认值|
|-XX:+UseLargePages|使用大页面内存|

我们在日常性能调优中基本上都会用到以上黑体的这几个属性； 


## 调试参数



|参数及其默认值|描述|
|-|-|
|-XX:-CITime|打印消耗在JIT编译的时间|
|-XX:ErrorFile=./hs_err_pid\<pid\>.log|保存错误日志或者数据到文件中|
|-XX:-ExtendedDTraceProbes|开启solaris特有的dtrace探针|
|**-XX:HeapDumpPath=./java_pid\<pid\>.hprof**|指定导出堆信息时的路径或文件名|
|**-XX:-HeapDumpOnOutOfMemoryError**|当首次遭遇OOM时导出此时堆中相关信息|
|-XX:|出现致命ERROR之后运行自定义命令|
|-XX:OnOutOfMemoryError="<cmd args>;<cmd args>"|当首次遭遇OOM时执行自定义命令|
|-XX:-PrintClassHistogram|遇到Ctrl-Break后打印类实例的柱状信息，与jmap -histo功能相同|
|**-XX:-PrintConcurrentLocks**|遇到Ctrl-Break后打印并发锁的相关信息，与jstack -l功能相同|
|-XX:-PrintCommandLineFlags|打印在命令行中出现过的标记|
|-XX:-PrintCompilation|当一个方法被编译时打印相关信息|
|-XX:-PrintGC|每次GC时打印相关信息|
|-XX:-PrintGC Details|每次GC时打印详细信息|
|-XX:-PrintGCTimeStamps|打印每次GC的时间戳|
|-XX:-TraceClassLoading|跟踪类的加载信息|
|-XX:-TraceClassLoadingPreorder|跟踪被引用到的所有类的加载信息|
|-XX:-TraceClassResolution|跟踪常量池|
|-XX:-TraceClassUnloading|跟踪类的卸载信息|
|-XX:-TraceLoaderConstraints|跟踪类加载器约束的相关信息|



