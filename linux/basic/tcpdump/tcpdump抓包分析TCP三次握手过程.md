

* [tcpdump抓包分析TCP三次握手过程-lrfgjj2-ChinaUnix博客 ](http://blog.chinaunix.net/uid-25979788-id-730630.html)

```sh
#指定接口
tcpdump -i eth0 
tcpdump -i ens33 -nn 'host 10.31.1.237 and port 80'
tcpdump -i ens33 -nn -x 'host 10.31.1.237 and port 80'
#指定
tcpdump port 80
```

# 三次握手过程分析 

```sh
#当前主机正在监听的端口，使用另一台机telnet过来，不输入任何内容，进行抓包
tcpdump -i ens33 port 80 -c 3 -n
#安装
yum install -y telnet
telnet 10.31.1.234 80
```

```r
18:14:36.131351 IP 10.31.1.237.38802 > 10.31.1.234.http: Flags [S], seq 76587224, win 29200, options [mss 1460,sackOK,TS val 1895716875 ecr 0,nop,wscale 7], length 0
18:14:36.131470 IP 10.31.1.234.http > 10.31.1.237.38802: Flags [S.], seq 2371148674, ack 76587225, win 28960, options [mss 1460,sackOK,TS val 1893835177 ecr 1895716875,nop,wscale 7], length 0
18:14:36.131612 IP 10.31.1.237.38802 > 10.31.1.234.http: Flags [.], ack 1, win 229, options [nop,nop,TS val 1895716876 ecr 1893835177], length 0
```
* 解析
  * 18:14:36 时间
  * 131351 ID号
  * IP (协议) 
  * 10.31.1.237.38802 > 10.31.1.234.http（源IP，端口，目的IP，端口）中间>表示方向
  * S (表示为SYN包）
  * 76587224 IP包序号
  * win 29200 数据窗口大小，告诉对方本机接收窗口大小
  * MSS: Maxitum Segment Size 最大分段大小，MSS表示TCP传往另一端的最大块数据的长度
* TCP连接的三次握手过程: 
  * A主机发送序号为`76587224`的SYN包到B，同时带有自身的WIN和MSS大小。 
  * B主机收到后，发送SYN+ACK的返回包到A，也带自身的WIN和MSS大小，`2371148674`，同时为为上一个包的应答包`76587225`。 
  * A主机返回ACK，包序号为1(相对序号，如果需要看绝对序号，可以在tcpdump命令中加-S) 
* 状态位
  * 紧急指针— URG 
  * 确认序号有效—ACK 
  * 接收方应该尽快将这个报文段交给应用层—PSH 
  * 重建连接—RST 
  * 同步序号用来发起一个连接—SYN 
  * 发端完成发送任务—IN 


# -x 让十六进制显示包内容


```sh
[root@KYENSTEST02 ~]# tcpdump -x -i ens33 port 80 -c 3 -n
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on ens33, link-type EN10MB (Ethernet), capture size 262144 bytes
18:26:11.317466 IP 10.31.1.237.39038 > 10.31.1.234.http: Flags [S], seq 1387539764, win 29200, options [mss 1460,sackOK,TS val 1896412061 ecr 0,nop,wscale 7], length 0
	0x0000:  4510 003c dea9 4000 4006 43ee 0a1f 01ed
	0x0010:  0a1f 01ea 987e 0050 52b4 2d34 0000 0000
	0x0020:  a002 7210 407e 0000 0204 05b4 0402 080a
	0x0030:  7108 f39d 0000 0000 0103 0307
18:26:11.317537 IP 10.31.1.234.http > 10.31.1.237.39038: Flags [S.], seq 3380383748, ack 1387539765, win 28960, options [mss 1460,sackOK,TS val 1894530363 ecr 1896412061,nop,wscale 7], length 0
	0x0000:  4500 003c 0000 4000 4006 22a8 0a1f 01ea
	0x0010:  0a1f 01ed 0050 987e c97c 9004 52b4 2d35
	0x0020:  a012 7120 1843 0000 0204 05b4 0402 080a
	0x0030:  70ec 3d3b 7108 f39d 0103 0307
18:26:11.317691 IP 10.31.1.237.39038 > 10.31.1.234.http: Flags [.], ack 1, win 229, options [nop,nop,TS val 1896412062 ecr 1894530363], length 0
	0x0000:  4510 0034 deaa 4000 4006 43f5 0a1f 01ed
	0x0010:  0a1f 01ea 987e 0050 52b4 2d35 c97c 9005
	0x0020:  8010 00e5 d8ba 0000 0101 080a 7108 f39e
	0x0030:  70ec 3d3b
3 packets captured
3 packets received by filter
0 packets dropped by kernel
```

* IP 包
  * 4510 = 4 IP版本号 IPV4; 5 IP包头长度 5个32字节；10 前三个BIT优先权，已忽略；4 bit分别代表:最小时延、最大吞吐量、最高可靠性和最小费用
  * 003c = 总长度，60个字节
  * 4000 －标志字段，和片偏移，用于分片
  * 4006 = 40 － TTL(64) 06 － 协议 TCP 
  * 22a8 = 包唯一标识
  * 0a1f 01ed = SRC IP 10.31.1.237
  * 0a1f 01ea = DST IP 10.31.1.234
* TCP包
  * 987e = 源端口，十进制为 39038
  * 0050 = 目的端口，十进制为 80
  * 52b4 2d34 = 包序号，十进制为 
  * 0000 0000 确认序号，0，未设置ACK，确认序号无效
  * 7210 －TCP包头长度，标志位。（1010 000000 000010）前4bitTCP长度7个32BIT，中间6bit保留，后6bit为标志位（URG, ACK，PSH， RST， SYN， FIN），可以看出设置了倒数第二位，SYN位。 


