centos使用jmap进行jvm分析报错 - CSDN博客 https://blog.csdn.net/learner198461/article/details/68925841

Heap Configuration:
  MinHeapFreeRatio = 40
  MaxHeapFreeRatio = 70
  MaxHeapSize      = 6442450944 (6144.0MB)
  NewSize          = 1310720 (1.25MB)
  MaxNewSize       = 17592186044415 MB
  OldSize          = 5439488 (5.1875MB)
  NewRatio         = 2
  SurvivorRatio    = 8
  PermSize         = 21757952 (20.75MB)
  MaxPermSize      = 174063616 (166.0MB)
  G1HeapRegionSize = 0 (0.0MB)

Heap Usage:
Exception in thread "main" java.lang.reflect.InvocationTargetException
       at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
       at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:57)
       at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
       at java.lang.reflect.Method.invoke(Method.java:606)
       at sun.tools.jmap.JMap.runTool(JMap.java:197)
       at sun.tools.jmap.JMap.main(JMap.java:128)
Caused by: java.lang.RuntimeException: unknown CollectedHeap type : class sun.jvm.hotspot.gc_interface.CollectedHeap
       at sun.jvm.hotspot.tools.HeapSummary.run(HeapSummary.java:146)
       at sun.jvm.hotspot.tools.Tool.start(Tool.java:221)
       at sun.jvm.hotspot.tools.HeapSummary.main(HeapSummary.java:40)

首先考虑有没有安装openjdk-debuginfo，安装openjdk-debuginfo一定要匹配openjdk版本，否则还是会出现错误。