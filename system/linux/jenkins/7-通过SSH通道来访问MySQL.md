通过SSH通道来访问MySQL_数据库技术_Linux公社-Linux系统门户网站 https://www.linuxidc.com/Linux/2012-09/70040.htm
https://www.howtogeek.com/howto/ubuntu/access-your-mysql-server-remotely-over-ssh/

许多时候当要使用Mysql时，会遇到如下情况：
1. 信息比较重要，希望通信被加密。
2. 一些端口，比如3306端口，被路由器禁用。

对第一个问题的一个比较直接的解决办法就是更改mysql的代码，或者是使用一些证书，不过这种办法显然不是很简单。

这里要介绍另外一种方法，就是利用SSH通道来连接远程的Mysql，方法相当简单。

一 建立SSH通道

只需要在本地键入如下命令：

ssh -fNg -L 3307:127.0.0.1:3306 myuser@remotehost.com

The command tells ssh to log in to remotehost.com as myuser, go into the background (-f) and not execute any remote command (-N), and set up port-forwarding (-L localport:localhost:remoteport ). In this case, we forward port 3307 on localhost to port 3306 on remotehost.com.

二 连接Mysql

现在，你就可以通过本地连接远程的数据库了，就像访问本地的数据库一样。

mysql -h 127.0.0.1 -P 3307 -u dbuser -p db

The command tells the local MySQL client to connect to localhost port 3307 (which is forwarded via ssh to remotehost.com:3306). The exchange of data between client and server is now sent over the encrypted ssh connection.

或者用Mysql Query Brower来访问Client的3307端口。

类似的，用PHP访问：

<?php
$smysql = mysql_connect( "127.0.0.1:3307", "dbuser", "PASS" );
mysql_select_db( "db", $smysql );
?>
Making It A Daemon

A quick and dirty way to make sure the connection runs on startup and respawns on failure is to add it to /etc/inittab and have the init process (the, uh, kernel) keep it going.

Add the following to /etc/inittab on each client:

sm:345:respawn:/usr/bin/ssh -Ng -L 3307:127.0.0.1:3306 myuser@remotehost.com

And that should be all you need to do. Send init the HUP signal ( kill -HUP 1 ) to make it reload the configuration. To turn it off, comment out the line and HUP init again.