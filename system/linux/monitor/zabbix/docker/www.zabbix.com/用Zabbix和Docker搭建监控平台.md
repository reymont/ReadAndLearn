

用Zabbix和Docker搭建监控平台-DockerInfo 
http://www.dockerinfo.net/3681.html


1. 架构

Zabbix 作为企业级分布式监控系统，具有很多优点，如：分布式监控，支持 node 和 proxy 分布式模式；自动化注册，根据规则，自动注册主机到监控平台，自动添加监控模板；支持 agentd、snmp、ipmi 和 jmx 等很多通信方式。

同时，Zabbix 官方还发布了 Zabbix Docker 镜像。此次我们以 Zabbix 的官方 Docker 镜像为基础，搭建一个监控平台。 总体架构图如下所示：


其中，使用 Zabbix 官方的提供的镜像 Zabbix-3.0:3.0.0 作为 Zabbix Web GUI 和 Zabbix Server；Zabbix Server 用来接收来自 Zabbix agent 的数据，并将数据存储到 Zabbix Database，根据配置的监控项和获取到的数据，判断是否达到报警条件，来对主机进行监控；Zabbix Web GUI 提供了 Zabbix Server 的配置和数据展示的可视化界面；

使用 MySQL 作为 Zabbix Database，官方有相应的 MariaDB 的镜像，但是与非容器化的 MySQL 并没有什么区别，因此便于数据的集中管理，我们并不再单独启动一个 MySQL 容器，而是使用已经存在的 MySQL；

使用由 million12 提供的 zabbix-agent:2.4.7 镜像作为 Zabbix agent 部署在各个需要监控的主机上，用来采集 CPU 、内存和进程等监控项的的数据，并发送到 Zabbix Server；

2. 数据库配置

对于数据库无需过多配置，仅需为 Zabbix Server 配置一个用户名密码让其能够访问数据库zabbix 即可。此处配置用户名：zabbix, 密码：zabbix，配置命令如下：

mysql> grant all privileges on zabbix.* to zabbix@'%' identified by 'zabbix';
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)
3. 启动 Zabbix Server

采用 docker-compose 的方式启动 Zabbix Server，docker-compose.yml 文件内容如下：

version: '2'
services:
  zabbix-server:
    image: zabbix/zabbix-3.0:3.0.0
    container_name: zabbix-server
    network_mode: "bridge"
    restart: always
    ports:
      - "8888:80"
      - "10051:10051"
    volumes:
      - /etc/localtime:/etc/localtime:ro
    environment:
      - ZS_DBHost=192.168.1.100
      - ZS_DBUser=zabbix
      - ZS_DBPassword=zabbix
其中环境变量 ZS_DBHost 是 Zabbix Server 的 IP，我的主机是 192.168.1.100; ZS_DBUser 和ZS_DBPassword 是数据库的用户名和密码，即我们上一步设置的 zabbix;

暴露端口 8888 用于访问页面，10051 用于和 Zabbix-agent 通信；

用 docker-compose up -d 即可启动 Zabbix Server, 启动过程大约需要 1~3 min。用docker logs -f zabbix-server 命令查看容器的日志，日志大致内容如下：

[smoker@192.168.1.100 zabbix-server]$ docker logs -f zabbix-server
Creating zabbix-server
Attaching to zabbix-server
zabbix-server | Nginx status page: allowed address set to 127.0.0.1.
zabbix-server | PHP-FPM status page: allowed address set to 127.0.0.1.
zabbix-server | [LOG 13:39:08] Preparing server configuration
zabbix-server | [LOG 13:39:16] Config updated.
zabbix-server | [LOG 13:39:16] Enabling logging and pid management
zabbix-server | [LOG 13:39:17] Done
zabbix-server | [LOG 13:39:17] Waiting for database server
zabbix-server | [LOG 13:39:17] Database server is available
zabbix-server | [LOG 13:39:17] Checking if database exists or SQL import is required
zabbix-server | [WARNING 13:39:17] Zabbix database doesn't exist. Installing and importing default settings
zabbix-server | ERROR 1044 (42000) at line 1: Access denied for user 'zabbix'@'%' to database 'zabbix'
zabbix-server | ERROR 1227 (42000) at line 1: Access denied; you need (at least one of) the RELOAD privilege(s) for this operation
zabbix-server |
zabbix-server | [LOG 13:39:17] Database and user created, importing default SQL
zabbix-server |
zabbix-server | [LOG 13:42:37] Import finished, starting
zabbix-server | [LOG 13:42:37] Starting Zabbix version 3.0.0
zabbix-server | 2016
zabbix-server | 2016-04-07 13:42:37,691 CRIT Supervisor running as root (no user in config file)
zabbix-server | 2016-04-07 13:42:37,691 WARN Included extra file "/etc/supervisor.d/nginx.conf" during parsing
zabbix-server | 2016-04-07 13:42:37,691 WARN Included extra file "/etc/supervisor.d/php-fpm.conf" during parsing
通过日志可以看出，Zabbix Server 启动过程中使用了我们配置的用户名和密码初始化了名为zabbix 的数据库，并导入相应的数据结构及相应的基础数据，所以该容器启动耗时长达 3 min 左右。容器启动后，我们访问 http://192.168.1.100:8888, 出现如下界面，证明 Zabbix Server 启动成功。


默认账号的用户名、密码是：Admin 和 zabbix, 输入用户名密码登录，即可看到主界面。


进入到 Configuration 》Hosts 下，点击 disable 按钮，启用 Zabbix Server。


启用成功后，AVAILABILITY 项中 ZBX 变为绿色，如下图：


4. 启动 Zabbix agent

同样，Zabbix agent 的启动仍然以 docker-compose 的方式，不同的是 Zabbix agent 添加了一个配置文件，zabbix-agent 目录结构如下：

zabbix-agent
|-- conf
|   -- zabbix-agentd.conf
 -- docker-compose.yml
conf/zabbix-agentd.conf 的内容如下：

LogFile=/tmp/zabbix_agentd.log
EnableRemoteCommands=1
Server=192.168.1.100
ListenPort=10050
ServerActive=192.168.1.100
其中 ListenPort 为容器 zabbix-agent 暴露的端口，用于接收 Zabbix Server 的指令与其交互；Server 和 ServerActive 都指向 Zabbix Server 的 IP；

docker-compose.yml 内容如下：

version: '2'
services:
  zabbix-agent:
    image: million12/zabbix-agent:2.4.7
    container_name: zabbix-agent
    restart: always
    network_mode: "bridge"
    ports:
      - "10050:10050"
    volumes:
      - ./conf/zabbix-agentd.conf:/etc/zabbix_agentd.conf
      - /proc:/data/proc
      - /sys:/data/sys
      - /dev:/data/dev
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - ZABBIX_SERVER=192.168.1.100
其中，ports 暴露了配置文件中需要暴露的接口；挂载 ./conf/zabbix-agentd.conf 自定义配置文件到容器中 /etc/zabbix_agentd.conf 取代默认的配置文件；挂载 /proc、 /sys 和 /dev到容器中 /data 相应文件夹下，用于 zabbix-agent 收集系统进程等监控信息；环境变量中ZABBIX_SERVER 指向 Zabbix Server 的 IP；

运行 docker-compose up -d 即可启动；

5. 结束

数据库已经配置成功，Zabbix Server 正常启动，Zabbix agent 也正常启动，至于如何在 Zabbix Server 中添加需要监控的主机，有很多方式，如主动添加和跟 IP 范围自动发现，但是不在本文讨论范围之内。至此，用Zabbix 和 Docker 搭建监控平台已经完全实现。

附

（1）报警媒介 Email 配置注意项


SMTP helo 配置项中，一般是 SMTP server 根域名。如对于腾讯企业邮箱，SMTP server 是smtp.exmail.qq.com，则此处的 SMTP helo 应填写 qq.com。

（2）修改 Zabbix Server 系统语言为简体中文

对于 3.0 版本的 Zabbix Server 系统语言选择下拉框中默认是没有简体中文的，需要改动其源码，改动方式如下：

docker exec -it zabbix-server /bin/bash 进入容器；
vi /usr/local/src/zabbix/frontends/php/include/locales.inc.php，修改文件中的'zh_CN' => ['name' => _('Chinese (zh_CN)'), 'display' => false] 的 false 为 true 即可。
不过中文翻译得并不贴切，而且还会有乱码（需要修改字体解决）的可能，不建议修改此项。