

* [转：Redis使用认证密码登录 - 502studio - 博客园 ](http://www.cnblogs.com/machanghai/p/5497043.html)

Redis默认配置是不需要密码认证的，也就是说只要连接的Redis服务器的host和port正确，就可以连接使用。这在安全性上会有一定的问题，所以需要启用Redis的认证密码，增加Redis服务器的安全性。

# 1. 修改配置文件

Redis的配置文件默认在/etc/redis.conf，找到如下行：
```conf
#requirepass foobared
```
去掉前面的注释，并修改为所需要的密码：

requirepass myPassword （其中myPassword就是要设置的密码）

# 2. 重启Redis

如果Redis已经配置为service服务，可以通过以下方式重启：

service redis restart
如果Redis没有配置为service服务，可以通过以下方式重启：

/usr/local/bin/redis-cli shutdown
/usr/local/bin/redis-server /etc/redis.conf
# 3. 登录验证

设置Redis认证密码后，客户端登录时需要使用-a参数输入认证密码，不添加该参数虽然也可以登录成功，但是没有任何操作权限。如下：

$ ./redis-cli -h 127.0.0.1 -p 6379
127.0.0.1:6379> keys *
(error) NOAUTH Authentication required.
使用密码认证登录，并验证操作权限：

$ ./redis-cli -h 127.0.0.1 -p 6379 -a myPassword
127.0.0.1:6379> config get requirepass
1) "requirepass"
2) "myPassword"
看到类似上面的输出，说明Reids密码认证配置成功。

除了按上面的方式在登录时，使用-a参数输入登录密码外。也可以不指定，在连接后进行验证：

$ ./redis-cli -h 127.0.0.1 -p 6379
127.0.0.1:6379> auth myPassword
OK
127.0.0.1:6379> config get requirepass
1) "requirepass"
2) "myPassword"
127.0.0.1:6379> 
# 4. 在命令行客户端配置密码（redis重启前有效）

前面介绍了通过redis.conf配置密码，这种配置方式需要重新启动Redis。也可以通命令行客户端配置密码，这种配置方式不用重新启动Redis。配置方式如下：

127.0.0.1:6379> config set requirepass newPassword
OK
127.0.0.1:6379> config get requirepass
1) "requirepass"
2) "newPassword"
注意：使用命令行客户端配置密码，重启Redis后仍然会使用redis.conf配置文件中的密码。

 

# 5. 在Redis集群中使用认证密码

如果Redis服务器，使用了集群。除了在master中配置密码外，也需要在slave中进行相应配置。在slave的配置文件中找到如下行，去掉注释并修改与master相同的密码即可：

```conf
# masterauth master-password
```

文章转自：http://itbilu.com/linux/management/Ey_r7mWR.html