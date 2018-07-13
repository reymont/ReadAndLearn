
logback - 巫巫巫政霖 - CSDN博客 http://blog.csdn.net/Doraemon_wu/article/category/6309538
阅读Logback文档笔记--Logback的Layout配置 - 巫巫巫政霖 - CSDN博客 http://blog.csdn.net/Doraemon_wu/article/details/52040859


什么是 layout ?
Layout 是Logback中的组件，负责将到来的event转换成 String。Layout 接口中的 doLayout（E event）方法接受一个模板类 event 参数，并返回 String 字符串。

下面是 Layout 接口概要

public interface Layout<E extends ContextAware, LifeCycle {

  String doLayout(E event);
  String getFileHeader();
  String getPresentationHeader();
  String getFileFooter();
  String getPresentationFooter();
  String getContentType();
}

logback-classic 中仅仅处理 ILoggingEvent。
下面我们尝试写一个自己的layout类
package chapters.layouts;

import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.LayoutBase;

public class MySampleLayout2 extends LayoutBase<ILoggingEvent {

  String prefix = null;
  boolean printThreadName = true;

  public void setPrefix(String prefix) {
    this.prefix = prefix;
  }

  public void setPrintThreadName(boolean printThreadName) {
    this.printThreadName = printThreadName;
  }

  public String doLayout(ILoggingEvent event) {
    StringBuffer sbuf = new StringBuffer(128);
    if (prefix != null) {
      sbuf.append(prefix + ": ");
    }
    sbuf.append(event.getTimeStamp() - event.getLoggerContextVO().getBirthTime());
    sbuf.append(" ");
    sbuf.append(event.getLevel());
    if (printThreadName) {
      sbuf.append(" [");
      sbuf.append(event.getThreadName());
      sbuf.append("] ");
    } else {
      sbuf.append(" ");
    }
    sbuf.append(event.getLoggerName());
    sbuf.append(" - ");
    sbuf.append(event.getFormattedMessage());
    sbuf.append(LINE_SEP);
    return sbuf.toString();
  }
}

可以看到 MySampleLayout2 继承自LayoutBase ，LayoutBase 这个类实现了很多其他内置layout 通用的函数，例如检测 layout 是否开启或关闭，设置header，footer，以及content type 等。它使开发人员可以只关注自己的格式化实现。记住，LayoutBase是泛型的，因此在使用logbook-classic时需要制定泛型 LayoutBase<ILoggingEvent>，而在hogback-access中 event的类型就是 IAccessEvent

下面是引用自己的Layout类
<configuration>

  <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender"
    <encoder class="ch.qos.logback.core.encoder.LayoutWrappingEncoder"
      <layout class="chapters.layouts.MySampleLayout2"
        <prefix>MyPrefix</prefix>
        <printThreadName>false</printThreadName>
      </layout>
    </encoder>
  </appender>

  <root level="DEBUG"
    <appender-ref ref="STDOUT" />
  </root>
</configuration>
可以看出，我们layout类中的变量，可以通过<layout>标签下<属性名>的方式来使用set方法赋值。

PatternLayout
PatternLayout是logback自带的一个比较灵活的布局类。与其他layout一样，PatternLayout接收一个logging event 然后返回一个String。然而这个String可以通过conversion pattern（转换模板）来个性化。与之相比，我们上面自级写的layout类的输出日志的格式也就写死在代码上了。
pattern 的格式的样子与c语言中的printf函数非常相似，由文本，以及称为conversion specifier(格式符)的格式控制表达式组成。格式符由%开头，并且跟随可选的的format modifiers(格式编辑符)，一个conversion word（转换字） 以及用{}包裹可选参数。conversion word控制数据域，例如logger name , level , thread name 等等。format modifiers 控制数据域的快读，padding ，左右浮动。
Encoder那篇博文也说过，在0.9.19版本引入 Encoder之后，FileAppender及其子类不在直接使用<Layout>，而是使用<encoder>包裹<layout>的方式。原因也说了，是因为layout只能将event转换成string，并且不能控制日志输出过，无法做先缓存再一次性写出的操作。

下面我们看看，不是配置文件的情况下，手写代码使用PatternLayout
package chapters.layouts;

import org.slf4j.LoggerFactory;

import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.LoggerContext;
import ch.qos.logback.classic.encoder.PatternLayoutEncoder;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.ConsoleAppender;

public class PatternSample {

  static public void main(String[] args) throws Exception {
    Logger rootLogger = (Logger)LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME);
    LoggerContext loggerContext = rootLogger.getLoggerContext();
    // we are not interested in auto-configuration
    loggerContext.reset();

    PatternLayoutEncoder encoder = new PatternLayoutEncoder();
    encoder.setContext(loggerContext);
    encoder.setPattern("%-5level [%thread]: %message%n");
    encoder.start();

    ConsoleAppender<ILoggingEvent appender = new ConsoleAppender<ILoggingEvent>();
    appender.setContext(loggerContext);
    appender.setEncoder(encoder);
    appender.start();

    rootLogger.addAppender(appender);

    rootLogger.debug("Message 1");
    rootLogger.warn("Message 2");
  }
}
将会输出如下日志
DEBUG [main]: Message 1
WARN [main]: Message 2

下面我们看看PatternLayout到底有哪些Conversion word 以及 格式化符
需要注意的时，有些符号是转义符，因此需要使用 “\” 来转换，例如  \(     \)      \%

Conversion Word
Effect
c{length} 
lo{length}
logger{length} 
logger 的名称
可接收一个可选参数，设置logger name的长度。默认输出全名，参数0代表只输出Logger name最右边点号的值，如只输出类名，不输出包名。
注意：点号最右边的字符串不会被压缩，如果length的值小于Logger name，其他字符串最小也只能被压缩成1个字符，但不会缺失。

Conversion specifier	Logger name	Result
%logger	mainPackage.sub.sample.Bar	mainPackage.sub.sample.Bar
%logger{0}	mainPackage.sub.sample.Bar	Bar
%logger{5}	mainPackage.sub.sample.Bar	m.s.s.Bar
%logger{10}	mainPackage.sub.sample.Bar	m.s.s.Bar
%logger{15}	mainPackage.sub.sample.Bar	m.s.sample.Bar
%logger{16}	mainPackage.sub.sample.Bar	m.sub.sample.Bar
%logger{26}	mainPackage.sub.sample.Bar	mainPackage.sub.sample.Bar

C{length} 
class{length} 
日志请求调用所在的全限定类名（caller data中的一部分），之前说过获取caller data消耗资源高。所以非必要，不建议。
contextName
cn
logger context上下文名称 
d{pattern} 
date{pattern} 
d{pattern, timezone} 
date{pattern, timezone} 
logging event的时间
可接收时间格式化参数（默认ISO 8601，格式参照java.text.SimpleDateFormat.）
以及时区参数（默认Jvm时区，如果所设置的时区有错，则使用GMT时区）
需要注意，在pattern中，如果要使用逗号, 需要用引号括起来。 例如%date{"HH:mm:ss,SSS"}

Conversion Pattern	Result
%d	2006-10-20 14:06:49,812
%date	2006-10-20 14:06:49,812
%date{ISO8601}	2006-10-20 14:06:49,812
%date{HH:mm:ss.SSS}	14:06:49.812
%date{dd MMM yyyy;HH:mm:ss.SSS}	20 oct. 2006;14:06:49.812

F / file	日志请求所在的java source file 文件名。不提倡，速度慢。参考caller data
caller{depth}
caller{depthStart..depthEnd}
caller{depth, evaluator-1, ... evaluator-n}
caller{depthStart..depthEnd, evaluator-1, ... evaluator-n}
日志请求的caller data 
包含 caller 的全限定类名，文件名，以及行号。
参数evaluator指定鉴别器，可以实现特定日志请求才包含caller data
参数depth,指定caller data 的深度
例如, %caller{2} 将输出如下
0    [main] DEBUG - logging statement 
Caller+0   at mainPackage.sub.sample.Bar.sampleMethodName(Bar.java:22)
Caller+1   at mainPackage.sub.sample.Bar.createLoggingRequest(Bar.java:17)
%caller{3} 如下
16   [main] DEBUG - logging statement 
Caller+0   at mainPackage.sub.sample.Bar.sampleMethodName(Bar.java:22)
Caller+1   at mainPackage.sub.sample.Bar.createLoggingRequest(Bar.java:17)
Caller+2   at mainPackage.ConfigTester.main(ConfigTester.java:38)
也可以指定一个范围
%caller{1..2} 如下
0    [main] DEBUG - logging statement
Caller+0   at mainPackage.sub.sample.Bar.createLoggingRequest(Bar.java:17)

而%caller{3, CALLER_DISPLAY_EVAL}，当鉴别器返回true时才会输出caller data
L / line	caller data 行号，速度慢，不推荐
m / msg / message	logging event 的 message
M / method	caller data 的method ，速度慢，不推荐
n	输出与系统平台相关的换行符。例如linux 的"\n", 或者 windows"\r\n"
p / le / level	日志的level 
r / relative	日志产生时，应用已存活的时间 
t / thread	产生logging event 的线程名 
X{key:-defaultVal} 
mdc{key:-defaultVal} 
输出指定MDC指定Key的值，没有输出默认值，如果不通过 :- 指定默认值，当key不存在，则输出空字符串
ex{depth} 
exception{depth} 
throwable{depth} 

ex{depth, evaluator-1, ..., evaluator-n} 
exception{depth, evaluator-1, ..., evaluator-n} 
throwable{depth, evaluator-1, ..., evaluator-n}
输出 exception的相关的stack trace 的值。默认是全部 stack trace
depth可以选择以下几种类型的值:
short: prints the first line of the stack trace
full: prints the full stack trace
Any integer: prints the given number of lines of the stack trace

以下是一些例子:
Conversion Pattern
Result
%ex	
mainPackage.foo.bar.TestException: Houston we have a problem
  at mainPackage.foo.bar.TestThrower.fire(TestThrower.java:22)
  at mainPackage.foo.bar.TestThrower.readyToLaunch(TestThrower.java:17)
  at mainPackage.ExceptionLauncher.main(ExceptionLauncher.java:38)
%ex{short}	
mainPackage.foo.bar.TestException: Houston we have a problem
  at mainPackage.foo.bar.TestThrower.fire(TestThrower.java:22)
%ex{full}	
mainPackage.foo.bar.TestException: Houston we have a problem
  at mainPackage.foo.bar.TestThrower.fire(TestThrower.java:22)
  at mainPackage.foo.bar.TestThrower.readyToLaunch(TestThrower.java:17)
  at mainPackage.ExceptionLauncher.main(ExceptionLauncher.java:38)
%ex{2}	
mainPackage.foo.bar.TestException: Houston we have a problem
  at mainPackage.foo.bar.TestThrower.fire(TestThrower.java:22)
  at mainPackage.foo.bar.TestThrower.readyToLaunch(TestThrower.java:17)

evaluator鉴别器，意义参照caller data中的声明。当evaluator返回false，则输出，与caller conversion相反哦。切记
xEx{depth} 
xException{depth} 
xThrowable{depth} 

xEx{depth, evaluator-1, ..., evaluator-n} 
xException{depth, evaluator-1, ..., evaluator-n} 
xThrowable{depth, evaluator-1, ..., evaluator-n}
与%ex类似，但是包含了包名以及版本号，如果包，版本号不确定，则会附带~波浪号。如果pattern不指定任何%ex或%xEx，则会默认添加%xEx。
但是需要注意，如果你使用Netbeans，则获取包名版本号可能导致阻塞，所以需要禁止%ex来防止这种默认行为。
例子：
java.lang.NullPointerException
at com.xyz.Wombat(Wombat.java:57) ~[wombat-1.3.jar:1.3]
at com.xyz.Wombat(Wombat.java:76) ~[wombat-1.3.jar:1.3]
at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method) ~[na:1.5.0_06]
at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:39) ~[na:1.5.0_06]
at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:25) ~[na:1.5.0_06]
at java.lang.reflect.Method.invoke(Method.java:585) ~[na:1.5.0_06]
at org.junit.internal.runners.TestMethod.invoke(TestMethod.java:59) [junit-4.4.jar:na] at org.junit.internal.runners.MethodRoadie.runTestMethod(MethodRoadie.java:98) [junit-4.4.jar:na] ...etc

nopex 
nopexception
无视 exception 信息，同时禁止PatternLayout中默认的安全机制，就是在pattern中添加%eXe。
marker	
日志的marker 标签
如果marker 存在 子marker，则转换器都会将它们按以下格式输出
parentName [ child1, child2 ]
property{key}	
输出指定Key的property属性值，如何定义属性呢，之前也讲过define variables
如果key指定的property不在logger context中，则会在system properties中找，如果还没有，就返回 Property_HAS_NO_KEY
replace(p){r, t}	
以 t 值 替换 在 p 中出现的符合 r 模板的值。
例如 "%replace(%msg){'\s', '’}" 会删除event message中所有的空格
注意，p 可以包含多个conversion word 。注意转义符的问题。 例如：%replace(%logger %msg){'\.', '/'}" 
rEx{depth} 
rootException{depth} 

rEx{depth, evaluator-1, ..., evaluator-n} 
rootException{depth, evaluator-1, ..., evaluator-n}
与%eXe类似，不同的是，将 root cause 放在了第一句，原本一般是在最后一句的。
例如：
java.lang.NullPointerException
  at com.xyz.Wombat(Wombat.java:57) ~[wombat-1.3.jar:1.3]
  at com.xyz.Wombat(Wombat.java:76) ~[wombat-1.3.jar:1.3]
Wrapped by: org.springframework.BeanCreationException: Error creating bean with name 'wombat': 
  at org.springframework.AbstractBeanFactory.getBean(AbstractBeanFactory.java:248) [spring-2.0.jar:2.0]
  at org.springframework.AbstractBeanFactory.getBean(AbstractBeanFactory.java:170) [spring-2.0.jar:2.0]
  at org.apache.catalina.StandardContext.listenerStart(StandardContext.java:3934) [tomcat-6.0.26.jar:6.0.26]



大多数情况下，pattern中的文本会包含空格以及一些其他的界定符，这样就会与conversion words 混淆在一起难以理解。
例如在模板 "%level [%thread] - %message%n”  中就包含了 [  ]  - space（空格）这些文本值。但是如果我们直接写成这样"%date%nHello”，那转换器就会认为%nHello是个未知的conversion word，logbook就会将%nHello输出为%PARSER_ERROR[nHello]，不过如果你非得这样，也可以在%n插入空参数花括号，例如"%date%n{}Hello"

说完了conversion word，我们再来看看 Format modifiers 
我们可以通过Format modifier来改变数值域的最大，最小宽度，左，右对齐，颜色等等。

下面是一些说明最大，最小宽度，左右对齐的例子：
Format modifier	Left justify	Minimum width	Maximum width	Comment
%20logger	false	20	none	指定最小宽度，如果logger name少于20个字符，则默认向右对齐 
%-20logger	true	20	none	-号 代表向左对齐，同样设置最小宽度为20 
%.30logger	NA	none	30	.点号后面的值，代表最大宽度，超过最大长度，默认，截断左边的值 
%20.30logger	false	20	30	设置最大最小宽度 
%-20.30logger	true	20	30	设置最大最小宽度，并且左对齐，超过最大宽度，默认截断左边的值 
%.-30logger	NA	none	30	这是最大宽度，在.点号右边加-减号，代表指定截断从尾部（右边）开始 



下面是一些例子，注意其中的”[ ]"只是为了方便理解，并不是pattern中的值
Format modifier	Logger name	Result
[%20.20logger]	main.Name	
[           main.Name]

[%-20.20logger]	main.Name	
[main.Name           ]

[%10.10logger]	main.foo.foo.bar.Name	
[o.bar.Name]

[%10.-10logger]	main.foo.foo.bar.Name	
[main.foo.f]




下面我们看几个常用的例子：

1、只输出 level 的一个字母，如T,D,W,I,E，可以使用 
"%.-1level"

2、将信用卡号码替换成xxxx，需要注意，如果option中包含特殊意义的符号，需要使用单引号或双引号 括住
<pattern>%5level - replace(%msg){‘\d{14,16}’,'xxxx'}</pattern>

 

小括号的特殊含义
在logback中，小括号括起来的pattern子串将被认为是一组。因此你可以针对这个组来设置样式。
例如下面的例子：
%-30(%d{HH:mm:ss:SSS} [%thread]) %-5level %logger{32} - %msg%n
输出结果格式如下：



颜色设置
logback 1.0.5版本，PatternLayout开始支持

%black
黑色
%red
红色
%green
绿色
%yellow
黄色
%blue
蓝色
%magenta
洋红色
%cyan
蓝绿色
%white
白色
%gray
灰色
 	 	 
%boldRed
鲜红色
%boldGreen
鲜绿
%boldYellow
鲜黄
%boldBlue
鲜蓝
%boldMagenta
鲜洋红
%boldCyan
鲜蓝绿色
%boldWhite
鲜白色
%highlight
高亮
 	 	 	 

高亮指的是：level级别：error鲜红，warn红色，info蓝色，其他黑色
下面看个例子：
<configuration debug="true"
  <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender"
    <!-- On Windows machines setting withJansi to true enables ANSI
        color code interpretation by the Jansi library. This requires
        org.fusesource.jansi:jansi:1.8 on the class path.  Note that
        Unix-based operating systems such as Linux and Mac OS X
        support ANSI color codes by default. -->
    <withJansi>true</withJansi>
    <encoder>
      <pattern>[%thread] %highlight(%-5level) %cyan(%logger{15}) - %msg %n</pattern>
    </encoder>
  </appender>
  <root level="DEBUG"
    <appender-ref ref="STDOUT" />
  </root>
</configuration>
输出格式如下：




鉴别器
上面提到过，如果需要动态的conversion specifier行为可以在option中指定evaluator，这是一个EventEvaluator对象。
例如，我们只希望某些需要caller data数据的日志才产生caller data信息，这样就不会严重影响性能。
鉴别器的详细说明会在filter章节中（下一篇博文）说明，也可参照官方文档dedicated section of the chapter on filters 
需要注意，默认的evaluator引用Janino library的 JaninoEventEvaluator，以下用maven引入依赖包
<dependency>
  <groupId>org.codehaus.janino</groupId>
  <artifactId>janino</artifactId>
  <version>2.7.8</version>
</dependency>

下面我们来看个鉴别期的例子
<configuration>
  <evaluator name="DISP_CALLER_EVAL"
    <expression>logger.contains("chapters.layouts") &amp;&amp; \
      message.contains("who calls thee")</expression>
  </evaluator>

  <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender"
    <encoder>
      <pattern>
        %-4relative [%thread] %-5level - %msg%n%caller{2, DISP_CALLER_EVAL}
      </pattern>
    </encoder>
  </appender>

  <root level="DEBUG"
    <appender-ref ref="STDOUT" />
  </root>
</configuration>


package chapters.layouts;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import ch.qos.logback.classic.LoggerContext;
import ch.qos.logback.classic.joran.JoranConfigurator;
import ch.qos.logback.core.joran.spi.JoranException;
import ch.qos.logback.core.util.StatusPrinter;

public class CallerEvaluatorExample {

  public static void main(String[] args)  {
    Logger logger = LoggerFactory.getLogger(CallerEvaluatorExample.class);
    LoggerContext lc = (LoggerContext) LoggerFactory.getILoggerFactory();

    try {
      JoranConfigurator configurator = new JoranConfigurator();
      configurator.setContext(lc);
      configurator.doConfigure(args[0]);
    } catch (JoranException je) {
      // StatusPrinter will handle this
    }
    StatusPrinter.printInCaseOfErrorsOrWarnings(lc);

    for (int i = 0; i < 5; i++) {
      if (i == 3) {
        logger.debug("who calls thee?");
      } else {
        logger.debug("I know me " + i);
      }
    }
  }
}

由以上logback配置和程序，将会产生如下输出
0    [main] DEBUG - I know me 0
0    [main] DEBUG - I know me 1
0    [main] DEBUG - I know me 2
0    [main] DEBUG - who calls thee?
Caller+0  at chapters.layouts.CallerEvaluatorExample.main(CallerEvaluatorExample.java:28)
0    [main] DEBUG - I know me 4

特别注意，上面也提到过，caller conversion word 是当evaluator 返回真有效，而ex，eXe，rEx是当evaluator返回假时有效。

例如以下配置，当异常不为空，且异常时TestException的实例，不输出异常信息。
<configuration>

  <evaluator name="DISPLAY_EX_EVAL"
    <expression>throwable != null &amp;&amp; throwable instanceof  \
      chapters.layouts.TestException</expression>
  </evaluator>

  <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender"
    <encoder>
      <pattern>%msg%n%ex{full, DISPLAY_EX_EVAL}</pattern>
    </encoder>
  </appender>

  <root level="debug"
    <appender-ref ref="STDOUT" />
  </root>
</configuration>



我们也可以定义使用自己的conversion word
定义使用自己的conversion word有两个步骤：
1：继承ClassicConverter，ClassicConverter 类负责获取ILooginEvent对象的信息，并且生成String。
public class MySampleConverter extends ClassicConverter {

  long start = System.nanoTime();

  @Override
  public String convert(ILoggingEvent event) {
    long nowInNanos = System.nanoTime();
    return Long.toString(nowInNanos-start);
  }
}

2：声明我们的converter
<configuration>

  <conversionRule conversionWord="nanos"
                  converterClass="chapters.layouts.MySampleConverter" />

  <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender"
    <encoder>
      <pattern>%-6nanos [%thread] - %msg%n</pattern>
    </encoder>
  </appender>

  <root level="DEBUG"
    <appender-ref ref="STDOUT" />
  </root>
</configuration>

该配置输出的日志格式如下：
4868695 [main] DEBUG - Everything's going well
5758748 [main] ERROR - maybe not quite...





HTMLLayout
HTMLLayout 会将日志信息以html table 的形式输出。我们先看下他默认的css样式：



需要注意的是：HTMLLayout的pattern中，conversion specifier不能用空格，或其他字符隔开。因为每一个specifier都会被分成一列。加入不必要的字符，会导致空白列，浪费屏幕空间。
<configuration debug="true"
  <appender name="FILE" class="ch.qos.logback.core.FileAppender"
    <encoder class="ch.qos.logback.core.encoder.LayoutWrappingEncoder"
      <layout class="ch.qos.logback.classic.html.HTMLLayout"
        <pattern>%relative%thread%mdc%level%logger%msg</pattern>
      </layout>
    </encoder>
    <file>test.html</file>
  </appender>

  <root level="DEBUG"
    <appender-ref ref="FILE" />
  </root>
</configuration>

特别注意，HTMLLayout实例自带一个IThrowableRenderer对象，该渲染器对象，可以让异常的stack trace的信息以一种易读的方式展现，如上面的例子,所以在HTMLLayout 的 pattern中一般都不用使用异常的conversion word。如果你一定要使用%ex来讲异常信息显示在某一列上，这会导致大多数的日志可能这一列为空，并且信息也不容易阅读。所以我们并不推荐。不过如果你心意已决，那就去吧比卡丘。
如果要修改样式呢，可以通过以下方式：引入样式文件。
<layout class="ch.qos.logback.classic.html.HTMLLayout"
  <pattern>%relative...%msg</pattern>
  <cssBuilder class="ch.qos.logback.classic.html.UrlCssBuilder"
    <!-- url where the css file is located -->
    <url>http://...</url>
  </cssBuilder>
</layout>



Log4j XMLLayout
XMLLayout（logbook-classic中的一部分）生成的日志满足log4j.dtd 规定的格式，可以通过 Chainsaw 和 Vigilog 这两个工具来交互处理。
logback-classic 中个XMLLayout 与 log4j 1.2.15版本中XMLLayout相同，接受两个boolean参数。
locationInfo 代表是否包含caller data
properties 代表是否包含MDC信息，这两个参数默认为false。
例子如下:
<configuration>
  <appender name="FILE" class="ch.qos.logback.core.FileAppender"
    <file>test.xml</file>
    <encoder class="ch.qos.logback.core.encoder.LayoutWrappingEncoder"
      <layout class="ch.qos.logback.classic.log4j.XMLLayout"
        <locationInfo>true</locationInfo>
      </layout>
    </encoder>
  </appender>

  <root level="DEBUG"
    <appender-ref ref="FILE" />
  </root>
</configuration>



Logback access
大多数logback-access 中的layout 其实是logback-access 中的副本，提供基本相同的功能。
PatternLayout在 logback-access中的配置与classic中的基本相同，不过它提供更多适合HTTP servlet request 和 HTTP servlet response的conversion specifiers。
下面列出了access模块中，PatternLayout可用的conversion specifiers。
Conversion Word
Effect
a / remoteIP
远程主机IP地址
A / localIP	本content
b / B / bytesSent	response content的长度
h / clientHost	远程主机名
H / protocol	request请求的协议
l	远程log name。在Logback access模块中，这个converter常返回 “-“。
reqParameter{paramName}	
ßå获取指定request 中的parameter，例如：%reqParameter{input_data}
i{header} / header{header}	
获取指定request中的header，例如：%header{Referer} 
m / requestMethod	Request 请求的方法
r / requestURL	URL requested.
s / statusCode	Status code of the request.
D / elapsedTime	处理这个request的时间，时间单位：毫秒
T / elapsedSeconds	处理这个request的时间，时间单位：秒
t / date	
日志的时间，例如：%t{HH:mm:ss,SSS} %t{dd MMM yyyy ;HH:mm:ss,SSS} 
%t{dd/MMM/yyyy:HH:mm:ss Z}
u / user	Remote user.
q / queryString	Request query string, prepended with a '?'.
U / requestURI	Requested URI.
S / sessionID	Session ID.
v / server	Server name.
I / threadName	
Name of the thread which processed the request.
localPort	Local port.
reqAttribute{attributeName}	
Attribute of the request.
例如：%reqAttribute{SOME_ATTRIBUTE}
reqCookie{cookie}	
Request cookie.
%cookie{COOKIE_NAME}
responseHeader{header}	
Header of the response.
%header{Referer}
requestContent	This conversion word displays the content of the request, that is the request'sInputStream. It is used in conjunction with a TeeFilter, a javax.servlet.Filter that replaces the original HttpServletRequest by a TeeHttpServletRequest. The latter object allows access to the request's InputStream multiple times without any loss of data.
fullRequest	This converter outputs the data associated with the request, including all headers and request contents.
responseContent	This conversion word displays the content of the response, that is the response'sInputStream. It is used in conjunction with a TeeFilter, a javax.servlet.Filter that replaces the original HttpServletResponse by a TeeHttpServletResponse. The latter object allows access to the request's InputStream multiple times without any loss of data.
fullResponse	This conversion word takes all the available data associated with the response, including all headers of the response and response contents.

除了以上这些，还有一些内置格式的别名：
keyword	equivalent conversion pattern
common 或者 CLF	%h %l %u [%t] "%r" %s %b
combined	%h %l %u [%t] "%r" %s %b "%i{Referer}" "%i{User-Agent}"




HTMLLayout
logbook access 中的 HTMLLayout  默认包含以下数据
Remote IP
Date
Request URL
Status code
Content Length

下面是它的一个示例图


