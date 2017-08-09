* [linux时间同步，ntpd、ntpdate_清新居士_新浪博客 ](http://blog.sina.com.cn/s/blog_636a55070101u1mg.html)

1./etc/ntp.conf：这个是NTP daemon的主要设文件，也是 NTP 唯一的设定文件。

```sh
#ntpdate手动同步下时间
ntpdate -u 192.168.0.135
```

# localtime

* [解析Linux系统修改时区不用重启方法 - eagle1830的专栏 - CSDN博客 ](http://blog.csdn.net/eagle1830/article/details/62042917)

```sh
[root@localhost ~]# cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
cp: overwrite `/etc/localtime'? y
[root@localhost ~]# date
Sat Feb 20 16:04:43 CST 2010
[root@localhost ~]# hwclock
Sat 20 Feb 2010 04:05:12 PM CST -0.474966 seconds
```


# ntpstat

如何确认我们的NTP服务器已经更新了自己的时间呢？

```bash 
[root@linux ~] # ntpstat
synchronized to NTP server(127.127.1.0) at stratum 11
time correct to within 950ms
polling server every 64 s
#改指令可列出NTP服务器是否与上层联机。由上述输出结果可知，时间校正约
#为950*10(-6)秒。且每隔64秒会主动更新时间。
```

# ntpq

```bash
[root@linux ~] # ntpq –p
#指令“ntpq -p”可以列出目前我们的NTP与相关的上层NTP的状态，以上的几个字段的意义如下：
remote：即NTP主机的IP或主机名称。注意最左边的符号，如果由“+”则代表目前正在作用钟的上层NTP，如果是“*”则表示也有连上线，不过是作为次要联机的NTP主机。
refid：参考的上一层NTP主机的地址
st：即stratum阶层
when：几秒前曾做过时间同步更新的操作
poll：下次更新在几秒之后
reach：已经向上层NTP服务器要求更新的次数
delay：网络传输过程钟延迟的时间
offset：时间补偿的结果
jitter：Linux系统时间与BIOS硬件时间的差异时间
```