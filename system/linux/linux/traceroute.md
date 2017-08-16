




* [每天一个linux命令（55）：traceroute命令 - peida - 博客园 ](http://www.cnblogs.com/peida/archive/2013/03/07/2947326.html)
* [Linux常用网络工具：路由扫描之traceroute - 全栈工程狮 - 博客园 ](http://www.cnblogs.com/ym123/p/4556723.html)


# 安装

> yum -y install traceroute

# 基本使用

路由扫描工具的原理都是`存活时间（TTL）`来实现的。每当数据包经过一个路由器，其`存活时间就会减1`。当其存活时间是0时，主机便取消数据包，并传送一个ICMP TTL数据包给原数据包的发出者，路由扫描工具就通过这个回送的ICMP来获得经过的每一跳路由的信息。

Linux下的traceroute和Windows的tracert功能相似，所不同的是Windows的tracert发送的是`ICMP报文`，Linux的traceroute发送的是`UDP数据包`。

traceroute通过发送小的数据包到目的设备直到其返回，来测量其需要多长时间。一条路径上的每个设备`traceroute要测3次`。输出结果中包括每次`测试的时间(ms)和设备的名称`（如有的话）及其IP地址。

由于traceroute使用UDP协议，所以其目标端口号默认为33433，一般应用程序都不会用到这个端口，所以目标主机会回送ICMP。

traceroute也支持发送TCP和ICMP：

-I  --icmp                  Use ICMP ECHO for tracerouting
-T  --tcp                   Use TCP SYN for tracerouting
-p port  --port=port 
一般的Linux都会默认带有traceroute工具，如果没有可以yum安装一下。

traceroute最简单的基本用法是：traceroute hostname，示例：
```sh
# traceroute  192.168.0.99
traceroute to 192.168.0.99 (192.168.0.99), 30 hops max, 60 byte packets
 1  192.168.2.1 (192.168.2.1)  5.642 ms  5.901 ms  12.287 ms
 2  192.168.0.99 (192.168.0.99)  0.416 ms  1.193 ms  1.045 ms
```
traceroute会对每个节点测试三次，因此每一行会有三个时间，通过这个时间可以分析出哪一个路由节点延时最大。

# Traceroute的工作原理：
Traceroute最简单的基本用法是：traceroute hostname
Traceroute程序的设计是利用ICMP及IP header的TTL（Time To Live）栏位（field）。首先，traceroute送出一个TTL是1的IP datagram（其实，每次送出的为3个40字节的包，包括源地址，目的地址和包发出的时间标签）到目的地，当路径上的第一个路由器（router）收到这个datagram时，它将TTL减1。此时，TTL变为0了，所以该路由器会将此datagram丢掉，并送回一个「ICMP time exceeded」消息（包括发IP包的源地址，IP包的所有内容及路由器的IP地址），traceroute 收到这个消息后，便知道这个路由器存在于这个路径上，接着traceroute 再送出另一个TTL是2 的datagram，发现第2 个路由器...... traceroute 每次将送出的datagram的TTL 加1来发现另一个路由器，这个重复的动作一直持续到某个datagram 抵达目的地。当datagram到达目的地后，该主机并不会送回ICMP time exceeded消息，因为它已是目的地了，那么traceroute如何得知目的地到达了呢？
Traceroute在送出UDP datagrams到目的地时，它所选择送达的port number 是一个一般应用程序都不会用的号码（30000 以上），所以当此UDP datagram 到达目的地后该主机会送回一个「ICMP port unreachable」的消息，而当traceroute 收到这个消息时，便知道目的地已经到达了。所以traceroute 在Server端也是没有所谓的Daemon 程式。
Traceroute提取发 ICMP TTL到期消息设备的IP地址并作域名解析。每次 ，Traceroute都打印出一系列数据,包括所经过的路由设备的域名及 IP地址,三个包每次来回所花时间。

# 命令参数：

```sh
-d 使用Socket层级的排错功能。
-f 设置第一个检测数据包的存活数值TTL的大小。
-F 设置勿离断位。
-g 设置来源路由网关，最多可设置8个。
-i 使用指定的网络界面送出数据包。
-I 使用ICMP回应取代UDP资料信息。
-m 设置检测数据包的最大存活数值TTL的大小。
-n 直接使用IP地址而非主机名称。
-p 设置UDP传输协议的通信端口。
-r 忽略普通的Routing Table，直接将数据包送到远端主机上。
-s 设置本地主机送出数据包的IP地址。
-t 设置检测数据包的TOS数值。
-v 详细显示指令的执行过程。
-w 设置等待远端主机回报的时间。
-x 开启或关闭数据包的正确性检验。
```

# traceroute使用技巧

用traceroute一些网站时，可能无法到达最终节点，如：

```sh
[root@localhost manifests]# traceroute www.baidu.com
traceroute to www.baidu.com (14.215.177.37), 30 hops max, 60 byte packets
 1  * * *
 2  192.168.20.1 (192.168.20.1)  0.398 ms  0.451 ms  0.523 ms
 3  65.32.137.219.broad.gz.gd.dynamic.163data.com.cn (219.137.32.65)  7.002 ms  7.001 ms  7.002 ms
 4  121.33.196.125 (121.33.196.125)  2.289 ms  2.321 ms 121.33.196.121 (121.33.196.121)  2.263 ms
 5  183.56.31.41 (183.56.31.41)  2.796 ms 183.56.31.21 (183.56.31.21)  3.199 ms 183.56.31.41 (183.56.31.41)  2.879 ms
 6  121.8.134.105 (121.8.134.105)  2.892 ms 183.56.34.9 (183.56.34.9)  3.069 ms 183.56.34.29 (183.56.34.29)  2.957 ms
 7  113.96.4.78 (113.96.4.78)  7.102 ms 113.96.4.74 (113.96.4.74)  1.921 ms 113.96.4.66 (113.96.4.66)  5.224 ms
 8  * * *
 9  14.29.121.190 (14.29.121.190)  4.357 ms 14.29.117.238 (14.29.117.238)  4.177 ms 14.29.121.182 (14.29.121.182)  4.270 ms
10  * * *
```

有时我们traceroute 一台主机时，会看到有一些行是`以星号表示的`。出现这样的情况，可能是防火墙`封掉了ICMP的返回信息`，所以我们得不到什么相关的数据包返回数据。

这主要是因为有些服务器把UDP数据包屏蔽了，所以没有返回ICMP。

对于有HTTP服务的主机，可以用参数设置traceroute使用TCP协议进行探测，就可以获得最终节点：

有时我们在某一网关处延时比较长，有可能是某台网关比较阻塞，也可能是物理设备本身的原因。当然如果某台DNS出现问题时，不能解析主机名、域名时，也会 有延时长的现象；您可以`加-n 参数来避免DNS解析，以IP格式输出数据`。


```sh
#跳数设置
traceroute -m 10 www.baidu.com 
#显示IP地址，不查主机名，避免DNS解析
traceroute -n www.baidu.com 
#探测包使用的基本UDP端口设置6888
traceroute -p 6888 www.baidu.com 
#把探测包的个数设置为值4
traceroute -q 4 www.baidu.com 
#绕过正常的路由表，直接发送到网络相连的主机
traceroute -r www.baidu.com
#把对外发探测包的等待响应时间设置为3秒
traceroute -w 3 www.baidu.com
```
