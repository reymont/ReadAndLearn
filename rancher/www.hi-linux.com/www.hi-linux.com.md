

Rancher使用入门 | 运维之美 
https://www.hi-linux.com/posts/20438.html

Rancher是继Apache Mesos、 Google Kubernetes以及Docker Swarm 之后，又一个可用于生产环境中的容器管理和服务编排工具。

Rancher致力于为 DevOps team打造一个最好的容器管理平台，让容器的部署和管理变得更加Easy。它把自己定位在持续交付流水线上的后半段上，如下图所示:



本文将带大家与Rancher来个亲密接触，直观的体会一下Rancher的入门级使用方法。

实验环境说明

一共需要三台主机(kernel版本 >= 3.16.7、Docker 1.13+)。Rancher具体支持的Docker版本可在这里查看：http://docs.rancher.com/rancher/v1.5/en/hosts/#supported-docker-versions

1
2
3
4
5
6
7
8
rancher server:
    10.211.55.5

rancher agent1:
    10.211.55.4

rancher agent2:
    10.211.55.8
Rancher Server安装

Rancher的各种容器管理理念均架构在由Rancher Server和Rancher Agent构建的Infrastructure之上。Rancher Server是Rancher的核心，其地位就类似于K8S、Docker Swarm或Mesos中的Master，提供核心容器管理服务以及API服务。

Rancher支持HA(High Available)多节点Rancher Server集群，安装比较复杂。由于是入门，这里就搭建一个单节点的Rancher Server。

Rancher的一个设计理念是所有组件都是容器化的，Rancher Labs的另外一个产品RancherOS(类似于CoreOS，一款专门为运行容器而设计的Linux发行版)中所有系统服务都是Dockerized的，这里的Rancher Server也是用容器部署，极大的方便了安装。

下面我们就在10.211.55.5上安装一个Rancher server。启动Rancher服务器相当简单，一条命令而已。

1
2
3
4
5
$ docker run -d \
    --name=rs \
    --restart=always \
    -p 8000:8080 \
    rancher/server:v1.5.1
启动成功后，可看到如下结果。

1
2
3
4
$ docker ps

CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS                              NAMES
ffa2d14aca65        rancher/server:v1.5.1   "/usr/bin/entry /u..."   19 minutes ago      Up 15 minutes       3306/tcp, 0.0.0.0:8000->8080/tcp   rs
映射的8000端口既服务于Rancher UI，也是Rancher API的服务端口。用浏览器打开http://10.211.55.5:8000/，如果你看到如下页面，则说明你的Rancher Server搭建成功了。



设置Account

第一次启动Rancher后，Rancher的UI是没有访问控制的，所有人都可以访问这个地址并控制一切。

首先我们来给Rancher添加一个Account，相信这也是所有要在生产环境使用Rancher的朋友必须要做的事情。

在Rancher UI中，也许你已经注意到了，在第一行菜单栏中，“ADMIN”菜单项右侧有一个红色的“!”，这也是在提醒你Rancher当前未设防。我们点击 “ADMIN”，选择出现的二级菜单中的”ACCOUNTS”菜单项，我们将看到如下页面。





添加权限控制，需要在[“ADMIN” -> “ACCESS CONTROL”]中。Rancher支持多种权限控制方案，分别是：Active Directory、Azure AD、GitHub、Local Auth、OpenLDAP和SHIBBOLETH。

我们使用最简单的Local Auth，即设置一个用户名和密码，然后点击“Enable Local Auth”按钮即可。



然后我们再回到”ACCOUNTS”页面。



可以看到我们已经建立了一个新的Admin权限的账号：mike。当前的登录账号也换成了mike。

Rancher Agent部署

访问http://10.211.55.5:8000/,点击["INFRASTRUCTURE"->"Host"->"Add host”]。执行下图中Sever管理端生成的Add Host命令，即可将Host添加到Server端管理。





在Agent 1上运行
1
$ sudo docker run -e CATTLE_AGENT_IP="10.211.55.4"  -d --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher rancher/agent:v1.2.1 http://10.211.55.5:8000/v1/scripts/48C709DD0096A44823DA:1483142400000:892Xa8prCmRfddPbHs7CmIph174
稍待片刻，就能看到Agent1已经被加入到Hosts里了。

在Agent 2上运行
1
$ sudo docker run -e CATTLE_AGENT_IP="10.211.55.8"  -d --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher rancher/agent:v1.2.1 http://10.211.55.5:8000/v1/scripts/48C709DD0096A44823DA:1483142400000:892Xa8prCmRfddPbHs7CmIph174
在Agent 2上也执行一遍类似命令，把Agent2也加入到Hosts里了。



运行容器

在主机上运行一个tomcat容器。点击Agent 1上的Add Container按钮，如下填入参数：

Name：tomcat
Select Image：tomcat:8.0.30-jre8
Public Host Port：8080
Private Container Port：8080

然后点击最下方的Create按钮。



过一段时间，便能看到如下的容器已经启动完成了。



之所以需要等一段时间，是因为需要给容器配一个网络代理Network Agent，不过功能要复杂得多，拥有跨网络通信、健康检查等功能。

在Agent 1上运行docker ps便能看到这些容器。



在页面上点击某个容器比如tomcat，可以看到容器的基本信息和一些基本监控数据。





通过http://10.211.55.4:8080/来访问已部署tomcat服务。



自行启动的容器也能被Rancher监控到。我们来启动一个小容器：

1
2
$  docker run -d --name=busybox  busybox:1.24.1 sleep 3600
615ff4510d85f22ca389fb63620d29345dd9f75dfd5d051a4a2be0818138de3d
在界面上便能看到这个busybox容器已经启动完成了。



通过Rancher启动的容器IP是在10.42.*.*区间的，自行启动的busybox容器的IP是在它之外的。如果想用相同IP段，可以使用以下命令：

1
$ docker run -d --name=busybox2 --label io.rancher.container.network=true busybox:1.24.1 sleep 3600
在界面上可以看到busybox2容器的IP已经落入区间了。



运行应用

前面演示了在指定的主机上创建单一容器的方法。不过对于一个真实的网络应用，我们并不关心它运行在哪里，只关心服务地址罢了。

Rancher通过Stack功能创建应用，这里的Stack概念和Docker Swarm 1.13里的Stack作用差不多的。

下面这幅图直观描述了stacks的用途：



我们来创建一个这样的WordPress应用。它包含一个MySQL数据库，两个WordPress实例和一套负载均衡。点击[“STACKS”->”Add Stack”]来创建一个新的STACKS。



然后点击Create来创建这个Stack。

接下来在新建这个STACKS中创建两个服务。

创建MySQL服务
Scale: 1
Name：mysql
Select Image：mysql:5.7.10
Environment Vars：MYSQL_ROOT_PASSWORD=000000

填入以上信息，并点击Create来创建MySQL服务。



创建WordPress服务
Scale：2
Name：wordpress
Select Image：wordpress:4.4.2
Service Links：mysql > mysql

填入以上信息，并点击Create来创建WordPress服务。



创建负载均衡
点击Add Service旁边的向下箭头，选择Add Load Balancer。填入：

Scale：Always run one instance of this container on every host
Name：mywordpress
Source IP/Port：80
Target Service：wordpress
Target Port：80

填入以上信息，并点击Create来创建这个负载均衡。





稍待片刻，就可以访问http://10.211.55.8/或http://10.211.55.4/来使用WordPress服务了。



预置模板

Rancher为我们预置了一系列的应用模板，方便我们快速部署应用。



这里用gogs试试看，点击CATALOG找到gogs的模板。

Name：gogs
Public Port: 3306
Http Port:10080
SSH Port:222
Mysql Password:000000
Start services after creating:true

填入以上信息，并点击Lanuch来快速运行这个应用。



还可以点击Preview来查看docker-compose.yml和rancher-compose.yml文件，里面也有比较详细的注释。



docker-compose.yml不必多说，rancher-compose.yml类似于它但更小一些。可以在任何Rancher页面的右下方点击Download CLI来下载rancher compose命令行工具，这样就可以通过命令行而非在网页上点来点去来管理容器和服务了。

最后附上部署好的两个Stack的大图一张



参考文档

http://www.google.com
http://qinghua.github.io/rancher/
http://docs.rancher.com/rancher/v1.5/en
http://tonybai.com/2016/04/14/an-introduction-about-rancher/