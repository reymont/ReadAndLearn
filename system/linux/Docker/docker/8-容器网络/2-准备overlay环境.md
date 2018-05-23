## 准备 Overlay 网络实验环境 

准备服务器
* consul: 172.20.62.127
* host1: 172.20.62.104
* host2: 172.20.62.105

### 使用consul

`docker run -d -p 8500:8500 --name=consul consul:1.1.0`

访问http://172.20.62.127:8500

### docker daemon 的配置文件

对host1和host2

--cluster-store 指定 consul 的地址。
--cluster-advertise 告知 consul 自己的连接地址。

```sh
### 修改docker配置
vi /etc/sysconfig/docker
...
OPTIONS='--selinux-enabled=false -H tcp://0.0.0.0:2376 -H unix:///var/run/docker.sock --cluster-store=consul://172.20.62.127:8500 --cluster-advertise=eth0:2376'
...

### 重启docker
systemctl daemon-reload  
systemctl restart docker.service
```

### host1 和 host2 将自动注册到 Consul 数据库中。

访问：http://172.20.62.127:8500/ui/#/dc1/kv/docker/nodes/

### 参考：

1 https://mp.weixin.qq.com/s/7o8QxGydMTUe4Q7Tz46Diw
2 http://www.dockone.io/article/840