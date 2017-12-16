

log4j的各种appender - 我思故我在 - ITeye博客 
http://cjjwzs.iteye.com/blog/967217

log4j.rootLogger=DEBUG,CONSOLE,A1,im 
log4j.addivity.org.apache=true 



# 应用于控制台 

log4j.appender.CONSOLE=org.apache.log4j.ConsoleAppender 
log4j.appender.Threshold=DEBUG 
log4j.appender.CONSOLE.Target=System.out 
log4j.appender.CONSOLE.layout=org.apache.log4j.PatternLayout 
log4j.appender.CONSOLE.layout.ConversionPattern=[framework] %d - %c -%-4r [%t] %-5p %c %x - %m%n 
#log4j.appender.CONSOLE.layout.ConversionPattern=[start]%d{DATE}[DATE]%n%p[PRIORITY]%n%x[NDC]%n%t[THREAD] n%c[CATEGORY]%n%m[MESSAGE]%n%n 


#应用于文件 

log4j.appender.FILE=org.apache.log4j.FileAppender 
log4j.appender.FILE.File=file.log 
log4j.appender.FILE.Append=false 
log4j.appender.FILE.layout=org.apache.log4j.PatternLayout 
log4j.appender.FILE.layout.ConversionPattern=[framework] %d - %c -%-4r [%t] %-5p %c %x - %m%n 
# Use this layout for LogFactor 5 analysis 



# 应用于文件回滚 

log4j.appender.ROLLING_FILE=org.apache.log4j.RollingFileAppender 
log4j.appender.ROLLING_FILE.Threshold=ERROR 
log4j.appender.ROLLING_FILE.File=rolling.log 
log4j.appender.ROLLING_FILE.Append=true 
log4j.appender.ROLLING_FILE.MaxFileSize=10KB 
log4j.appender.ROLLING_FILE.MaxBackupIndex=1 
log4j.appender.ROLLING_FILE.layout=org.apache.log4j.PatternLayout 
log4j.appender.ROLLING_FILE.layout.ConversionPattern=[framework] %d - %c -%-4r [%t] %-5p %c %x - %m%n 


#应用于socket 
log4j.appender.SOCKET=org.apache.log4j.RollingFileAppender 
log4j.appender.SOCKET.RemoteHost=localhost 
log4j.appender.SOCKET.Port=5001 
log4j.appender.SOCKET.LocationInfo=true 
# Set up for Log Facter 5 
log4j.appender.SOCKET.layout=org.apache.log4j.PatternLayout 
log4j.appender.SOCET.layout.ConversionPattern=[start]%d{DATE}[DATE]%n%p[PRIORITY]%n%x[NDC]%n%t[THREAD]%n%c[CATEGORY]%n%m[MESSAGE]%n%n 


# Log Factor 5 Appender 
log4j.appender.LF5_APPENDER=org.apache.log4j.lf5.LF5Appender 
log4j.appender.LF5_APPENDER.MaxNumberOfRecords=2000 



# 发送日志给邮件 

log4j.appender.MAIL=org.apache.log4j.net.SMTPAppender 
log4j.appender.MAIL.Threshold=FATAL 
log4j.appender.MAIL.BufferSize=10 
log4j.appender.MAIL.From=xxx@www.xxx.com 
log4j.appender.MAIL.SMTPHost=www.wusetu.com 
log4j.appender.MAIL.Subject=Log4J Message 
log4j.appender.MAIL.To=xxx@www.xxx.com 
log4j.appender.MAIL.layout=org.apache.log4j.PatternLayout 
log4j.appender.MAIL.layout.ConversionPattern=[framework] %d - %c -%-4r [%t] %-5p %c %x - %m%n 



# 用于数据库 
log4j.appender.DATABASE=org.apache.log4j.jdbc.JDBCAppender 
log4j.appender.DATABASE.URL=jdbc:mysql://localhost:3306/test 
log4j.appender.DATABASE.driver=com.mysql.jdbc.Driver 
log4j.appender.DATABASE.user=root 
log4j.appender.DATABASE.password= 
log4j.appender.DATABASE.sql=INSERT INTO LOG4J (Message) VALUES ('[framework] %d - %c -%-4r [%t] %-5p %c %x - %m%n') 
log4j.appender.DATABASE.layout=org.apache.log4j.PatternLayout 
log4j.appender.DATABASE.layout.ConversionPattern=[framework] %d - %c -%-4r [%t] %-5p %c %x - %m%n 


log4j.appender.A1=org.apache.log4j.DailyRollingFileAppender 
log4j.appender.A1.File=SampleMessages.log4j 
log4j.appender.A1.DatePattern=yyyyMMdd-HH'.log4j' 
log4j.appender.A1.layout=org.apache.log4j.xml.XMLLayout 


输出到2000NT日志 
把Log4j压缩包里的NTEventLogAppender.dll拷到WINNT\SYSTEM32目录下 

log4j.logger.NTlog=FATAL, A8 
# APPENDER A8 
log4j.appender.A8=org.apache.log4j.nt.NTEventLogAppender 
log4j.appender.A8.Source=JavaTest 
log4j.appender.A8.layout=org.apache.log4j.PatternLayout 
log4j.appender.A8.layout.ConversionPattern=%-4r %-5p [%t] %37c %3x - %m%n 


#自定义Appender 

log4j.appender.im = net.cybercorlin.util.logger.appender.IMAppender 

log4j.appender.im.host = mail.cybercorlin.net 
log4j.appender.im.username = username 
log4j.appender.im.password = password 
log4j.appender.im.recipient = xxx@xxx.net 

log4j.appender.im.layout=org.apache.log4j.PatternLayout 
log4j.appender.im.layout.ConversionPattern =[framework] %d - %c -%-4r [%t] %-5p %c %x - %m%n 

http://logging.apache.org/log4j/docs/manual.html 

http://supportweb.cs.bham.ac.uk/documentation/tutorials/docsystem/build/tutorials/log4j/log4j.html