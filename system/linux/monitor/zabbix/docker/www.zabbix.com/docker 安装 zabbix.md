

docker 安装 zabbix - CSDN博客 http://blog.csdn.net/u012373815/article/details/71598457


docker pull zabbix/zabbix-server-mysql
1
启动镜像命令

docker run --name some-zabbix-server-mysql  -p 10051:10051 --net=host -e DB_SERVER_HOST="数据库ip" -e DB_SERVER_PORT=数据库端口 -e MYSQL_USER="数据库用户名" -e MYSQL_PASSWORD="数据库密码" -d zabbix/zabbix-server-mysql
1
2. 安装zabbix-web-apache-mysql

拉取镜像

docker pull zabbix/zabbix-web-apache-mysql
1
启动命令

docker run --name some-zabbix-web-apache-mysql -p 8088:80  -e DB_SERVER_HOST="数据库ip" -e DB_SERVER_PORT=数据库端口 -e MYSQL_USER="数据库用户名" -e MYSQL_PASSWORD="数据库密码" -e ZBX_SERVER_HOST="zabbix服务器IP" -e TZ="Asia/Shanghai" -d zabbix/zabbix-web-apache-mysql
1
3. 安装agent

在需要监控的机器上 安装agent 
拉去镜像

docker pull zabbix/zabbix-agent
1
启动命令

docker run --name some-zabbix-agent -p 10050:10050 -e ZBX_HOSTNAME="hostname" -e ZBX_SERVER_HOST="zabbix服务器IP" -e ZBX_SERVER_PORT=10051 -d zabbix/zabbix-agent
1
此时安装成功了。访问安装web 的服务器ip 端口号为8088 进入zabbix 登录页面，默认帐号为Admin 密码为 zabbix 登录后就可以配置自己的监控了。

版权声明：本文为博主编写文章，未经博主允许转载，转载请注明出处。