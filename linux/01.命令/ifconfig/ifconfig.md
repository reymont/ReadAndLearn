
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [ifconfig详解](#ifconfig详解)
	* [1.ifconfig 查看网络接口状态](#1ifconfig-查看网络接口状态)
	* [2.ifconfig 配置网络接口](#2ifconfig-配置网络接口)
		* [＊ 调试eth0网卡的地址 ：](#调试eth0网卡的地址)
		* [＊ 设置网卡的物理地址（MAC地址）；](#设置网卡的物理地址mac地址)
	* [3.如何用ifconfig 来配置虚拟网络接口](#3如何用ifconfig-来配置虚拟网络接口)
	* [4.如何用ifconfig 来激活和终止网络接口的连接](#4如何用ifconfig-来激活和终止网络接口的连接)
* [Linux下ifconfig配置IP地址](#linux下ifconfig配置ip地址)
	* [静态修改方式：](#静态修改方式)
	* [动态方法：](#动态方法)

<!-- /code_chunk_output -->

---

# ifconfig详解

* [ifconfig详解 — 人人小站 ](http://zhan.renren.com/cxymst?gid=3602888498030770811&checked=true)

ifconfig 是一个用来查看、配置、启用或禁用网络接口的工具，这个工具极为常用的。可以用这个工具来临时性的配置网卡的IP地址、掩码、广播地址、网关等。也可以把它写入一个文件中（比如**/etc/rc.d/rc.local**)，这样系统引导后，会读取这个文件，为网卡设置IP地址 

## 1.ifconfig 查看网络接口状态  

ifconfig 如果不接任何参数，就会输出当前网络接口的情况； 

* eth0 表示第一块网卡
* HWaddr 表示网卡的物理地址(MAC地址)00:03:0D:27:86:41; 
* inet addr：IPv4的IP地址，此网卡的 IP地址是 192.168.1.86；
* 广播地址， Bcast:192.168.1.255，
* 掩码地址Mask:255.255.255.0 
* inet6 addr：IPv6的IP地址；
* MTU
* RX：网络由启动到目前为止的封包**接收**情况，packets封包数，errors封包错误数，dropped问题封包丢弃数；
* TX：网络由启动到目前为止的封包**传送**情况；
* collisions：封包碰撞，网络状况；
* RX bytes，TX bytes：总接收、发送字节总量；

lo 是表示主机的回坏地址，这个一般是用来测试一个网络程序，但又不想让局域网或外网的用户能够查看，只能在此台主机上运行和查看所用的网络接口。比如把 HTTPD服务器的指定到回坏地址，在浏览器输入 127.0.0.1 就能看到你所架WEB网站了。但只是您能看得到，局域网的其它主机或用户无从知道； 

```sh
#如果想知道主机所有网络接口的情况，请用下面的命令； 
[root@linuxchao ~]#ifconfig -a 
#如果想查看某个端口，比如查看eth0 的状态，就可以用下面的方法； 
[root@linuxchao ~]#ifconfig eth0 
```

## 2.ifconfig 配置网络接口  

ifconfig 可以用来配置网络接口的IP地址、掩码、网关、物理地址等；值得一说的是用ifconfig 为网卡指定IP地址，这只是用来调试网络用的，并不会更改系统关于网卡的配置文件。如果您想把网络接口的IP地址固定下来，目前有三个方法：

* 一是通过各个发行和版本专用的工具来修改IP地址；
* 二是直接修改网络接口的配置文件；
* 三是修改特定的文件，加入ifconfig 指令来指定网卡的IP地址，比如在redhat或Fedora中，把ifconfig 的语名写入/etc/rc.d/rc.local文件中； 

ifconfig 配置网络端口的方法： 

> ifconfig 工具配置网络接口的方法是通过指令的参数来达到目的的，我们只说最常用的参数； 
ifconfig 网络端口 IP地址 **hw** MAC地址 **netmask** 掩码地址 **broadcast** 广播地址 [up/down]

### ＊ 调试eth0网卡的地址 ：  
```sh
#ifconfig eth0 down 表示如果eth0是激活的，就把它DOWN掉。此命令等同于 ifdown eth0；
[root@linuxchao ~]#ifconfig eth0 down 
#用ifconfig 来配置 eth0的IP地址、广播地址和网络掩码；
[root@linuxchao ~]#ifconfig eth0 192.168.1.99 broadcast 192.168.1.255 netmask 255.255.255.0 
# 用ifconfig eth0 up 来激活eth0 ； 此命令等同于 ifup eth0 
[root@linuxchao ~]#ifconfig eth0 up 
# 用 ifconfig eth0 来查看 eth0的状态；
[root@linuxchao ~]#ifconfig eth0 
# 也可以用直接在指令IP地址、网络掩码、广播地址的同时，激活网卡；要加up参数；
[root@linuxchao ~]#ifconfig eth0 192.168.1.99 broadcast 192.168.1.255 netmask 255.255.255.0 up 
```

### ＊ 设置网卡的物理地址（MAC地址）； 

```sh
# 设置网卡eth1的IP地址、网络掩码、广播地址，物理地址并且激活它； 
# 其中 hw 后面所接的是网络接口类型， ether表示乙太网， 同时也支持 ax25 、ARCnet、netrom等，详情请查看 man ifconfig ； 
[root@linuxchao ~]#ifconfig eth1 192.168.1.252 hw ether 04:64:03:00:12:51 netmask 255.255.255.0 broadcast 192.168.1.255 up 
或 
[root@linuxchao ~]#ifconfig eth1 hw ether 04:64:03:00:12:51 
[root@linuxchao ~]#ifconfig eth1 192.168.1.252 netmask 255.255.255.0 broadcast 192.168.1.255 up 
```

## 3.如何用ifconfig 来配置虚拟网络接口  

有时我们为了满足不同的需要还需要配置虚拟网络接口，比如我们用不同的IP地址来架运行多个HTTPD服务器，就要用到虚拟地址；这样就省却了同一个IP地址，如果开设两个的HTTPD服务器时，要指定端口号。 

虚拟网络接口指的是为一个网络接口指定多个IP地址，虚拟接口是这样的 eth0:0 、 eth0:1、eth0:2 ... .. eth1N。当然您为eth1 指定多个IP地址，也就是 eth1:0、eth1:1、eth1:2 ... ...以此类推； 

其实用ifconfig 为一个网卡配置多个IP地址，就用前面我们所说的ifconfig的用法，这个比较简单；看下面的例子； 
```sh
[root@linuxchao ~]#ifconfig eth1:0 192.168.1.251 hw ether 04:64:03:00:12:51 netmask 255.255.255.0 broadcast 192.168.1.255 up 
或 
[root@linuxchao ~]#ifconfig eth1 hw ether 04:64:03:00:12:51 
[root@linuxchao ~]#ifconfig eth1 192.168.1.251 netmask 255.255.255.0 broadcast 192.168.1.255 up 
```

注意：指定时，要为**每个虚拟网卡指定不同的物理地址**； 

在 Redhat/Fedora 或与Redhat/Fedora类似的系统，您可以把配置网络IP地址、广播地址、掩码地址、物理地址以及激活网络接口同时放在一个句子中，写入/etc/rc.d/rc.local中。比如下面的例子； 
```sh
ifconfig eth1:0 192.168.1.250 hw ether 00:11:00:33:11:44 netmask 255.255.255.0 broadcast 192.168.1.255 up
ifconfig eth1:1 192.168.1.249 hw ether 00:11:00:33:11:55 netmask 255.255.255.0 broadcast 192.168.1.255 up
```
解说：上面是为eth1的网络接口，设置了两个虚拟接口；每个接口都有自己的物理地址、IP地址... ... 


## 4.如何用ifconfig 来激活和终止网络接口的连接  

激活和终止网络接口的用 ifconfig 命令，后面接网络接口，然后加上 down或up参数，就可以禁止或激活相应的网络接口了。当然也可以用专用工具ifup和ifdown 工具； 
[root@linuxchao ~]#ifconfig eth0 down 
[root@linuxchao ~]#ifconfig eth0 up 
[root@linuxchao ~]#ifup eth0 
[root@linuxchao ~]#ifdown eth0 

对于激活其它类型的网络接口也是如此，比如 ppp0，wlan0等；不过只是对指定IP的网卡有效。


# Linux下ifconfig配置IP地址

* [Linux下ifconfig配置IP地址 - blank - CSDN博客 ](http://blog.csdn.net/hbyshlr/article/details/7164150)

> cat /etc/sysconfig/network-scripts/ifcfg-ens192

## 静态修改方式： 
编辑文件/etc/sysconfig/network-scripts/ifcfg-eth0
```conf
DEVICE=eth0 //设备名称
BOOTPROTO=static //获得IP的方式或依赖的协议，可以是static/dhcp/bootp
BROADCAST=10.10.22.255 //广播地址，一般为本网段的最后一个IP
IPADDR=10.10.22.145 //ip地址
NETMASK=255.255.255.0 //子网掩码
NETWORK=10.10.22.0 //网段地址
ONBOOT=yes //是否启动时激活该网卡
TYPE=Ethernet //网络类型
```
注意： ifcfg-eth0是第一张网卡，ifcfg-eth1是第二张网卡，依次类推，如果再增加一个ip，则再增加如下配置：
```conf
DEVICE=eth0:1 //设备名称
BOOTPROTO=static 
BROADCAST=10.10.44.255 //广播地址，一般为本网段的最后一个IP
IPADDR=10.10.44.145 //ip地址
NETMASK=255.255.255.0 //子网掩码
NETWORK=10.10.44.0 //网段地址
ONBOOT=yes 
TYPE=Ethernet 
```
同样如果在第二张网卡，则需要增加：
```conf
DEVICE=eth1:0 //设备名称
BOOTPROTO=static 
BROADCAST=10.10.33.255 //广播地址，一般为本网段的最后一个IP
IPADDR=10.10.33.145 //ip地址
NETMASK=255.255.255.0 //子网掩码
NETWORK=10.10.33.0 //网段地址
ONBOOT=yes 
TYPE=Ethernet 
```
增加默认网关的方法：
注意一台机器只能有一个缺省网关，否则就应该给出具体的路由方式。
在相关的设备配置中增加一项即可，例如在上述配置中，在第一张网卡的第一个IP增加一个缺省网关：
```conf
DEVICE=eth0
BOOTPROTO=static
BROADCAST=10.10.22.255
IPADDR=10.10.22.145
NETMASK=255.255.255.0
NETWORK=10.10.22.0
ONBOOT=yes
TYPE=Ethernet
GATEWAY=10.10.22.3
```

修改完成后，要想使上述修改生效，需要重起网络。
重起网络的方法是：service network restart以上为静态增加ip的方法，即机器重起后仍然有效的方法。


## 动态方法：

```sh
#注意：所有操作均使用root用户
#修改IP：
ifconfig eth0 10.10.22.145
#则直接将第一张网卡的IP修改成10.10.22.145增加IP：
#增加一个IP
ifconfig eth0 add 10.10.33.145 
#修改刚刚增加IP的广播地址再增加一个IP：
ifconfig eth0:0 broadcast 10.10.33.255 
ifconfig eth0:0 add 10.10.44.145
#修改刚刚增加IP的广播地址
ifconfig eth0:0:1 broadcast 10.10.44.255 
#千万不要如下操作：
ifconfig eth0 add 10.10.44.145
#这样就把刚刚加的IP10.10.33.145修改成了10.10.44.145
#再增加一个IP：
ifconfig eth0:0:1 add 10.10.55.145
#修改刚刚增加IP的广播地址
ifconfig eth0:0:1:1 broadcast 10.10.55.255 
```