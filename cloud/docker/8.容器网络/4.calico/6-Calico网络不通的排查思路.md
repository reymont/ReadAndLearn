


```sh
### 获取容器ip
docker exec bbox2 ip a
# inet 192.168.23.193/32 scope global cali0
### 找到IP对应的网卡 ip neigh
192.168.23.193 dev cali22428d4c372 lladdr ee:ee:ee:ee:ee:ee PERMANENT
### tcpdump
### 在容器A所在的node上用tcpdump监听calicc354b946ce网卡，查看是否能够收到容器A发出的报文
yum install -y tcpdump
tcpdump -i cali22428d4c372
```

## 169.254.1.1

使用calico后，在容器内只有一条默认路由，所有的报文都通过169.254.1.1送出

## 从calico中获取接收端容器的信息:

```sh
calicoctl get workloadendpoint --workload=libnetwork -o yaml
```

参考
1 https://mp.weixin.qq.com/s/MZIj_cvvtTiAfNf_0lpfTg
2 https://blog.csdn.net/qq_21816375/article/details/79475163