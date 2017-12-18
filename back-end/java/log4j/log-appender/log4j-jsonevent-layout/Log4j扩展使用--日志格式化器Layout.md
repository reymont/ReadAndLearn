

Log4j扩展使用--日志格式化器Layout - CSDN博客 
http://blog.csdn.net/fwh66/article/details/54581231

Layout：格式化输出日志信息
OK，前面我已经知道了。Appender必须使用一个与之相关联的Layout，这样才能知道怎样格式化输出日志信息。
日志格式化器Layout负责格式化日志信息，方法log.error()的参数只包含日志信息，利用Layout可以附加其他信息，以输出更多的信息或者布局显示。

Log4j具有几种类型的Layout
PatternLayout：根据指定的转换模式格式化日志输出
HTMLLayout：格式化日志输出为HTML表格
XMLLayout：格式化日志输出为XML文件
SimpleLayout：以一种非常简单的方式格式化日志输出
TTCCLayout：包含日志产生的时间、线程、类别等信息

实际编码中，我们使用最多的就是PatternLayout布局。
这里我们详细整理下该日志格式化器。PatternLayout是最常用的格式化器，用户可以自定义信息，比如日期，时间，所在的线程，类型，方法名等等。
下面是一份PatternLayout的配置文件。
[html] view plain copy  在CODE上查看代码片派生到我的代码片
# 以下是rootLogger的配置，子类默认继承，但是子类重写下面配置=rootLogger+自己配置，我晕  
#输出到控制台     
log4j.appender.console=org.apache.log4j.ConsoleAppender    
#设置输出样式     
log4j.appender.console.layout=org.apache.log4j.PatternLayout   
#日志输出信息格式为  
log4j.appender.console.layout.ConversionPattern=[%-d{yyyy-MM-dd HH:mm:ss}]-[%t-%5p]-[%C-%M(%L)]： %m%n   
#DEBUG以上级别输出，Threshold，入口，临界值  
#log4j.appender.console.Threshold=DEBUG  
#日志编码方式  
#log4j.appender.console.Encoding=UTF-8  
#是否立即输出  
#log4j.appender.console.ImmediateFlush=true  
#使用System.error作为输出  
#log4j.appender.console.Target=System.error  
使用ConversionPattern自定义样式
关于ConversionPattern该属性的说明，该属性设置了日志输出的格式，具体的参数如下：
[html] view plain copy  在CODE上查看代码片派生到我的代码片
#自定义样式     
#%c 输出所属的类目，通常就是所在类的全名   
#%C 输出Logger所在类的名称，通常就是所在类的全名   
#%d 输出日志时间点的日期或时间，默认格式为ISO8601，也可以在其后指定格式，比如：%d{yyy MMM dd HH:mm:ss , SSS}，%d{ABSOLUTE}，%d{DATE}  
#%F 输出所在类的类名称，只有类名。  
#%l 输出语句所在的行数，包括类名+方法名+文件名+行数  
#%L 输出语句所在的行数，只输出数字  
#%m 输出代码中指定的讯息，如log(message)中的message  
#%M 输出方法名  
#%p 输出日志级别，即DEBUG，INFO，WARN，ERROR，FATAL  
#%r 输出自应用启动到输出该log信息耗费的毫秒数  
#%t 输出产生该日志事件的线程名  
#%n 输出一个回车换行符，Windows平台为“/r/n”，Unix平台为“/n”  
#%% 用来输出百分号“%”  
#log4j.appender.Linkin.layout.ConversionPattern=%n[%l%d{yy/MM/dd HH:mm:ss:SSS}][%C-%M] %m    
#log4j.appender.Linkin.layout.ConversionPattern=%-d{yyyy-MM-dd HH:mm:ss}[%C]-[%p] %m%n     
#log4j.appender.Linkin.layout.ConversionPattern = %d{ABSOLUTE} %5p %t %c{2}:%L - %m%n  
关于该PatternLayout格式化器的补充：
1，Log4j能输出形形色色的参数，这些参数内容的长度不同。比如%C输出的类名，有的类名很长，有的类名很短，这会导致日志比较凌乱。为了解决该问题，Log4j允许设置输出内容的长度等，不够长的会用空格补齐，使输出内容变得整齐。
2，设置方法是在%与参数符号间添加数字，例如%20p，%-20p等。正数表示右对齐，负数表示左对齐，数字表示最小宽度，不足时用空格补齐。
3，还可以设置最大宽度，如果超出，则截取，方法是用小数点+数字设置，例如%.30p。





关于HTMLLayout，XMLLayout这里只做一个简单的介绍。
HTMLLayout将日志格式化为HTML代码，输出到文件后，可以直接用浏览器浏览。使用该格式化器时，日志文件后缀一般为.html。
配置如下：
[html] view plain copy  在CODE上查看代码片派生到我的代码片
#输出到文件(这里默认为追加方式)     
log4j.appender.file=org.apache.log4j.FileAppender   
#输出文件位置  
log4j.appender.file.File=/Users/LinkinPark/WorkSpace/linkin-log-test/log/log4j.log  
#是否在原日志基础上追加输出日志。true，默认，追加。false，清掉原来日志重新添加  
log4j.appender.file.Append=true  
#样式为TTCCLayout     
#log4j.appender.file.layout=org.apache.log4j.TTCCLayout  
#样式为HTMLLayout  
log4j.appender.file.layout=org.apache.log4j.HTMLLayout  
log4j.appender.file.File=/Users/LinkinPark/WorkSpace/linkin-log-test/log/log4j.html  
#log4j.appender.file.layout=org.apache.log4j.PatternLayout  
#log4j.appender.file.layout.ConversionPattern=[%-d{yyyy-MM-dd HH:mm:ss}]-[%t-%5p]-[%C-%M(%L)]： %m%n    
运行我们的测试代码，然后生成了log4j.html。用浏览器打开查看日志内容：

XMLLayout把日志内容格式化成XML文件，XML文件的好处就是解析比较容易，因为有现成的DOM技术和SAX技术。配置时候只需要将appender的layout设置为XMLLayout即可。
值得注意的是：XMLLayout生成的并不是完整的XML文件，而只是XML文件的一部分，因此是无法直接打开和解析的。

OK，到目前为止，有关Log4j的使用和配置我都整理完了。这里来总结一下：
1，Java代码中获取Logger。通过org.apache.log4j.Logger类的getLogger()方法即可。
[java] view plain copy  在CODE上查看代码片派生到我的代码片
public static Logger log = Logger.getLogger(Log4jTest1.class);  
当然如果我们在配置Log4j的时候，如果配置文件路径没有按照约定加入到classpath中的话，我们也可以通过Java代码去加载该配置文件。
[java] view plain copy  在CODE上查看代码片派生到我的代码片
BasicConfigurator.configure()：自动快速地使用缺省Log4j环境。  
PropertyConfigurator.configure(StringconfigFilename)：读取使用Java的特性文件编写的配置文件。  
DOMConfigurator.configure(Stringfilename)：读取XML形式的配置文件。  
最后我们就可以直接使用日志对象来输出日志了。调用log对象的各种输出日志方法，比如debug()，比如info()方法等等。
2，配置Log4j。要使用配置文件才能配置Log4j→log4j.xml配置文件后者log4j.properties配置文件
通常，我们都提供一个名为log4j.properties的文件，在第一次调用到Log4J时，Log4J会在类路径（../web-inf/class/当然也可以放到其它任何目录，只要该目录被包含到类路径中即可）中定位这个文件，并读入这个文件完成的配置。这个配置文
件告诉Log4J以什么样的格式、把什么样的信息、输出到什么地方。

最后这里贴出一份最完整的log4j.properties文件。
[html] view plain copy  在CODE上查看代码片派生到我的代码片
#   可设置级别：TRACE→DEBUG→INFO→WARNING→ERROR→FATAL→OFF  
#   高级别level会屏蔽低级别level。  
#   debug：显示debug、info、error     
#   info：显示info、error     
  
#log4j.rootLogger=DEBUG,console,file  
#子类重新定义日志级别，logger的名字是日志类的权限类名  
#log4j.logger.org.linkinpark.commons.logtest.Log4jTest1=ERROR  
#子类重新定义日志级别，category的名字是日志类的包名，可以将category理解为Java的package。  
#log4j.category.org.linkinpark.commons.logtest1=ERROR,file,rolling_file,daily_rolling_file  
log4j.rootLogger=DEBUG,console,daily_rolling_file  
  
# 以下是rootLogger的配置，子类默认继承，但是子类重写下面配置=rootLogger+自己配置，我晕  
#输出到控制台     
log4j.appender.console=org.apache.log4j.ConsoleAppender    
#设置输出样式     
log4j.appender.console.layout=org.apache.log4j.PatternLayout   
#日志输出信息格式为  
log4j.appender.console.layout.ConversionPattern=[%-d{yyyy-MM-dd HH:mm:ss}]-[%t-%5p]-[%C-%M(%L)]： %m%n   
#DEBUG以上级别输出，Threshold，入口，临界值  
#log4j.appender.console.Threshold=DEBUG  
#日志编码方式  
#log4j.appender.console.Encoding=UTF-8  
#是否立即输出  
#log4j.appender.console.ImmediateFlush=true  
#使用System.error作为输出  
#log4j.appender.console.Target=System.error  
  
#输出到文件(这里默认为追加方式)     
log4j.appender.file=org.apache.log4j.FileAppender   
#输出文件位置  
log4j.appender.file.File=/Users/LinkinPark/WorkSpace/linkin-log-test/log/log4j.log  
#是否在原日志基础上追加输出日志。true，默认，追加。false，清掉原来日志重新添加  
log4j.appender.file.Append=true  
#样式为TTCCLayout     
#log4j.appender.file.layout=org.apache.log4j.TTCCLayout  
#样式为HTMLLayout  
log4j.appender.file.layout=org.apache.log4j.HTMLLayout  
log4j.appender.file.File=/Users/LinkinPark/WorkSpace/linkin-log-test/log/log4j.html  
#log4j.appender.file.layout=org.apache.log4j.PatternLayout  
#log4j.appender.file.layout.ConversionPattern=[%-d{yyyy-MM-dd HH:mm:ss}]-[%t-%5p]-[%C-%M(%L)]： %m%n    
  
#按大小滚动文件(这里默认为追加方式)     
log4j.appender.rolling_file=org.apache.log4j.RollingFileAppender   
#输出文件位置  
log4j.appender.rolling_file.File=/Users/LinkinPark/WorkSpace/linkin-log-test/log/rolling_log4j.log  
log4j.appender.rolling_file.Append=true  
#文件达到最大值自动更名  
log4j.appender.rolling_file.MaxFileSize=1KB  
#最多备份100个文件  
log4j.appender.rolling_file.MaxBackupIndex=100  
log4j.appender.rolling_file.layout=org.apache.log4j.PatternLayout  
log4j.appender.rolling_file.layout.ConversionPattern=[%-d{yyyy-MM-dd HH:mm:ss}]-[%t-%5p]-[%C-%M(%L)]： %m%n  
  
#按日期滚动文件  
log4j.appender.daily_rolling_file=org.apache.log4j.DailyRollingFileAppender   
#输出文件位置  
log4j.appender.daily_rolling_file.File=/Users/LinkinPark/WorkSpace/linkin-log-test/log/daily_rolling_log4j.log  
#文件滚动日期格式  
#每天：.YYYY-MM-dd（默认）  
#每星期：.YYYY-ww  
#每月：.YYYY-MM  
#每隔半天：.YYYY-MM-dd-a  
#每小时：.YYYY-MM-dd-HH  
#每分钟：.YYYY-MM-dd-HH-mm  
#log4j.appender.daily_rolling_file.DatePattern=.yyyy-MM-dd  
log4j.appender.daily_rolling_file.DatePattern=.YYYY-MM-dd-HH-mm  
log4j.appender.daily_rolling_file.layout=org.apache.log4j.PatternLayout  
log4j.appender.daily_rolling_file.layout.ConversionPattern=[%-d{yyyy-MM-dd HH:mm:ss}]-[%t-%5p]-[%C-%M(%L)]： %m%n  
  
#自定义样式     
#%c 输出所属的类目，通常就是所在类的全名   
#%C 输出Logger所在类的名称，通常就是所在类的全名   
#%d 输出日志时间点的日期或时间，默认格式为ISO8601，也可以在其后指定格式，比如：%d{yyy MMM dd HH:mm:ss , SSS}，%d{ABSOLUTE}，%d{DATE}  
#%F 输出所在类的类名称，只有类名。  
#%l 输出语句所在的行数，包括类名+方法名+文件名+行数  
#%L 输出语句所在的行数，只输出数字  
#%m 输出代码中指定的讯息，如log(message)中的message  
#%M 输出方法名  
#%p 输出日志级别，即DEBUG，INFO，WARN，ERROR，FATAL  
#%r 输出自应用启动到输出该log信息耗费的毫秒数  
#%t 输出产生该日志事件的线程名  
#%n 输出一个回车换行符，Windows平台为“/r/n”，Unix平台为“/n”  
#%% 用来输出百分号“%”  
#log4j.appender.Linkin.layout.ConversionPattern=%n[%l%d{yy/MM/dd HH:mm:ss:SSS}][%C-%M] %m    
#log4j.appender.Linkin.layout.ConversionPattern=%-d{yyyy-MM-dd HH:mm:ss}[%C]-[%p] %m%n     
#log4j.appender.Linkin.layout.ConversionPattern = %d{ABSOLUTE} %5p %t %c{2}:%L - %m%n  