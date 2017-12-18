

Log4j扩展使用--日志格式化器Layout - CSDN博客 
http://blog.csdn.net/fwh66/article/details/54581231

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