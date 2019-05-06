
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [ip命令](#ip命令)
	* [设置和删除Ip地址](#设置和删除ip地址)
	* [列出路由表条目](#列出路由表条目)
	* [更改默认路由](#更改默认路由)
	* [显示网络统计数据](#显示网络统计数据)
	* [ARP条目](#arp条目)
	* [监控netlink消息](#监控netlink消息)
	* [激活和停止网络接口](#激活和停止网络接口)
	* [获取帮助](#获取帮助)
* [iproute2 cheat sheet](#iproute2-cheat-sheet)
* [Linux Advanced Routing & Traffic Control HOWTO](#linux-advanced-routing-traffic-control-howto)
* [linux ip命令和ifconfig命令](#linux-ip命令和ifconfig命令)
* [用Iproute2进行隧道配置](#用iproute2进行隧道配置)
* [Configuring tunnels with iproute2](#configuring-tunnels-with-iproute2)
	* [1. iproute2](#1-iproute2)
	* [2. Introduction to tunnels](#2-introduction-to-tunnels)
	* [3. Creating tunnels](#3-creating-tunnels)
	* [4. Special tunnels](#4-special-tunnels)
		* [4.1. GRE tunnels](#41-gre-tunnels)
		* [4.2. Explicit local endpoint](#42-explicit-local-endpoint)
		* [4.3. Time-to-live](#43-time-to-live)
	* [5. Assigning an IP address to the interface](#5-assigning-an-ip-address-to-the-interface)
		* [5.1. Main address](#51-main-address)
		* [5.2. Aliasing](#52-aliasing)
		* [5.3. Which IP for the tunnel](#53-which-ip-for-the-tunnel)
	* [6. Routing](#6-routing)
	* [7. Practical applications](#7-practical-applications)
		* [7.1. A complete example](#71-a-complete-example)
		* [7.2. Comfort](#72-comfort)
	* [8. Thanks](#8-thanks)

<!-- /code_chunk_output -->
---

# ip命令

* [ip命令_Linux ip 命令用法详解：网络配置工具 ](http://man.linuxde.net/ip)



```sh
-V：显示指令版本信息； 
-s：输出更详细的信息； 
-f：强制使用指定的协议族； 
-4：指定使用的网络层协议是IPv4协议； 
-6：指定使用的网络层协议是IPv6协议； 
-0：输出信息每条记录输出一行，即使内容较多也不换行显示； 
-r：显示主机时，不使用IP地址，而使用主机的域名。


```


* [每天一个Linux命令（60）ip命令 - MenAngel - 博客园 ](http://www.cnblogs.com/MenAngel/p/5617533.html)


* [How To Use Ip Command In Linux with Examples ](https://linoxide.com/linux-command/use-ip-command-linux/)
* [试试Linux下的ip命令，ifconfig已经过时了-技术 ◆ 学习|Linux.中国-开源社区 ](https://linux.cn/article-3144-1.html)

|net-tools|iproute2|
|-|-|
|arp -na|ip neigh|
|ifconfig|ip link|
|ifconfig -a|ip addr show|
|ifconfig --help|ip help|
|ifconfig -s|ip -s link|
|ifconfig eth0 up|ip link set eth0 up|
|ipmaddr|ip maddr|
|iptunnel|ip tunnel|
|netstat|ss|
|netstat -i|ip -s link|
|netstat -g|ip maddr|
|netstat -l|ss -l|
|netstat -r|ip route|
|route add|ip route add|
|route del|ip route del|
|route -n|ip route show|
|vconfig|ip link|



linux的ip命令和ifconfig类似，但前者功能更强大，并旨在取代后者。使用ip命令，只需一个命令，你就能很轻松地执行一些网络管理任务。ifconfig是net-tools中已被废弃使用的一个命令，许多年前就已经没有维护了。iproute2套件里提供了许多增强功能的命令，ip命令即是其中之一。

Net tools vs Iproute2

要安装ip，请点击这里下载iproute2套装工具 。不过，大多数Linux发行版已经预装了iproute2工具。

你也可以使用git命令来下载最新源代码来编译：

```sh
$ git clone https://kernel.googlesource.com/pub/scm/linux/kernel/git/shemminger/iproute2.git
```
iproute2 git clone

## 设置和删除Ip地址

```sh
#要给你的机器设置一个IP地址，可以使用下列ip命令：
$ sudo ip addr add 192.168.0.193/24 dev wlan0
```

请注意IP地址要有一个后缀，比如/24。这种用法用于在无类域内路由选择（CIDR）中来显示所用的子网掩码。在这个例子中，子网掩码是255.255.255.0。

在你按照上述方式设置好IP地址后，需要查看是否已经生效。

$ ip addr show wlan0
set ip address

你也可以使用相同的方式来删除IP地址，只需用del代替add。

$ sudo ip addr del 192.168.0.193/24 dev wlan0
delete ip address

## 列出路由表条目
ip命令的路由对象的参数还可以帮助你查看网络中的路由数据，并设置你的路由表。第一个条目是默认的路由条目，你可以随意改动它。

在这个例子中，有几个路由条目。这个结果显示有几个设备通过不同的网络接口连接起来。它们包括WIFI、以太网和一个点对点连接。

$ ip route show
ip route show

假设现在你有一个IP地址，你需要知道路由包从哪里来。可以使用下面的路由选项（译注：列出了路由所使用的接口等）：

$ ip route get 10.42.0.47
ip route get

## 更改默认路由
要更改默认路由，使用下面ip命令：

$ sudo ip route add default via 192.168.0.196
default route

## 显示网络统计数据
使用ip命令还可以显示不同网络接口的统计数据。

ip statistics all interfaces

当你需要获取一个特定网络接口的信息时，在网络接口名字后面添加选项ls即可。使用多个选项-s会给你这个特定接口更详细的信息。特别是在排除网络连接故障时，这会非常有用。

$ ip -s -s link ls p2p1
ip link statistics

## ARP条目
地址解析协议（ARP）用于将一个IP地址转换成它对应的物理地址，也就是通常所说的MAC地址。使用ip命令的neigh或者neighbour选项，你可以查看接入你所在的局域网的设备的MAC地址。

$ ip neighbour
ip neighbour

## 监控netlink消息
也可以使用ip命令查看netlink消息。monitor选项允许你查看网络设备的状态。比如，所在局域网的一台电脑根据它的状态可以被分类成REACHABLE或者STALE。使用下面的命令：

$ ip monitor all
ip monitor all

## 激活和停止网络接口
你可以使用ip命令的up和down选项来激某个特定的接口，就像ifconfig的用法一样。

在这个例子中，当ppp0接口被激活和在它被停止和再次激活之后，你可以看到相应的路由表条目。这个接口可能是wlan0或者eth0。将ppp0更改为你可用的任意接口即可。

$ sudo ip link set ppp0 down
 
$ sudo ip link set ppp0 up
ip link set up and down

## 获取帮助
当你陷入困境，不知道某一个特定的选项怎么用的时候，你可以使用help选项。man页面并不会提供许多关于如何使用ip选项的信息，因此这里就是获取帮助的地方。

比如，想知道关于route选项更多的信息：

$ ip route help
ip route help

小结
对于网络管理员们和所有的Linux使用者们，ip命令是必备工具。是时候抛弃ifconfig命令了，特别是当你写脚本时。

via: http://linoxide.com/linux-command/use-ip-command-linux/

# iproute2 cheat sheet

* [iproute2 cheat sheet ](http://baturin.org/docs/iproute2/)

# Linux Advanced Routing & Traffic Control HOWTO

* [Linux Advanced Routing & Traffic Control HOWTO ](http://lartc.org/howto/index.html)

# linux ip命令和ifconfig命令

* [linux ip命令和ifconfig命令 - CSDN博客 ](http://blog.csdn.net/freeking101/article/details/68939059)

# 用Iproute2进行隧道配置

* [用Iproute2进行隧道配置 - wqch22hit的专栏 - CSDN博客 ](http://blog.csdn.net/wqch22hit/article/details/26057)
* [用Iproute2进行隧道配置 - 计算机网络知识库 ](http://lib.csdn.net/article/computernetworks/14287)


# Configuring tunnels with iproute2

* [Configuring tunnels with iproute2 ](http://deepspace6.net/docs/iproute2tunnel-en.html)


## 1. iproute2

iproute2 is a package for advanced network management under linux. In practice, it is composed of a bunch of small utilities to dinamically configure the kernel by means of rtnetlink sockets - a modern and powerful interface for the configuration of the networking stack implemented by Alexey Kuznetsov starting from the 2.2 kernel series.

The most interesting feature of iproute2 is that it replaces with a single integrated and organic command all the functionalities we were used to find in ifconfig, arp, route and iptunnel (and it even adds some more!).

Nowadays iproute2 is installed by default on most major distributions, even if their initialization scripts are still built on commands from the old net-tools package (e.g. ifconfig or iptunnel - the latter is actually deprecated). If your distribution doesn't include this important package, you can always download it from [ftpsite] and compile it yourself.

As the time of this writing, the worst defect of iproute2 is a relative lack of documentation, partially compensated by the fact that the syntax of the ip command is very easy and similar to the english language. We believe that people used to ifconfig and route shouldn't encounter any problem using ip and that they will feel at home in a macommander of hours. In this document we will suppose that the reader has already a good knowledge of basic networking concepts and has used ifconfig and route in the past.

## 2. Introduction to tunnels

Let's imagine two Internet nodes wanting to exchange data traffic over a protocol different from IPv4 or directed to a private LAN using non-globally-valid IP addresses. This problem is typically solved using a virtual point-to-point connection between the two nodes and we call this configuration a tunnel.

You can think to every packet traveling over the network like it was an envelope with a few bits inside and the sender's and receiver's addresses written on. Tunnels simply hide this envelope inside an additional one, with different sender and receiver, effectively diverting the packet's trip. When the packet arrives to the external receiver (the one written on the external envelope), the external envelope is removed and thrown away, so that the packet can continue its travel to the real destinantion.

The two nodes putting and removing the additional envelope are called endpoints and need to have a known IPv4 address. This is why tunnels generally don't work when traversing a network address translation (NAT). Moreover, if the tunnel is built throuh a firewall, the latter must be configured ad hoc to permit this kind of traffic.

A typical tunnel usage is connecting two IPv6 nodes through an IPv4-only network. The two nodes can build an IPv6-in-IPv4 tunnel pretending to have a real direct point-to-point IPv6 connection, and this way they can link together two IPv6 islands (6bone works this way, a web of tunnels). Tunnels for IPv6-over-IPv4 transport come in two different flawors: automatic [RFC2373] and manually configured. In this document we will talk only of the latter type.

## 3. Creating tunnels

Creating tunnels with iproute2 is very easy. First of all you need a name for your tunnel. If you choose to name it foo then you can create the tunnel with the command:

```sh
ip tunnel add foo mode sit remote 192.168.1.42
```

This way, you created a sit (IPv6-in-IPv4) tunnel with a remote endpoint at the IP address 192.168.1.42. Notice that we have not specified which IP address to use for the local side of the tunnel, which interface, and so on. The result can be viewed with the command **ip tunnel show**:

```sh
# ip tunnel show 
sit0: ipv6/ip  remote any  local any  ttl 64  nopmtudisc
foo: ipv6/ip  remote 192.168.1.42  local any  ttl inherit
```

Our tunnel is the one in the 2nd row. Now we can also ask a list of all available interfaces, regardless if they are real network adapters or software simulations:

```sh
# ip link show
1: lo: <loopback,up> mtu 16436 qdisc noqueue 
  link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <broadcast,multicast,up> mtu 1500 qdisc pfifo_fast qlen 100
  link/ether 00:48:54:1b:25:30 brd ff:ff:ff:ff:ff:ff
4: sit0@none: <noarp> mtu 1480 qdisc noop 
  link/sit 0.0.0.0 brd 0.0.0.0
6: foo@none: <pointopoint,noarp> mtu 1480 qdisc noop 
  link/sit 0.0.0.0 peer 192.168.1.42
```

The fact that should get your attention is that while lo and eth0 are marked as being up, our tunnel is not. To double check, the good old ifconfig says only:

```sh
# ifconfig
eth0    Link encap:Ethernet  HWaddr 00:48:54:1b:25:30  
        inet addr:192.168.0.1  Bcast:192.168.0.255  Mask:255.255.255.0
        inet6 addr: fe80::248:54ff:fe1b:2530/10 Scope:Link
        UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
        RX packets:0 errors:0 dropped:0 overruns:0 frame:0
        TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
        collisions:0 txqueuelen:100 
        RX bytes:0 (0.0 b)  TX bytes:528 (528.0 b)
        Interrupt:9 Base address:0x5000 

lo      Link Encap:Local Loopback  
        inet addr:127.0.0.1  Mask:255.0.0.0
        inet6 addr: ::1/128 scope:host
        UP LOOPBACK RUNNING  MTU:16436  Metric:1
        RX packets:35402 errors:0 dropped:0 overruns:0 frame:0
        TX packets:35402 errors:0 dropped:0 overruns:0 carrier:0
        collisions:0 txqueuelen:0 
        RX bytes:3433996 (3.2 mb)  TX bytes:3433996 (3.2 mb)          
```

So we must remember that the ip link command shows all available interfaces, regardless of them being activated or not. To activate foo, we use the command:

```sh
ip link set foo up
and to deactivate it:

ip link set foo down
To completely discard our tunnel we use:

ip tunnel del foo
```

## 4. Special tunnels

In the previous paragraph, we've seen how to build an IPv6-in-IPv4 tunnel, now we'll examine a few different situations.

### 4.1. GRE tunnels

If you don't need IPv6 but for example you want to carry normal IPv4 traffic through a non-cooperating transit network, then you'd better use mode gre instead of mode sit. For example:

```sh
# ip tunnel add foo4 mode gre remote 192.168.1.42
# ip tunnel show
gre0: gre/ip  remote any  local any  ttl inherit  nopmtudisc
foo4: gre/ip  remote 192.168.1.42  local any  ttl inherit
# ip link show
1: lo: <loopback,up> mtu 16436 qdisc noqueue 
  link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <broadcast,multicast,up> mtu 1500 qdisc pfifo_fast qlen 100
  link/ether 00:48:54:1b:25:30 brd ff:ff:ff:ff:ff:ff
7: gre0@none: <noarp> mtu 1476 qdisc noop 
  link/gre 0.0.0.0 brd 0.0.0.0
9: foo4@none: <pointopoint,noarp> mtu 1476 qdisc noop 
  link/gre 0.0.0.0 peer 192.168.1.42
```

GRE [RFC2784] is a particular tunnelling protocol supported by Cisco routers which is capable to carry different protocols over IPv4. There's another kind of tunnels implemented by linux: ipip. The latter is also useful for IPv4-in-IPv4 encapsulation, but it's implemented only by linux and does only unicast IP over IP (so you can't transport for example IPX or broadcasts). In general, GRE is better.

### 4.2. Explicit local endpoint

Even if the kernel is smart enough to choose for you, it could be a good idea to explicitly force the local IP address and interface we're going to use for tunneling. To do that, we can use the local and dev parameters:

```sh
# ip tunnel add foo mode sit local 192.168.0.1 remote 192.168.1.42 dev eth0
# ip tunnel show
sit0: ipv6/ip  remote any  local any  ttl 64  nopmtudisc
foo: ipv6/ip  remote 192.168.1.42  local 192.168.0.1  dev eth0  ttl inherit 
# ip link show
1: lo: <loopback,up> mtu 16436 qdisc noqueue 
 link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <broadcast,multicast,up> mtu 1500 qdisc pfifo_fast qlen 100
 link/ether 00:48:54:1b:25:30 brd ff:ff:ff:ff:ff:ff
4: sit0@none: <noarp> mtu 1480 qdisc noop 
 link/sit 0.0.0.0 brd 0.0.0.0
11: foo@eth0: <pointopoint,noarp> mtu 1480 qdisc noop 
 link/sit 192.168.0.1 peer 192.168.1.42
```

Please notice that now the interface is labeled as foo@eth0, to remind us where the tunnel has been explicitly connected.

### 4.3. Time-to-live

When using tunnels, creating accidental loops in the network it's easy. To limit the problem, it's fundamental to generate packets with a low TTL value. Initial TTL can be specified by the ttl parameter in ip tunnel add. The default value is inherited from the network interface the tunnel is associated to. [IANA] suggests using 64 for TTL.

## 5. Assigning an IP address to the interface

Like any other network interface, tunnels can have one or more addresses assigned to them.

### 5.1. Main address

Assigning the main address is straightforward:

```sh
ip addr add 3ffe:9001:210:3::42/64 dev foo  
ip addr add 192.168.0.2/24 dev foo4
ip addr add 10.20.30.40/8 dev eth0
```
      
The number immediately following the slash is to suggest to the kernel the network prefix we prefer, useful to automatically compute broadcast address and netmask on IPv4 LANs (this is called CIDR notation). However, tunnels are point-to-point interfaces and this number is then ignored.

Note: to be able to assign an IP address to an interface, first you need to activate the interface using:

ip link set interfacename up
To remove an address from an interface, you can obviously use del instead of add:

ip addr del 3ffe:9001:210:3::42/64 dev foo
ip addr del 192.168.0.2/24 dev foo4
      
We can even ask for a list of all the IP addresses in use on our server:

```sh
# ip addr show
1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 brd 127.255.255.255 scope host lo
    inet6 ::1/128 scope host 
2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
    link/ether 00:48:54:1b:25:30 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.1/24 brd 192.168.0.255 scope global eth0
    inet6 fe80::248:54ff:fe1b:2530/10 scope link 
4: sit0@NONE: <NOARP> mtu 1480 qdisc noop 
    link/sit 0.0.0.0 brd 0.0.0.0
5: foo@NONE: <POINTOPOINT,NOARP> mtu 1480 qdisc noop 
    link/sit 0.0.0.0 peer 192.168.1.42
    inet6 3ffe:9001:210:3::42/64 scope global 
    inet6 fe80::c0a8:1/10 scope link 
```

### 5.2. Aliasing

When using multiple addresses on a single interface, people used to ifconfig will be surprised noting that multiple ip addr add commands do not generate fictitious interfaces like eth0:1, eth0:2 and so on. This is a legacy naming scheme coming from the 2.0 kernel version and nowadays no more mandated. For example:

```sh
# ip addr add 192.168.0.11/24 dev eth0
# ip addr show eth0
2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
    link/ether 00:48:54:1b:25:30 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.1/24 brd 192.168.0.255 scope global eth0
    inet 192.168.0.11/24 scope global secondary eth0
    inet6 fe80::248:54ff:fe1b:2530/10 scope link 
# ifconfig     
eth0      Link encap:Ethernet  HWaddr 00:48:54:1B:25:30  
          inet addr:192.168.0.1  Bcast:192.168.0.255  Mask:255.255.255.0
          inet6 addr: fe80::248:54ff:fe1b:2530/10 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100 
          RX bytes:0 (0.0 b)  TX bytes:528 (528.0 b)
          Interrupt:9 Base address:0x5000 

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:34732 errors:0 dropped:0 overruns:0 frame:0
          TX packets:34732 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:3386912 (3.2 Mb)  TX bytes:3386912 (3.2 Mb)

foo       Link encap:IPv6-in-IPv4  
          inet6 addr: 3ffe:9001:210:3::42/64 Scope:Global
          inet6 addr: fe80::c0a8:1/10 Scope:Link
          UP POINTOPOINT RUNNING NOARP  MTU:1480  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
``` 

Our addictional IP address is reported by ip addr show and works, but ifconfig doesn't even know of its existence! To solve the problem we can use the label parameter:

```sh
# ip addr add 192.168.0.11/24 label eth0:1 dev eth0
# ip addr show eth0
2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
    link/ether 00:48:54:1b:25:30 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.1/24 brd 192.168.0.255 scope global eth0
    inet 192.168.0.11/24 scope global secondary eth0:1
    inet6 fe80::248:54ff:fe1b:2530/10 scope link 
# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:48:54:1B:25:30  
          inet addr:192.168.0.1  Bcast:192.168.0.255  Mask:255.255.255.0
          inet6 addr: fe80::248:54ff:fe1b:2530/10 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100 
          RX bytes:0 (0.0 b)  TX bytes:528 (528.0 b)
          Interrupt:9 Base address:0x5000 

eth0:1    Link encap:Ethernet  HWaddr 00:48:54:1B:25:30  
          inet addr:192.168.0.11  Bcast:0.0.0.0  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          Interrupt:9 Base address:0x5000 
```

Notice that we can choose any arbitrary string as the label. We're not forced to use the 2.0 naming scheme; we must comply to it only if we care having backward compatibility with ifconfig.

### 5.3. Which IP for the tunnel

Choosing a global/public IP address (respectively an IPv6 address for SIT/IPv6-in-IPv4 tunnels and an IPv4 address for GRE/IPv4-in-IPv4 tunnels) for the local endpoint of the tunnel is probably the best thing we can do when our computer is a single host and not a router providing IPv6 connectivity to a whole LAN.

Instead, if we're configuring a router, we'd better use a link-local address for SIT/IPv6-in-IPv4 tunnels (in IPv6 link-local addresses are assigned automatically by means of stateless address autoconfiguration or manually configured) and a private address for GRE/IPv4-in-IPv4 tunnels (IPv4 has no link-local addresses). The valid address will then be only on eth0 (or the interface on the LAN side). Notice that in this configuration you need to activate forwarding among interfaces, using these commands:

```sh
sysctl -w net.ipv4.conf.all.forwarding=1  # for GRE (IPv4-in-IPv4)
sysctl -w net.ipv6.conf.all.forwarding=1  # for SIT (IPv6-in-IPv4)
```

For IPv4 you can even decide to enable forwarding only between a couple of interfaces, in this case you could use these commands:

```sh
sysctl -w net.ipv4.conf.eth0.forwarding=1
sysctl -w net.ipv4.conf.pippo.forwarding=1
```

Warning

meaning of this switch is different for IPv6 and doesn't work as expected, see kernel documentation for more information.

## 6. Routing

Now that our tunnel is configured, we have to specify which traffic will be directed through it. For IPv6 the most common choice is the following:

ip route add 2000::/3 dev foo
This way all IPv6 traffic going to addresses starting with 3 bits equal to 001 (that is, all global unicast IPv6 address space) will be directed to the foo interface. This is only one 8th of the available IPv6 address space, but you are guaranteed that every possible remote host will be in this range.

We can see the IPv4 routing table this way:

```sh
# ip route
192.168.0.0/24 dev eth0  scope link 
127.0.0.0/8 dev lo  scope link 
```
    
and the IPv6 routing table this way:

```sh
# ip -6 route
2000::/3 dev foo  proto kernel  metric 256  mtu 1480 advmss 1420
fe80::/10 dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440
fe80::/10 dev foo  proto kernel  metric 256  mtu 1480 advmss 1420
ff00::/8 dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440
ff00::/8 dev foo  proto kernel  metric 256  mtu 1480 advmss 1420
default dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440
unreachable default dev lo  metric -1  error -101
```

If you need to specify a gateway (this is not for tunnels) then you can add the via parameter, for example:

ip route add 192.168.1.0/24 via 192.168.0.254 dev eth0
To remove a route you can obviously use ip route del but be careful: if you write ip route del default you're removing the default IPv4 route, not the IPv6 one! To remove the IPv6 default destination you need to use ip -6 route del default.

## 7. Practical applications

### 7.1. A complete example

This is a typical IPv6 tunnel for 6bone:

```sh
ip tunnel add $TUNNEL mode sit local any remote $V4_REMOTEADDR ttl 64
ip link   set $TUNNEL up
ip addr   add $V6_LOCALADDR dev $TUNNEL
ip route  add 2000::/3      dev $TUNNEL
```

where $TUNNEL is an arbitrary name assigned to the tunnel, $V4_REMOTEADDR is the IPv4 address of the remote end of the tunnel and $V6_LOCALADDR is the IPv6 local address assigned to our host. We've used the any value for the local endpoint address because this way we can handle a dynamic IPv4 address (e.g. assigned by a dialup connection to the ISP). Obviously we need to inform our tunnel broker when our address changes but this is out of the scope of this writing, also because there's no general standard procedure.

To shut down the tunnel:

ip tunnel del $TUNNEL
also automatically removes the routing entry and the address.

### 7.2. Comfort

Now, after we made sure everything works, we can use previous commands in a script called ip-up.local and saved in /etc/ppp/. This way, those commands will be automatically executed everytime we connect PPP. If we wanted to also automatically delete the tunnel upon PPP disconnection, we can create another script in the same directory, and call it ip-down.local.

As an example, if our tunnel broker is [NGNET], we could use this script as ip-up.local:

```pl
#!/usr/bin/perl
####################################################################
# Auto-setup script for NGNET's Tunnel Broker.
####################################################################

# Configuration, fill with your values
# ------------------------------------
my $username  = '';
my $password  = '';
my $interface = '';
my $v6hname   = '';

# Don't touch anything below this line
# ------------------------------------

my $ngnet_tb  = '163.162.170.173';
my $ipv6_pref = '2001:06b8:0000:0400::/64';
my $url       = 'https://tb.ngnet.it/cgi-bin/tb.pl';

use strict;
use IO::File;
use LWP::UserAgent;

# Get our IPv4 address
my $lines;
my $f = IO::File->new();
$f->open("/sbin/ip addr show dev $interface|") or die("$!\n");
$f->read($lines, 4096);
$f->close();
$lines =~ /(\d+\.\d+\.\d+\.\d+)/ or die('Impossible condition');
my $v4addr = $1;

# Logging in
my $ua = LWP::UserAgent->new(keep_alive => 5);
my $resp = $ua->post($url, { 
	oper     => 'reg_accesso',
	username => $username,
	password => $password,
	submit   => 'Submit'
});
$resp->is_success() or die('Failed reg_accesso: '.$resp->message);
$resp->as_string =~ /name=sid.*value=\"([^\"]+)\"/i or die('Missing sid');
my $sid = $1;

# Retrieve IPv6 addresses
my $myipv6;
my $ipv6end;
$resp = $ua->post($url, {
	oper        => 'tunnel_info',
	sid         => $sid,
	username    => $username,
	submit      => 'Submit'
});
$resp->is_success() or die('Failed tunnel_info: '.$resp->message);
$resp->as_string =~ /name=ipv6client.*value=\"([^\"]+)\"/i and $myipv6 = $1;
$resp->as_string =~ /name=ipv6server.*value=\"([^\"]+)\"/i and $ipv6end = $1;
die("missing IPv6 endpoints") unless ($myipv6 and $ipv6end);

# Extend tunnel lifetime
$resp = $ua->post($url, {
	oper        => 'tunnel_extend',
	sid         => $sid,
	username    => $username,
	submit      => 'Submit'
});
$resp->is_success() or die('Failed tunnel_extend: '.$resp->message);

# Update parameters on the remote side
$resp = $ua->post($url, {
	oper        => 'update_parameter',
	sid         => $sid,
	os_type     => 'Linux',
	ipv4client  => $v4addr,
	fl_entry    => $v6hname,
	username    => $username,
	ipv6_pref   => $ipv6_pref,
	submit      => 'Submit'
});
$resp->is_success() or die('Failed update_parameter: '.$resp->message);

# Set up tunnel on our side
system("/sbin/modprobe ipv6");
system("/sbin/ip tunnel add ngnet mode sit local any remote $ngnet_tb ttl 64");
system("/sbin/ip link set ngnet up");
system("/sbin/ip addr add $myipv6 dev ngnet");
system("/sbin/ip route add 2000::/3 dev ngnet");
```

ip-down.local could be:
```bash
#!/bin/bash
/sbin/ip tunnel del ngnet
```

## 8. Thanks

Thank to Giacomo Piva for pppd and NGNET integration idea.

References

Here are some useful links:

[IANA] Internet assigned numbers authority.

[ftpsite] iproute2 ftp site.

[RFC2784] Generic Routing Encapsulation (GRE). IETF. March 2000. Farinacci. Li. Hanks. Meyer. Traina.

[RFC2373] IP Version 6 Addressing Architecture. IETF. July 1998. Hinden. Deering.

[RFC2893] Transition Mechanisms for IPv6 Hosts and Routers. IETF. August 2000. Gilligan. Nordmark.

[NGNET] Telecom Italia Lab NGNET.