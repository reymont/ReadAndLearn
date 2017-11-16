

nginx：403 forbidden 二种原因 - ^小七 - 博客园 
http://www.cnblogs.com/zengguowang/p/5504160.html

出现403 forbidden的两种原因：1.是缺少索引文件（index.html/inde.php）；2.是权限问题

一、缺少索引文件index.html/inde.php

　　比如下面的配置：

　　server {

　　　　listen 80;
　　　　server_name z.com;

　　　　location / {
　　　　　　root /home/www/zgw/;
　　　　　　index index.html;
　　　　}
　　}

　　当你在/home/www/zgw/下面没有index.html文件，此时你使用z.com来访问时，它找不到索引文件，所以提示403  forbidden

二、权限问题

　　　server {

　　　　  listen 80;
　　　　  server_name z.com;

　　　　  location / {
　　　　　　  root /home/www/zgw/;
　　　　　　  index index.html;
　　　　  }
　　  }

　　如上配置，我把web文件放置到了某个用户的加目录下面，而nginx的启动默认用户是nginx，所以对web目录没有一个读的权限，此时会报403  forbidden

　　1>.要么把web的目录权限放大

　　2>.修改nginx.conf文件，里面开头全局设置有个配置：

　　　　user  nobody; -- 改成 --> user  root root;（这里本人是改成root，你也可以把启动用户改成web目录的所有者用户）

　　　　检查是否配置正确：/usr/local/nginx/sbin/nginx -t(出现test is successful标识成功)

　　　　然后重启nginx:kill -HUP `cat /usr/local/nginx/logs/nginx.pid`，就OK了！