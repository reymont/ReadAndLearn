
centos 6.4 server 安装nginx - bigwhiteshark(云飞扬) - 博客园 
http://www.cnblogs.com/jenry/archive/2013/06/13/3134414.html

1.环境准备
yum -y install gcc gcc-c++ autoconf automake make
yum -y install zlib zlib-devel openssl openssl--devel pcre pcre-devel 
 
yum install nginx
 
2.下载 nginx 
wget  http://nginx.org/download/nginx-1.2.1.tar.gz  
 
tar –xzvf nginx-1.2.1.tar.gz
cd nginx-1.0.2
./configure--sbin-path=/root/soft/nginx
 
configure 支持下面的选项： 

--prefix=<path> - Nginx安装路径。如果没有指定，默认为 /usr/local/nginx。 

--sbin-path=<path> - Nginx可执行文件安装路径。只能安装时指定，如果没有指定，默认为<prefix>/sbin/nginx。 

--conf-path=<path> - 在没有给定-c选项下默认的nginx.conf的路径。如果没有指定，默认为<prefix>/conf/nginx.conf。 

--pid-path=<path> - 在nginx.conf中没有指定pid指令的情况下，默认的nginx.pid的路径。如果没有指定，默认为 <prefix>/logs/nginx.pid。 

--lock-path=<path> - nginx.lock文件的路径。 

--error-log-path=<path> - 在nginx.conf中没有指定error_log指令的情况下，默认的错误日志的路径。如果没有指定，默认为 <prefix>/logs/error.log。 

--http-log-path=<path> - 在nginx.conf中没有指定access_log指令的情况下，默认的访问日志的路径。如果没有指定，默认为 <prefix>/logs/access.log。 

--user=<user> - 在nginx.conf中没有指定user指令的情况下，默认的nginx使用的用户。如果没有指定，默认为 nobody。 

--group=<group> - 在nginx.conf中没有指定user指令的情况下，默认的nginx使用的组。如果没有指定，默认为 nobody。 

--builddir=DIR - 指定编译的目录 

--with-rtsig_module - 启用 rtsig 模块 


3.最后安装 
make && make install
 
我们测试一下nginx是否正常工作。因为我们把nginx的二进制执行文件配置安装在 /usr/local/sbin/nginx  (前面的configure参数 --sbin-path=/usr/local/sbin/nginx )，目录/usr/local/sbin/默认在linux的PATH环境变量里，所以我们可以省略路径执行它：
 
[root@fsvps nginx-1.2.1]# nginx
它不会有任何信息显示。打开浏览器，通过IP地址访问你的nginx站点，如果看到这样一行大黑字，就证明nginx已经工作了：
 
Welcome to nginx!
 
看上去很简陋，只是因为没有给它做漂亮的页面。我们来简单配置一下它的运行配置。我们configure的参数--conf-path=/usr/local/conf/nginx/nginx.conf 这就是它的配置文件。我们去看看。
 
[root@fsvps nginx-1.2.1]# cd /usr/local/conf/nginx/
[root@fsvps nginx]# ls
fastcgi.conf          fastcgi_params.default  mime.types          nginx.conf.default   uwsgi_params
fastcgi.conf.default  koi-utf                 mime.types.default  scgi_params          uwsgi_params.default
fastcgi_params        koi-win                 nginx.conf          scgi_params.default  win-utf
如果这里没有nginx.conf,但有个 nginx.conf.default，我们用它复制个副本nginx.conf （早期版本默认是没有nginx.conf的）
 
用你熟悉的编辑器打开它，vi nginx.conf
找到如下的部分，大概在35行，
 
server {
        listen       80 default;
        server_name  localhost;
        root /var/www/html/default;
        #charset koi8-r;
 
        #access_log  logs/host.access.log  main;
 
        location / {
        #    root   html;
            index  index.html index.htm;
        }
....................
}
如上红色加粗显示部分，做三处修改：
 
listen 80 后插入“空格default”
在里面加入一行 root /var/www/html/default;
注释掉root html;一行
上面的server{....}是定义的一台虚拟主机，我们刚加入的一行是定义这个虚假主机的web目录。listen 行的default是表示这一个server{...}节点是默认的虚假主机（默认站点）
 
执行 nginx -t 测试刚才的nginx配置文件是否有语法错误：
 
[root@fsvps nginx]# nginx -t
nginx: the configuration file /usr/local/conf/nginx/nginx.conf syntax is ok
nginx: configuration file /usr/local/conf/nginx/nginx.conf test is successful
显示没有错误，检测通过。如果不是这样，请返回仔细检查你的配置文件是否哪里写错了，注意行尾要有英文分号。
 
我们在硬盘上创建这个目录：
 
[root@fsvps nginx]# mkdir -p /var/www/html/default
写一个html文件index.html 到/var/www/html/default目录里，使用你熟悉的编辑器，随便写什么内容、怎么排版。
 
然后让nginx重新加载配置文件，看看刚才创作的html页面效果如何。
 
常见错误FAQ
1) 如果通常访问时看到还是 Welcome to nginx! ,请返回检查，重点在这几处：
 
请确认/var/www/html/default 目录下有你创作的index.html 文件？
检查该文件权限，other用户是否有读的权限？ 如果不懂linux文件权限，请执行 chmod 755 /var/www/html/default/index.html
检查nginx.conf配置文件里，只否只有一个server{...} 节点，并且该节点里是否有 listen       80 default;   一行，注意其中要有 default 。
检查上述server{...}节点里是否有 root /var/www/html/default; 一行，注意路径是拼写是否正确。
检查其中 location / {...} 节点里的 #    root   html;  一行，是否注释掉了。
2) 如果看到的是 404 Not Found 或者“找不到该页面”类似的提示：
 
检查上述 location / {...} 节点中是否有这一行 index  index.html index.htm;
3) 如果访问时，显示“找不到服务器”、“无法连接到服务器”这样的错误：
 
运行检查nginx进程在运行，运行ps aux |grep nginx 命令，正常情况有如下三条：
nginx: master process nginx
nginx: worker process
grep nginx
如果只有第三条，请运行nginx 重新启用nginx，如有报错请照说明检查。一般是配置文件的语法错误。
请运行nginx -t 检查配置文件是否有语法错误。
[tips] location / {...} 节点里的 #    root   html;  一行，不注释掉也可以：请把你创造的index.html 放到/var/www/html/default/html目录下。
 
至此，我们的nginx也可以正常工作了。
 
查看nginx进程
ps –ef | grep nginx  
 
 
4.设置成系统开机服务： 
在 /etc/init.d/  目录下创建 nginx 文件 内容如下：
 

#!/bin/bash
# nginx Startup script for the Nginx HTTP Server
# this script create it by gcec at 2009.10.22.
# it is v.0.0.1 version.
# if you find any errors on this scripts,please contact gcec cyz.
# and send mail to support at gcec dot cc.
#
# chkconfig: - 85 15
# description: Nginx is a high-performance web and proxy server.
#              It has a lot of features, but it's not for everyone.
# processname: nginx
# pidfile: /var/run/nginx.pid
# config: /usr/local/nginx/conf/nginx.conf
 
nginxd=/app/nginx/sbin/nginx
nginx_config=/app/nginx/conf/nginx.conf
nginx_pid=/var/run/nginx.pid
 
RETVAL=0
prog="nginx"
 
# Source function library.
. /etc/rc.d/init.d/functions
 
# Source networking configuration.
. /etc/sysconfig/network
 
# Check that networking is up.
[ ${NETWORKING} = "no" ] && exit 0
 
[-x $nginxd ]||exit0
 
 
# Start nginx daemons functions.
start() {
 
if[-e $nginx_pid ];then
   echo "nginx already running...."
   exit1
fi
 
   echo -n $"Starting $prog: "
   daemon $nginxd -c ${nginx_config}
   RETVAL=$?
   echo
   [ $RETVAL =0]&& touch /var/lock/subsys/nginx
   return $RETVAL
 
}
 
 
# Stop nginx daemons functions.
stop() {
        echo -n $"Stopping $prog: "
        killproc $nginxd
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && rm -f /var/lock/subsys/nginx /var/run/nginx.pid
}
 
 
# reload nginx service functions.
reload() {
 
    echo -n $"Reloading $prog: "
    #kill -HUP `cat ${nginx_pid}`
    killproc $nginxd -HUP
    RETVAL=$?
    echo
 
}
 
# See how we were called.
case "$1" in
start)
        start
        ;;
 
stop)
        stop
        ;;
 
reload)
        reload
        ;;
 
restart)
        stop
        start
        ;;
 
status)
        status $prog
        RETVAL=$?
        ;;
*)
        echo $"Usage: $prog {start|stop|restart|reload|status|help}"
        exit1
esac
 
exit $RETVAL
 
chkco
分类: Linux/unix