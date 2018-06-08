


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