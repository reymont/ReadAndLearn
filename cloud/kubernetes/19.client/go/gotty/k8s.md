三、启动gotty ：

./gotty -w --permit-arguments  docker exec -ti  
或者 
./gotty -w -p 8081 --permit-arguments  kubectl exec -ti -n test02 &

pkill gotty

浏览器直接传入容器的ID和进入容器需要执行的命令（/bin/bash）
http://172.20.62.78:8081/?arg=dubbo-admin-hpkb6&arg=%2fbin%2fbash

## 参考

1. https://blog.csdn.net/cj2580/article/details/79318726