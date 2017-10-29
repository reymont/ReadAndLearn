

* [nginx 负载均衡和反向代理 - CSDN博客 ](http://blog.csdn.net/tonyxf121/article/details/7957830)

* 负载均衡
  * 将用户的请求均匀的或者按照一定的优先级分配到一组服务器中的一台上，
  * 而接收到请求的服务器独立的处理请求并返回。
  * 负载均衡技术主要用于扩展后端服务的性能。
* 反向代理
  * 代理服务器将接收到的用户请求转发给内部服务器，
  * 再将内部服务器返回的结果返回给用户，
  * 此时代理服务器就充当一个服务器的角色。

# 实例

```conf
upstream backend {  
    server 192.168.43.158:8086 weight=4 max_fails=2 fail_timeout=30s;    
    server 192.168.41.167 weight=4 max_fails=2 fail_timeout=30s;   
    server unix:/tmp/backends weight=4 max_fails=2 fail_timeout=30s;  
}  
server {  
    listen 80 ;  
    server_name frontend.com;  
    location = / {  
        proxy_pass http://backend;  
        proxy_set_header Host backend.com;  
        proxy_set_header Forwarded $remote_addr;  
    }  
}  
```

* proxy_pass
  * 用于指定反向代理的upstream服务器集群
  * proxy_set_header用于添加指定的头信息，用于当后端服务器上有多个基于域名的虚拟主机时，host可以指定要访问哪一个虚拟主机，
  * forwarded用于告诉后端服务器终端用户的ip地址，否则后端服务器只能获取前端代理服务器的ip地址。
* upstream
  * nginx 利用 upstream 模块来实现负载均衡
  * 该模块还可以对后端服务器进行健康检查
* ip_hash
  * ip_hash 指令可以将某个客户端的请求通过ip hash算法定位到同一台后端服务器上
  * 保证客户端的请求能一直被定向到一台后端服务器上，否则就会随机被定向到不同的后端服务器上。
  * ip_hash 的缺点就是无法保证后端服务器的负载均衡，
  * 因为ip的不均匀导致有可能有的后端服务器接收的请求多，
  * 而且即使设置后端服务器的权重也不起作用。
  * 如果某个后端服务器要从nginx负载均衡中摘除一段时间，必须将其标记为“down”，而不是直接从配置文件中删掉或者注释掉
  * 如果直接从配置文件中删除的话，nginx就会按照3台后端服务器重新hash
  * 原来定向到backend1的用户就有可能重新定向到backend2，这样backend1上的用户数据就会失效，比如SESSION数据。
* server指令
  * 该指令用于指定后端服务器的名称和参数，服务器的名称可以是一个域名，一个ip，端口号或者unix scoket。
  * 参数主要有：
    * weight，设置后端服务器的权重，权重越高，被分配到的客户端请求数越多。如果没有设置权重，则权重值默认为1；
    * max_fails，指定在参数 fail_timeout 时间内后端服务器请求失败的次数，如果检测到后端服务器无法连接或者服务器内部错误，则标记失败，默    * 认值为1，设置为0将会关闭这项检查；
    * fail_timeout，在指定的时间内如果失败次数到达max_fails时，后端服务器将会暂停服务的时间；
    * down，标记服务器为永久离线状态，仅用于ip_hash指令；
    * backup，仅仅在非backup服务器全部宕机或繁忙的时候才启用。