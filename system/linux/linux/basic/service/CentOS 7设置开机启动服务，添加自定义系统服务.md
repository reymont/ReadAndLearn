
CentOS 7设置开机启动服务，添加自定义系统服务 - CSDN博客
 http://blog.csdn.net/chenxiabinffff/article/details/51374635

 CentOS 7设置开机启动服务

建立服务文件
保存目录
设置开机自启动
其他命令
## 1.建立服务文件

文件路径

vim /usr/lib/systemd/system/nginx.service 
1
服务文件内容

1.nginx.service
```conf
[Unit]
Description=nginx - high performance web server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s stop

[Install]
WantedBy=multi-user.target
```

2.mysql.service
```conf
[Unit]
Description=mysql
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
ExecStart=/usr/local/mysql/support-files/mysql.server start
#ExecReload=/usr/local/mysql/support-files/mysql.server restart
#ExecStop=/usr/local/mysql/support-files/mysql.server stop
#PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

## 3.php-fpm.service
```conf
[Unit]
Description=php
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
ExecStart=/usr/local/php/sbin/php-fpm

[Install]
WantedBy=multi-user.target
```


## 4.redis.service
```conf
[Unit]
Description=Redis
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
ExecStart=/usr/local/bin/redis-server /etc/redis.conf
ExecStop=kill -INT `cat /tmp/redis.pid`
User=www
Group=www

[Install]
WantedBy=multi-user.target
```

## 5.supervisord.service
```conf
[Unit]
Description=Process Monitoring and Control Daemon
After=rc-local.service

[Service]
Type=forking
ExecStart=/usr/bin/supervisord -c /etc/supervisord.conf
SysVStartPriority=99

[Install]
WantedBy=multi-user.target
```
文件内容解释

[Unit]:服务的说明
Description:描述服务
After:描述服务类别

[Service]服务运行参数的设置
Type=forking是后台运行的形式
ExecStart为服务的具体运行命令
ExecReload为重启命令
ExecStop为停止命令
PrivateTmp=True表示给服务分配独立的临时空间
注意：启动、重启、停止命令全部要求使用绝对路径

[Install]服务安装的相关设置，可设置为多用户
2.保存目录

以754的权限保存在目录：

/usr/lib/systemd/system 

3.设置开机自启动

任意目录下执行

systemctl enable nginx.service 

4.其他命令
```sh
# 启动nginx服务
systemctl start nginx.service
# 设置开机自启动
systemctl enable nginx.service
# 停止开机自启动
systemctl disable nginx.service
# 查看服务当前状态
systemctl status nginx.service
# 重新启动服务
systemctl restart nginx.service
# 查看所有已启动的服务
systemctl list-units --type=service
```