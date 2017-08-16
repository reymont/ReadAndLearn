

[DNSmasq – 配置DNS和DHCP - nosodeep的专栏 - CSDN博客 ](http://blog.csdn.net/nosodeep/article/details/45971705)

原文：[http://debugo.com/dnsmasq/](http://debugo.com/dnsmasq/)

DNSmasq是一个小巧且方便地用于配置DNS和DHCP的工具，适用于小型网络。它提供了DNS功能和可选择的DHCP功能可以取代dhcpd(DHCPD服务配置)和bind等服务，配置起来更简单，更适用于虚拟化和大数据环境的部署。

dhcp服务
其中一些关键的配置如下,配置文件/etc/dnsmasq.conf 中的注释已经给出了非常详细的解释。


```bash
# 服务监听的网络接口地址
# If you want dnsmasq to listen for DHCP and DNS requests only on
# specified interfaces (and the loopback) give the name of the
# interface (eg eth0) here.
# Repeat the line for more than one interface.
#interface=
# Or you can specify which interface _not_ to listen on
#except-interface=
# Or which to listen on by address (remember to include 127.0.0.1 if
# you use this.)
listen-address=192.168.1.132,127.0.0.1
 
# dhcp动态分配的地址范围
# Uncomment this to enable the integrated DHCP server, you need
# to supply the range of addresses available for lease and optionally a lease time
dhcp-range=192.168.1.50,192.168.1.150,48h
 
# dhcp服务的静态绑定
# Always set the name and ipaddr of the host with hardware address
# dhcp-host=00:0C:29:5E:F2:6F,192.168.1.201
# dhcp-host=00:0C:29:5E:F2:6F,192.168.1.201,infinite	无限租期
dhcp-host=00:0C:29:5E:F2:6F,192.168.1.201,os02
dhcp-host=00:0C:29:15:63:CF,192.168.1.202,os03
 
# 设置默认租期
# Set the limit on DHCP leases, the default is 150
#dhcp-lease-max=150
 
# 租期保存在下面文件
# The DHCP server needs somewhere on disk to keep its lease database.
# This defaults to a sane location, but if you want to change it, use
# the line below.
#dhcp-leasefile=/var/lib/dnsmasq/dnsmasq.leases
 
# 通过/etc/hosts来分配对应的hostname
# Enable the address given for "judge" in /etc/hosts
# to be given to a machine presenting the name "judge" when
# it asks for a DHCP lease.
#dhcp-host=judge
 
# 忽略下面MAC地址的DHCP请求
# Never offer DHCP service to a machine whose ethernet
# address is 11:22:33:44:55:66
#dhcp-host=11:22:33:44:55:66,ignore
 
# dhcp所在的domain
# Set the domain for dnsmasq. this is optional, but if it is set, it
# does the following things.
# 1) Allows DHCP hosts to have fully qualified domain names, as long
#     as the domain part matches this setting.
# 2) Sets the "domain" DHCP option thereby potentially setting the
#    domain of all systems configured by DHCP
# 3) Provides the domain part for "expand-hosts"
domain=debugo.com
 
# 设置默认路由出口
# dhcp-option遵循RFC 2132（Options and BOOTP Vendor Extensions),可以通过dnsmasq --help dhcp来查看具体的配置
# 很多高级的配置，如iSCSI连接配置等同样可以由RFC 2132定义的dhcp-option中给出。
# option 3为default route
# Override the default route supplied by dnsmasq, which assumes the
# router is the same machine as the one running dnsmasq.
dhcp-option=3,192.168.0.1
 
# 设置NTP Server.这是使用option name而非选项名来进行设置
# Set the NTP time server addresses to 192.168.0.4 and 10.10.0.5
#dhcp-option=option:ntp-server,192.168.0.4,10.10.0.5
```

注意:当为某一MAC地址同时静态分配主机名和IP时，如果写到两条dhcp-host选项里（如下所示），则只会生效后面的一条。正确的选项写法如上配置。

```bash
dhcp-host=00:0C:29:5E:F2:6F,192.168.1.201
dhcp-host=00:0C:29:5E:F2:6F,os02
```

重新启动客户端网卡。由于之前测试中客户端网卡已经申请了DHCP租期。所以这里需要修改租期文件，让客户端重新获得IP和hostname。

```bash
[root@server] vim /var/lib/dnsmasq/dnsmasq.leases
1400240493 00:0c:29:5e:f2:6f 192.168.1.143 os02 *
1400240498 00:0c:29:15:63:cf 192.168.1.52 os01 *
```

启动dnsmasq服务（server的IP为192.168.1.132）
```
[root@server]
dnsmasq
```

下面在客户端进行测试：

```bash
# 确保网络接口配置使用dhcp方式
[root@localhost] cat /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE="eth1"
BOOTPROTO=dhcp
IPV6INIT=no
NM_CONTROLLED=no
ONBOOT="yes"
TYPE="Ethernet"
# 重启网络服务
[root@localhost] service network restart
Shutting down interface eth0:                              [  OK  ]
Shutting down loopback interface:                          [  OK  ]
Bringing up loopback interface:                            [  OK  ]
Bringing up interface eth0:  
Determining IP information for eth1... done.
# 检查IP地址                                                           [  OK  ]
[root@os03] ifconfig
eth1      Link encap:Ethernet  HWaddr 00:0C:29:15:63:D9  
          inet addr:192.168.1.202  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fe15:63d9/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:251 errors:0 dropped:0 overruns:0 frame:0
          TX packets:43 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:36077 (35.2 KiB)  TX bytes:4598 (4.4 KiB)
......
# 检查默认路由
[root@os03] route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
192.168.1.0     0.0.0.0         255.255.255.0   U     0      0        0 eth1
169.254.0.0     0.0.0.0         255.255.0.0     U     1002   0        0 eth1
```

# 配置DNS服务
dnsmasq能够缓存外部DNS记录，同时提供本地DNS解析或者作为外部DNS的代理，即dnsmasq会首先查找/etc/hosts等本地解析文件，然后再查找/etc/resolv.conf等外部nameserver配置文件中定义的外部DNS。所以说dnsmasq是一个很不错的DNS中继。DNS配置同样写入dnsmasq.conf配置文件里。

```bash
# 本地解析文件
# If you don't want dnsmasq to read /etc/hosts, uncomment the following line.
#no-hosts
# or if you want it to read another file, as well as /etc/hosts, use this.
#addn-hosts=/etc/banner_add_hosts
 
# Set this (and domain: see below) if you want to have a domain
# automatically added to simple names in a hosts-file.
# 例如，/etc/hosts中的os01将扩展成os01.debugo.com
expand-hosts
# Add local-only domains here, queries in these domains are answered
# from /etc/hosts or DHCP only.
local=/debugo.com/
 
# 强制使用完整的解析名
# Never forward plain names (without a dot or domain part)
domain-needed
 
# 添加额外的上级DNS主机（nameserver）配置文件
# Change this line if you want dns to get its upstream servers from
# somewhere other that /etc/resolv.conf
#resolv-file=
 
# 不使用上级DNS主机配置文件(/etc/resolv.conf和resolv-file）
# If you don't want dnsmasq to read /etc/resolv.conf or any other
# file, getting its servers from this file instead (see below), then
# uncomment this.
no-resolv
# 相应的，可以为特定的域名指定解析它的nameserver。一般是其他的内部DNS name server
# Add other name servers here, with domain specs if they are for
# non-public domains.
# server=/myserver.com/192.168.0.1
 
# 设置DNS缓存大小（单位：DNS解析条数）
#Set the size of dnsmasq's cache. The default is 150 names. Setting the cache size to zero disables caching.
cache-size=500
 
# 关于log的几个选项
# For debugging purposes, log each DNS query as it passes through
# dnsmasq.
log-queries
 
# Log lots of extra information about DHCP transactions.
#log-dhcp
 
# Log to this syslog facility or file. (defaults to DAEMON)
log-facility=/var/log/dnsmasq.log
 
# 异步log，缓解阻塞，提高性能。
# Enable asynchronous logging and optionally set the limit on the number of lines which will be queued by dnsmasq
# when writing to the syslog is slow.
# Dnsmasq can log asynchronously: this allows it to continue functioning without being blocked by syslog,
# and allows syslog to use dnsmasq for DNS queries without risking deadlock. If the queue of log-lines becomes
# full, dnsmasq will log the overflow, and the number of messages lost.
# The default queue length is 5, a sane value would be 5-25, and a maximum limit of 100 is imposed.
log-async=20
 
# 指定domain的IP地址
# Add domains which you want to force to an IP address here.
# The example below send any host in doubleclick.net to a local
# webserver.
address=/doubleclick.net/127.0.0.1
address=/.phobos.apple.com/202.175.5.114
```

配置完成后重启dnsmasq，然后在客户端测试：


```bash
[root@os03] nslookup os01.debugo.com
Server: 192.168.1.132
Address: 192.168.1.132#53
Name: os01.debugo.com
Address: 192.168.1.132
[root@os03] nslookup os02.debugo.com
Server: 192.168.1.132
Address: 192.168.1.132#53
Name: os02.debugo.com
Address: 192.168.1.201
[root@os03] nslookup doubleclick.net
Server: 192.168.1.132
Address: 192.168.1.132#53
Name: doubleclick.net
Address: 127.0.0.1
#注意，由于address选项解析为127.0.0.1，而非server的192.168.1.132地址。
[root@os03] nslookup a1.phobos.apple.com
Server: 192.168.1.132
Address: 192.168.1.132#53
Name: a1.phobos.apple.com
Address: 202.175.5.114
^^