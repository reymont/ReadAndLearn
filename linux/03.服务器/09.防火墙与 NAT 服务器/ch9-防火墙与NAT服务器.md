

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [9 防火墙与 NAT 服务器](#9-防火墙与-nat-服务器)
	* [9.3 Linux 的封包过滤软件： iptables](#93-linux-的封包过滤软件-iptables)
		* [9.3.1 不同 Linux 核心版本的防火墙软件](#931-不同-linux-核心版本的防火墙软件)
		* [9.3.2 封包进入流程：规则顺序的重要性！](#932-封包进入流程规则顺序的重要性)
		* [9.3.3 iptables 的表格 (table) 与链 (chain)](#933-iptables-的表格-table-与链-chain)
		* [9.3.4 本机的 iptables 语法](#934-本机的-iptables-语法)
			* [9.3.4-1 规则的观察与清除](#934-1-规则的观察与清除)
			* [9.3.4-2 定义预设政策 (policy)](#934-2-定义预设政策-policy)
			* [9.3.4-3 封包的基础比对： IP, 网域及接口装置](#934-3-封包的基础比对-ip-网域及接口装置)
			* [9.3.4-4 TCP, UDP 的规则比对：针对埠口设定](#934-4-tcp-udp-的规则比对针对埠口设定)
			* [9.3.4-5 iptables 外挂模块： mac 与 state](#934-5-iptables-外挂模块-mac-与-state)
			* [9.3.4-6 ICMP 封包规则的比对：针对是否响应 ping 来设计](#934-6-icmp-封包规则的比对针对是否响应-ping-来设计)
			* [9.3.4-7 超阳春客户端防火墙设计与防火墙规则储存](#934-7-超阳春客户端防火墙设计与防火墙规则储存)
		* [9.3.5 IPv4 的核心管理功能： /proc/sys/net/ipv4/*](#935-ipv4-的核心管理功能-procsysnetipv4)
	* [9.4 单机防火墙的一个实例](#94-单机防火墙的一个实例)
	* [9.5 NAT 服务器的设定](#95-nat-服务器的设定)
		* [9.5.1 什么是 NAT？ SNAT？ DNAT？](#951-什么是-nat-snat-dnat)
		* [9.5.2 最阳春 NAT 服务器： IP 分享功能](#952-最阳春-nat-服务器-ip-分享功能)
		* [9.5.4 在防火墙后端之网络服务器 DNAT 设定](#954-在防火墙后端之网络服务器-dnat-设定)

<!-- /code_chunk_output -->

# 9 防火墙与 NAT 服务器

## 9.3 Linux 的封包过滤软件： iptables

### 9.3.1 不同 Linux 核心版本的防火墙软件

查看核心`uname -r`

### 9.3.2 封包进入流程：规则顺序的重要性！

* iptables
  * 利用封包过滤的机制
  * 根据表头数据与定义的“规则”来决定该封包是否可以进入主机
  * 根据封包的分析资料`对比`预先定义的规则内存，如果相同则执行，否则继续下一条规则对比
  * 规则是有顺序的
  * 所有的规则都不符合，就会透过预设动作（封包策略，Policy）来决定这个封包的去向
  * 当规则顺序排列错误时，就会产生很严重的错误

### 9.3.3 iptables 的表格 (table) 与链 (chain)

* iptables表格
  * 管理本机进出的filter：开放客户端WWW响应，需要处理filter的INPUT链
  * 管理后端主机的nat（防火墙内部的其他主机）：作为局域网的路由器，要分析nat的各个链及filter的FORWARD链
  * 管理特殊旗标使用的mangle
  * 自定义额外的链
* filter（过滤器）
  * INPUT：进入主机的封包相关
  * OUTPUT：主机要发送的封包有关
  * FORWARD：传递封包
* nat（地址转换）Network Address Translation：来源与目的IP或port的转换
  * PREROUTING：路由判断前进行的规则（DNAT/REDIRECT）
  * POSTROUTING：路由判断后进行的规则（SNAT/MASQUERADE）
  * OUTPUT：发送的封包
* mangle（破坏者）
* 封包流向
  * 封包进入Linux主机使用资源：透过filter的INPUT链
  * 封包经由Linux主机转递，没有使用主机资源，向后端主机流动：经过filter的FORWARD以及nat的POSTROUTING、PREROUTING
  * 封包由Linux主机发送出去：透过filter的OUTPUT链传送，最终经过nat的POSTROUTING

### 9.3.4 本机的 iptables 语法  


#### 9.3.4-1 规则的观察与清除
```sh
# iptables [-t tables] [-L] [-nv]
# 选项与参数
#   -t: 后接table，nat|filter等，默认为filter
#   -L: 列出table规则
#   -n: 不进行IP与HOSTNAME反查
#   -v: 列出更多信息
# 列出filter table三条链的规则
iptables -L -n
# 列出nat table三条链的规则
iptalbes -t nat -L -n
```

* Chain
  * policy预设的政策
  * target：代表进行的动作，ACCEPT|REJECT|DROP
  * prot：封包协议，tcp|udp|icmp
  * source：来源IP进行限制
  * destination：目标IP进行限制

```sh
ACCEPT all -- 0.0.0.0/0 0.0.0.0/0 state RELATED,ESTABLISHED
#<==封包状态为RELATED, ESTABLISHED就予以接受
ACCEPT icmp -- 0.0.0.0/0 0.0.0.0/0
#<==封包协议是icmp类型就接受
ACCEPT all -- 0.0.0.0/0 0.0.0.0/0
#<==针对主机内部循环测试网络（lo）接口，不论任何封包都接受
ACCEPT tcp -- 0.0.0.0/0 0.0.0.0/0 state NEW tcp dpt:22
#<==传给22端口的主动式联机tcp封包就接受
REJECT all -- 0.0.0.0/0 0.0.0.0/0 reject-with icmp-host-prohibited
#全部的封包信息都拒绝
```

iptables-save

```sh
#iptables-save [-t table]
#  -t：nat|filter
#  iptables-save列出完整的防火墙规则
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
#<==针对 INPUT的规则
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT 
#<==这条很重要！针对本机内部接口开放！
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited 
#<==针对FORWARD 的规则
```

* iptables [-t tables] [-FXZ]
  * -F：清理所有的定义的规则
  * -X：杀掉所有使用者“自定义”的chain
  * -Z：将所有chain的计数与流量统计归零
* 三个指令会将本机防火墙的所有规则都清理，但不会改变预设政策（policy）


#### 9.3.4-2 定义预设政策 (policy)

```sh
#INPUT设置为DROP，同时没有任何规则
#所有封包都无法进入主机
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
#设置nat
iptables -t nat -P PREROUTING ACCEPT
```

#### 9.3.4-3 封包的基础比对： IP, 网域及接口装置

* iptables [-AI 链名] [-io 网络接口] [-p 协议] [-s 来源 IP/网域] [-d 目标 IP/网域] -j [ACCEPT|DROP|REJECT|LOG]
  * -AI 链名：针对某的链进行规则的 "插入" 或 "累加"
    * -A ：在原本规则的`最后面新增`一条规则
    * -I ：在原本规则的`最前面插入`一条规则
  * -io 网络接口：设定封包进出的接口规范
    * -i ：封包所进入的那个网络接口，例如 eth0, lo 等接口。需与 INPUT 链配合；
    * -o ：封包所传出的那个网络接口，与 OUTPUT 链配合；
  * -p 协定：封包格式。tcp, udp, icmp 及 all 。
  * -s 来源 IP/网域。
    * IP ： 192.168.0.100；网域： 192.168.0.0/24, 192.168.0.0/255.255.255.0 均可
    * 若规范为『不许』时，则加上 ! 即可，例如：-s ! 192.168.100.0/24
  * -d 目标 IP/网域：同 -s ，只不过这里指的是目标的 IP 或网域。
  * -j ：后面接动作，接受(ACCEPT)、丢弃(DROP)、拒绝(REJECT)及记录(LOG)

```sh
#进出lo的封包都予以接受
#没有指定的项目，则表示该项目完全接受
iptables -A INPUT -i lo -j ACCEPT
#来自内网(192.168.100.0/24)的封包通通接受
iptables -A INPUT -i eth1 -s 192.168.100.0/24 -j ACCEPT
#10就接受，230就丢弃
iptables -A INPUT -i eth1 -s 192.168.100.10 -j ACCEPT
iptables -A INPUT -i eth1 -s 192.168.100.230 -j DROP
#在/var/log/messages中记录200中的信息
iptables -A INPUT -i eth1 -s 192.168.2.200 -j LOG
```

#### 9.3.4-4 TCP, UDP 的规则比对：针对埠口设定

* iptables [-AI 链] [-io 网络接口] [-p tcp,udp] [-s 来源 IP/网域] [--sport 埠口范围] [-d 目标 IP/网域] [--dport 埠口范围] -j [ACCEPT|DROP|REJECT]
  * --sport：限制来源的端口范围，例如，1024:65535
  * --dport：限制目标的端口范围
  * 仅有tcp与udp封包具有端口，必须与`-p`配合使用
  * --syn：主动联机的SYN旗标


```sh
# 进入本机 port 21 的封包都抵挡掉
iptables -A INPUT -i eth0 -p tcp --dport 21 -j DROP
# udp 137,138 tcp 139,445放行
iptables -A INPUT -i eth0 -p udp --dport 137:138 -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --dport 139 -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --dport 445 -j ACCEPT
# 来自192.168.1.0/24的 1024:65534端口的封包，且访问ssh端口予以抵挡
iptables -A INPUT -i eth0 -p tcp -s 192.168.1.0/24 --sport 1024:65534 --dport ssh -j DROP
# 将来自任何地方来源 port 1:1023的主动联机到本机端 1:1023 联机丢弃
iptables -A INPUT -i eth0 -p tcp --sport 1:1023 --dport 1:1023 --syn -j DROP
```  

#### 9.3.4-5 iptables 外挂模块： mac 与 state

* 联机到远程主机的 port 22
  * OUTPUT链：本机端的 1024:65535 到远程的 port 22 必须放行
  * INPUT链：远程主机 port 22 到本机 1024:65535 必须放行
* 状态
  * 如果是刚刚我发出去的响应，就可以予以接受放行
* iptables -A INPUT [-m state] [--state 状态]
  * -m ：一些 iptables 的外挂模块，主要常见的有：
    * state ：状态模块
    * mac ：网络卡硬件地址 (hardware address)
  * --state ：封包的状态
    * INVALID ：无效的封包，例如数据破损的封包状态
    * ESTABLISHED：已经联机成功的联机状态；
    * NEW ：想要新建立联机的封包状态；
    * RELATED ：表示这个封包是与我们主机发送出去的封包有关

```sh
#范例：只要已建立或相关封包就予以通过，只要是不合法封包就丢弃
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -m state --state INVALID -j DROP
#范例：针对局域网络内的 aa:bb:cc:dd:ee:ff 主机开放其联机
iptables -A INPUT -m mac --mac-source aa:bb:cc:dd:ee:ff -j ACCEPT
```

#### 9.3.4-6 ICMP 封包规则的比对：针对是否响应 ping 来设计

* iptables -A INPUT [-p icmp] [--icmp-type 类型] -j ACCEPT
  * --icmp-type ：后面必须要接 ICMP 的封包类型，也可以使用代号
  * 将ICMP type 8 (echo request)拿掉，不接受ping响应

#### 9.3.4-7 超阳春客户端防火墙设计与防火墙规则储存

### 9.3.5 IPv4 的核心管理功能： /proc/sys/net/ipv4/*


* kernel-doc
  * yum install -y kernel-doc
  * /usr/share/doc/kernel-doc-3.10.0/Documentation/networking
  * ip-sysctl.txt
* /proc/sys/net/ipv4/tcp_syncookies
  * 阻断式服务DoS
  * SYN三向交握，SYN Flooding
  * 启用核心SYN Cookie模块：echo "1" > /proc/sys/net/ipv4/tcp_syncookies
  * 不适用在负载很高的服务器，核心会误判遭受`SYN Flooding`攻击
* SYN Cookie
  * 主机在发送SYN/ACK确认封包前，要求Client在段时间内回复一个序号
  * 如果Client回复正确的需要，确认该封包为可信的，发送SYN/ACK封包
  * 否则不理会此封包
* /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
  * `ping flooding`(不断发ping)
  * 取消ICMP类型8的ICMP封包回应
  * icmp_echo_ignore_broadcasts：仅有ping broadcast地址才取消ping回应
  * icmp_echo_ignore_all：全部ping都不回应
  * echo "1" /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
  * ping -b 192.168.31.0
* /proc/sys/net/ipv4/conf/网络接口/*
  * /proc/sys/net/ipv4/conf/eth0/ 
  * rp_filter：逆向路径过滤（Reverse Path Filtering），分析网络接口的路由信息配合封包的来源地址，判断该封包是否合理
  * log_martians：记录不合法的IP来源
  * accept_source_route：来源路由
  * accept_redirects：同一实体网域内架设一部路由器，但有两个IP网域，路由器可能发送ICMP redirect封包，让主机之间直连。而两台不同网域的IP段无法直接通信
  * send_redirects：与accept_redirects类似
* /etc/sysctl.conf
  * 修改系统设定值
  * sysctl -p

## 9.4 单机防火墙的一个实例

* 防火墙
  * 安装两块实体网卡，将网卡接在不同的网域
  * 将信任网域（LAN）与不信任网络（Internet）分开

## 9.5 NAT 服务器的设定

NAT(Network Address Translation，网络地址转换)

### 9.5.1 什么是 NAT？ SNAT？ DNAT？

* 封包透过主机传送
  * 先经过 NAT table 的PREROUTING链
  * 经由路由判断确定这个封包是否进入本机，若不进入进行下一步
  * 再经过Filter table的FORWARD链
  * 通过 NAT table 的POSTROUTING链，最后传送出去
* NAT
  * POSTROUTING修改`来源IP`，来源NAT（Source NAT，SNAT）
  * PREROUTING修改`目标IP`，目标NAT（Destination NAT，DNAT）
* SNAT：修改封包表头的`来源`
  * 客户端发出的封包传送到NAT主机
  * NAT主机收到封包，分析表头，目的并非Linux主机，将封包转到Internet的Public IP
  * NAT内的Postrouting将封包表头伪装成Public IP，并将两个不同来源的封包对应写入内存
  * Internet主机响应数据给Public IP的主机
  * NAT主机收到Internet响应，对比内存中数据，在NAT Prerouting将目标IP修改为后端主机
* DNAT：修改封包表头`目标`
  * SNAT使内部LAN连接到Internet的使用方式
  * DNAT使Internet访问内部主机

### 9.5.2 最阳春 NAT 服务器： IP 分享功能

MASQUERADE 将 IP 伪装成封包出去（-o）的那块设备的IP

### 9.5.4 在防火墙后端之网络服务器 DNAT 设定

```sh
# 将内部主机192.168.100.10向Internet开放WWW服务
# 从eth0接口进入，且想要使用80段扩的服务时，重定向到192.168.100.10:80
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 192.168.100.10:80
# 将要求与80联机的封包转递到8080这个端口
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
```