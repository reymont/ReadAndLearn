wireshark过滤语法总结 - CSDN博客 http://blog.csdn.net/dszgf5717/article/details/42427679

http://blog.csdn.net/cumirror/article/details/7054496
做应用识别这一块经常要对应用产生的数据流量进行分析。
抓包采用wireshark，提取特征时，要对session进行过滤，找到关键的stream，这里总结了wireshark过滤的基本语法，供自己以后参考。（脑子记不住东西）

wireshark进行过滤时，按照过滤的语法可分为协议过滤和内容过滤。
对标准协议，既支持粗粒度的过滤如HTTP，也支持细粒度的、依据协议属性值进行的过滤如tcp.port==53、http.request.method=="GET"。
对内容的过滤，既支持深度的字符串匹配过滤如http contains "Server"，也支持特定偏移处值的匹配过滤如tcp[20:3] == 47:45:54。

wireshark有两种过滤器：
捕捉过滤器（CaptureFilters）：用于决定将什么样的信息记录在捕捉结果中。
显示过滤器（DisplayFilters）：用于在捕捉结果中进行详细查找。

捕捉过滤器在抓抱前进行设置，决定抓取怎样的数据；显示过滤器用于过滤抓包数据，方便stream的追踪和排查。
捕捉过滤器仅支持协议过滤，显示过滤器既支持协议过滤也支持内容过滤。
两种过滤器它们支持的过滤语法并不一样。

捕捉过滤器--捕捉前依据协议的相关信息进行过滤设置
语法：	Protocol	Direction	Host(s)	Value	Logical Operations	Other expression
例子：	tcp	dst	10.1.1.1	80	and	tcp dst 10.2.2.2 3128
示例：
(host 10.4.1.12 or src net 10.6.0.0/16) and tcp dst portrange 200-10000 and dst net 10.0.0.0/8
捕捉IP为10.4.1.12或者源IP位于网络10.6.0.0/16，目的IP的TCP端口号在200至10000之间，并且目的IP位于网络 10.0.0.0/8内的所有封包。

字段详解：
Protocol（协议）:
可能值: ether, fddi, ip, arp, rarp, decnet, lat, sca, moprc, mopdl, tcp and udp.
如果没指明协议类型，则默认为捕捉所有支持的协议。
注：在wireshark的HELP-Manual Pages-Wireshark Filter中查到其支持的协议。

Direction（方向）:
可能值: src, dst, src and dst, src or dst
如果没指明方向，则默认使用 “src or dst” 作为关键字。
”host 10.2.2.2″与”src or dst host 10.2.2.2″等价。

Host(s):
可能值： net, port, host, portrange.
默认使用”host”关键字，”src 10.1.1.1″与”src host 10.1.1.1″等价。

Logical Operations（逻辑运算）:
可能值：not, and, or.
否(“not”)具有最高的优先级。或(“or”)和与(“and”)具有相同的优先级，运算时从左至右进行。
“not tcp port 3128 and tcp port 23″与”(not tcp port 3128) and tcp port 23″等价。
“not tcp port 3128 and tcp port 23″与”not (tcp port 3128 and tcp port 23)”不等价。

显示过滤器--对捕捉到的数据包依据协议或包的内容进行过滤
1.协议过滤语法
语法：	Protocol	.	String 1	.	String 2	Comparison operator	  Value	Logical Operations	Other expression
例子：	http	 	request	 	method 	==	"POST"	or	icmp.type
string1和string2是可选的。
依据协议过滤时，可直接通过协议来进行过滤，也能依据协议的属性值进行过滤。
按协议进行过滤：
snmp || dns || icmp	显示SNMP或DNS或ICMP封包。
按协议的属性值进行过滤：
ip.addr == 10.1.1.1
ip.src != 10.1.2.3 or ip.dst != 10.4.5.6
ip.src == 10.230.0.0/16	显示来自10.230网段的封包。
tcp.port == 25	显示来源或目的TCP端口号为25的封包。
tcp.dstport == 25	显示目的TCP端口号为25的封包。
http.request.method== "POST"	显示post请求方式的http封包。
http.host == "tracker.1ting.com"	显示请求的域名为tracker.1ting.com的http封包。
tcp.flags.syn == 0×02	显示包含TCP SYN标志的封包。
2.内容过滤语法
2.1深度字符串匹配
contains ：Does the protocol, field or slice contain a value
示例
tcp contains "http"	显示payload中包含"http"字符串的tcp封包。
http.request.uri contains "online"	显示请求的uri包含"online"的http封包。
2.2特定偏移处值的过滤
tcp[20:3] == 47:45:54  /* 16进制形式，tcp头部一般是20字节，所以这个是对payload的前三个字节进行过滤 */
http.host[0:4] == "trac"


过滤中函数的使用（upper、lower）
upper(string-field) - converts a string field to uppercase
lower(string-field) - converts a string field to lowercase
示例
upper(http.request.uri) contains "ONLINE"


wireshark过滤支持比较运算符、逻辑运算符，内容过滤时还能使用位运算。
如果过滤器的语法是正确的，表达式的背景呈绿色。如果呈红色，说明表达式有误。

参考：
wireshark的HELP-Manual Pages-Wireshark Filter
http://blog.csdn.net/yhwxxx/article/details/5643095
http://tieba.baidu.com/p/739516717