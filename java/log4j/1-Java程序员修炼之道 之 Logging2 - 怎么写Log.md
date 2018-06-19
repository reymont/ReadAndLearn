Java程序员修炼之道 之 Logging(2/3) - 怎么写Log - 紫风乱写 - BlogJava http://www.blogjava.net/justfly/archive/2015/08/19/416925.html

1. 一个最基本的例子
使用Logging框架写Log基本上就三个步骤
引入loggerg类和logger工厂类
声明logger
记录日志
下面看一个例子
//1. 引入slf4j接口的Logger和LoggerFactory
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class UserService {
  //2. 声明一个Logger，这个是static的方式，我比较习惯这么写。
  private final static Logger logger = LoggerFactory.getLogger(UserService.class);

  public boolean verifyLoginInfo(String userName, String password) {
    //3. log it，输出的log信息将会是："Start to verify User [Justfly]
    logger.info("Start to verify User [{}]", userName);
    return false;
  }
}
其中的第二步，关于Logger对象是否要声明为静态的业界有过一些讨论，Logback的作者最早是推荐使用对象变量的方式来声明，后来他自己也改变了想法。想详细了解的同学可以去看一下: http://slf4j.org/faq.html#declared_static
两种方式的优劣概述如下：
静态Logger对象相对来说更符合语义，节省CPU，节省内存，不支持注入
对象变量Logger支持注入，对于一个JVM中运行的多个引用了同一个类库的应用程序，可以在不同的应用程序中对同个类的Logger进行不同的配置。比如Tomcat上部署了俩个应用，他们都引用了同一个lib。
2. Logger接口的方法
Logger接口分为俩个版本，一个带Marker版本和一个没带Marker版本的。带Marker版本的我没用过就不介绍了。没带Marker版本的接口方法可以分为以下两组：
2.1 判断Logger级别是否开启的方法

public boolean isTraceEnabled();
public boolean isDebugEnabled();
public boolean isInfoEnabled();
public boolean isWarnEnabled();
public boolean isErrorEnabled();
这组方法的作用主要是避免没必要的log信息对象的产生，尤其是对于不支持参数化信息的Log框架(Log4j 1, commons-logging)。如下面的例子所示，如果没有加debug级别判断，在Debug级别被禁用的环境（生产环境）中，第二行的代码将没有必要的产生多个String对象。
1 if(logger.isDebugEnabled()){
2   logger.debug("["+resultCount+"]/["+totalCount+"] of users are returned");
3 }
如果使用了参数信息的方法，在如下代码中，即使没有添加debug级别（第一行）判断，在生产环境中，第二行代码只会生成一个String对象。
1 if(logger.isDebugEnabled()){
2   logger.debug("[{}]/[{}] of users in group are returned", resultCount,totalCount);
3 }
因此，为了代码的可读性，我一般情况下使用参数化信息的方法，并且不做Logger级别是否开启的判断，换句话说，这组方法我一般情况下不会用。
2.2 log信息的方法

2.2.1 方法说明

Logger中有五个级别：track,debug,info,warn,error。对于每个级别，分别有五个log方法，以info级别为例子：
public void info(String msg);
无参数的log方法，例子：
logger.info("开始初始化配置文件读取模块");
输出
2014-08-11 23:36:17,783 [main] INFO  c.j.training.logging.service.UserService - 开始初始化配置文件读取模块
public void info(String format, Object arg);
支持一个参数的参数化log方法，例子：
logger.info("开始导入配置文件[{}]","/somePath/config.properties");
输出
2014-08-11 23:36:17,787 [main] INFO  c.j.training.logging.service.UserService - 开始导入配置文件[/somePath/config.properties]
public void info(String format, Object arg1, Object arg2);
支持俩个参数的参数化log方法，例子：
logger.info("开始从配置文件[{}]中读取配置项[{}]的值","/somePath/config.properties","maxSize");
输出
2014-08-11 23:36:17,789 [main] INFO  c.j.training.logging.service.UserService - 开始从配置文件[/somePath/config.properties]中读取配置项[maxSize]的值
public void info(String format, Object... arguments);
支持多个参数的参数化log方法，对比上面的俩个方法来说，会多增加构造一个Object[]的开销。例子：
logger.info("在配置文件[{}]中读取到配置项[{}]的值为[{}]","/somePath/config.properties","maxSize", 5);
输出
2014-08-11 23:36:17,789 [main] INFO  c.j.training.logging.service.UserService - 在配置文件[/somePath/config.properties]中读取到配置项[maxSize]的值为[5]
public void info(String msg, Throwable t);
无参数化记录log异常信息
logger.info("读取配置文件时出现异常",new FileNotFoundException("File not exists"));
输出
2014-08-11 23:36:17,794 [main] INFO  c.j.training.logging.service.UserService - 读取配置文件时出现异常
java.io.FileNotFoundException: File not exists
  at cn.justfly.training.logging.service.UserServiceTest.testLogResult(UserServiceTest.java:31) ~[test-classes/:na]
  at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method) ~[na:1.6.0_45]
  at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:39) ~[na:1.6.0_45]
  at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:25) ~[na:1.6.0_45]
  at java.lang.reflect.Method.invoke(Method.java:597) ~[na:1.6.0_45]

参数化说明
在上面的例子中，我们可以看到log信息中的{}将会按照顺序被后面的参数所替换。这样带来了一个好处：如果在运行时不需要打印该Log，则不会重复产生String对象。
2.2.2 如何Log Exception

2.2.2.1 把Exception作为Log方法的最后一个参数

上面讲的参数化Log方法的中的最后一个参数如果是一个Exception类型的对象的时候，logback将会打印该Exception的StackTrace信息。看下面的这个例子：
logger.info("读取配置文件[{}]时出错。","/somePath/config.properties",new FileNotFoundException("File not exists"));
上面的代码在执行的时候会输出如下内容：
2014-08-12 00:22:49,167 [main] INFO  c.j.training.logging.service.UserService - 读取配置文件[/somePath/config.properties]时出错。
java.io.FileNotFoundException: File not exists
  at cn.justfly.training.logging.service.UserServiceTest.testLogResult(UserServiceTest.java:30) [test-classes/:na]
  at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method) ~[na:1.6.0_45]
  at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:39) ~[na:1.6.0_45]
  at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:25) ~[na:1.6.0_45]
  at java.lang.reflect.Method.invoke(Method.java:597) ~[na:1.6.0_45]
  at org.junit.runners.model.FrameworkMethod$1.runReflectiveCall(FrameworkMethod.java:47) [junit.jar:na]
  at org.junit.internal.runners.model.ReflectiveCallable.run(ReflectiveCallable.java:12) [junit.jar:na]
  at org.junit.runners.model.FrameworkMethod.invokeExplosively(FrameworkMethod.java:44) [junit.jar:na]
  at org.junit.internal.runners.statements.InvokeMethod.evaluate(InvokeMethod.java:17) [junit.jar:na]
  at org.junit.runners.ParentRunner.runLeaf(ParentRunner.java:271) [junit.jar:na]
2.2.2.2 Exception不会替换log信息中的参数

另外需要注意的时，该Exception不会作为参数化内容中的参数进行替换。比如下面的代码：
logger.info("读取配置文件[{}]时出错。异常为[{}]","/somePath/config.properties",new FileNotFoundException("File not exists"));
其执行结果如下所示，第二个参数没有进行替换
2014-08-12 00:25:37,994 [main] INFO  c.j.training.logging.service.UserService - 读取配置文件[/somePath/config.properties]时出错。异常为[{}]
java.io.FileNotFoundException: File not exists
  at cn.justfly.training.logging.service.UserServiceTest.testLogResult(UserServiceTest.java:30) [test-classes/:na]
  at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method) ~[na:1.6.0_45]
  at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:39) ~[na:1.6.0_45]
  at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:25) ~[na:1.6.0_45]
  at java.lang.reflect.Method.invoke(Method.java:597) ~[na:1.6.0_45]
2.2.2.3 参数化Exception

如果你就是不想要打印StackTrace，就是要将其参数化的话怎么弄？一般情况下不建议这么做，因为你把Exception中有用的东西吃掉了。但是如果你非要这么做的话，也不是不可以，有俩个方法：
把Exception的toString()方法的返回值作为参数
例子如下所示，注意我们不用ex.getMessage()而是用toString()方法，原因在于不是每个Message实例都有Message，但是默认的toString()方法里面包括有Message
logger.info("读取配置文件[{}]时出错。异常为[{}]","/somePath/config.properties",new FileNotFoundException("File not exists").toString());
执行结果为：
2014-08-12 00:29:24,018 [main] INFO  c.j.training.logging.service.UserService - 读取配置文件[/somePath/config.properties]时出错。异常为[java.io.FileNotFoundException: File not exists]
不要让Exception成为最后一个参数
例子如下：
logger.info("读取参数[{}]的时候出错：[{}], 请检查你的配置文件[{}]","maxSize",new FileNotFoundException("File not exists"),"/somePath/config.properties");
执行结果为：
2014-08-12 00:35:11,125 [main] INFO  c.j.training.logging.service.UserService - 读取参数[maxSize]的时候出错：[java.io.FileNotFoundException: File not exists], 请检查你的配置文件[/somePath/config.properties]
3. Log什么
前面讲了怎么使用Loggger的方法log日志，下面继续讲讲在什么地方需要记录什么级别的log，以及需要记录什么内容。
3.1 如何使用不同级别的Log

SLF4J把Log分成了Error，Warn，Info，Debug和Trace五个级别。我们可以把这俩个级别分成两组
3.1.1 用户级别

Error、Warn和Info这三个级别的Log会出现在生产环境上，他们必须是运维人员能阅读明白的
3.1.1.1 Error

影响到程序正常运行、当前请求正常运行的异常情况,例如：
打开配置文件失败
第三方应用网络连接异常
SQLException
不应该出现的情况，例如：
某个Service方法返回的List里面应该有元素的时候缺获得一个空List
做字符转换的时候居然报错说没有GBK字符集
3.1.1.2 Warn

不应该出现但是不影响程序、当前请求正常运行的异常情况，例如：
有容错机制的时候出现的错误情况
找不到配置文件，但是系统能自动创建配置文件
即将接近临界值的时候，例如：
缓存池占用达到警告线
3.1.1.3 Info

系统运行信息
Service方法的出入口
主要逻辑中的分步骤
外部接口部分
客户端请求参数和返回给客户端的结果
调用第三方时的调用参数和调用结果
3.1.2 开发级别

Debug和Trace这俩个级别主要是在开发期间使用或者当系统出现问题后开发人员介入调试的时候用的，需要有助于提供详细的信息。
3.1.2.1 Debug

用于记录程序变量，例如：
多次迭代中的变量
用于替代代码中的注释
如果你习惯在代码实现中写：
//1. 获取用户基本薪资

//2. 获取用户休假情况

//3. 计算用户应得薪资

不妨这么写试试
logger.debug("开始获取员工[{}] [{}]年基本薪资",employee,year);

logger.debug("获取员工[{}] [{}]年的基本薪资为[{}]",employee,year,basicSalary);
logger.debug("开始获取员工[{}] [{}]年[{}]月休假情况",employee,year,month);

logger.debug("员工[{}][{}]年[{}]月年假/病假/事假为[{}]/[{}]/[{}]",employee,year,month,annualLeaveDays,sickLeaveDays,noPayLeaveDays);
logger.debug("开始计算员工[{}][{}]年[{}]月应得薪资",employee,year,month);

logger.debug("员工[{}] [{}]年[{}]月应得薪资为[{}]",employee,year,month,actualSalary);
3.1.2.2 Trace

主要用于记录系统运行中的完整信息，比如完整的HTTP Request和Http Response
3.2 Log中的要点

3.2.1 Log上下文

在Log中必须尽量带入上下文的信息，对比以下俩个Log信息，后者比前者更有作用
"开始导入配置文件"
"开始导入配置文件[/etc/myService/config.properties]"
3.2.2 考虑Log的读者

对于用户级别的Log，它的读者可能是使用了你的框架的其他开发者，可能是运维人员，可能是普通用户。你需要尽量以他们可以理解的语言来组织Log信息，如果你的Log能对他们的使用提供有用的帮助就更好了。
下面的两条Log中，前者对于非代码维护人员的帮助不大，后者更容易理解。
"开始执行getUserInfo 方法，用户名[jimmy]"
"开始获取用户信息，用户名[jimmy]"
下面的这个Log对于框架的使用者提供了极大的帮助
"无法解析参数[12 03, 2013]，birthDay参数需要符合格式[yyyy-MM-dd]"
3.2.3 Log中的变量用[]与普通文本区分开来

把变量和普通文本隔离有这么几个作用
在你阅读Log的时候容易捕捉到有用的信息
在使用工具分析Log的时候可以更方便抓取
在一些情况下不容易混淆
对比以下下面的两条Log，前者发生了混淆：
"获取用户lj12月份发邮件记录数"
"获取用户[lj1][2]月份发邮件记录数"
3.2.4 Error或者Warn级别中碰到Exception的情况尽量log 完整的异常信息

Error和Warn级别是比较严重的情况，意味着系统出错或者危险，我们需要更多的信息来帮助分析原因，这个时候越多的信息越有帮助。这个时候最好的做法是Log以下全部内容：
你是在做什么事情的时候出错了
你是在用什么数据做这个事情的时候出错了
出错的信息是什么
对比下面三个Log语句，第一个提供了详尽的信息，第二个只提供了部分信息，Exception的Message不一定包含有用的信息，第三个只告诉你出错了，其他的你一无所知。
log.error("获取用户[{}]的用户信息时出错",userName,ex);
log.error("获取用户[{}]的用户信息时报错，错误信息：[{}]",userName,ex.getMessage());
log.error("获取用户信息时出错");
3.2.5 对于Exception，要每次都Log StackTrace吗？

在一些Exception处理机制中，我们会每层或者每个Service对应一个RuntimeException类，并把他们抛出去，留给最外层的异常处理层处理。典型代码如下:
try{
  
}catch(Exception ex){
  String errorMessage=String.format("Error while reading information of user [%s]",userName);
  logger.error(errorMessage,ex);
  throw new UserServiceException(errorMessage,ex);
}
这个时候问题来了，在最底层出错的地方Log了异常的StackTrace，在你把这个异常外上层抛的过程中，在最外层的异常处理层的时候，还会再Log一次异常的StackTrace，这样子你的Log中会有大篇的重复信息。
我碰到这种情况一般是这么处理的：Log之！原因有以下这几个方面：
这个信息很重要，我不确认再往上的异常处理层中是否会正常的把它的StackTrace打印出来。
如果这个异常信息在往上传递的过程中被多次包装，到了最外层打印StackTrace的时候最底层的真正有用的出错原因有可能不会被打印出来。
如果有人改变了LogbackException打印的配置，使得不能完全打印的时候，这个信息可能就丢了。
就算重复了又怎么样？都Error了都Warning了还省那么一点空间吗？