

Rancher使用入门 | Tony Bai 
http://tonybai.com/2016/04/14/an-introduction-about-rancher/

Rancher使用入门
四月 14, 2016 6 条评论
上个月末，Rancher Labs在其官方博客上宣布了 Rancher 1.0正式版本发布。 这是继Apache Mesos、 Google Kubernetes以及Docker 原生 Swarm 之后，又一个可用于Production环境中的容器管理和服务编排工具，而Rancher恰似这个领域的最后一张拼图（请原谅我的孤陋寡闻，如 果有其他 厂商在做这方面产品，请在评论中留言告诉我）。从Rancher Labs的官方about中我们可以看到：Rancher Labs致力于为DevOps team打造一个最好的容器管理平台，让容器的部署和管理变得更加Easy。

本文将带大家与Rancher来个亲密接触，直观的体会一下Rancher的入门级使用方法。

注意：由于Rancher还在active development中，本文仅适用于刚刚发布的v1.0.0版本，包括：

rancher/server:v1.0.0
rancher/agent:v0.11.0
rancher/agent-instance:v0.8.1
rancher-compose-v0.7.3
后续版本演进可能会导致本文中某些操作不再适用或某些UI元素发生变化。

零、实验环境

这里继续使用之前文章中的两个Ubuntu 14.04主机环境(kernel版本 >= 3.16.7)，Docker 1.9.1+。

其中：

rancher server:
    10.10.126.101

rancher agents:
    10.10.126.101
    10.10.105.71
    10.10.105.72
一、搭建单节点Rancher Server

Rancher的各种容器管理理念均架构在由Rancher server和rancher agent构建的Infrastructure之上。Rancher server是Rancher的核心，其地位就类似于k8s、Docker swarm或mesos中的master，提供核心容器管理服务以及API服务。作为正式版发布的Rancher v1.0.0支持HA(high available)的多节点rancher server集群，不过Install起来也的确复杂些，依赖的第三方组件也较多，什么MySQL、Redis、ZooKeeper等统统都要额外部署。由于是入门，这里就偷个赖儿，我们就搭建一个单节点的Rancher Server。

Rancher的一个设计理念是所有组件都Containerized（容器化），更有甚者Rancher Labs的另外一个产品RancherOS(地位类似于CoreOS，一款专门为运行容器而设计的Linux发行版)中所有系统服务都是 Dockerized的，这里的Rancher Server也不例外，极大的方便了我们的Install。

下面我们就在126.101 host上安装一个Rancher server。

首先，我们将rancher/server image pull到local，这个image size很大，需要耐心等待一段时间，即便是使用国内容器云厂商提供的加速器：

$ docker pull rancher/server
... ...

$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
rancher/server      latest              26bce58807d1        22 hours ago        775.9 MB
接下来，启动rancher server：

$ docker run -d --restart=always -p 8080:8080 rancher/server
d8ce1654ff9f1d056d7cdc9216cf19173d85037bf23be44f802d627eabc8e607

$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                              NAMES
d8ce1654ff9f        rancher/server      "/usr/bin/s6-svscan /"   12 seconds ago      Up 8 seconds        3306/tcp, 0.0.0.0:8080->8080/tcp   agitated_ardinghelli
映射的8080端口既服务于Rancher UI，也是Rancher API的服务端口。用浏览器打开http://10.10.126.101:8080，如果你看到如下页面，则说明你的Rancher Server搭建成功了：

img{512x368}

Rancher image size之所以大，是因为其内部安装和运行了诸多服务程序，我们来hack一下：

$ docker exec d8ce1654ff9f ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0    188     4 ?        Ss   03:50   0:00 /usr/bin/s6-svscan /service
root         5  0.0  0.0    188     4 ?        S    03:50   0:00 s6-supervise cattle
root         6  0.0  0.0    188     4 ?        S    03:50   0:00 s6-supervise mysql
root         7  6.5 18.1 3808308 710284 ?      Ssl  03:50   1:05 java -Xms128m -Xmx1024m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/lib/cattle/logs -Dlogback.bootstrap.level=WARN -cp /usr/share/cattle/9283c067b6f96f5ff1e38fb0ddfd8649:/usr/share/cattle/9283c067b6f96f5ff1e38fb0ddfd8649/etc/cattle io.cattle.platform.launcher.Main
mysql       28  0.4  2.3 2135756 92164 ?       Ssl  03:50   0:04 /usr/sbin/mysqld --basedir=/usr --datadir=/var/lib/mysql --plugin-dir=/usr/lib/mysql/plugin --user=mysql --log-error=/var/log/mysql/error.log --pid-file=/var/run/mysqld/mysqld.pid --socket=/var/run/mysqld/mysqld.sock --port=3306
root       170  0.1  0.2 264632 11552 ?        Sl   03:52   0:01 websocket-proxy
root       179  0.0  0.2 274668  8632 ?        Sl   03:52   0:00 rancher-catalog-service -catalogUrl library=https://github.com/rancher/rancher-catalog.git,community=https://github.com/rancher/community-catalog.git -refreshInterval 300
root       180  0.0  0.3 254044 12652 ?        Sl   03:52   0:00 rancher-compose-executor
root       181  0.5  0.4 1579572 16692 ?       Sl   03:52   0:05 go-machine-service
root       610  0.0  0.0  14988  2576 ?        S    04:06   0:00 git -C ./DATA/library pull -r origin master
root       611  0.0  0.0   4448  1696 ?        S    04:06   0:00 /bin/sh /usr/lib/git-core/git-pull -r origin master
root       640  0.0  0.0  15024  3020 ?        S    04:06   0:00 git fetch --update-head-ok origin master
root       641  3.0  0.1 161180  6028 ?        S    04:06   0:00 git-remote-https origin https://github.com/rancher/rancher-catalog.git
root       643  0.0  0.0  15572  2120 ?        Rs   04:07   0:00 ps aux

可以看出里面有mysql、cattle、go-machine-service、rancher-compose-executor以及 websocket-proxy等。通过PID我们可以看出/usr/bin/s6-svscan是容器的第一个启动进程，/service这个 路径作为其命令行参数，估计这是一个类似于supervisord的进程控制程 序，由其 负责启动和管理Rancher server的两个重要服务：MySQL和cattle。注：单节点rancher server的数据都保存在其内部的MySQL中，而多节点rancher server则采用一个外部的MySQL存储数据。

二、设置Account

第一次启动Rancher后，Rancher的UI是没有访问控制的，所有人都可以访问这个地址并控制一切。

切换到API菜单，可以看到当前默认Environment（后续会详细说这个概念）的API访问endpoint是： http://10.10.126.101:8080/v1/projects/1a5

我们可以用curl来访问一下这个url：

$ curl http://10.10.126.101:8080/v1/projects/1a5
{"id":"1a5","type":"project","links":{"self":"http://10.10.126.101:8080/v1/projects/1a5","agents":"http://10.10.126.101:8080/v1/projects/1a5/agents","auditLogs":"http://10.10.126.101:8080/v1/projects/1a5/auditlogs","certificates":"http://10.10.126.101:8080/v1/projects/1a5/certificates",
... ...
"swarm":false,"transitioning":"no","transitioningMessage":null,"transitioningProgress":null,"uuid":"adminProject"}

返回超过一屏的信息，这同时也说明Rancher Server在正常工作。

在正式感受Rancher功能前，我们来给Rancher添加一个Account，相信这也是所有要在生产环境使用Rancher的朋友必须要做 的事情。

在Rancher UI中，也许你已经注意到了，在第一行菜单栏中，“ADMIN”菜单项右侧有一个红色的“!”，这也是在提醒你Rancher当前未设防。我们点击 “ADMIN”，选择出现的二级菜单中的”ACCOUNTS”菜单项，我们将看到如下页面：

img{512x368}

添加权限控制，需要在【”ADMIN” -> “ACCESS CONTROL”】中。Rancher支持四种权限控制方案，分别是：Active Directory、GitHub、Local Auth和OpenLDAP。我们使用最简单的Local Auth，即设置一个用户名和密码，然后点击“Enable Local Auth”按钮即可。然后我们再回到”ACCOUNTS”页面：

img{512x368}

可以看到我们已经建立了一个新的Admin权限的账号：tonybai。当前的登录账号也换成了tonybai。

这时如果你再用API访问当前默认环境的EndPoint的话，结果就会变成下面这样：

 curl http://10.10.126.101:8080/v1/projects/1a5
{"id":"b052db07-d58e-45bf-872e-06ced8bcc4e1","type":"error","links":{},"actions":{},"status":401,"code":"Unauthorized","message":"Unauthorized","detail":null}
提示错误：Unauthorized

这时如果还想用API访问，就需要为该环境添加一个API Key了。在”API”页面下，点击 “Add Environment API Key”按钮，在弹出的窗口中输入key的name：tonybai-default-env-key，点击”Create”创建：

img{512x368}

Rancher会随机生成一对access key和secret key，即user和password，使用它们即可通过API访问该环境，注意：secret key只显示这么一次，你需要手工将其记录下来，否则一旦关闭这个窗口，就无法再找到secret key的内容了，只能再重新生成一对。

$curl -u 5569108BE7489DEE47A5:76Yw5v63ag8SdKYQDYgVok7Co6HRncU7bUCEShXh http://10.10.126.101:8080/v1/projects/1a5
{"id":"1a5","type":"project","links":{"self":"http://10.10.126.101:8080/v1/projects/1a5","agents":"http://10.10.126.101:8080/v1/projects/1a5/agents","auditLogs":"http://10.10.126.101:8080/v1/projects/1a5/auditlogs","certificates":"http://10.10.126.101:8080/v1/projects/1a5/certificates",
... ...
"swarm":false,"transitioning":"no","transitioningMessage":null,"transitioningProgress":null,"uuid":"adminProject"}

三、Environment

前面说过，Rancher中有个概念是Environment。在Rancher UI的右上角，我们可以看到”Default Enviromnet”字样，点击向下箭头，打开下拉菜单，选择：“Manage Enviromnets”，可以看到当前的Enviroments列表：

img{512x368}

在这个页面，我们可以看到Rancher对Enviroments的诠释：

Rancher supports grouping resources into multiple environments. Each one gets its own set of services and infrastructure resources, and is owned by one or more GitHub users, teams or organizations.

For example, you might create separate "dev", "test", and "production" environments to keep things isolated from each other, and give "dev" access to your entire organization but restrict the "production" environment to a smaller team.
大致意思就是一个Environment就是一个resource group，每个Environment都有自己的服务和基础设施资源，并且通过Access Control来赋予每个Account访问该Environments的权限。Rancher Labs的一个目标就是为DevOps Team打造一个Easy的容器管理工具，因此在解释Environment术语时，还特地以DevOps Workflow来解释，比如建立dev、test、production environment，保证Environments间的隔离。下面的这幅图可能会更直观的展现出Environment在Rancher中的“角 色”：

img{512x368}

Rancher Server建立后，会建立一个”Default” Environment，我们可以Edit一下这个Environment的信息，可以修改它的Name、Container Orchestration引擎（cattle、k8s和swarm，默认cattle）以及Access Control，我们看到tonybai的用户是这个Environment的Owner，当然我们也可以修改tonybai这个用户的Role，比如 member、readonly或restricted。这里我们将Default的名字改为”dev”。

我们再添加一个Environment “test”，引擎用cattle:

img{512x368}

我们看到dev environment后面有一个”对号”，说明dev environment是当前active environment，所有操作均针对该environment，你当然可以通过点击每个environment列表后面的切换图标来切换active environment。

到目前为止，虽然Rancher Server建立ok了，environment这个逻辑实体也建立了，但dev environment仍处于“无米下炊”的状态。因为除了Rancher自身外，该Environment下没有任何Resources（主机、存储 等）可供使用（比如创建Containers）。

我们来为dev environment添加两个主机资源：10.10.126.101和10.10.105.72。在”INFRASTRUCTURE”-> HOSTS中点击”Add Host”按钮添加主机资源。Rancher支持多种主机资源，包括Custom（本地自定义）、Amazon EC2、 Azure 以及 DigitalOcean 等。

我们以本地Host资源(选择Custom)为例，在添加Host页面中，我们输入第一个Host的IP，Rancher UI会生成下面这段命令行：

sudo docker run -e CATTLE_AGENT_IP='10.10.126.101'  -d --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher rancher/agent:v0.11.0 http://10.10.126.101:8080/v1/scripts/B0C997705263867F519F:1460440800000:1Rd9TyJIS2Fnae5lcjsvnIRDJE
我们需要手动在10.10.126.101这个Host上执行上述命令行：

$ sudo docker run -e CATTLE_AGENT_IP='10.10.126.101'  -d --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher rancher/agent:v0.11.0 http://10.10.126.101:8080/v1/scripts/B0C997705263867F519F:1460440800000:1Rd9TyJIS2Fnae5lcjsvnIRDJE
2d05764d42c52b1449021766a5c0e104098605cd7d53b632571c46f1e84f2a4b

$ docker ps
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS                              NAMES
2d05764d42c5        rancher/agent:v0.11.0   "/run.sh http://10.10"   27 seconds ago      Up 22 seconds                                          big_bhabha
d8ce1654ff9f        rancher/server          "/usr/bin/s6-svscan /"   4 days ago          Up 4 days           0.0.0.0:8080->8080/tcp, 3306/tcp   agitated_ardinghelli
等待一会儿，我们刷新一下”INFRASTRUCTURE”-> HOSTS页面，我们会看到10.10.126.101这个Host被加入到dev environment的Infrastructure中了：

img{512x368}

按照同样的步骤，我们再将10.10.105.72加入到Infrastructure中：

$ sudo docker run -e CATTLE_AGENT_IP='10.10.105.72'  -d --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher rancher/agent:v0.11.0 http://10.10.126.101:8080/v1/scripts/B0C997705263867F519F:1460440800000:1Rd9TyJIS2Fnae5lcjsvnIRDJE
e1f335c665853348810aef8736c67f610ae7f4c93e4b6265361b95a354af434a

$docker ps
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS                  PORTS               NAMES
2e212fda35d3        rancher/agent:v0.11.0   "/run.sh inspect-host"   23 seconds ago      Up Less than a second                       trusting_noyce
e1f335c66585        rancher/agent:v0.11.0   "/run.sh http://10.10"   39 seconds ago      Up 23 seconds                               clever_bohr
我们注意到：上面的命令启动了两个Container，image虽然都是rancher/agent:v0.11.0，但执行的命令行参数略有 不同（其中一个Container为临时Container，一段时间后会自动退出）。片刻，我们就在Hosts下看到了两个Host资源了。

我们点击Rancher UI右上角的下拉箭头，将当前Environment从dev切换到test，我们发现test Environment下的Hosts又为空了（不过此处似乎有个bug，在我的Mac Chrome浏览器中，等的时间足够久后，似乎test environment把dev enviroment的Host资源显示出来了，很怪异）。可以看出Infra是Environment相关的。我们在test环境下增加一个 10.10.105.71 host：

$ sudo docker run -e CATTLE_AGENT_IP='10.10.105.71'  -d --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher rancher/agent:v0.11.0 http://10.10.126.101:8080/v1/scripts/A63B9C5F8066E29377C3:1460448000000:UbPcmDXOqoI6mls6e75Qp17QR0
4a5f9e13615e562636cd515763e293449607a8b2d827d2599f80f9ad8f16aa2d

$ docker ps
CONTAINER ID        IMAGE                   COMMAND                  CREATED              STATUS                  PORTS                    NAMES
d101095c7709        rancher/agent:v0.11.0   "/run.sh run"            6 seconds ago        Up Less than a second                            rancher-agent
4a5f9e13615e        rancher/agent:v0.11.0   "/run.sh http://10.10"   About a minute ago   Up About a minute                                evil_khorana

到这里，test Environment下也有了一个Host了，从Rancher UI页面可以看到。

四、Stack

Rancher UI的左上角APPLICATIONS下面有一个“STACKS”的二级菜单项。Rancher官方docs对Stack的解释是：”A Rancher stack mirrors the same concept as a docker-compose project. It represents a group of services that make up a typical application or workload.”。同时Rancher UI上关于Service的解释如下：“A service is simply a group of containers created from the same Docker image but extends Docker’s “link” concept to leverage Rancher’s lightweight distributed DNS service for service discovery”。从这两段描述中，我们大致可以推出如下关系：

A Stack <=> An Application <=> A group of services(由类docker-compose的工具rancher-compose管理)
下面这幅图直观描述了user account, environment与stacks之间的关系：

img{512x368}

我们在dev environment下添加一个Service。Rancher UI “APPLICATIONS” -> “STACKS”下面支持两种添加Service的方式，一种是手工添加，一种是从Catalog添加。Catalog类似于一个Rancher App Market，里面有Rancher预定义好的service template。我们这次采用手工添加的方式，便于控制。我们基于nginx:1.8-alpine创建单一实例的service: nginx-alpine-service，端口映射：10086->80。其他采用默认配置。添加Service时，并没有位置让你为Stack 起名，但添加一个Service后，我们会看到当前Stack是Default Stack，你可以修改Stack name，这里改为nginx-app-stack。启动后，我们看到第一个nginx-alpine-service的Container运行在 105.72上。

img{512x368}

点击stack名字，可以查看stack的详细信息：

img{512x368}

点击”nginx-alpine-service”，进入到service属性页面，我们将nginx-alpine-service的 Scale +1。Rancher会自动在Resource host上根据默认调度策略，运行一个新的基于nginx image的Container。我们可以看到这个新Container运行在126.101上，这样dev Environmnet中的两个Host上就各自运行了一个nginx-alpine-service的Container：

img{512x368}

nginx-alpine-service的两个容器分别为：

 Running    Default_nginx-alpine-app_1  10.42.96.91 10.10.105.72  nginx:1.8-alpine
 Running    nginx-app-stack_nginx-alpine-service_1  10.42.164.174   10.10.126.101 nginx:1.8-alpine
Rancher内置“Internal DNS Services”，同一Stack下的Container可以通过Container name相互ping通。Rancher以Environment为界限，每个Environment下的Container name都是全局唯一的。

在10.10.105.72上，我们执行如下命令来ping 10.10.126.101上的容器：nginx-app-stack_nginx-alpine-service_1：

$ docker exec r-Default_nginx-alpine-app_1  ping -c 3 nginx-app-stack_nginx-alpine-service_1
PING nginx-app-stack_nginx-alpine-service_1 (10.42.164.174): 56 data bytes
64 bytes from 10.42.164.174: seq=0 ttl=62 time=0.729 ms
64 bytes from 10.42.164.174: seq=1 ttl=62 time=0.754 ms
64 bytes from 10.42.164.174: seq=2 ttl=62 time=0.657 ms

--- nginx-app-stack_nginx-alpine-service_1 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.657/0.713/0.754 ms
在10.10.126.101上，我们执行如下命令来ping 10.10.105.72上的容器：Default_nginx-alpine-app_1：

$ docker exec r-nginx-app-stack_nginx-alpine-service_1 ping -c 3 Default_nginx-alpine-app_1
PING Default_nginx-alpine-app_1 (10.42.96.91): 56 data bytes
64 bytes from 10.42.96.91: seq=0 ttl=62 time=0.640 ms
64 bytes from 10.42.96.91: seq=1 ttl=62 time=0.814 ms
64 bytes from 10.42.96.91: seq=2 ttl=62 time=0.902 ms

--- Default_nginx-alpine-app_1 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.640/0.785/0.902 ms
我们按照上述方法为nginx-app-stack再添加一个Service: redis-alpine-service，该service基于redis:alpine image，该service的Container被运行在105.72上了：

$ docker ps
CONTAINER ID        IMAGE                           COMMAND                  CREATED             STATUS              PORTS                                          NAMES
7246dce88ea6        redis:alpine                    "/entrypoint.sh redis"   3 minutes ago       Up 3 minutes        6379/tcp                                       r-nginx-app-stack_redis-service_1
我们来测试一下同一stack下，不同Service的互ping：

我们在redis-alpine-service的Container中来ping nginx-alpine-service，地址直接使用”nginx-alpine-service”这个service name即可：

$ docker exec r-nginx-app-stack_redis-service_1 ping -c 3 nginx-alpine-service
PING nginx-alpine-service (10.42.164.174): 56 data bytes
64 bytes from 10.42.164.174: seq=0 ttl=62 time=0.660 ms
64 bytes from 10.42.164.174: seq=1 ttl=62 time=0.634 ms
64 bytes from 10.42.164.174: seq=2 ttl=62 time=0.599 ms

--- nginx-alpine-service ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.599/0.631/0.660 ms

可以看到Rancher的Internal DNS Service将”nginx-alpine-service”这个service name解析为nginx-alpine-service的两个Container中的一个：10.42.164.174。

我们再添加一个Stack：memcached-app-stack，来看一下跨Stack的容器连通方法。ping之前我们需要为该Stack添加一个基于memcached:latest image的Service: memcached-service

10.10.105.72

$ docker ps
CONTAINER ID        IMAGE                           COMMAND                  CREATED             STATUS              PORTS                                          NAMES
184e8e8f448e        memcached:latest                "/entrypoint.sh memca"   24 seconds ago      Up 16 seconds       11211/tcp                                      r-memcached-app-stack_memcached-service_1
Rancher官方docs中明确说明：不同Stack间service互ping，需要采用“ service_name.stack_name”的地址格式，我们在memcached-app-stack中的“r-memcached-app-stack_memcached-service_1”容器里去ping nginx-app-stack中的nginx-alpine-service服务：

$ docker exec r-memcached-app-stack_memcached-service_1  ping -c 3 nginx-alpine-service.nginx-app-stack
PING nginx-alpine-service.nginx-app-stack (10.42.164.174): 56 data bytes
64 bytes from 10.42.164.174: icmp_seq=0 ttl=62 time=0.710 ms
92 bytes from 10.42.84.96: Redirect Host
64 bytes from 10.42.164.174: icmp_seq=1 ttl=62 time=2.543 ms
--- nginx-alpine-service.nginx-app-stack ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.710/1.627/2.543/0.917 ms
ping nginx-app-stack中的redis-alpine-service服务：

$ docker exec r-memcached-app-stack_memcached-service_1  ping -c 3 redis-alpine-service.nginx-app-stack
PING redis-alpine-service.nginx-app-stack (10.42.220.43): 56 data bytes
64 bytes from 10.42.220.43: icmp_seq=0 ttl=64 time=0.161 ms
64 bytes from 10.42.220.43: icmp_seq=1 ttl=64 time=0.050 ms
64 bytes from 10.42.220.43: icmp_seq=2 ttl=64 time=0.051 ms
--- redis-alpine-service.nginx-app-stack ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.050/0.087/0.161/0.052 ms

我们通过cat /etc/resolv.conf可以查看到Rancher内部DNS的地址：

$docker exec r-memcached-app-stack_memcached-service_1  cat /etc/resolv.conf
search memcached-app-stack.rancher.internal memcached-service.memcached-app-stack.rancher.internal rancher.internal
nameserver 169.254.169.250
五、Rancher Compose CLI

Rancher除了提供UI工具外，还提供了一个名为rancher-compose的CLI工具，用于在一个stack的范围内管理各个services。rancher-compose的灵感来源于docker-compose，兼容docker-compose的配置文件格式，并有自己的扩展。此外与docker-compose不同的是rancher-compose支持跨多主机管理。

在Rancher UI的右下角有一个Rancher-compose的下载链接，支持Linux，Windows和Mac。rancher-compose当前版本是0.7.3，下载后将其路径放到PATH环境变量里，验证一下运行是否ok：

$ rancher-compose -v
rancher-compose version v0.7.3
要管理某个stack下的Service，我们至少需要提供一个docker-compose.yml文件，这里针对memcached-app-stack下的memcached-service这个服务做一些操作，我们提供一个docker-compose.yml：

memcached-service:
  log_driver: ''
  tty: true
  log_opt: {}
  image: memcached:latest
  stdin_open: true
利用dev环境的api key和secret，rancher-compose可以实现与rancher的交互：

$ rancher-compose --url http://10.10.126.101:8080  --access-key 5569108BE7489DEE47A5 --secret-key 76Yw5v63ag8SdKYQDYgVok7Co6HRncU7bUCEShXh -p memcached-app-stack up
INFO[0000] Project [memcached-app-stack]: Starting project
INFO[0000] [0/1] [memcached-service]: Starting
INFO[0000] [1/1] [memcached-service]: Started
INFO[0000] Project [memcached-app-stack]: Project started

由于memcached-service已经存在并启动了相应Container，因此上面的命令实际上没有做任何改动。如果想看rancher-compose的执行细节，可以在rancher-compose后面加上–verbose命令行option，可以看到如下结果：

$ rancher-compose --verbose --url http://10.10.126.101:8080  --access-key 5569108BE7489DEE47A5 --secret-key 76Yw5v63ag8SdKYQDYgVok7Co6HRncU7bUCEShXh -p memcached-app-stack up
DEBU[0000] Environment Context from file : map[]
DEBU[0000] Opening compose file: docker-compose.yml
DEBU[0000] [0/0] [memcached-service]: Adding
DEBU[0000] Opening rancher-compose file: /home1/tonybai/rancher-compose.yml
DEBU[0000] Looking for stack memcached-app-stack
DEBU[0000] Found stack: memcached-app-stack(1e3)
DEBU[0000] Launching action for memcached-service
DEBU[0000] Project [memcached-app-stack]: Creating project
DEBU[0000] Finding service memcached-service
DEBU[0000] [0/1] [memcached-service]: Creating
DEBU[0000] Found service memcached-service
DEBU[0000] [0/1] [memcached-service]: Created
DEBU[0000] Project [memcached-app-stack]: Project created
INFO[0000] Project [memcached-app-stack]: Starting project
DEBU[0000] Launching action for memcached-service
DEBU[0000] Finding service memcached-service
INFO[0000] [0/1] [memcached-service]: Starting
DEBU[0000] Found service memcached-service
DEBU[0000] Finding service memcached-service
INFO[0000] [1/1] [memcached-service]: Started
INFO[0000] Project [memcached-app-stack]: Project started
DEBU[0000] Found service memcached-service
DEBU[0000] Finding service memcached-service
DEBU[0000] Found service memcached-service
我们再通过rancher-compose将memcached-service扩展到两个Container：

$ rancher-compose --url http://10.10.126.101:8080  --access-key 5569108BE7489DEE47A5 --secret-key 76Yw5v63ag8SdKYQDYgVok7Co6HRncU7bUCEShXh -p memcached-app-stack scale memcached-service=2
INFO[0000] Setting scale memcached-service=2...
几秒后，Rancher UI上memcached-service的Container数量就会从1变为2。在105.72上我们也可以看到两个memcached service container：

$ docker ps
CONTAINER ID        IMAGE                           COMMAND                  CREATED             STATUS              PORTS                                          NAMES
43c1443fec9f        memcached:latest                "/entrypoint.sh memca"   8 minutes ago       Up 7 minutes        11211/tcp                                      r-memcached-app-stack_memcached-service_2
184e8e8f448e        memcached:latest                "/entrypoint.sh memca"   14 hours ago        Up 13 hours         11211/tcp                                      r-memcached-app-stack_memcached-service_1
六、Service upgrade

Rancher支持stack中Service的upgrade管理。Rancher提供了两种Service Upgrade方法：In-service upgrade和Rolling upgrade（滚动升级）。rancher-compose同时支持两种升级方法，Rancher UI中针对stack下的service也有upgrade菜单选项，但UI提供的升级方式等同于in-service upgrade。

根据官方docs的说明，In-Service upgrade的默认upgrade步骤大致是：

1、停掉existing service的containers；
2、等待interval时间；
3、启动new version service的containers；
4、confirm upgrade or rollback。
而Rolling upgrade的升级步骤则是：

1、启动new service ；
2、将old service的scale降为0。
下面我们就每种method分别举一个例子说明一下（均采用rancher-compose工具）。

1、In-Service Upgrade

我们来将dev Environment下nginx-app-stack的nginx-alpine-service从nginx:1.8-alpine升级到nginx:1.9-alpine。为此我们需要给rancher-compose提供一份升级后的service的docker-compose.yml文件：

//docker-compose-nginx-service-upgrade.yml

nginx-alpine-service:
  ports:
  - 10086:80/tcp
  log_driver: ''
  labels:
    io.rancher.container.start_once: 'true'
  tty: true
  log_opt: {}
  image: nginx:1.9-alpine
  stdin_open: true
可以看到我们仅是将nginx-alpine-service的image从1.8-alpine改为1.9-alpine了。接下来我们就来升级nginx-alpine-service：

$ rancher-compose -f ./docker-compose-nginx-service-upgrade.yml --url http://10.10.126.101:8080  --access-key 5569108BE7489DEE47A5 --secret-key 76Yw5v63ag8SdKYQDYgVok7Co6HRncU7bUCEShXh -p nginx-app-stack up --upgrade nginx-alpine-service
INFO[0000] Project [nginx-app-stack]: Starting project
INFO[0000] [0/1] [nginx-alpine-service]: Starting
INFO[0000] Updating nginx-alpine-service
INFO[0001] Upgrading nginx-alpine-service
INFO[0056] [1/1] [nginx-alpine-service]: Started
INFO[0056] Project [nginx-app-stack]: Project started

我们通过Rancher UI可以看到upgrade执行在界面上体现出来的变化：

img{512x368}

Upgrade后，nginx-alpine-service的详细信息如下：

img{512x368}

我们来Confirm一下：

$ rancher-compose -f ./docker-compose-nginx-service-upgrade.yml  --url http://10.10.126.101:8080  --access-key 5569108BE7489DEE47A5 --secret-key 76Yw5v63ag8SYQDYgVok7Co6HRncU7bUCEShXh -p nginx-app-stack up --upgrade --confirm-upgrade
INFO[0000] Project [nginx-app-stack]: Starting project
INFO[0000] [0/1] [nginx-alpine-service]: Starting
INFO[0001] [1/1] [nginx-alpine-service]: Started
INFO[0001] Project [nginx-app-stack]: Project started
ERRO[0002] Failed to get logs for Default_nginx-alpine-app_1: Failed to find action: logs
ERRO[0002] Failed to get logs for nginx-app-stack_nginx-alpine-service_1: Failed to find action: logs
Confirm后，Rancher UI上的upgrade标记不见了，两个没有running的old版本 container也被cleanup了。confirm时出现两个ERRO，不知何原因，但问题不大，没有影响到confirm结果。

2、Rolling Upgrade

与In-service upgrade服务中断不同，Rolling Upgrade会先启动new Service，然后再逐渐将old service的scale减少到0。这种情况下，如果其他服务配合到位，该服务是不会中断的。

我们以nginx-app-stack中的redis-alpine-service为例，将其从redis:alpine版本升级到3.0.7-alpine。

$docker images
redis                                  3.0.7-alpine        633ba621a23f        6 weeks ago         15.95 MB
redis                                  alpine              633ba621a23f        6 weeks ago         15.95 MB
... ...
我们同样要为这次Roll upgrade准备一份docker-compose.yml文件：

//docker-compose-redis-service-upgrade.yml

redis-alpine-service:
redis-alpine-service-v1:
  log_driver: ''
  tty: true
  log_opt: {}
  image: redis:3.0.7-alpine
  stdin_open: true

执行Rolling upgrade命令：

$rancher-compose -f ./docker-compose-redis-service-upgrade.yml --url http://10.10.126.101:8080  --access-key 5569108BE7489DEE47A5 --secret-key 76Yw5v63ag8SdKYQDYgVok7Co6HRncU7bUCEShXh -p nginx-app-stack upgrade  redis-alpine-service redis-alpine-service-v1
INFO[0000] Creating service redis-alpine-service-v1
INFO[0005] Upgrading redis-alpine-service to redis-alpine-service-v1, scale=2
Rancher UI上出现如下状态变化：

img{512x368}

最终redis-alpine-service-v1启动，redis-alpine-service停止，但Rancher UI并未将其Remove，你可以手动删除，或者在上面命令中加入–cleanup自动删除old service。

七、参考资料

关于Rancher，网上可用的资料并不多，这里主要是参考了官方文档：

http://rancher.com/announcing-rancher-1-0-ga/

http://docs.rancher.com/rancher/quick-start-guide/

不过Rancher的Doc文字太多，少图，尤其是在Rancher UI介绍这块，基本无图，还待改善。

另外国内的云舒网络与 Rancher Labs是深度的合作伙伴，云舒公司博客上的内容也值得大家认真参考。

八、小结

相比于Mesos、Kubernetes和Swarm这三位欧巴，Rancher还最为年轻(至少从发布时间上来看是这样的)，也刚刚起步。而这个领域的激烈的竞争也才刚刚开始。 谁能笑道最后，还待观察。