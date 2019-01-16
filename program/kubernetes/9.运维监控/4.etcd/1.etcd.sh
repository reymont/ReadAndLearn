


kubectl exec -it -n kube-system etcd-kns-m1 sh
# https://blog.csdn.net/liukuan73/article/details/82115146
# https://coreos.com/etcd/docs/latest/dev-guide/interacting_v3.html
### 1. 设置环境变量
# k8s会使用etcd v3版本的API记录数据。而默认etcdctl是使用v2版本的API，查看不到v3的数据。设置环境变量ETCDCTL_API=3后就OK了：
export ETCDCTL_API=3       #或者在etcdctl前面加上这个
### 2. 获取etcd member列表
kubectl member list
### 3. 这条指令的意思是获取etcd中存储的所有key，并且前缀为 ‘/’
etcdctl get / --prefix --keys-only
etcdctl get /registry/apiregistration.k8s.io/apiservices/v1.
### 4. 查看全路径
ps -ef |grep -i root
# 数据目录为/var/lib/etcd
etcd --listen-client-urls=http://127.0.0.1:2379 --advertise-client-urls=http://127.0.0.1:2379 --data-dir=/var/lib/etcd
