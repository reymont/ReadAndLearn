


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