

[k8s]kubelet最佳实战 - 狮子XL - 博客园 http://www.cnblogs.com/iiiiher/p/7879587.html
[k8s]kubelet最佳实战 - _毛台 - 博客园 https://www.cnblogs.com/iiiiher/p/7879587.html


kubelet端口解析:
10250  –port:           kubelet服务监听的端口,api会检测他是否存活
10248  –healthz-port:   健康检查服务的端口
10255  –read-only-port: 只读端口，可以不用验证和授权机制，直接访问
4194   –cadvisor-port:  当前节点 cadvisor 运行的端口
kubelet参数手头书
参数	解释	默认值
–address	kubelet 服务监听的地址	0.0.0.0
–port	kubelet 服务监听的端口	10250
–read-only-port	只读端口，可以不用验证和授权机制，直接访问	10255
–allow-privileged	是否允许容器运行在 privileged 模式	false
–api-servers	以逗号分割的 API Server 地址，用于和集群中数据交互	[]
–cadvisor-port	当前节点 cadvisor 运行的端口	4194
–config 本地 manifest	文件的路径或者目录	""
–file-check-frequency	轮询本地 manifest 文件的时间间隔	20s
–container-runtime	后端容器 runtime，支持 docker 和 rkt	docker
–enable-server	是否启动 kubelet HTTP server	true
–healthz-bind-address	健康检查服务绑定的地址，设置成 0.0.0.0 可以监听在所有网络接口	127.0.0.1
–healthz-port	健康检查服务的端口	10248
–hostname-override	指定 hostname，如果非空会使用这个值作为节点在集群中的标识	""
–log-dir	日志文件，如果非空，会把 log 写到该文件	""
–logtostderr	是否打印 log 到终端	true
–max-open-files	允许 kubelet 打开文件的最大值	1000000
–max-pods	允许 kubelet 运行 pod 的最大值	110
–pod-infra-container-image	基础镜像地址，每个 pod 最先启动的容器，会配置共享的网络	gcr.io/google_containers/pause-amd64:3.0
–root-dir	kubelet 保存数据的目录	/var/lib/kubelet
–runonce	从本地 manifest 或者 URL 指定的 manifest 读取并运行结束就退出，和 --api-servers 、--enable-server 参数不兼容
–v	日志 level	0
简单的启动kubelet
kubelet \
    --api-servers=http://192.168.14.132:8080
完善的启动kubelet
kubelet \
    --api-servers=http://192.168.14.132:8080 \
    --pod-infra-container-image=kubeguide/pause-amd64:3.0 \
    --allow-privileged=true \
    --kubelethostname-override=192.168.14.133 \
    --logtostderr=false \
    --log-dir=/root/logs/ \
    --v=2
查看node状态
参考:
https://k8smeetup.github.io/docs/concepts/architecture/nodes/

kubectl describe node
查看cadvisor(kubelet自带)
http://192.168.14.133:4194
状态观察
参考:
https://k8smeetup.github.io/docs/concepts/architecture/nodes/

50s容器由exit状态到删掉
kubectl delete -f busybox.yaml  #50s容器由exit状态到删掉
5min节点好像由不可用到删除
kube-controller-manager一个参数:根据节点状态删除.
# The grace period for deleting pods on failed nodes. (default 5m0s)5分钟
--pod-eviction-timeout duration

Ready 条件处于状态 “Unknown” 或者 “False” 的时间超过了 pod-eviction-timeout(一个传递给 kube-controller-manager 的参数)，node 上的所有 Pods 都会被 Node 控制器计划删除。默认的删除超时时长为5分钟。
kubelet报错但是没解决的-据说是1.7版本的bug.我是1.7.10
W1122 15:49:22.233484   71196 helpers.go:793] eviction manager: no observation found for eviction signal allocatableNodeFs.available
W1122 15:49:32.301474   71196 helpers.go:793] eviction manager: no observation found for eviction signal allocatableNodeFs.available
W1122 15:49:42.355303   71196 helpers.go:793] eviction manager: no observation found for eviction signal allocatableNodeFs.available
W1122 15:49:52.402125   71196 helpers.go:793] eviction manager: no observation found for eviction signal allocatableNodeFs.available
etcd报出问题--这个是etcd版本问题,不影响使用,我是yum install etcd搞的
[root@m1 yaml]# E1122 16:19:49.499797   57214 watcher.go:210] watch chan error: etcdserver: mvcc: required revision has been compacted
E1122 16:21:15.609115   57214 watcher.go:210] watch chan error: etcdserver: mvcc: required revision has been compacted
kubelet启动后会自动创建它的工作目录/var/lib/kubelet/
[root@n1 kubernetes]# tree /var/lib/kubelet/
/var/lib/kubelet/
├── plugins
└── pods
    ├── f56d5553-cf58-11e7-adbb-000c29154f03
    │   ├── containers
    │   │   └── busybox
    │   │       └── 24bd58a0
    │   ├── etc-hosts
    │   ├── plugins
    │   └── volumes
    ├── fffefc20-cf58-11e7-adbb-000c29154f03
    │   ├── containers
    │   │   └── nginx
    │   │       └── 221a8328
    │   ├── etc-hosts
    │   ├── plugins
    │   └── volumes
    ├── ffff1611-cf58-11e7-adbb-000c29154f03
    │   ├── containers
    │   │   └── nginx
    │   │       └── d2d2f44d
    │   ├── etc-hosts
    │   ├── plugins
    │   └── volumes
    └── ffff1ff8-cf58-11e7-adbb-000c29154f03
        ├── containers
        │   └── nginx
        │       └── bd101c6e
        ├── etc-hosts
        ├── plugins
        └── volumes