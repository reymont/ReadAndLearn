

在linux上安装nginx是不是会创建名为nginx或nobody的用户和用户组_搜狗问问 
http://wenwen.sogou.com/z/q720467659.htm

要编译安装Nginx，首先我们要安装依赖包 pcre-devel 和 zlib-devel：# yum  install  pcre-devel  zlib-devel  -y
程序默认是使用 nobody 身份运行的，我们建议使用 nginx 用户来运行，首先添加Nginx组和用户，不创建家目录，不允许登陆系统
```sh
# groupadd  nginx
# useradd  -M  -s /sbin/nologin  -g  nginx  nginx
```

2
准备工作完成后就是下载编译安装Nginx了，可以从我提供的网盘下载，也可以去Nginx的官网下载。
```sh
首先解压源码包：
# tar xf nginx-1.4.4.tar.gz 
然后 cd 到解压后的目录就可以执行 ./configure 了
# cd nginx-1.4.4
指定安装目录和运行时用的属主和属组，并启用状态监控模块等
#  ./configure \
  --prefix=/usr/local/nginx   \
  --pid-path=/var/run/nginx/nginx.pid  \
  --lock-path=/var/lock/nginx.lock \
  --user=nginx \
  --group=nginx \
  --with-http_ssl_module \
  --with-http_flv_module \
  --with-http_stub_status_module \
  --with-http_gzip_static_module \
  --http-client-body-temp-path=/var/tmp/nginx/client/ \
  --http-proxy-temp-path=/var/tmp/nginx/proxy/ \
  --http-fastcgi-temp-path=/var/tmp/nginx/fcgi/ \
  --http-uwsgi-temp-path=/var/tmp/nginx/uwsgi \
  --http-scgi-temp-path=/var/tmp/nginx/scgi \
  --with-pcre
等配置完成后就可以 make && make install 了
```
