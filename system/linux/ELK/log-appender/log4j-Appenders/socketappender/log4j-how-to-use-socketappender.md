

java - log4j: How to use SocketAppender? - Stack Overflow 
https://stackoverflow.com/questions/11759196/log4j-how-to-use-socketappender
java - socket appenders - basic example step by step - Stack Overflow https://stackoverflow.com/questions/11756148/socket-appenders-basic-example-step-by-step

This one looks simple and straightforward. From the article:

Example server startup with SimpleSocketServer (from the command line):
> java -jar log4j.jar org.apache.log4j.net.SimpleSocketServer 4712 log4j-server.properties
Now all you have to do is specify your appender on the client.

Example appender:
> log4j.appender.SERVER=org.apache.log4j.net.SocketAppender
> log4j.appender.SERVER.Port=4712
> log4j.appender.SERVER.RemoteHost=loghost
> log4j.appender.SERVER.ReconnectionDelay=10000

You can run the server using

java -classpath log4j.jar org.apache.log4j.net.SimpleSocketServer 4712 log4j-server.properties
The SimpleSocketServer receives logging events sent to the specified port number by the remote SocketAppender, and logs them as if they were generated locally, according to the configuration you supply in log4j-server.properties. It's up to you to configure the relevant console/file/rolling file appenders and attach them to the relevant loggers just as you would if you were doing the logging directly in the original process rather than piping the log events over a network socket. I.e. if you're currently creating local log files with something like:

log4j.rootLogger=DEBUG, file
log4j.appender.file=org.apache.log4j.RollingFileAppender
log4j.appender.file.File=logfile.log
log4j.appender.file.MaxFileSize=1MB
log4j.appender.file.MaxBackupIndex=1
log4j.appender.file.layout=org.apache.log4j.PatternLayout
log4j.appender.file.layout.ConversionPattern=[%d] [%t] [%m]%n
then you would change it so that the sending side log4j.properties simply says

log4j.rootLogger=DEBUG, server
log4j.appender.server=org.apache.log4j.net.SocketAppender
log4j.appender.server.Port=4712
log4j.appender.server.RemoteHost=loghost
log4j.appender.server.ReconnectionDelay=10000
and the server-side log4j-server.properties contains the definitions that were previously on the sending side:

log4j.rootLogger=DEBUG, file
log4j.appender.file=org.apache.log4j.RollingFileAppender
log4j.appender.file.File=logfile.log
log4j.appender.file.MaxFileSize=1MB
log4j.appender.file.MaxBackupIndex=1
log4j.appender.file.layout=org.apache.log4j.PatternLayout
log4j.appender.file.layout.ConversionPattern=[%d] [%t] [%m]%n
In particular, note that there's no point specifying a layout on the SocketAppender on the sending side - what goes over the network is the whole logging event object, it's the receiving side that is responsible for doing the layout.