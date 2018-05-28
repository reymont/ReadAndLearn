

```sh
etcdctl get /docker-test/network/subnets/10.2.41.0-24
# {"PublicIP":"172.20.62.104","BackendType":"vxlan","BackendData":{"VtepMAC":"ca:4f:c3:1c:69:70"}}
### 172.20.62.104上查看路由表
ip r
# 10.2.41.0/24 dev docker0  proto kernel  scope link  src 10.2.41.1 
# 10.2.54.0/24 via 10.2.54.0 dev flannel.1 onlink 
etcdctl get /docker-test/network/subnets/10.2.54.0-24
# {"PublicIP":"172.20.62.105","BackendType":"vxlan","BackendData":{"VtepMAC":"1a:4b:d7:f7:16:89"}}
### 172.20.62.105上查看路由表
ip r
# 10.2.41.0/24 via 10.2.41.0 dev flannel.1 onlink 
# 10.2.54.0/24 dev docker0  proto kernel  scope link  src 10.2.54.1 
```

参考：

1 http://dockone.io/article/618
