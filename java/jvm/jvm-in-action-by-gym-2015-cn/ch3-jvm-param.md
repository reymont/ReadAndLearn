
# 虚拟机参数


<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [虚拟机参数](#虚拟机参数)
* [调试参数](#调试参数)
* [java 虚拟机启动参数](#java-虚拟机启动参数)
* [JVM系列三:JVM参数设置、分析](#jvm系列三jvm参数设置-分析)
* [JVM启动参数大全](#jvm启动参数大全)
* [JVM 几个重要的参数](#jvm-几个重要的参数)
	* [大内存使用](#大内存使用)
* [cat /proc/meminfo | grep Huge](#cat-procmeminfo-grep-huge)
* [echo 4294967295 > /proc/sys/kernel/shmmax](#echo-4294967295-procsyskernelshmmax)
* [echo 1536 > /proc/sys/vm/nr_hugepages](#echo-1536-procsysvmnr_hugepages)
* [JVM启动参数详解](#jvm启动参数详解)
	* [行为参数：](#行为参数)
	* [性能调优参数](#性能调优参数)
	* [调试参数](#调试参数-1)

<!-- /code_chunk_output -->




# 调试参数

`-XX:+PrintGC`
```bash
[GC (Metadata GC Threshold)  4668K->1248K(125952K), 0.0023475 secs]
#                              ^      ^     ^           ^
#                            GC前    GC后  总可用堆   GC花费时间
```

`-XX:+PrintCGDetials`

# java 虚拟机启动参数

[java 虚拟机启动参数 - 大毛过河的日志 - 网易博客 ](http://blog.163.com/wb_zhaoyuwei/blog/static/183075439201111524716439/)

```bash
java
java -X
```

# JVM系列三:JVM参数设置、分析

[JVM系列三:JVM参数设置、分析 - redcreen - 博客园 ](http://www.cnblogs.com/redcreen/archive/2011/05/04/2037057.html)

经验&&规则

年轻代大小选择
响应时间优先的应用:尽可能设大,直到接近系统的最低响应时间限制(根据实际情况选择).在此种情况下,年轻代收集发生的频率也是最小的.同时,减少到达年老代的对象.
吞吐量优先的应用:尽可能的设置大,可能到达Gbit的程度.因为对响应时间没有要求,垃圾收集可以并行进行,一般适合8CPU以上的应用.
避免设置过小.当新生代设置过小时会导致:1.YGC次数更加频繁 2.可能导致YGC对象直接进入旧生代,如果此时旧生代满了,会触发FGC.
年老代大小选择
响应时间优先的应用:年老代使用并发收集器,所以其大小需要小心设置,一般要考虑并发会话率和会话持续时间等一些参数.如果堆设置小了,可以会造成内存碎 片,高回收频率以及应用暂停而使用传统的标记清除方式;如果堆大了,则需要较长的收集时间.最优化的方案,一般需要参考以下数据获得:
并发垃圾收集信息、持久代并发收集次数、传统GC信息、花在年轻代和年老代回收上的时间比例。
吞吐量优先的应用:一般吞吐量优先的应用都有一个很大的年轻代和一个较小的年老代.原因是,这样可以尽可能回收掉大部分短期对象,减少中期的对象,而年老代尽存放长期存活对象.
较小堆引起的碎片问题
因为年老代的并发收集器使用标记,清除算法,所以不会对堆进行压缩.当收集器回收时,他会把相邻的空间进行合并,这样可以分配给较大的对象.但是,当堆空间较小时,运行一段时间以后,就会出现"碎片",如果并发收集器找不到足够的空间,那么并发收集器将会停止,然后使用传统的标记,清除方式进行回收.如果出现"碎片",可能需要进行如下配置:
-XX:+UseCMSCompactAtFullCollection:使用并发收集器时,开启对年老代的压缩.
-XX:CMSFullGCsBeforeCompaction=0:上面配置开启的情况下,这里设置多少次Full GC后,对年老代进行压缩
用64位操作系统，Linux下64位的jdk比32位jdk要慢一些，但是吃得内存更多，吞吐量更大
XMX和XMS设置一样大，MaxPermSize和MinPermSize设置一样大，这样可以减轻伸缩堆大小带来的压力
使用CMS的好处是用尽量少的新生代，经验值是128M－256M， 然后老生代利用CMS并行收集， 这样能保证系统低延迟的吞吐效率。 实际上cms的收集停顿时间非常的短，2G的内存， 大约20－80ms的应用程序停顿时间
系统停顿的时候可能是GC的问题也可能是程序的问题，多用jmap和jstack查看，或者killall -3 java，然后查看java控制台日志，能看出很多问题。(相关工具的使用方法将在后面的blog中介绍)
仔细了解自己的应用，如果用了缓存，那么年老代应该大一些，缓存的HashMap不应该无限制长，建议采用LRU算法的Map做缓存，LRUMap的最大长度也要根据实际情况设定。
采用并发回收时，年轻代小一点，年老代要大，因为年老大用的是并发回收，即使时间长点也不会影响其他程序继续运行，网站不会停顿
JVM参数的设置(特别是 –Xmx –Xms –Xmn -XX:SurvivorRatio  -XX:MaxTenuringThreshold等参数的设置没有一个固定的公式，需要根据PV old区实际数据 YGC次数等多方面来衡量。为了避免promotion faild可能会导致xmn设置偏小，也意味着YGC的次数会增多，处理并发访问的能力下降等问题。每个参数的调整都需要经过详细的性能测试，才能找到特定应用的最佳配置。
promotion failed:

垃圾回收时promotion failed是个很头痛的问题，一般可能是两种原因产生，第一个原因是救助空间不够，救助空间里的对象还不应该被移动到年老代，但年轻代又有很多对象需要放入救助空间；第二个原因是年老代没有足够的空间接纳来自年轻代的对象；这两种情况都会转向Full GC，网站停顿时间较长。

解决方方案一：

第一个原因我的最终解决办法是去掉救助空间，设置-XX:SurvivorRatio=65536 -XX:MaxTenuringThreshold=0即可，第二个原因我的解决办法是设置CMSInitiatingOccupancyFraction为某个值（假设70），这样年老代空间到70%时就开始执行CMS，年老代有足够的空间接纳来自年轻代的对象。

解决方案一的改进方案：

又有改进了，上面方法不太好，因为没有用到救助空间，所以年老代容易满，CMS执行会比较频繁。我改善了一下，还是用救助空间，但是把救助空间加大，这样也不会有promotion failed。具体操作上，32位Linux和64位Linux好像不一样，64位系统似乎只要配置MaxTenuringThreshold参数，CMS还是有暂停。为了解决暂停问题和promotion failed问题，最后我设置-XX:SurvivorRatio=1 ，并把MaxTenuringThreshold去掉，这样即没有暂停又不会有promotoin failed，而且更重要的是，年老代和永久代上升非常慢（因为好多对象到不了年老代就被回收了），所以CMS执行频率非常低，好几个小时才执行一次，这样，服务器都不用重启了。

-Xmx4000M -Xms4000M -Xmn600M -XX:PermSize=500M -XX:MaxPermSize=500M -Xss256K -XX:+DisableExplicitGC -XX:SurvivorRatio=1 -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0 -XX:+CMSClassUnloadingEnabled -XX:LargePageSizeInBytes=128M -XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=80 -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintHeapAtGC -Xloggc:log/gc.log

 

CMSInitiatingOccupancyFraction值与Xmn的关系公式

上面介绍了promontion faild产生的原因是EDEN空间不足的情况下将EDEN与From survivor中的存活对象存入To survivor区时,To survivor区的空间不足，再次晋升到old gen区，而old gen区内存也不够的情况下产生了promontion faild从而导致full gc.那可以推断出：eden+from survivor < old gen区剩余内存时，不会出现promontion faild的情况，即：
(Xmx-Xmn)*(1-CMSInitiatingOccupancyFraction/100)>=(Xmn-Xmn/(SurvivorRatior+2))  进而推断出：

CMSInitiatingOccupancyFraction <=((Xmx-Xmn)-(Xmn-Xmn/(SurvivorRatior+2)))/(Xmx-Xmn)*100

例如：

当xmx=128 xmn=36 SurvivorRatior=1时 CMSInitiatingOccupancyFraction<=((128.0-36)-(36-36/(1+2)))/(128-36)*100 =73.913

当xmx=128 xmn=24 SurvivorRatior=1时 CMSInitiatingOccupancyFraction<=((128.0-24)-(24-24/(1+2)))/(128-24)*100=84.615…

当xmx=3000 xmn=600 SurvivorRatior=1时  CMSInitiatingOccupancyFraction<=((3000.0-600)-(600-600/(1+2)))/(3000-600)*100=83.33

CMSInitiatingOccupancyFraction低于70% 需要调整xmn或SurvivorRatior值。

令：

网上一童鞋推断出的公式是：:(Xmx-Xmn)*(100-CMSInitiatingOccupancyFraction)/100>=Xmn 这个公式个人认为不是很严谨，在内存小的时候会影响xmn的计算。

 

关于实际环境的GC参数配置见:实例分析   监测工具见JVM监测

参考：

JAVA HOTSPOT VM（http://www.helloying.com/blog/archives/164）

JVM 几个重要的参数 (校长)

java jvm 参数 -Xms -Xmx -Xmn -Xss 调优总结

Java HotSpot VM Options

http://bbs.weblogicfans.net/archiver/tid-2835.html

Frequently Asked Questions About the Java HotSpot VM

Java SE HotSpot at a Glance

Java性能调优笔记(内附测试例子 很有用)

说说MaxTenuringThreshold这个参数

 

相关文章推荐:

GC调优方法总结

Java 6 JVM参数选项大全（中文版）

# JVM启动参数大全

[JVM启动参数大全 zz - 岁月如哥 - BlogJava ](http://www.blogjava.net/midstr/archive/2008/09/21/230265.html)

java启动参数共分为三类；
* 其一是标准参数（-），所有的JVM实现都必须实现这些参数的功能，而且向后兼容；
* 其二是非标准参数（-X），默认jvm实现这些参数的功能，但是并不保证所有jvm实现都满足，且不保证向后兼容；
* 其三是非Stable参数（-XX），此类参数各个jvm实现会有所不同，将来可能会随时取消，需要慎重使用；


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

# cat /proc/meminfo | grep Huge
HugePages_Total: 0
HugePages_Free: 0
Hugepagesize: 2048 kB
#

If the output shows the three "Huge" variables then your system can support large page memory, but it needs to be configured. If the command doesn't print out anything, then large page support is not available. To configure the system to use large page memory, one must log in as root, then:
Increase SHMMAX value. It must be larger than the Java heap size. On a system with 4 GB of physical RAM (or less) the following will make all the memory sharable:

# echo 4294967295 > /proc/sys/kernel/shmmax 

Specify the number of large pages. In the following example 3 GB of a 4 GB system are reserved for large pages (assuming a large page size of 2048k, then 3g = 3 x 1024m = 3072m = 3072 * 1024k = 3145728k, and 3145728k / 2048k = 1536): 

# echo 1536 > /proc/sys/vm/nr_hugepages 

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







































