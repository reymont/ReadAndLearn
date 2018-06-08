
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [5 垃圾收集器和内存分配](#5-垃圾收集器和内存分配)
	* [5.1 串行回收器](#51-串行回收器)
	* [5.2 并行回收器](#52-并行回收器)
		* [5.2.1 新生代ParNew回收器](#521-新生代parnew回收器)
		* [5.2.2 新生代ParallelGC回收器](#522-新生代parallelgc回收器)
		* [5.2.3 老年代ParallelOldGC回收器](#523-老年代paralleloldgc回收器)
	* [5.3 CMS回收器](#53-cms回收器)
	* [5.4 G1回收器](#54-g1回收器)
	* [5.5 对象内存分配和回收的一些细节问题](#55-对象内存分配和回收的一些细节问题)
		* [5.5.1 禁用System.gc()](#551-禁用systemgc)
		* [5.5.2 System.gc()使用并发回收](#552-systemgc使用并发回收)
		* [5.5.3 并行GC前额外触发的新生代GC](#553-并行gc前额外触发的新生代gc)
		* [5.5.4 对象何时进入老年代](#554-对象何时进入老年代)
		* [5.5.5 在TLAB上分配对象](#555-在tlab上分配对象)

<!-- /code_chunk_output -->

---

# 5 垃圾收集器和内存分配

## 5.1 串行回收器

* 串行回收器
  * 串行回收器是指使用**单线程**进行垃圾回收的回收器；
  * 新生代串行处理器使用**复制算法**；
  * 老年代串行处理器使用**标记压缩算法**
  * **独占式**的垃圾回收；
  * **Stop-The-World**垃圾回收时，应用程序中的所有线程都停止工作，进行等待；
  * 串行回收器可以在新生代和老年代使用；
* 参数
  * -XX:+UseSerialGC：新生代、老年代都使用串行回收器。Client模式默认的垃圾回收器；
  * -XX:+UseParNewGC：新生代使用ParNew回收器，老年代使用串行收集器；
  * -XX:+UseParallelGC：新生代使用ParallelGC回收器，老年代使用串行收集器；

## 5.2 并行回收器

### 5.2.1 新生代ParNew回收器

* 新生代ParNew回收器
  * 简单地将串行回收器多线程化；
  * 使用**复制算法**；
  * **独占式**的垃圾回收；
  * 并发能力强的CPU上停顿时间短，单CPU或并发能力弱CPU表现差；
* 参数
  * -XX:+UseParNewGC：新生代使用ParNew回收器，老年代使用串行；
  * -XX:+UseConcMarkSweepGC：新生代使用ParNew回收器，老年代使用CMS；
  * **-XX:+ParallelGCThreads**：设定ParNew工作时的线程数量。与CPU数量相对；

### 5.2.2 新生代ParallelGC回收器

* 新生代ParallelGC回收器
  * 与ParNew类似；
  * 非常关注系统的吞吐量；
  * 自适用的方式，仅指定虚拟机的最大堆、目标吞吐量（**GCTimeRatio**）和停顿时间（**MaxGCPauseMillis**），让虚拟机自己完成调优工作。
  * -XX:MaxGCPauseMillis和-XX:GCTimeRatio两个参数互相矛盾：
    * 减少收集的最大停顿时间会同时减少系统吞吐量
    * 增加系统吞吐量会同时增加垃圾回收的最大停顿时间
* 参数
  * -XX:+UseParallelGC：新生代使用ParallelGC回收器，老年代使用串行回收器；
  * -XX:+UseParallelOldGC：新生代使用ParallelGC回收器，老年代使用**ParallelOldGC**回收器；
  * -XX:MaxGCPauseMillic: 设置最大垃圾收集停顿时间。工作时，调整Java堆大小或者其他参数；
  * -XX:GCTimeRatio：设置吞吐量大小。花费不超过1/(1 + n)的时间用于垃圾收集。默认为19，则垃圾回收时间不超过1/(1+19)=5%；
  * **-XX:UseAdaptiveSizePolicy**：自动调整新生代的大小、eden和survivior的比例、晋升老年代的对象年龄等参数；

### 5.2.3 老年代ParallelOldGC回收器

* 老年代ParallelOldGC回收器
  * 使用**标记压缩算法**；
  * 关注吞吐量的垃圾回收器组合；
* 参数
  * -XX:ParallelGCThreads也可以用于设置垃圾回收时的线程数量；

## 5.3 CMS回收器

* CMS的步骤
  * 初始标记（STW独占）CMS-initial-mark
  * 并发标记CMS-concurrent-mark
  * 预清理CMS-concurrent-preclean
  * 重新标记（STW独占）CMS-remark
  * 并发清除CMS-concurrent-sweep
  * 并发重置CMS-concurrent-reset
* CMS
  * **并发**是指收集器和应用线程交替执行；
  * **并行**是指应用程序停止，同时由多个线程一起执行GC；
  * CMS（Concurrent Mark Sweep）回收器主要关注与**系统停顿时间**，意为并发标记清除。
  * 基于**标记清除算法**，将会造成内存碎片；
  * **abortable-preclean**，CMS根据之前新生代GC的情况，将**重新标记**的时间放置在一个最不可能和下一次新生代GC重叠的时刻；
  * 当堆内存使用率达到某一阈值时便开始进行回收，以确保应用程序在CMS工作过程中，依然有足够的空间支持应用程序运行；
  * 在CMS执行过程中，已经出现内存不足的情况**concurrent mode failure**，会导致CMS回收失败，虚拟机启动老年代串行收集器进行垃圾回收；
* 参数
  * -XX:-CMSPrecleaningEnabled，不进行预清理；
  * -XX:+UseConcMarkSweepGC，启用CMS回收器；
  * -XX:ParallelGCThreads，GC并行时使用的线程数量。CMS并发线程数默认为(ParallelGCThreads+3)/4
  * -XX:ConcGCThreads或-XX:ParallelCMSThreads，设置并发线程数量；
  * -XX:CMSInitiatingOccupancyFraction，回收阈值，默认为68；
  * -XX:+UseCMSCompactAtFullCollection，CMS垃圾回收后，进行一次内存整理；
  * -XX:CMSFullGCsBeforeCompaction，多少次CMS回收后，进行一次内存压缩；
  * -XX:+CMSClassUnloadingEnabled，CMS回收Perm区；

## 5.4 G1回收器

* G1(Garbage First)
  * JDK1.7引入；
  * 属于分代垃圾回收器，使用了分区算法；
  * **记忆集**是G1中维护的一个数据结构，简称RS；
  * 区域A的RS中，记录了区域A中被其他区域引用的对象；
  * RS通过CardTable来记录存活对象；
  * CSet(Collection Sets)表示被选取的、将要被收集的区域的集合；
* 特点
  * 并行性：多线程同时工作；
  * 并发性：G1与应用程序交替执行，不阻塞应用；
  * 分代GC：同时兼顾年轻代和老年代；
  * 空间整理：回收过程中，进行适当的对象移动，减少空间碎片；
  * 可预见性：选取部分区域进行回收；
* 阶段
  * 新生代GC
  * 并发标记周期
  * 混合回收
  * 少量的Full GC
* 新生代GC
  * 新生代GC只处理eden和survivor区；
  * 部分survivor或eden区会晋升到老年代；
* 并发标记周期
  * 初始标记（停顿）**initial-mark**：标记从根节点直接可达的对象，新生代GC，全局停顿，应用线程停止；
  * 根区域扫描**concurrent-root-region-scan**：扫描由survivor区直接可达的老年代区域，根区域扫描不能和新生代GC同时执行；
  * 并发标记**concurrent-mark**：扫描并标记整个堆的存活对象，可被新生代GC打断；
  * 重新标记（停顿）**remark**：修正并发标记的结果，使用**SATB(Snapshot At The Beginning)**算法，在标记之初为存活对象创建快照，加速重新标记速度；
  * 独占清理（停顿）**cleanup**：更新**记忆集（Remebered Set）**，标记混合回收的区域；
  * 并发清理**concurrent-cleanup**：并发清理空闲区域；
* 混合回收
  * 并发标记确定垃圾较多的区域，混合回收优先回收垃圾比例较高的区域；
  * 执行年轻代GC，同时，选取一些被标记的老年代区域进行回收；
  * 在回收过程中内存不足，G1会转入Full GC；
* 参数
  * -XX:+UseG1GC：打开G1收集器；
  * -XX:MaxGCPauseMillis：最大停顿时间，超过该值，G1调整新老比例、堆大小、晋升年龄等；
  * -XX:ParallelGCThreads：并行回收的线程；
  * -XX:InitiatingHeapOccupancyPercent：堆使用率超过该值，触发并发标记周期，默认为45。一旦设置，不再修改；

## 5.5 对象内存分配和回收的一些细节问题

### 5.5.1 禁用System.gc()

* System.gc()会显式直接触发Full GC，同时回收老年代和新生代；
* -XX:+DisableExplicitGC：禁用显式GC；

### 5.5.2 System.gc()使用并发回收

* System.gc()默认使用Full GC方式回收堆；
* +XX:+ExplicitGCInvokesConcurrent：System.gc()显式GC使用并发的方式进行回收；

### 5.5.3 并行GC前额外触发的新生代GC

* 对于并行回收器(UseParallelOldGC或者UseParallelGC)，每次Full GC之前会伴随一次新生代GC；
* 使用-XX:-ScavengeBeforeFullGC除去Full GC前的新生代GC；

### 5.5.4 对象何时进入老年代

* 新生代每经历GC，年龄加1；
* **MaxTenuringThreshold**：默认15，最多经历15次GC晋升到老年代；
* 达到年龄必然晋升，未达到有可能晋升。虚拟机自行判断实际晋升年龄；
* **TargetSurvivorRatio**设置survivor区的目标使用率，默认为50。如果survivor区在GC后超过50%的使用率，可能使用较小的age作为晋升年龄；
* 对象的实际晋升年龄是根据survivor区的使用情况动态计算得来的，而MaxTenuringThreshold只是表示这个年龄的最大值；
* 对象体积大可能直接晋升到老年代；
* **PretenureSizeThreshold**设置对象直接晋升到老年代的阈值，单位是字节。只对串行回收器和ParNew有效，对于ParallelGC无效；
* 对于体积不大的对象，很有可能会在**TLAB**上先行分配；

### 5.5.5 在TLAB上分配对象

* TLAB
  * TLAB全称是Thread Local Allocation Buffer，线程本地分配缓存；
  * 加速对象分配；
  * TLAB本身占用了eden区的空间，虚拟机为每个Java线程分配一块TLAB空间；
  * 当请求对象大于refill_waste，堆中分配，小于该值，新建TLAB来分配对象；
  * 运行时会不断调整TLAB和refill_waste
* 参数
  * -XX:-BackgroundCompilation：禁止后台编译；
  * -XX:-DoEscapeAnalysis：禁用逃逸分析，Server模式下支持；
  * -XX:-ResizeTLAB：禁用自动调整TLAB；
  * -XX:TLABSize：手工指定TLAB；
  * -XX:+PrintTLAB：观察TLAB使用情况；
