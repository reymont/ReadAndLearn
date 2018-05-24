
* [Linux网络抓包分析工具Tcpdump基础篇[参数说明]-博客-云栖社区-阿里云 ](https://yq.aliyun.com/articles/24198)

```sh
#首先需要查看设备上有哪些设备可以抓取，通过`tcpdump -D`会列出可以抓取的网络设备名以及编号
#-c 定义抓取数据包的count ，没有此参数的话tcpdump会一直抓下去直到ctrl+c手工终止
tcpdump -i 1 -c 2
#这里tcpdump -i eth0 -c 2效果是完全一样的
#抓取所有的包
tcpdump -i any
#-w 将抓取的数据包保存到一个文件中，用于离线分析或者保存
tcpdump -i 1 -c 2 -w test.cap
#通过wireshark或tcpdump -r参数打开
tcpdump -r test.cat
#抓取的IP和端口会被反向解析为域名和服务名，-nn看到纯粹的数据
tcpdump -i 1 -c 2  -nn
#避免本地ssh程序产生的数据包影响了分析
tcpdump -i 1 port ! ssh
#发往192.168.233.1的80端口的数据包，可以通过dst参数（多个筛选条件通过and或者or连接）
tcpdump -i 1 -c 1 -nn  dst 192.168.233.1 and port 80
#如果想抓192.168.233.1与192.168.233.2之外的所有IP通讯的数据包
tcpdump -i any host 192.168.233.1 and ! 192.168.233.2
#如果想抓取192.168.233.1和192.168.233.237之间的数据包
tcpdump -i 1 -c 1 -nn host 192.168.233.1 and host 192.168.233.237
#想要截获主机192.168.233.1 和（主机192.168.233.2 或192.168.233.3）的通信（shell下需要用括号要用\进行转义）
tcpdump host 192.168.233.1 and \ (192.168.233.2 or 192.168.233.3 \)
#如果想抓取指定协议的数据包，比如arp或者udp来分析arp欺骗或者udp攻击，可以通过-p 加协议名称：icmp,ip,ip6,arp,tcp,udp等，比如抓取arp信息#:
tcpdump -i 1 -c 1 -nn -p arp
```