

[使用dnsmasq作为dns服务器 - 积水成渊 - CSDN博客 ](http://blog.csdn.net/daydring/article/details/27201123)


# 服务端配置

```bash
vi /etc/dnsmasq.conf
```
默认配置下，dnsmasq使用系统的`/etc/resolv.conf`并读取`/etc/hosts`，在配置里可以更改或关闭，现在是修改了这两个，其它的按默认：
```bash  
resolv-file=/etc/dnsmasq.resolv.conf  
listen-address=192.168.1.235（本地地址），127.0.0.1  
addn-hosts=/etc/dnsmasq.hosts  
```

（dnsmasq还支持dhcp服务，但一般不用）  
dnsmasq可以用hosts文件来设置域名：  
例：在dnsmasq配置www.test123.com指向一个ip里：
```bash
echo "192.168.1.24 www.test123.com" > /etc/dnsmasq.hosts  
echo "nameserver 192.168.1.254(上级DNS服务器地址)"  
#改完后启动dnsmasq  
./dnsmasq -d
```

# 客户机配置  
 /etc/resolv.conf  
    nameserver 192.168.1.235  
  
ping test.sudone.com则可以看出效果