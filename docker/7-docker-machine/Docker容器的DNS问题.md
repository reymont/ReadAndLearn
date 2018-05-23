

Docker的大坑小洼 | DaoCloud 
http://blog.daocloud.io/docker_troubleshootings/


Docker成为云计算领域的新宠儿已经是不争的事实，作为高速发展的开源项目，难免存在这样或那样的瑕疵。笔者最近在开发实战中曾经跌进去一些坑，有些坑还很深，写出来分享，相当于是在坑边挂个警示牌，避免大家重蹈覆辙。话不多说，一起来领略Docker的大坑小洼。

1.Docker中同种类型不同tag的镜像并非可互相替代问题描述:
Docker中同种类型的镜像，一般会用tag来进行互相区分。如Docker中的mysql镜像，镜像tag有很多种，有5.6.17，5.6.22，latest等。用户的环境中若已经熟练使用mysql:5.6.17,并不代表用户如果使用mysql:5.6.22，环境依旧工作。

原因剖析:
不同tag同种类型的Docker镜像，会因为以下的原因导致镜像差异。 (1).Docker镜像内容不同。同种类型Docker镜像的tag不同，很大程度上是因为镜像中应用版本的差异。Dockerfile代表Docker镜像的制作流程，换言之是Dockerfile的不同，导致Docker镜像的不同。 (2).Docker镜像的entrypoint.sh不同。entrypoint.sh代表容器中应用进程按照何种形式启动，entrypoint.sh的差异直接导致应用容器的使用差异。举例说明：mysql:5.6.17和mysql:5.6.22的entrypoint.sh存在很大差异，两者对于隔离认为重要的环境变量的定义就不一致，使用的差异自然存在。

解决方案：
不同tag的同类型镜像作为替代品时，需谨慎。查看Docker镜像layer层的差异，查阅Dockerfile与entrypoint.sh的差异，可以提供起码的保障。

2.不同时间段使用tag为latest的镜像，效果不尽相同问题描述:
在一个时间点使用latest镜像，应用容器运行正常；之后的另一个时间点按照相应的Dockerfile，build出镜像再运行应用容器，失效。

原因剖析：
Docker官方关于同种类型Docker镜像的latest标签，并未永久赋予某一指定的Docker镜像，而是会变化。举例说明：某一个时间点ubuntu镜像的latest标签属于ubuntu:12.04，之后的另一时间点，该latest标签属于ubuntu:14.04，若Dockerfile在这两个时间点进行build时，结果必然相异。原因回归至上文的第一个坑。

解决方案：
慎用latest标签，最好不用，Docker镜像都使用指定的tag。

3.使用fig部署依赖性强的容器时出错问题描述:
使用fig部署两个有依赖关系的容器A和B，容器A内部应用的启动依赖于容器B内应用的完成。容器A内应用程序尝试连接容器B内部应用时，由于容器B内应用程序并未启动完毕，导致容器A应用程序启动失败，容器A停止运行。

原因剖析：
容器的启动分为三个阶段，依次为dockerinit、entrypoint.sh以及cmd，三个阶段都会消耗时间，不同的容器消耗的时间不一，这主要取决于docker容器中entrypoint和command到底做了什么样的操作。如mysql容器B的启动，首先执行dockerinit；然后通过dockerinit执行entrypoint.sh，由于entrypoint.sh执行过程中需要执行mysql_install_db等操作，会占据较多时间；最后由entrypoint.sh来执行cmd，运行真正的应用程序mysqld。综上所述，从启动容器到mysqld的运行，战线拉得较长，整个过程docker daemon都认为mysql容器存活，而mysqld正常运行之前，mysql容器并未提供mysql服务。如果fig中的容器A要访问mysql容器B时，虽然fig会简单辨别依赖关系，让B先启动，再启动A，当fig无法辨别容器应用的状态，导致A去连接B时，B中应用仍然未启动完毕，最终A一场退出。

解决方案：
对自身环境有起码的预估，如从容器B的启动到容器B内应用的启动完毕，所需多少时间，从而在容器A内的应用程序逻辑中添加延时机制；或者使得A内应用程序逻辑中添加尝试连接的机制，等待容器B内应用程序的启动完毕。 笔者认为，以上解决方案只是缓解了出错的可能性，并未根除。

4.Swarm管理多个Docker Node时，Docker Node注册失败问题描述：
笔者的Docker部署方式如下：在vSphere中安装一台ubuntu 14.04的虚拟机，在该虚拟机上安装docker 1.4.1；将该虚拟机制作vm使用的镜像；创建虚拟机节点时通过该镜像创建，从而虚拟机中都含有已经安装好的docker。如果使用Swarm管理这些虚拟机上的docker daemon时，仅一个Docker Node注册成功，其他Docker Node注册失败，错误信息为：docker daemon id已经被占用。

原因剖析：
如果多个Docker Host上的Docker Daemon ID一样的话，Swarm会出现Docker Node注册失败的情况。原理如下： (1).Docker Daemon在启动的时候，会为自身赋一个ID值，这个ID值通过trustKey来创建，trustkey存放的位置为~/.docker/key.json。 (2).如果在IaaS平台，安装了一台已经装有docker的虚拟机vm1，然后通过制作vm1的镜像，再通过该镜像在IaaS平台上创建虚拟机vm2，那么vm1与vm2的key.json文件将完全一致，导致Docker Daemon的ID值也完全一致。

解决方案：
(1).创建虚拟机之后，删除文件~/.docker/key.json ,随后重启Docker Daemon。Docker Daemon将会自动生成该文件，且内容不一致，实现多Docker Host上Docker Daemon ID不冲突。 (2).创建虚拟机镜像时，删除key.json文件。 建议使用方案二，一劳永逸。

# 5.Docker容器的DNS问题问题描述：
Dockerfile在build的过程中只要涉及访问外网，全部失效。

原因剖析：
用户在创建docker容器的时候，不指定dns的话，Docker Daemon默认给Docker Container的DNS设置为8.8.8.8和8.8.4.4。而在国内这个特殊的环境下，这两个DNS地址并不提供稳定的服务。如此一来，只要Docker Container内部涉及到域名解析，则立即受到影响。

解决方案:
(1)使用docker run命令启动容器的时候，设定–dns参数，参数值为受信的DNS地址，必须保证该DNS地址Docker Container可访问。 (2)如果按以上做修改，适用于docker run命令。而使用docker build的时候其实是多个docker run的叠加，由于docker build没有dns参数的传入，因此docker container不能保证域名的成功解析。

解决方案:
启动Docker Daemon的时候设定DOCKER_OPTS，添加–dns参数，这样可以保证所有的docker run默认使用这个DNS地址。   以上这些坑深浅不一，但基本上还都集中在Docker外围的配置，行为模式等方面。

 

最近虽然在Docker的坑里摔得鼻青脸肿，但是“Docker虐我千百遍，我待Docker如初恋”的情怀始终不变，这货一定是云计算的未来，我坚信。前方的大坑，我来了，duang。。。 。。。