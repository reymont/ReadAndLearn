

# 字节、字、bit、byte的关系

* [字节、字、bit、byte的关系 - 波比特的专栏 - CSDN博客 ](http://blog.csdn.net/wanlixingzhe/article/details/7107923)

字 word 
字节 byte 
位 bit 
字长是指字的长度

1字=2字节(1 word = 2 byte) 
1字节=8位(1 byte = 8bit) 
 
一个字的字长为16 
一个字节的字长是8

bps 是 bits per second 的简称。一般数据机及网络通讯的传输速率都是以「bps」为单位。如56Kbps、100.0Mbps 等等。 
Bps即是Byte per second 的简称。而电脑一般都以Bps 显示速度，如1Mbps 大约等同 128 KBps。 

bit 电脑记忆体中最小的单位，在二进位电脑系统中，**每一bit 可以代表0 或 1 的数位讯号**。 

Byte一个Byte由8 bits 所组成，可代表一个字元(A~Z)、数字(0~9)、或符号(,.?!%&+-*/)，是记忆体储存资料的基本单位，至於每个中文字则须要两Bytes。当记忆体容量过大时，位元组这个单位就不够用，因此就有千位元组的单位KB出现，以下乃个记忆体计算单位之间的相关性：

1 Byte = 8 Bits

1 KB = 1024 Bytes

1 MB = 1024 KB

1 GB = 1024 MB

usb2.0标准接口传输速率。许多人都将“480mbps”误解为480兆/秒。其实，这是错误的，事实上“480mbps”应为“480兆比特/秒”或“480兆位/秒”，它等于“60兆字节/秒”，大家看到差距了吧。

这要从bit和byte说起：bit和byte同译为"比特"，都是数据量度单位，bit=“比特”或“位”。 
byte=字节即1byte=8bits,两者换算是1：8的关系。 
mbps=mega bits per second(兆位/秒)是速率单位，所以正确的说法应该是说usb2.0的传输速度是480兆位/秒,即480mbps。 
mb=mega bytes(兆比、兆字节)是量单位，1mb/s（兆字节/秒）=8mbps（兆位/秒）。

我们所说的硬盘容量是40gb、80gb、100gb，这里的b指是的byte也就是“字节”。 
1 kb = 1024 bytes =2^10 bytes 
1 mb = 1024 kb = 2^20 bytes 
1 gb = 1024 mb = 2^30 bytes

比如以前所谓的56kb的modem换算过来56kbps除以8也就是7kbyte，所以真正从网上下载文件存在硬盘上的速度也就是每秒7kbyte。 
也就是说与传输速度有关的b一般指的是bit。 
与容量有关的b一般指的是byte。

最后再说一点: usb2.0 480mbps=60mb/s的传输速率还只是理论值，它还要受到系统环境的制约（cpu、硬盘和内存等），其实际读、取写入硬盘的速度约在11～16mb/s。但这也比usb1.1的12mbps(1.5m/s)快了近10倍。