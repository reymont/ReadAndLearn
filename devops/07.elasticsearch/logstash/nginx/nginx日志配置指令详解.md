

# nginx日志配置指令详解_nginx_脚本之家
 http://www.jb51.net/article/52573.htm

日志对于统计排错来说非常有利的。本文总结了nginx日志相关的配置如access_log、log_format、open_log_file_cache、log_not_found、log_subrequest、rewrite_log、error_log。
nginx有一个非常灵活的日志记录模式。每个级别的配置可以有各自独立的访问日志。日志格式通过log_format命令来定义。ngx_http_log_module是用来定义请求日志格式的。
1. access_log指令
语法: access_log path [format [buffer=size [flush=time]]];
复制代码代码如下:

access_log path format gzip[=level] [buffer=size] [flush=time];
access_log syslog:server=address[,parameter=value] [format];
access_log off;
默认值: access_log logs/access.log combined;
配置段: http, server, location, if in location, limit_except
gzip压缩等级。
buffer设置内存缓存区大小。
flush保存在缓存区中的最长时间。
不记录日志：access_log off;
使用默认combined格式记录日志：access_log logs/access.log 或 access_log logs/access.log combined;
2. log_format指令
语法: log_format name string …;
默认值: log_format combined “…”;
配置段: http
name表示格式名称，string表示等义的格式。log_format有一个默认的无需设置的combined日志格式，相当于apache的combined日志格式，如下所示：
复制代码代码如下:

log_format  combined  '$remote_addr - $remote_user  [$time_local]  '
                                   ' "$request"  $status  $body_bytes_sent  '
                                   ' "$http_referer"  "$http_user_agent" ';
如果nginx位于负载均衡器，squid，nginx反向代理之后，web服务器无法直接获取到客户端真实的IP地址了。 $remote_addr获取反向代理的IP地址。反向代理服务器在转发请求的http头信息中，可以增加X-Forwarded-For信息，用来记录 客户端IP地址和客户端请求的服务器地址。如下所示：
复制代码代码如下:

log_format  porxy  '$http_x_forwarded_for - $remote_user  [$time_local]  '
                             ' "$request"  $status $body_bytes_sent '
                             ' "$http_referer"  "$http_user_agent" ';
日志格式允许包含的变量注释如下：
复制代码代码如下:

$remote_addr, $http_x_forwarded_for 记录客户端IP地址
$remote_user 记录客户端用户名称
$request 记录请求的URL和HTTP协议
$status 记录请求状态
$body_bytes_sent 发送给客户端的字节数，不包括响应头的大小； 该变量与Apache模块mod_log_config里的“%B”参数兼容。
$bytes_sent 发送给客户端的总字节数。
$connection 连接的序列号。
$connection_requests 当前通过一个连接获得的请求数量。
$msec 日志写入时间。单位为秒，精度是毫秒。
$pipe 如果请求是通过HTTP流水线(pipelined)发送，pipe值为“p”，否则为“.”。
$http_referer 记录从哪个页面链接访问过来的
$http_user_agent 记录客户端浏览器相关信息
$request_length 请求的长度（包括请求行，请求头和请求正文）。
$request_time 请求处理时间，单位为秒，精度毫秒； 从读入客户端的第一个字节开始，直到把最后一个字符发送给客户端后进行日志写入为止。
$time_iso8601 ISO8601标准格式下的本地时间。
$time_local 通用日志格式下的本地时间。
发送给客户端的响应头拥有“sent_http_”前缀。 比如$sent_http_content_range。
实例如下：
复制代码代码如下:

http {
 log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                                        '"$status" $body_bytes_sent "$http_referer" '
                                        '"$http_user_agent" "$http_x_forwarded_for" '
                                        '"$gzip_ratio" $request_time $bytes_sent $request_length';
 log_format srcache_log '$remote_addr - $remote_user [$time_local] "$request" '
                                '"$status" $body_bytes_sent $request_time $bytes_sent $request_length '
                                '[$upstream_response_time] [$srcache_fetch_status] [$srcache_store_status] [$srcache_expire]';
 open_log_file_cache max=1000 inactive=60s;
 server {
  server_name ~^(www\.)?(.+)$;
  access_log logs/$2-access.log main;
  error_log logs/$2-error.log;
  location /srcache {
   access_log logs/access-srcache.log srcache_log;
  }
 }
}
3. open_log_file_cache指令
语法: open_log_file_cache max=N [inactive=time] [min_uses=N] [valid=time];
open_log_file_cache off;
默认值: open_log_file_cache off;
配置段: http, server, location
对于每一条日志记录，都将是先打开文件，再写入日志，然后关闭。可以使用open_log_file_cache来设置日志文件缓存(默认是off)，格式如下：
参数注释如下：
max:设置缓存中的最大文件描述符数量，如果缓存被占满，采用LRU算法将描述符关闭。
inactive:设置存活时间，默认是10s
min_uses:设置在inactive时间段内，日志文件最少使用多少次后，该日志文件描述符记入缓存中，默认是1次
valid:设置检查频率，默认60s
off：禁用缓存
实例如下：
复制代码代码如下:
open_log_file_cache max=1000 inactive=20s valid=1m min_uses=2;
4. log_not_found指令
语法: log_not_found on | off;
默认值: log_not_found on;
配置段: http, server, location
是否在error_log中记录不存在的错误。默认是。
5. log_subrequest指令
语法: log_subrequest on | off;
默认值: log_subrequest off;
配置段: http, server, location
是否在access_log中记录子请求的访问日志。默认不记录。
6. rewrite_log指令
由ngx_http_rewrite_module模块提供的。用来记录重写日志的。对于调试重写规则建议开启。 Nginx重写规则指南
语法: rewrite_log on | off;
默认值: rewrite_log off;
配置段: http, server, location, if
启用时将在error log中记录notice级别的重写日志。
7. error_log指令
语法: error_log file | stderr | syslog:server=address[,parameter=value] [debug | info | notice | warn | error | crit | alert | emerg];
默认值: error_log logs/error.log error;
配置段: main, http, server, location
配置错误日志。
您可能感兴趣的文章:
•	nginx 多站点配置方法集合
•	CentOS+Nginx+PHP+MySQL详细配置(图解)
•	nginx 作为反向代理实现负载均衡的例子
•	一句简单命令重启nginx
•	Nginx下301重定向域名的方法小结
•	Nginx伪静态配置和常用Rewrite伪静态规则集锦
•	Nginx 下配置SSL证书的方法
•	NGINX下配置404错误页面的方法分享
•	Nginx和PHP-FPM的启动、重启、停止脚本分享
•	nginx rewrite 伪静态配置参数和使用例子
•	Nginx 启动脚本/重启脚本代码
•	nginx 如何实现读写限流的方法
