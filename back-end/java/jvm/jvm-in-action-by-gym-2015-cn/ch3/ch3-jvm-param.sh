

### 3.1.1 跟踪垃圾回收-读懂虚拟机日志
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

####################
3.1.2 类加载/卸载的跟踪


# TraceClassUnloading
# TraceClassLoading
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+TraceClassUnloading -XX:+TraceClassLoading com.gmail.mosoft521.ch03.trace.UnloadClass

# PrintClassHistogram
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+PrintClassHistogram -XX:+TraceClassUnloading -XX:+TraceClassLoading com.gmail.mosoft521.ch03.trace.UnloadClass

####################
3.1.3 系统参数查看

# PrintVMOptions打印虚拟机显示命令行参数
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+PrintVMOptions -XX:+PrintGC com.gmail.mosoft521.ch03.trace.UnloadClass
# PrintCommandLineFlags隐式和显式
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+PrintCommandLineFlags -XX:+PrintGC com.gmail.mosoft521.ch03.trace.UnloadClass
# PrintFlagsFinal所有
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+PrintFlagsFinal -XX:+PrintGC com.gmail.mosoft521.ch03.trace.UnloadClass




# PrintVMOptions打印虚拟机显示命令行参数
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+PrintVMOptions -XX:+PrintGC com.gmail.mosoft521.ch03.trace.UnloadClass
# PrintCommandLineFlags隐式和显式
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+PrintCommandLineFlags -XX:+PrintGC com.gmail.mosoft521.ch03.trace.UnloadClass
# PrintFlagsFinal所有
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -XX:+PrintFlagsFinal -XX:+PrintGC com.gmail.mosoft521.ch03.trace.UnloadClass

#########################
#3.2.1 最大堆和初始堆的设置#
#########################
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -Xmx20m -Xms5m -XX:+PrintCommandLineFlags -XX:+PrintGCDetails -XX:+UseSerialGC com.gmail.mosoft521.ch03.heap.HeapAlloc

###################
#3.2.2 新生代的配置#
###################
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

###############
#3.2.3 堆溢出处理

# HeapDumpOnOutOfMemoryError 
# HeapDumpPath导出堆的存放路径
java -classpath target/szjvm-1.0-SNAPSHOT-jar-with-dependencies.jar -Xmx20m -Xms5m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./a.dump com.gmail.mosoft521.ch03.heap.DumpOOM
# 在发生错误时执行一个脚本文件
# jps获取pid
jstack -F 344
-XX:OnOutOfMemoryError=printstack.bat

