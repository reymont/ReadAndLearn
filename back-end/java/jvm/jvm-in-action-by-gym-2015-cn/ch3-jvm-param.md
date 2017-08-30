
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [3 常用Java虚拟机参数](#3-常用java虚拟机参数)
	* [3.1 掌握跟踪调试参数](#31-掌握跟踪调试参数)
		* [查看JVM的配置说明](#查看jvm的配置说明)
		* [JVM启动参数](#jvm启动参数)
		* [JVM 默认参数](#jvm-默认参数)
		* [3.1.1 跟踪垃圾回收-读懂虚拟机日志](#311-跟踪垃圾回收-读懂虚拟机日志)
		* [3.1.2 类加载/卸载的跟踪](#312-类加载卸载的跟踪)
		* [3.1.3 系统参数查看](#313-系统参数查看)
	* [3.2 让性能飞起来：学习堆的配置参数](#32-让性能飞起来学习堆的配置参数)
		* [3.2.1 最大堆和初始堆的设置](#321-最大堆和初始堆的设置)
		* [3.2.2 新生代的配置](#322-新生代的配置)
		* [3.2.3 堆溢出处理](#323-堆溢出处理)
	* [3.3 别让性能有缺口：了解非堆内存的参数配置](#33-别让性能有缺口了解非堆内存的参数配置)
		* [3.3.1 方法区配置](#331-方法区配置)
		* [3.3.2 栈配置](#332-栈配置)
		* [3.3.3 直接内存配置](#333-直接内存配置)
	* [3.4 Client和Server二选一](#34-client和server二选一)
* [JVM 几个重要的参数](#jvm-几个重要的参数)
	* [大内存使用](#大内存使用)
* [JVM启动参数详解](#jvm启动参数详解)
	* [行为参数：](#行为参数)
	* [性能调优参数](#性能调优参数)
	* [调试参数](#调试参数)

<!-- /code_chunk_output -->

---


# 3 常用Java虚拟机参数



## 3.1 掌握跟踪调试参数

### 查看JVM的配置说明

* [java 虚拟机启动参数 - 大毛过河的日志 - 网易博客 ](http://blog.163.com/wb_zhaoyuwei/blog/static/183075439201111524716439/)

```bash
java
#java -X 命令查看JVM的配置说明
java -X
```

### JVM启动参数

* [JVM启动参数大全 zz - 岁月如哥 - BlogJava ](http://www.blogjava.net/midstr/archive/2008/09/21/230265.html)

java启动参数共分为三类；
* 其一是**标准参数（-）**，所有的JVM实现都必须实现这些参数的功能，而且向后兼容；
* 其二是**非标准参数（-X）**，默认jvm实现这些参数的功能，但是并不保证所有jvm实现都满足，且不保证向后兼容；
* 其三是**非Stable参数（-XX）**，此类参数各个jvm实现会有所不同，将来可能会随时取消，需要慎重使用；

### JVM 默认参数

* [JVM 默认参数 - 天天备忘录 ](http://blog.btnotes.com/articles/375.html)

有时候你会需要了解JVM相关的参数，不管是出于好奇或者工作需要。Oracle的文档中列出了一些，（http://www.oracle.com/technetwork/java/javase/tech/vmoptions-jsp-140102.html）， 但这些并不是全部，而且有些参数的设置会默认启用或者关闭其他一些参数，而在某些情况下设置某个参数是不会生效的。还有些时候你想让JVM做某些事情，但是你不知道那个参数可以用。下面介绍一些办法用以列出所有参数，这样你在研究或者Google的时候也比较有明确的目标。

```sh
#1、查看你使用的JDK支持的参数
java -XX:+UnlockDiagnosticVMOptions -XX:+PrintFlagsFinal -version
#2、查看某个JVM参数是否生效
#先使用jps查找到jvm的pid，然后使用jinfo
jinfo -flag UseParallelOldGC 881
-XX:–UseParallelOldGC
#减号表示关闭，加号表示开启
```

### 3.1.1 跟踪垃圾回收-读懂虚拟机日志


`-XX:+PrintGC`
```bash
[GC (Metadata GC Threshold)  4668K->1248K(125952K), 0.0023475 secs]
#                              ^      ^     ^           ^
#                            GC前    GC后  总可用堆   GC花费时间
```
`-XX:+PrintCGDetials`


```bash
#java编译UTF-8
javac -encoding UTF-8 geym\zbase\ch2\localvar\LocalVarGC.java
# PrintGC
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+PrintGC com.gmail.mosoft521.ch02.localvar.LocalVarGC
# PrintGCDetails
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+PrintGCDetails com.gmail.mosoft521.ch02.localvar.LocalVarGC
# PrintHeapAtGC在GC前后打印堆的信息
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+PrintHeapAtGC com.gmail.mosoft521.ch02.localvar.LocalVarGC
# PrintGCTimeStamps输出虚拟机启动后的时间偏移量
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+PrintGCTimeStamps -XX:+PrintGC com.gmail.mosoft521.ch02.localvar.LocalVarGC
# PrintGCApplicationConcurrentTime应用程序的执行时间
# PrintGCApplicationStoppedTime应用程序由于GC而产生的停顿时间
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+PrintGCApplicationConcurrentTime -XX:+PrintGCApplicationStoppedTime com.gmail.mosoft521.ch02.localvar.LocalVarGC
# PrintReferenceGC系统内的软引用、弱引用、虚引用和Finallize队列，
# 配合PrintGCDetails使用
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+PrintReferenceGC -XX:+PrintGCDetails com.gmail.mosoft521.ch02.localvar.LocalVarGC
# -Xloggc:gc.log输出日志文件
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+PrintGC -Xloggc:gc.log com.gmail.mosoft521.ch02.localvar.LocalVarGC
```

### 3.1.2 类加载/卸载的跟踪

```bash
# TraceClassUnloading
# TraceClassLoading
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+TraceClassUnloading -XX:+TraceClassLoading com.gmail.mosoft521.ch03.trace.UnloadClass
```

* 系统首先加载了java.lang.Object类
* 系统对Example类先后进行了10次加载和9次卸载（最后一次加载的类没有机会被卸载）


```bash
# PrintClassHistogram
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+PrintClassHistogram -XX:+TraceClassUnloading -XX:+TraceClassLoading com.gmail.mosoft521.ch03.trace.UnloadClass
```

### 3.1.3 系统参数查看

```bash
# PrintVMOptions打印虚拟机显示命令行参数
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+PrintVMOptions -XX:+PrintGC com.gmail.mosoft521.ch03.trace.UnloadClass
# PrintCommandLineFlags隐式和显式
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+PrintCommandLineFlags -XX:+PrintGC com.gmail.mosoft521.ch03.trace.UnloadClass
# PrintFlagsFinal所有
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+PrintFlagsFinal -XX:+PrintGC com.gmail.mosoft521.ch03.trace.UnloadClass
```



## 3.2 让性能飞起来：学习堆的配置参数



* [成为Java GC专家（5）—Java性能调优原则 - ImportNew ](http://www.importnew.com/13954.html)

### 3.2.1 最大堆和初始堆的设置

```sh
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -Xmx20m -Xms5m -XX:+PrintCommandLineFlags -XX:+PrintGCDetails -XX:+UseSerialGC com.gmail.mosoft521.ch03.heap.HeapAlloc
```

### 3.2.2 新生代的配置

* **-Xmn**设置新生代的大小。－Xmn 是将NewSize与MaxNewSize设为一致。设置一个较大的新生代会减少老年代的大小。（eden+ 2 survivor space)。年轻代大小(1.4or later)
* -XX:**NewSize**=n :设置年轻代大小下限。(for 1.3/1.4)
* -XX:**MaxNewSize**=n :设置年轻代大小上限。(for 1.3/1.4)
  * 可以通过指定**NewSize和MaxNewSize**来代替NewRatio
* –XX:**NewRatio**来指定新生代和整个堆的大小比例
  * 新生代(eden+2*s)和老年代（不包含永久代）的比值
  * 4 表示 新生代：老年代=1:4，即年轻代占堆的1/5
* **SurvivorRatio**设置新生代中eden空间和from/to空间的比例关系。XX:SurvivorRatio=eden/from=eden/to
  * 设置两个Survivor区与eden的比
  * 8表示两个Survivor:eden = 2:8，即一个Survivor占年轻代的1/10

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


```sh
# eden space 5632K,from space 512K,to space 512K
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -Xmx20m -Xms20m -XX:+PrintGCDetails com.gmail.mosoft521.ch03.heap.newsize.NewSizeDemo
# -XX:SurvivorRatio=2
# eden space 3584K,from space 1536K,to space 1536K
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -Xmx20m -Xms20m -XX:SurvivorRatio=2 -XX:+PrintGCDetails com.gmail.mosoft521.ch03.heap.newsize.NewSizeDemo
# -Xmn2m -XX:SurvivorRatio=2
# 触发一次新生代GC，对eden区进行部分回收，所有数组都分配在老年代
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -Xmx20m -Xms20m -Xmn2m -XX:SurvivorRatio=2 -XX:+PrintGCDetails com.gmail.mosoft521.ch03.heap.newsize.NewSizeDemo
# -Xmn7m -XX:SurvivorRatio=2
# 出现3次新生代GC。所有的内存分配在新生代进行，部分新生代对象晋升到老年代
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -Xmx20m -Xms20m -Xmn7m -XX:SurvivorRatio=2 -XX:+PrintGCDetails com.gmail.mosoft521.ch03.heap.newsize.NewSizeDemo
# -Xmn15m -XX:SurvivorRatio=8
# eden space 12288K,from space 1536K,to space 1536K
# eden区占用12288K，满足10MB数组的分配，分配行为在eden进行。没有触发GC。
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -Xmx20m -Xms20m -Xmn15m -XX:SurvivorRatio=8 -XX:+PrintGCDetails com.gmail.mosoft521.ch03.heap.newsize.NewSizeDemo
# -XX:NewRatio=2
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -Xmx20M -Xms20M -XX:NewRatio=2 -XX:+PrintGCDetails com.gmail.mosoft521.ch03.heap.newsize.NewSizeDemo
```


### 3.2.3 堆溢出处理



```sh
# HeapDumpOnOutOfMemoryError 
# HeapDumpPath导出堆的存放路径
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -Xmx20m -Xms5m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./a.dump com.gmail.mosoft521.ch03.heap.DumpOOM
# 在发生错误时执行一个脚本文件
# jps获取pid
jstack -F 344
-XX:OnOutOfMemoryError=printstack.bat
```

## 3.3 别让性能有缺口：了解非堆内存的参数配置

### 3.3.1 方法区配置

1.6,1.7
-XX:PermSize初始的永久区大小
-XX:MaxPermSize最大永久区

### 3.3.2 栈配置

-Xss指定线程的栈大小

### 3.3.3 直接内存配置

-XX:MaxDirectMemorySize设置最大可用直接内存

直接内存访问快，申请空间慢

## 3.4 Client和Server二选一

使用-XX:+PrintFlagsFinal参数查看给定参数的默认值。



```sh
#以JIT编译阈值和最大堆为例
java -XX:+PrintFlagsFinal -client -version|grep -E ' CompileThreshold|MaxHeapSize'
java -XX:+PrintFlagsFinal -server -version|grep -E ' CompileThreshold|MaxHeapSize'
```



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







































