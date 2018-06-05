
# JVM致命错误日志(hs_err_pid.log)分析

* [JVM致命错误日志(hs_err_pid.log)分析（转载） - 浮沉一梦 - 博客园 ](http://www.cnblogs.com/jjzd/p/6519686.html)

JVM致命错误日志(hs_err_pid.log)分析（转载）

当jvm出现致命错误时，会生成一个错误文件 hs_err_pid<pid>.log，其中包括了导致jvm crash的重要信息，可以通过分析该文件定位到导致crash的根源，从而改善以保证系统稳定。当出现crash时，该文件默认会生成到工作目录下，然而可以通过jvm参数指定生成路径（JDK6中引入）：

-XX:ErrorFile=./hs_err_pid<pid>.log
该文件包含如下几类关键信息：

日志头文件
导致crash的线程信息
所有线程信息
安全点和锁信息
堆信息
本地代码缓存
编译事件
gc相关记录
jvm内存映射
jvm启动参数
服务器信息
下面用一个crash demo文件逐步解读这些信息，以便大家以后碰到crash时方便分析。

## 日志头文件
日志头文件包含概要信息，简述了导致crash的原因。而导致crash的原因很多，常见的原因有jvm自身的bug，应用程序错误，jvm参数配置不当，服务器资源不足，jni调用错误等。

现在参考下如下描述：

```
#
# A fatal error has been detected by the Java Runtime Environment:
#
#  SIGSEGV (0xb) at pc=0x00007fb8b18fdc6c, pid=191899, tid=140417770411776
#
# JRE version: Java(TM) SE Runtime Environment (7.0_55-b13) (build 1.7.0_55-b13)
# Java VM: Java HotSpot(TM) 64-Bit Server VM (24.55-b03 mixed mode linux-amd64 compressed oops)
# Problematic frame:
# J  org.apache.http.impl.cookie.BestMatchSpec.formatCookies(Ljava/util/List;)Ljava/util/List;
#
# Failed to write core dump. Core dumps have been disabled. To enable core dumping, try "ulimit -c unlimited" before starting Java again
#
# If you would like to submit a bug report, please visit:
#   http://bugreport.sun.com/bugreport/crash.jsp
#
```

这里一个重要信息是“SIGSEGV(0xb)”表示jvm crash时正在执行jni代码，而不是在执行java或者jvm的代码，如果没有在应用程序里手动调用jni代码，那么很可能是JIT动态编译时导致的该错误。其中SIGSEGV是信号名称，0xb是信号码，pc=0x00007fb8b18fdc6c指的是程序计数器的值，pid=191899是进程号，tid=140417770411776是线程号。

PS：除了“SIGSEGV(0xb)”以外，常见的描述还有“EXCEPTION_ACCESS_VIOLATION”，该描述表示jvm crash时正在执行jvm自身的代码，这往往是因为jvm的bug导致的crash；另一种常见的描述是“EXCEPTION_STACK_OVERFLOW”，该描述表示这是个栈溢出导致的错误，这往往是应用程序中存在深层递归导致的。

还有一个重要信息是：
```
# Problematic frame:

# J org.apache.http.impl.cookie.BestMatchSpec.formatCookies(Ljava/util/List;)Ljava/util/List;
```

这表示出现crash时jvm正在执行的代码，这里的“J”表示正在执行java代码，后面的表示执行的方法栈。除了“J”外，还有可能是“C”、“j”、“V”、“v”，它们分别表示：

C: Native C frame
j: Interpreted Java frame
V: VMframe
v: VMgenerated stub frame
J: Other frame types, including compiled Java frames
加上前面对SIGSEGV(0xb)”的分析，现在可以断定是JIT动态编译导致的该错误。

查阅资料发现：

此异常是由于jdk JIT compiler optimization 导致，bug id 8021898，官网描述如下：

1
The JIT compiler optimization leads to a SIGSEGV or an NullPointerException at a place it must not happen.
 

jdk1.7.0_25到1.7.0_55这几个版本都存在此bug，1.7.0_60后修复。可通过升级jdk解决此异常，可参考 http://bugs.java.com/view_bug.do?bug_id=8021898。

到这里该问题已经分析出原因了，但是咱们可以再深入一步，分析下其它信息。

### 导致crash的线程信息
文件下面是导致crash的线程信息和该线程栈信息，描述信息如下：

Current thread (0x00007fb7b4014800):  JavaThread "catalina-exec-251" daemon [_thread_in_Java, id=205044, stack(0x00007fb58f435000,0x00007fb58f536000)]
 
siginfo:si_signo=SIGSEGV: si_errno=0, si_code=1 (SEGV_MAPERR), si_addr=0x0000003f96dc9c6c
 

以上表示导致出错的线程是0x00007fb7b4014800（指针），线程类型是JavaThread，JavaThread表示执行的是java线程，关于该线程其它类型还可能是：

VMThread：jvm的内部线程
CompilerThread：用来调用JITing，实时编译装卸class 。 通常，jvm会启动多个线程来处理这部分工作，线程名称后面的数字也会累加，例如：CompilerThread1
GCTaskThread：执行gc的线程
WatcherThread：jvm周期性任务调度的线程，是一个单例对象。 该线程在JVM内使用得比较频繁，比如：定期的内存监控、JVM运行状况监控，还有我们经常需要去执行一些jstat 这类命令查看gc的情况
ConcurrentMarkSweepThread：jvm在进行CMS GC的时候，会创建一个该线程去进行GC，该线程被创建的同时会创建一个SurrogateLockerThread（简称SLT）线程并且启动它，SLT启动之后，处于等待阶段。CMST开始GC时，会发一个消息给SLT让它去获取Java层Reference对象的全局锁：Lock
后面的”catalina-exec-251″表示线程名，带有catalina前缀的线程一般是tomcat启动的线程，“daemon”表示该线程为守护线程，再后面的“[_thread_in_Java”表示线程正在执行解释或者编译后的Java代码，关于该描述其它类型还可能是：

_thread_in_native：线程当前状态
_thread_uninitialized：线程还没有创建，它只在内存原因崩溃的时候才出现
_thread_new：线程已经被创建，但是还没有启动
_thread_in_native：线程正在执行本地代码，一般这种情况很可能是本地代码有问题
_thread_in_vm：线程正在执行虚拟机代码
_thread_in_Java：线程正在执行解释或者编译后的Java代码
_thread_blocked：线程处于阻塞状态
…_trans：以_trans结尾，线程正处于要切换到其它状态的中间状态
最后的“id=205044”表示线程ID，stack(0x00007fb58f435000,0x00007fb58f536000)表示栈区间。

“siginfo:si_signo=SIGSEGV: si_errno=0, si_code=1 (SEGV_MAPERR), si_addr=0x0000003f96dc9c6c”这部分是导致虚拟机终止的非预期的信号信息：其中si_errno和si_code是Linux下用来鉴别异常的，Windows下是一个ExceptionCode。

## 所有线程信息
再下面是线程信息：

Java Threads: ( => current thread )
  0x00007fb798015800 JavaThread "catalina-exec-280" daemon [_thread_blocked, id=206093, stack(0x00007fb58d718000,0x00007fb58d819000)]
  0x00007fb7a4016800 JavaThread ”catalina-exec-279″ daemon [_thread_blocked, id=206091, stack(0x00007fb58d819000,0x00007fb58d91a000)]
  … …(省略)
 
  Other Threads:
  0x00007fb8b4231000 VMThread [stack: 0x00007fb854eb6000,0x00007fb854fb7000] [id=192015]
  0x00007fb8b4321000 WatcherThread [stack: 0x00007fb835e6c000,0x00007fb835f6d000] [id=192414]
 

信息和上面介绍的类似，其中[_thread_blocked表示线程阻塞。

## 安全点和锁信息
再下面是安全点和锁信息：

VM state:not at safepoint (normal execution)
 
VM Mutex/Monitor currently owned by a thread: None
 

安全线信息为正常运行，其它可能得描述还有：

not at a safepoint：正常运行状态
at safepoint：所有线程都因为虚拟机等待状态而阻塞，等待一个虚拟机操作完成
synchronizing：一个特殊的虚拟机操作，要求虚拟机内的其它线程保持等待状态
锁信息为未被线程持有，Mutex是虚拟机内部的锁，而Monitor则是synchronized锁或者其它关联到的Java对象。

## 堆信息
再下面是堆信息：

Heap
 par new generation   total 2293760K, used 1537284K [0x00000006f0000000, 0x0000000790000000, 0x0000000790000000)
  eden space 1966080K,  78% used [0x00000006f0000000, 0x000000074dc97aa8, 0x0000000768000000)
  from space 327680K,   0% used [0x0000000768000000, 0x00000007680a9580, 0x000000077c000000)
  to   space 327680K,   0% used [0x000000077c000000, 0x000000077c000000, 0x0000000790000000)
 concurrent mark-sweep generation total 1572864K, used 49449K [0x0000000790000000, 0x00000007f0000000, 0x00000007f0000000)
 concurrent-mark-sweep perm gen total 262144K, used 49857K [0x00000007f0000000, 0x0000000800000000, 0x0000000800000000)
 
 Card table byte_map: [0x00007fb8b8fa8000,0x00007fb8b9829000] byte_map_base: 0x00007fb8b5828000
 

堆信息包括：新生代、老生代、永久代信息。这里标识了使用CMS垃圾收集器。

下面的“Card table”表示一种卡表，是jvm维护的一种数据结构，用于记录更改对象时的引用，以便gc时遍历更少的table和root。

## 本地代码缓存
再下面是本地代码缓存信息：

Code Cache  [0x00007fb8b1000000, 0x00007fb8b1a60000, 0x00007fb8b4000000)
 total_blobs=3580 nmethods=3111 adapters=421 free_code_cache=38857Kb largest_free_block=39469312
 

这是一块用于编译和保存本地代码的内存；注意是本地代码，它和PermGen（永久代）是不一样的，永久代是用来存放jvm和java类的元数据的。

## 编译事件
再下面是本地代码编译信息：


Compilation events (10 events):
Event: 110587.798 Thread 0x00007fb8b425a800 3338             java.util.HashSet::remove (20 bytes)
Event: 110587.804 Thread 0x00007fb8b425a800 nmethod 3338 0x00007fb8b168a9d0 code [0x00007fb8b168ab60, 0x00007fb8b168afa8]
... ...（省略）
Event: 112147.387 Thread 0x00007fb8b425a800 3342             org.apache.http.impl.cookie.BestMatchSpec::formatCookies (116 bytes)
Event: 112147.465 Thread 0x00007fb8b425a800 nmethod 3342 0x00007fb8b18fcd50 code [0x00007fb8b18fd1a0, 0x00007fb8b18ff338]
 

可以看到，一共编译了10次；其中包含org.apache.http.impl.cookie.BestMatchSpec::formatCookies的编译；这和前面的结论相吻合。

## gc相关记录
再下面是gc执行记录：

GC Heap History (10 events):
Event: 110665.975 GC heap before
{Heap before GC invocations=255 (full 31):
 par new generation   total 2293760K, used 1966777K [0x00000006f0000000, 0x0000000790000000, 0x0000000790000000)
  eden space 1966080K, 100% used [0x00000006f0000000, 0x0000000768000000, 0x0000000768000000)
  from space 327680K,   0% used [0x0000000768000000, 0x00000007680ae480, 0x000000077c000000)
  to   space 327680K,   0% used [0x000000077c000000, 0x000000077c000000, 0x0000000790000000)
 concurrent mark-sweep generation total 1572864K, used 49237K [0x0000000790000000, 0x00000007f0000000, 0x00000007f0000000)
 concurrent-mark-sweep perm gen total 262144K, used 49856K [0x00000007f0000000, 0x0000000800000000, 0x0000000800000000)
Event: 110665.981 GC heap after
Heap after GC invocations=256 (full 31):
 par new generation   total 2293760K, used 693K [0x00000006f0000000, 0x0000000790000000, 0x0000000790000000)
  eden space 1966080K,   0% used [0x00000006f0000000, 0x00000006f0000000, 0x0000000768000000)
  from space 327680K,   0% used [0x000000077c000000, 0x000000077c0ad6f8, 0x0000000790000000)
  to   space 327680K,   0% used [0x0000000768000000, 0x0000000768000000, 0x000000077c000000)
 concurrent mark-sweep generation total 1572864K, used 49237K [0x0000000790000000, 0x00000007f0000000, 0x00000007f0000000)
 concurrent-mark-sweep perm gen total 262144K, used 49856K [0x00000007f0000000, 0x0000000800000000, 0x0000000800000000)
}
... ...（省略）
 

可以看到gc次数为10次（full gc），然后后面描述了每次gc前后的内存信息；看一看到并没有内存不足等问题。

## jvm内存映射
再下面是jvm加载的库信息：

Dynamic libraries:
00400000-00401000 r-xp 00000000 08:02 39454583                           /home/service/jdk1.7.0_55/bin/java
00600000-00601000 rw-p 00000000 08:02 39454583                           /home/service/jdk1.7.0_55/bin/java
013cd000-013ee000 rw-p 00000000 00:00 0                                  [heap]
6f0000000-800000000 rw-p 00000000 00:00 0
3056400000-3056416000 r-xp 00000000 08:02 57409539                       /lib64/libgcc_s-4.4.7-20120601.so.1
3056416000-3056615000 ---p 00016000 08:02 57409539                       /lib64/libgcc_s-4.4.7-20120601.so.1
3056615000-3056616000 rw-p 00015000 08:02 57409539                       /lib64/libgcc_s-4.4.7-20120601.so.1
353be00000-353be20000 r-xp 00000000 08:02 57409933                       /lib64/ld-2.12.so
353c01f000-353c020000 r--p 0001f000 08:02 57409933                       /lib64/ld-2.12.so
353c020000-353c021000 rw-p 00020000 08:02 57409933                       /lib64/ld-2.12.so
... ...（省略）
 

这些信息是虚拟机崩溃时的虚拟内存列表区域。它可以告诉你崩溃原因时哪些类库正在被使用，位置在哪里，还有堆栈和守护页信息。以列表中第一条为例介绍下：

00400000-00401000：内存区域
r-xp：权限，r/w/x/p/s分别表示读/写/执行/私有/共享
00000000：文件内的偏移量
08:02：文件位置的majorID和minorID
39454583：索引节点号
/home/service/jdk1.7.0_55/bin/java：文件位置

## jvm启动参数
再下面是jvm启动参数信息：

VM Arguments:
jvm_args: -Djava.util.logging.config.file=/home/service/tomcat7007-account-web/conf/logging.properties -Xmx4096m -Xms4096m -Xmn2560m -XX:SurvivorRatio=6 -XX:PermSize=256m -XX:MaxPermSize=256m -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintGCDetails -Xloggc:/home/work/webdata/logs/tomcat7007-account-web/develop/gc.log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/work/webdata/logs/tomcat7007-account-web/develop/ -Dtomcatlogdir=/home/work/webdata/logs/tomcat7007-account-web/develop -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=7407 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.endorsed.dirs=/home/service/tomcat7007-account-web/endorsed -Dcatalina.base=/home/service/tomcat7007-account-web -Dcatalina.home=/home/service/tomcat7007-account-web -Djava.io.tmpdir=/home/service/tomcat7007-account-web/temp 
java_command: org.apache.catalina.startup.Bootstrap start
Launcher Type: SUN_STANDARD
 
Environment Variables:
JAVA_HOME=/home/service/jdk1.7.0_55
PATH=/opt/zabbix/bin:/opt/zabbix/sbin:/home/service/jdk1.7.0_55/bin:/home/work/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/work/bin
SHELL=/bin/bash
 

上面是jvm参数，下面是系统的环境配置。

服务器信息
再下面是服务器信息：

/proc/meminfo:
MemTotal:       65916492 kB
MemFree:        14593468 kB
Buffers:          222452 kB
Cached:         28502452 kB
SwapTotal:             0 kB
SwapFree:              0 kB
... ...（省略）
/proc/cpuinfo:
processor   : 0
vendor_id   : GenuineIntel
cpu family  : 6
model       : 62
model name  : Intel(R) Xeon(R) CPU E5-2420 v2 @ 2.20GHz
stepping    : 4
... ...（省略）
 上面是内存信息，主要关注下swap信息，看看有没有使用虚拟内存；下面是cpu信息。