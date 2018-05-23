
Docker网络——单host网络 - shoufengwei - 博客园 http://www.cnblogs.com/shoufengwei/p/7268300.html
http://www.cnblogs.com/shoufengwei/p/7268300.html

# 一、Docker默认网络
`docker network ls`
便能看到docker默认安装的所有网络，分别是none网络、host网络和bridge网络。

1.1 none 网络
none网络就是什么都没有的网络。挂在这个网络下的容器除了lo，没有其他任何网卡。容器run时，可以通过添加--network=none参数来指定该容器使用none网络。那么这样一个只有lo的网络有什么用呢？此处CloudMan指出：

none网络应用与隔离场景，一些对安全性要求高并且不需要联网的应用可以使用none网络。
比如某个容器的唯一用途是生成随机密码，就可以放到none网络中避免密码被窃取。

1.2 host 网络
连接到host网络的容器共享Docker宿主机的网络栈，即容器的网络配置与host宿主机完全一样。可以通过添加--network=host参数来指定该容器使用host网络。
在容器中可以看到host的所有网卡，并且连hostname也是host的。host网络的使用场景又是什么呢？
直接使用Docker host的网络最大的好处就是性能，如果容器对网络传输效率有较高要求，则可以选择host网络。当然不便之处就是牺牲一些灵活性，比如要考虑端口冲突问题，Docker host上已经使用的端口就不能再用了。
Docker host的另一个用途是让容器可以直接配置 host 网路。比如某些跨host的网络解决方案，其本身也是以容器方式运行的，这些方案需要对网络进行配置。
相当于该容器拥有了host主机的网络，那么其ip等配置也相同，相当于主机中套了一个与外部一模一样的容器，可以直接通过host的ip地址来访问该容器。
1.3 bridge 网络
在不指定--network参数或者--network=bridge的情况下创建的容器其网络类型都是bridge。
Docker在安装时会在宿主机上创建名为docker0的网桥，所谓网桥相当于一个虚拟交换机，如果使用上述两种方式run的容器都会挂到docker0上。
容器和docker0之间通过veth进行连接，veth相当于一根虚拟网线，连接容器和虚拟交换机，这样就使得docker0与容器连通了。

# 二、自定义容器网络
理论上有了上述三种网络已经足够满足普通用户的需求，但是有时候可能用户需要指定自己的网络，以此来适应某些配置，如ip地址规划等等。

2.1 创建自定义网络
Docker提供三种user-defined网络驱动：bridge，overlay和macvlan。overlay和macvlan用于创建跨主机的网络，会在下一篇文章介绍。所以本文介绍创建bridge自定义网络。命令如下：
docker network create -d bridge --subnet 172.10.0.0/24 --gateway 172.10.0.1 my_net
-d bridge表示自定义网络的驱动为bridge，--subnet 172.10.0.0/24 --gateway 172.10.0.1分别指定网段和网关。
这样就创建好了一个自动一网络，可以通过以下命令查看此网络的信息：
`docker network inspect my_net`
会得到此网络的配置信息，my_net是刚刚创建的网络名称，如果为bridge就是查看docker创建的默认bridge网络信息。
每创建一个自定义网络便会在宿主机中创建一个网桥（docker0是创建的默认网桥，其实原理是一致的，而且也是对等的。）。名字为br-<网络短ID>，可以通过

`yum install bridge-utils -y` 
brctl show命令查看全部网桥信息。
docker的自定义网络与OpenStack中的网络信息倒是基本一致。所以一通百通，只要docker的明白了，所有虚拟化甚至实体的网络也就基本都搞清楚了。

2.2 使用自定义网络
通过以下命令为容器指定自定义网络：
?
1
docker run -it --network my_net --ip 172.10.0.3 busybox
其实这与使用docker默认网络是一致的，都是添加--network参数参数，此处也添加了--ip参数来指定容器的ip地址。
三、不同容器之间的连通性
同一个网络（默认网络或者自定义网络）下的容器之间是能ping通的，但是不同网络之间的容器由于网络独立性的要求是无法ping通的。原因是iptables-save DROP掉了docker之间的网络，大概如下：
-A DOCKER-ISOLATION -i docker0 -o br-ac4fe2d72b18 -j DROP
-A DOCKER-ISOLATION -i br-ac4fe2d72b18 -o docker0 -j DROP
-A DOCKER-ISOLATION -i br-62f17c363f02 -o br-ac4fe2d72b18 -j DROP
-A DOCKER-ISOLATION -i br-ac4fe2d72b18 -o br-62f17c363f02 -j DROP
-A DOCKER-ISOLATION -i br-62f17c363f02 -o docker0 -j DROP
-A DOCKER-ISOLATION -i docker0 -o br-62f17c363f02 -j DROP
那么如何让不同网络之间的docker通信呢？接下来介绍容器间通信的三种方式。

## 3.1 IP 通信
IP通信就是直接用IP地址来进行通信，根据上面的分析需要保证两个容器处于同一个网络，那么如果不在同一个网络如何处理呢？
如果是实体机我们很容易理解，只需要为其中一台服务器添加一块网卡连接到另一个网络就可以了。容器同理，只需要为其中一个容器添加另外一个容器的网络就可以了。使用如下命令：

docker network connect my_net httpd

connect命令能够为httpd容器再添加一个my_net网络（假设httpd原来只有默认的bridge网络）。这样上面创建的busybox容器就能与此次connect的httpd容器进行通信。

## 3.2 Docker DNS Server
通过 IP 访问容器虽然满足了通信的需求，但还是不够灵活。因为我们在部署应用之前可能无法确定IP，部署之后再指定要访问的IP会比较麻烦。对于这个问题，可以通过docker自带的DNS服务解决。
从Docker 1.10 版本开始，docker daemon 实现了一个内嵌的DNS server，使容器可以直接通过“容器名”通信。
方法很简单，只要在启动时用--name为容器命名就可以了。
下面的命令启动两个容器bbox1和bbox2：
docker run -it --network=my_net --name=bbox1 busybox
docker run -it --network=my_net --name=bbox2 busybox
然后，bbox2就可以直接ping到bbox1了，但是使用docker DNS有个限制，只能在user-defined网络中使用。默认的bridge网络是无法使用的。

## 3.3 joined 容器
joined 容器是另一种实现容器间通信的方式。joined 容器非常特别，它可以使两个或多个容器共享一个网络栈，共享网卡和配置信息，joined容器之间可以通过127.0.0.1直接通信。host网络使得容器与宿主机共用同一个网络，而jointed是使得两个容器共用同一个网络。
请看下面的例子：
先创建一个httpd容器，名字为web1。
docker run -d -it --name=web1 httpd
然后创建busybox容器并通过--network=container:web1指定jointed容器为web1：
docker run -it --network=container:web1 busybox
这样busybox和web1的网卡mac地址与IP完全一样，它们共享了相同的网络栈。busybox 可以直接用127.0.0.1访问web1的http服务。
其实也很容易理解，之前的--network参数指定了默认网络或者自定义网络，而此处是指定了一个容器，那么当然意思就是使用这个容器的网络。这也有点类似上一篇文章讲到的共享存储。
joined 容器非常适合以下场景：
不同容器中的程序希望通过loopback高效快速地通信，比如web server与app server。
希望监控其他容器的网络流量，比如运行在独立容器中的网络监控程序。
其实就是应用于即需要独立而又需要两个容器网络高度一致的场景。
3.4 容器与外部网络的连通性
3.4.1 容器访问外部网络
容器默认是能访问外部网络的。通过NAT，docker实现了容器对外网（此处外网不一定是互联网）的访问。
3.4.2 外部网络访问容器
通过端口映射的方式实现外部网络访问容器，即通过-p参数实现将容器的端口映射到外部端口。
总结
以上所述是小编给大家介绍的Docker网络之单host网络及使用案例，希望对大家有所帮助，如果大家有任何疑问请给我留言，小编会及时回复大家的。在此也非常感谢大家对脚本之家网站的支持！
原文链接：http://www.cnblogs.com/shoufengwei/p/7268300.html