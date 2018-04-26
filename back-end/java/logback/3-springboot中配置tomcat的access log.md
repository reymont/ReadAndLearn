springboot中配置tomcat的access log - 那啥快看 - 博客园 https://www.cnblogs.com/shamo89/p/8134865.html

springboot中配置tomcat的access log

在tomcat的access中打印出请求的情况可以帮助我们分析问题，通常比较关注的有访问IP、线程号、访问url、返回状态码、访问时间、持续时间。

在Spring boot中使用了内嵌的tomcat，可以通过server.tomcat.accesslog配置tomcat 的access日志，这里就以Spring boot 1.5.3为例。

复制代码
server.tomcat.accesslog.buffered=true # Buffer output such that it is only flushed periodically.
server.tomcat.accesslog.directory=logs # Directory in which log files are created. Can be relative to the tomcat base dir or absolute.
server.tomcat.accesslog.enabled=false # Enable access log.
server.tomcat.accesslog.file-date-format=.yyyy-MM-dd # Date format to place in log file name.
server.tomcat.accesslog.pattern=common # Format pattern for access logs.
server.tomcat.accesslog.prefix=access_log # Log file name prefix.
server.tomcat.accesslog.rename-on-rotate=false # Defer inclusion of the date stamp in the file name until rotate time.
server.tomcat.accesslog.request-attributes-enabled=false # Set request attributes for IP address, Hostname, protocol and port used for the request.
server.tomcat.accesslog.rotate=true # Enable access log rotation.
server.tomcat.accesslog.suffix=.log # Log file name suffix.
复制代码
比较常用的有（省略了前缀server.tomcat.accesslog.）：

enabled，取值true、false，需要accesslog时设置为true
directory，指定access文件的路径
pattern，定义日志的格式，后续详述
rotate，指定是否启用日志轮转。默认为true。这个参数决定是否需要切换切换日志文件，如果被设置为false，则日志文件不会切换，即所有文件打到同一个日志文件中，并且file-date-format参数也会被忽略
pattern的配置：

%a - Remote IP address，远程ip地址，注意不一定是原始ip地址，中间可能经过nginx等的转发
%A - Local IP address，本地ip
%b - Bytes sent, excluding HTTP headers, or '-' if no bytes were sent
%B - Bytes sent, excluding HTTP headers
%h - Remote host name (or IP address if enableLookups for the connector is false)，远程主机名称(如果resolveHosts为false则展示IP)
%H - Request protocol，请求协议
%l - Remote logical username from identd (always returns '-')
%m - Request method，请求方法（GET，POST）
%p - Local port，接受请求的本地端口
%q - Query string (prepended with a '?' if it exists, otherwise an empty string
%r - First line of the request，HTTP请求的第一行（包括请求方法，请求的URI）
%s - HTTP status code of the response，HTTP的响应代码，如：200,404
%S - User session ID
%t - Date and time, in Common Log Format format，日期和时间，Common Log Format格式
%u - Remote user that was authenticated
%U - Requested URL path
%v - Local server name
%D - Time taken to process the request, in millis，处理请求的时间，单位毫秒
%T - Time taken to process the request, in seconds，处理请求的时间，单位秒
%I - current Request thread name (can compare later with stacktraces)，当前请求的线程名，可以和打印的log对比查找问题
Access log 也支持将cookie、header、session或者其他在ServletRequest中的对象信息打印到日志中，其配置遵循Apache配置的格式（{xxx}指值的名称）：

%{xxx}i for incoming headers，request header信息
%{xxx}o for outgoing response headers，response header信息
%{xxx}c for a specific cookie
%{xxx}r xxx is an attribute in the ServletRequest
%{xxx}s xxx is an attribute in the HttpSession
%{xxx}t xxx is an enhanced SimpleDateFormat pattern (see Configuration Reference document for details on supported time patterns)
Access log内置了两个日志格式模板，可以直接指定pattern为模板名称，如：

server.tomcat.accesslog.pattern=common
common - %h %l %u %t "%r" %s %b，依次为：远程主机名称，远程用户名，被认证的远程用户，日期和时间，请求的第一行，response code，发送的字节数
combined - %h %l %u %t "%r" %s %b "%{Referer}i" "%{User-Agent}i"，依次为：远程主机名称，远程用户名，被认证的远程用户，日期和时间，请求的第一行，response code，发送的字节数，request header的Referer信息，request header的User-Agent信息。
除了内置的模板，我们常用的配置有：

%t %a "%r" %s (%D ms)，日期和时间，请求来自的IP（不一定是原始IP），请求第一行，response code，响应时间（毫秒），样例：[21/Mar/2017:00:06:40 +0800] 127.0.0.1 POST /bgc/syncJudgeResult HTTP/1.0 200 63，这里请求来自IP就是经过本机的nginx转发的。
%t [%I] %{X-Forwarded-For}i %a %r %s (%D ms)，日期和时间，线程名，原始IP，请求来自的IP（不一定是原始IP），请求第一行，response code，响应时间（毫秒），样例：[21/Apr/2017:00:24:40 +0800][http-nio-7001-exec-4] 10.125.15.1 127.0.0.1 POST /bgc/syncJudgeResult HTTP/1.0 200 5，这里的第一个IP是Nginx配置了X-Forwarded-For记录了原始IP。
这里简要介绍下上面用到的HTTP请求头X-Forwarded-For，它是一个 HTTP 扩展头部，用来表示 HTTP 请求端真实 IP，其格式为：X-Forwarded-For: client, proxy1, proxy2，其中的值通过一个逗号+空格把多个IP地址区分开，最左边（client）是最原始客户端的IP地址，代理服务器每成功收到一个请求，就把请求来源IP地址添加到右边。