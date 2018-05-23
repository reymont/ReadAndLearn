
# 在 overlay 中运行容器

```sh
### 运行一个 busybox 容器并连接到 ov_net1
docker run -it --rm --network ov_net1 busybox
### 查看网络配置
#### eth0 IP 为 10.0.0.2，连接的是 overlay 网络 ov_net1
#### 容器的默认路由是走 eth1
ip r
# default via 172.18.0.1 dev eth1 
# 10.0.0.0/24 dev eth0 scope link  src 10.0.0.2 
# 172.18.0.0/16 dev eth1 scope link  src 172.18.0.2
#### docker 会创建一个 bridge 网络 “docker_gwbridge”，为所有连接到 overlay 网络的容器提供访问外网的能力
docker network ls
# NETWORK ID          NAME                DRIVER              SCOPE
# ecd4615949a8        bridge              bridge              local               
# b5aaf1a3c3c9        docker_gwbridge     bridge              local               
# b078c3a4b1ff        host                host                local               
# 8399a0966a2b        none                null                local               
# 01eb637d5e24        ov_net1             overlay             global
docker network inspect docker_gwbridge
ifconfig docker_gwbridge
```



# 参考：

1 https://mp.weixin.qq.com/s/7o8QxGydMTUe4Q7Tz46Diw