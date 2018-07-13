

# https://elasticsearch.cn/article/338

一、软件环境
Intellij Idea:2017.1版本
Elasticsearch源码版本:5.3.1
JDK:1.8.0_111 
Gradle :建议3.3及以上版本。官网：https://gradle.org/
二、下载Elasticsearch源码
到github clone源码，https://github.com/elastic/elasticsearch.git，建议选择稳定版本分支。

三、导入idea
1，编译执行gradle build.gradle，报错：
you must run gradle idea from the root of elasticsearch before importing into intellij
解决办法：运行命令：gradle idea。同理如使用eclipse编译器，运行gradle eclipse。该过程会向mvn仓库下载响应的jar包，视网络情况，大概会持续20分钟。

 
2，运行org.elasticsearch.bootstrap.Elasticsearch 方法，报错：
"path.home is not configured" when starting ES in transport and client mode“，
解决办法：在VM options中加入配置：-Des.path.home=/home/jiangtao/code/elasticsearch/core，即指向相应的core模块的路径。

3，报错：org.elasticsearch.bootstrap.BootstrapException: java.nio.file.NoSuchFileException
  
Exception in thread "main" org.elasticsearch.bootstrap.BootstrapException: java.nio.file.NoSuchFileException: /home/jiangtao/code/elasticsearch/core/config Likely root cause: java.nio.file.NoSuchFileException: /home/jiangtao/code/elasticsearch/core/config
    at sun.nio.fs.UnixException.translateToIOException(UnixException.java:86)
    at sun.nio.fs.UnixException.rethrowAsIOException(UnixException.java:102)
    at sun.nio.fs.UnixException.rethrowAsIOException(UnixException.java:107)
    at sun.nio.fs.UnixFileAttributeViews$Basic.readAttributes(UnixFileAttributeViews.java:55)
   at sun.nio.fs.UnixFileSystemProvider.readAttributes(UnixFileSystemProvider.java:144)
   at sun.nio.fs.LinuxFileSystemProvider.readAttributes(LinuxFileSystemProvider.java:99)
   at java.nio.file.Files.readAttributes(Files.java:1737)
   at java.nio.file.FileTreeWalker.getAttributes(FileTreeWalker.java:225)
   at java.nio.file.FileTreeWalker.visit(FileTreeWalker.java:276)
   at java.nio.file.FileTreeWalker.walk(FileTreeWalker.java:322)
   at java.nio.file.Files.walkFileTree(Files.java:2662)

解决办法：将distribution模块src路径下的config整个文件copy到core模块中

4，报错： ERROR Could not register mbeans java.security.AccessControlException
2017-06-06 09:52:08,007 main ERROR Could not register mbeans java.security.AccessControlException: access denied ("javax.management.MBeanTrustPermission" "register")
             at java.security.AccessControlContext.checkPermission(AccessControlContext.java:472)
            at java.lang.SecurityManager.checkPermission(SecurityManager.java:585)
            at com.sun.jmx.interceptor.DefaultMBeanServerInterceptor.checkMBeanTrustPermission(DefaultMBeanServerInterceptor.java:1848)
            at com.sun.jmx.interceptor.DefaultMBeanServerInterceptor.registerMBean(DefaultMBeanServerInterceptor.java:322)
            at com.sun.jmx.mbeanserver.JmxMBeanServer.registerMBean(JmxMBeanServer.java:522)
             ........
           at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:91)
           at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:84)

       解决办法：禁用jmx,在VM options中继续添加配置：  -Dlog4j2.disable.jmx=true。注意：在VM options中多个配置中间用空格分隔。

5，报错： java.lang.IllegalStateException: Unsupported transport.type 
错误栈如下：
[2017-06-06T10:04:21,327][WARN ][o.e.b.ElasticsearchUncaughtExceptionHandler]  uncaught exception in thread [main]
org.elasticsearch.bootstrap.StartupException: java.lang.IllegalStateException: Unsupported transport.type 
at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:127) ~[main/:?]
at org.elasticsearch.bootstrap.Elasticsearch.execute(Elasticsearch.java:114) ~[main/:?]
at org.elasticsearch.cli.EnvironmentAwareCommand.execute(EnvironmentAwareCommand.java:58) ~[main/:?]
at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:122) ~[main/:?]
at org.elasticsearch.cli.Command.main(Command.java:88) ~[main/:?]
at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:91) ~[main/:?]
at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:84) ~[main/:?]
Caused by: java.lang.IllegalStateException: Unsupported transport.type 
at org.elasticsearch.common.network.NetworkModule.getTransportSupplier(NetworkModule.java:213) ~[main/:?]
at org.elasticsearch.node.Node.<init>(Node.java:421) ~[main/:?]
at org.elasticsearch.node.Node.<init>(Node.java:242) ~[main/:?]
at org.elasticsearch.bootstrap.Bootstrap$6.<init>(Bootstrap.java:242) ~[main/:?]
at org.elasticsearch.bootstrap.Bootstrap.setup(Bootstrap.java:242) ~[main/:?]
at org.elasticsearch.bootstrap.Bootstrap.init(Bootstrap.java:360) ~[main/:?]
at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:123) ~[main/:?]
... 6 more

这个是由于依赖的transport等jar并没有找到，可以在项目根目录找到models模块，然后将下面目录打包，然后copy到distribution/src/main/models目录下，
也可以直接去官网（https://www.elastic.co/downloads/elasticsearch）下载zip包，解压后直接copy。
我直接去官网下载的zip包：从官网下载完毕zip包后，具体解决办法请看：错误 6。


6，copy module版本冲突
错误栈如下： 
org.elasticsearch.bootstrap.StartupException: java.lang.IllegalArgumentException: Plugin [lang-expression] is incompatible with Elasticsearch [5.3.4]. Was designed for version [5.3.1]
 at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:127) ~[main/:?]
 at org.elasticsearch.bootstrap.Elasticsearch.execute(Elasticsearch.java:114) ~[main/:?]
 at org.elasticsearch.cli.EnvironmentAwareCommand.execute(EnvironmentAwareCommand.java:58) ~[main/:?]
 at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:122) ~[main/:?]
 at org.elasticsearch.cli.Command.main(Command.java:88) ~[main/:?]
at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:91) ~[main/:?]
at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:84) ~[main/:?]
Caused by: java.lang.IllegalArgumentException: Plugin [lang-expression] is incompatible with Elasticsearch [5.3.4]. Was designed for version [5.3.1]

解决办法：修改es当前版本
将core模块中的Version.java类由
public static final Version CURRENT = V_5_3_4_UNRELEASED;
修改为：
public static final Version CURRENT = V_5_3_1;