
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [3 常用Java虚拟机参数](#3-常用java虚拟机参数)
	* [3.1 掌握跟踪调试参数](#31-掌握跟踪调试参数)
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

<!-- /code_chunk_output -->

---


# 3 常用Java虚拟机参数

## 3.1 掌握跟踪调试参数

### 3.1.1 跟踪垃圾回收-读懂虚拟机日志

`-XX:+PrintGC`
```bash
[GC (Metadata GC Threshold)  4668K->1248K(125952K), 0.0023475 secs]
#                              ^      ^     ^           ^
#                            GC前    GC后  总可用堆   GC花费时间
```
`-XX:+PrintCGDetials`

-XX:+PrintGC
-XX:+PrintGCDetails
-XX:+PrintHeapAtGC在GC前后打印堆的信息
-XX:+PrintGCTimeStamps输出虚拟机启动后的时间偏移量
PrintGCApplicationConcurrentTime应用程序的执行时间
PrintGCApplicationStoppedTime应用程序由于GC而产生的停顿时间
PrintReferenceGC系统内的软引用、弱引用、虚引用和Finallize队列，

### 3.1.2 类加载/卸载的跟踪

TraceClassUnloading
TraceClassLoading

* 系统首先加载了java.lang.Object类
* 系统对Example类先后进行了10次加载和9次卸载（最后一次加载的类没有机会被卸载）

PrintClassHistogram

### 3.1.3 系统参数查看

PrintVMOptions打印虚拟机显示命令行参数
PrintCommandLineFlags隐式和显式
PrintFlagsFinal所有

## 3.2 让性能飞起来：学习堆的配置参数

### 3.2.1 最大堆和初始堆的设置

-Xmx20m -Xms5m

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

### 3.2.3 堆溢出处理

HeapDumpOnOutOfMemoryError 
HeapDumpPath导出堆的存放路径

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
