

Docker之Flannel管理网络-yellowcong - yelllowcong的专栏 - CSDN博客 http://blog.csdn.net/yelllowcong/article/details/78303626


Docker中管理网络的工具的确挺多的，但是比如Weave的性能相对 较差，而且有虚拟机断网的bug. pipework 的ip没次重启就需要重新的配置，这也是挺麻烦的一件事，所以Flannel还是比较推荐使用的。
网络拓扑图可以看出 ，数据发送到了物理节点后，走的是Flannel，然后分发到自己节点里面的docker容器里面,他们是通过维护一张表，来保证ip的唯一，通过将ip的信息存在etcd上

这里写图片描述

1、安装etcd

1.1安装etcd

我这个地方的安装方式是单节点安装

#安装etcd
yum install etcd

#启动服务
service etcd start

#获取节点数据，看本生好不好用，然后再进行下一步，配置ETCD的操作（很重要，不进行这步，容易发生错误，不知道是那个地方的问题）
etcdctl get /
1
2
3
4
5
6
7
8
9
1.2 配置ETCD

我这个地方是单节点的，也没啥配置操作， 需要配置节点，需要修改为自己当前的ip，这样其他主机的服务器就能访问到了。不然访问不到，初始化失败。配置了监听的节点(ETCD_LISTEN_CLIENT_URLS）没有加上http://127.0.0.1:2379,直接使用命令，需要加上路径 etcdctl --endpoints http://192.168.66.110:2379，不然就会报错

配置下面类容

#配置文件夹 ,配置etcd集群操作 ，可以修改端口，但是我们没有啥必要去修改他
vim /etc/etcd/etcd.conf

# [member]
ETCD_NAME=default
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="http://192.168.66.110:2380,http://127.0.0.1:2380"
ETCD_LISTEN_CLIENT_URLS="http://192.168.66.110:2379,http://127.0.0.1:2379"

#[cluster]
ETCD_INITIAL_CLUSTER="default=http://192.167.66.110:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.66.110:2379"
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
ETCD监听的服务端口默认是2379 、2380，需要 记得开启防火墙 
这里写图片描述

测试ETCD好不好用

如果ectd配置的但节点的，

#创建文件夹
etcdctl mkdir /test

#查看文件夹的信息
etcdctl ls /

#查看本节点的 目录下的所有类容
etcdctl --endpoints  http://192.168.66.110:2379 ls /

#创建节点
etcdctl --endpoints  http://192.168.66.110:2379 mkdir /web

#设定节点数据
etcdctl --endpoints  http://192.168.66.110:2379 set /web/web001 "test" 

#获取节点数据
etcdctl --endpoints  http://192.168.66.110:2379 get /web001 
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
这里写图片描述

1.3 设定网段

确定etcd可以使用之后，我们需要设置分配给docker网络的网段

#在etcd中添加一条数据
etcdctl  mk /atomic.io/network/config '{"Network":"172.17.0.0/16", "SubnetMin": "172.17.1.0", "SubnetMax": "172.17.254.0"}'
1
2
这里写图片描述

1.4开启端口

#编辑iptables
vim /etc/sysconfig/iptables

#添加规则链条
-A INPUT -p tcp -m tcp --dport 2379 -m state --state NEW,ESTABLISHED -j ACCEPT

-A INPUT -p tcp -m tcp --dport 2380 -m state --state NEW,ESTABLISHED -j ACCEPT


#重启防火墙
service iptables restart
1
2
3
4
5
6
7
8
9
10
11
2、安装flannel

2.1安装flannel

yum install flannel
1
2.2配置flanneld的etcd服务器

#编辑配置文件
vim /etc/sysconfig/flanneld

#配置属性 ，http://192.168.66.110:2379 是本机的etcd服务，也可以别的地方的，都行
FLANNEL_ETCD_ENDPOINTS="http://192.168.66.110:2379"

#注意这个必须和上面Etcd配置的要一样，不然flannel启动不了
FLANNEL_ETCD_PREFIX="/atomic.io/network"

#需要配置成自己的网卡， 不然容器找不到网络的问题
#logtostderr 日志不打印到控制台
#log_dir 日志文件地址
#etcd-endpoints ETCD访问的地址
#iface 使用的网卡，必须是自己存在的，不然docker没地址 ，而且服务启动不起来

FLANNEL_OPTIONS="--logtostderr=false --log_dir=/var/log/k8s/flannel/ --etcd-prefix=/atomic.io/network  --etcd-endpoints=http://192.168.66.110:2379 --iface=eth0"

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
这里写图片描述

多个ETCD节点，配置例子

FLANNEL_ETCD_ENDPOINTS="http://10.132.47.70:2379,http://10.132.47.71:2379,http://10.132.47.72:2379"

FLANNEL_ETCD_PREFIX=“/flannel/network"

FLANNEL_OPTIONS="--logtostderr=false --log_dir=/var/log/k8s/flannel/ --etcd-endpoints=http://10.132.47.70:2379,http://10.132.47.71:2379,http://10.132.47.72:2379 --iface=eno16780032"
1
2
3
4
5
2.3启动Flannel

#修改配置文件后，需要重新加载
systemctl daemon-reload

#开启flanneld 服务
service flanneld start

#重启服务
service flanneld restart

#状态查看
service flanneld status

#日志查看 
flanneld -alsologtostderr
1
2
3
4
5
6
7
8
9
10
11
12
13
14
2.4配置信息查看

我们查看网桥，看到了flannel0，而且ip的地址端是我们自己指定的172.17.0.0/16,而且还生成了配置文件/run/flannel/subnet.env和/run/flannel/docker 存储了这个服务器端信息。

这里写图片描述

cat /run/flannel/subnet.env 配置信息里面，看到了我们的网段配置。注意其中的“–bip=172.17.8.1/24”这个参数，它限制了所在节点容器获得的IP范围。这个IP范围是由Flannel自动分配的，由Flannel通过保存在Etcd服务中的记录确保它们不会重复

这里写图片描述

cat /run/flannel/docker配置看到，配置的网段已经生成在这个地方了

这里写图片描述

2.5Flannel错误日志查看

flanneld -alsologtostderr
1
1.错误 ：failed to retrieve network config: client: etcd cluster is unavailable or misconfigured; error #0: dial tcp 127.0.0.1:2379: getsockopt: connection refused

这个问题的原因是，ETCD配置文件有问题，还有本地没有这个服务导致

2.错误：E1022 11:15:47.547338 5984 network.go:102] failed to retrieve network config: 100: Key not found (/atomic.io) [34] 
这个是节点的配置不对，需要在配置文件 /etc/sysconfig/flanneld，加上FLANNEL_OPTIONS=‘–etcd-prefix=/atomic.io/network ’解决

3.错误（没能解决）：端口占用 failed to register network: failed to start listening on UDP socket: listen udp4 192.168.66.110:8285: bind: address already in use

监听的时候说绑定地址失败了，我就尴尬了，明明是你自己占用了，还说别人。

#查看端口占用，发现是自己的服务啊。。
netstat -tunlp|grep 8285

#杀死端口
kill pid

#重启flannel服务
service flanneld start
1
2
3
4
5
6
7
8
Flannel默认采用vxlan作为backend，使用kernel vxlan默认的udp 8742端口。Flannel还支持udp的backend，使用udp 8285端口。

这里写图片描述

flanneld占用了端口 
这里写图片描述

3、配置开机启动

由于必须先启动Flannel，所以不能通过chkconfig xx on 的方式来设定开机启动，所以需要通过修改vim /etc/rc.local配置文件来做到。不然每次重启服务器，有可能Flannel获取不到ETCD的问题。

#修改rc.local
vim /etc/rc.local

#Docker FLANNEL
su - root -c 'service etcd start' #先ETCD
su - root -c 'service flanneld restart' #后flannel
su - root -c 'service docker restart'

1
2
3
4
5
6
7
8
9
4、配置Docker

#不重新加载配置，有可能docker先启动，这样就不生效了
systemctl daemon-reload

#重启docker
systemctl restart docker 
1
2
3
4
5
我们会看到docker的ip已经修改成我们Flannel配置的IP了

这里写图片描述

启动后查看下启动的docker是不是被flannel托管了： 
如果有–bip=172.17.45.1/24(xxxx) ，说明Flannel管理了Docker

ps aux | grep docker
1
可以看到docker启动后被加上了flanneld的相关配置项了（bip, ip-masq 和 mtu） 
这里写图片描述

问题集合

1、配置完Flannel后，启动失败

FLANNEL_ETCD_PREFIX很可能是/atomic.io/network，将其改为/coreos.com/network，或者也可以通过-etcd-prefix指定。

这里写图片描述

修改配置文件（推荐） 
vi /etc/sysconfig/flanneld

# Flanneld configuration options

# etcd url location.  Point this to the server where etcd runs
FLANNEL_ETCD_ENDPOINTS="http://192.168.66.110:2379"

# etcd config key.  This is the configuration key that flannel queries
# For address range assignment
FLANNEL_ETCD_PREFIX="/atomic.io/network"
#FLANNEL_ETCD_PREFIX="/coreos.com/network"

# Any additional options that you want to pass

FLANNEL_OPTIONS="--logtostderr=false --log_dir=/var/log/k8s/flannel/ --etcd-prefix=/atomic.io/network  --etcd-endpoints=http://192.168.66.110:2379 --iface=eth0"
1
2
3
4
5
6
7
8
9
10
11
12
13
这里写图片描述

2、其他主机连接不上Extd服务

其他节点配置也对，但是就是连接不上，产生 问题的原因是ETCD服务没有启动和配置正确锁导致的，必须要确定ETCD服务先启动，然后再启动Flannel

这里写图片描述

3.ETCDCTL命令直接使用不了

这里写图片描述 
这个问题原因是，监听的路径是当前ip，所以在使用的时候，需要 加上 –endpoints 参数，来说明监听的网络地址

etcdctl --endpoints  http://192.168.66.110:2379 ls /
1
网卡不是eth0导致容器没有ip

特别注意，这里因为我是使用的虚拟机，通过ifconfig可以看到有etc0和eth1两个网卡，这里我们要选择ip是192.168.0.xx的那个,我这里node1的ip是192.168.0.11，eth1网卡的ip是192.168.0.11，所以需要将修改成FLANNEL_OPTIONS=”-iface eth1”，要去掉注释，默认这句是注释的，并指向eth0。

容器不能获得独立的ip地址基本上是这个原因。

FLANNEL_OPTIONS="-iface eth0"
1
这里写图片描述