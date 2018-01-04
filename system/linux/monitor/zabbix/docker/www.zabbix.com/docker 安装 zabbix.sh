

docker 安装 zabbix - CSDN博客 http://blog.csdn.net/u012373815/article/details/71598457
 https://labs.play-with-docker.com

docker run -p 3306:3306 --name mysql\
 -v ~/mysql/data:/var/lib/mysql\
 -e MYSQL_ROOT_PASSWORD=123456\
 -d mysql
# -p 3309:3306 是将docker 的3306端口映射到本机3309 端口
# v ~/mysql/data:/var/lib/mysql 是将docker的/var/lib/mysql 文件夹映射到本机的/mysql/data
# -e MYSQL_ROOT_PASSWORD=123456 输入密码，mysql原始密码为123456
# （如果需要修改密码 执行docker -exec -it 容器id /bin/bash 进入容器修改密码，
# 修改后可以使用 docker commit 容器id 新名称 提交镜像修改。）

# 启动镜像命令
docker run --name zabbix-server\
 -p 10051:10051\
 --link mysql:mysql\
 -e DB_SERVER_HOST="mysql"\
 -e DB_SERVER_PORT="3306"\
 -e MYSQL_USER="root"\
 -e MYSQL_PASSWORD="123456"\
 -d zabbix/zabbix-server-mysql
# 2. 安装zabbix-web-apache-mysql
docker run --name zabbix-web\
 -p 8088:80\
 --link mysql:mysql\
 --link zabbix-server:zabbix-server\
 -e DB_SERVER_HOST="mysql"\
 -e DB_SERVER_PORT="3306"\
 -e MYSQL_USER="root"\
 -e MYSQL_PASSWORD="123456"\
 -e ZBX_SERVER_HOST="zabbix-server"\
 -e TZ="Asia/Shanghai"\
 -d zabbix/zabbix-web-apache-mysql

# 3. 安装agent
# 在需要监控的机器上 安装agent 
docker run --name zabbix-agent\
 -p 10050:10050\
 --link zabbix-server:zabbix-server\
 -e ZBX_HOSTNAME="agent-1"\
 -e ZBX_SERVER_HOST="zabbix-server"\
 -e ZBX_SERVER_PORT=10051\
 -d zabbix/zabbix-agent
# ZBX_HOSTNAME用来表示自己的身份，
# ZBX_SERVER_HOST是用来标明zabbix server的ip信息的

# 访问安装web 的服务器ip 端口号为8088 进入zabbix 登录页面，
# 默认帐号为Admin 密码为 zabbix
