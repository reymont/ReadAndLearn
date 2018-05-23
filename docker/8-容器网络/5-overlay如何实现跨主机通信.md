



```sh
### host2 运行容器 bbox2
docker run -it --rm --name=bbox2 --network ov_net1 busybox
### host1 运行容器 bbox1
docker run -it --rm --name=bbox1 --network ov_net1 busybox
# / # ping -c 2 bbox2
# PING bbox2 (10.0.0.2): 56 data bytes
# 64 bytes from 10.0.0.2: seq=0 ttl=64 time=0.971 ms
# 64 bytes from 10.0.0.2: seq=1 ttl=64 time=0.662 ms
```


# 参考：

1 https://mp.weixin.qq.com/s/7o8QxGydMTUe4Q7Tz46Diw