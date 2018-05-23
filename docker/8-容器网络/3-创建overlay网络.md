


# 创建 overlay 网络

```sh
### 在 host1 中创建 overlay 网络 ov_net1
docker network create -d overlay ov_net1
# 01eb637d5e243dd57697a360769a17d447c6dc2bd62067df0caa71a138732a3f
### host1 查看当前网络
#### 注意到 ov_net1 的 SCOPE 为 global，而其他网络为 local
docker network ls
# NETWORK ID          NAME                DRIVER              SCOPE
# ecd4615949a8        bridge              bridge              local               
# b078c3a4b1ff        host                host                local               
# 8399a0966a2b        none                null                local               
# 01eb637d5e24        ov_net1             overlay             global
### host2 查看网络
#### 创建 ov_net1 时 host1 将 overlay 网络信息存入了 consul
#### host2 从 consul 读取到了新网络的数据
#### 之后 ov_net 的任何变化都会同步到 host1 和 host2
docker network ls
# NETWORK ID          NAME                DRIVER              SCOPE
# 5cc020c4a45b        bridge              bridge              local               
# e527d688502c        host                host                local               
# 95b825d77e7d        none                null                local               
# 01eb637d5e24        ov_net1             overlay             global
### docker network inspect 查看 ov_net1 的详细信息：
#### IPAM 是指 IP Address Management，docker 自动为 ov_net1 分配的 IP 空间为 10.0.0.0/24。
docker network inspect ov_net1
# [
#     {
#         "Name": "ov_net1",
#         "Id": "01eb637d5e243dd57697a360769a17d447c6dc2bd62067df0caa71a138732a3f",
#         "Scope": "global",
#         "Driver": "overlay",
#         "EnableIPv6": false,
#         "IPAM": {
#             "Driver": "default",
#             "Options": {},
#             "Config": [
#                 {
#                     "Subnet": "10.0.0.0/24",
#                     "Gateway": "10.0.0.1/24"
#                 }
#             ]
#         },
#         "Internal": false,
#         "Containers": {},
#         "Options": {},
#         "Labels": {}
#     }
# ]
```

# 参考：

1 https://mp.weixin.qq.com/s/7o8QxGydMTUe4Q7Tz46Diw