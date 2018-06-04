

# nginx中用JSON格式记录日志的配置示例_nginx_脚本之家 
http://www.jb51.net/article/52575.htm

nginx的日志配置可以参见《nginx日志配置指令详解》一文。如果要想以json格式记录nginx日志以便logstash分析，该如何指定日志格式呢？可以按照下面的格式来实现。
定义nginx日志格式：
复制代码代码如下:

log_format logstash_json '{ "@timestamp": "$time_local", '
                         '"@fields": { '
                         '"remote_addr": "$remote_addr", '
                         '"remote_user": "$remote_user", '
                         '"body_bytes_sent": "$body_bytes_sent", '
                         '"request_time": "$request_time", '
                         '"status": "$status", '
                         '"request": "$request", '
                         '"request_method": "$request_method", '
                         '"http_referrer": "$http_referer", '
                         '"body_bytes_sent":"$body_bytes_sent", '
                         '"http_x_forwarded_for": "$http_x_forwarded_for", '
                         '"http_user_agent": "$http_user_agent" } }';
指定记录日志格式：
复制代码代码如下:

access_log  /data/logs/nginx/www.jb51.net.access.log  logstash_json;
日志输出如下：
 
不利于阅读。复制到http://jsonlint.com/美化下格式。
 
您可能感兴趣的文章:
•	nginx日志配置指令详解
•	实现Nginx中使用PHP-FPM时记录PHP错误日志的配置方法
•	nginx php-fpm中启用慢日志配置（用于检测执行较慢的PHP脚本）
•	Linux服务器nginx访问日志里出现大量http 400错误的请求分析
•	nginx访问日志并删除指定天数前的日志记录配置方法
•	nginx日志切割shell脚本
•	Python 分析Nginx访问日志并保存到MySQL数据库实例
•	nginx关闭favicon.ico、robots.txt日志记录配置
•	nginx日志分割 for linux
•	Nginx实现浏览器可实时查看访问日志的步骤详解
