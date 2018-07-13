
# kubelet.service

/lib/systemd/system/kubelet.service

```conf
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=http://kubernetes.io/docs/

[Service]
EnvironmentFile=-/etc/kubernetes/kubelet.env
ExecStartPre=-/etc/kubernetes/config.sh
ExecStart=/usr/bin/kubelet \
  --allow-privileged=true \
  --kubeconfig=/etc/kubernetes/kubelet.conf \
  --require-kubeconfig=true \
  --network-plugin=cni \
  --cni-conf-dir=/etc/cni/net.d \
  --cni-bin-dir=/opt/cni/bin \
  --cluster-dns=10.96.0.10 \
  --cluster-domain=cluster.local \
  --pod-manifest-path=/etc/kubernetes/manifests \
  --pod-infra-container-image=image.service.ob.local:5000/google_containers/pause-amd64:3.0 \
  $NODE_HOSTNAME \
  $KUBELET_ARGS
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
```


```sh
#查看配置
kubectl config --kubeconfig=/etc/kubernetes/kubelet.conf view
```

## 环境

```sh
/etc/kubernetes/kubelet.env
NODE_HOSTNAME="--hostname-override=0.0.0.0"
KUBELET_ARGS=
```

## pod-manifest-path

* [kubelet - Kubernetes ](https://kubernetes.io/docs/admin/kubelet/)

Path to to the directory containing pod manifest files to run, or the path to a single pod manifest file. Files starting with dots will be ignored.

* [Step 2: Deploy Kubernetes Master ](https://coreos.com/kubernetes/docs/latest/deploy-master.html)

Set Up the kube-apiserver Pod
The API server is where most of the magic happens. It is stateless by design and takes in API requests, processes them and stores the result in etcd if needed, and then returns the result of the request.

We're going to use a unique feature of the kubelet to launch a Pod that runs the API server. Above we configured the kubelet to watch a local directory for pods to run with the `--pod-manifest-path=/etc/kubernetes/manifests` flag. All we need to do is place our Pod manifest in that location, and the kubelet will make sure it stays running, just as if the Pod was submitted via the API. The cool trick here is that we don't have an API running yet, but the Pod will function the exact same way, which simplifies troubleshooting later on.

If this is your first time looking at a Pod manifest, don't worry, they aren't all this complicated. But, this shows off the power and flexibility of the Pod concept. Create /etc/kubernetes/manifests/kube-apiserver.yaml with the following settings:

Replace ${ETCD_ENDPOINTS}
Replace ${SERVICE_IP_RANGE}
Replace ${ADVERTISE_IP} with this node's publicly routable IP.


## allow-privileged


是否允许容器运行在 privileged 模式


## kubeconfig

* [Kubernetes(k8s)1.5新特性:Kubelet API增加认证和授权能力_Kubernetes中文社区 ](https://www.kubernetes.org.cn/1086.html)

kubeconfig参数：设置kubelet配置文件路径，这个配置文件用来告诉kubelet组件api server组件的位置，默认路径是。

require-kubeconfig参数：这是一个布尔类型参数，可以设置成true或者false，如果设置成true，那么表示启用kubeconfig参数，从kubeconfig参数设置的配置文件中查找api server组件，如果设置成false，那么表示使用kubelet另外一个参数“api-servers”来查找api server组件位置。

## pod-infra-container-image

pause-amd64是一个基础容器，每一个Pod启动的时候都会启动一个这样的容器。如果本地没有这个镜像，kubelet会连接外网把这个镜像下载下来。最开始的时候是在Google的镜像仓库gcr.io上，因此国内因为GFW都下载不了导致Pod运行不起来。现在每个版本的Kubernetes都把这个镜像打包，你可以提前传到自己的registry上，然后再用这个参数指定。

基础镜像地址，每个 pod 最先启动的容器，会配置共享的网络，gcr.io/google_containers/pause-amd64:3.0


# 阅读

## Docker run 命令的使用方法
* [[Enhancement] Support privileged container · Issue #391 · kubernetes/kubernetes ](https://github.com/kubernetes/kubernetes/issues/391)
* [Docker run 命令的使用方法 - WonSoon的专栏 - CSDN博客 ](http://blog.csdn.net/wongson/article/details/49077353)

Sometimes containers need to run with privileged mode.
https://docs.docker.com/reference/run/#runtime-privilege-and-lxc-configuration

Container manifest schema should support privileged flag so that users can deploy privileged container.

```sh
Runtime privilege, Linux capabilities, and LXC configuration
--cap-add: Add Linux capabilities
--cap-drop: Drop Linux capabilities
--privileged=false: Give extended privileges to this container
--device=[]: Allows you to run devices inside the container without the --privileged flag.
--lxc-conf=[]: (lxc exec-driver only) Add custom lxc options --lxc-conf="lxc.cgroup.cpuset.cpus = 0,1"
```

默认情况下，Docker的容器是没有特权的，例如不能在容器中再启动一个容器。这是因为默认情况下容器是不能访问任何其它设备的。但是通过"privileged"，容器就拥有了访问任何其它设备的权限。

当操作者执行docker run --privileged时，Docker将拥有访问主机所有设备的权限，同时Docker也会在apparmor或者selinux做一些设置，使容器可以容易的访问那些运行在容器外部的设备。你可以访问Docker博客来获取更多关于--privileged的用法。

同时，你也可以限制容器只能访问一些指定的设备。下面的命令将允许容器只访问一些特定设备：
$ sudo docker run --device=/dev/snd:/dev/snd ...

　　默认情况下，容器拥有对设备的读、写、创建设备文件的权限。使用:rwm来配合--device，你可以控制这些权限。
```sh
　$ sudo docker run --device=/dev/sda:/dev/xvdc --rm -it ubuntu fdisk  /dev/xvdc

Command (m for help): q
$ sudo docker run --device=/dev/sda:/dev/xvdc:r --rm -it ubuntu fdisk  /dev/xvdc
You will not be able to write the partition table.

Command (m for help): q

$ sudo docker run --device=/dev/sda:/dev/xvdc:w --rm -it ubuntu fdisk  /dev/xvdc
    crash....

$ sudo docker run --device=/dev/sda:/dev/xvdc:m --rm -it ubuntu fdisk  /dev/xvdc
fdisk: unable to open /dev/xvdc: Operation not permitted
```


使用--cap-add和--cap-drop，配合--privileged，你可以更细致的控制人哦怒气。默认使用这两个参数的情况下，容器拥有一系列的内核修改权限，这两个参数都支持all值，如果你想让某个容器拥有除了MKNOD之外的所有内核权限，那么可以执行下面的命令：
```sh
$ sudo docker run --cap-add=ALL --cap-drop=MKNOD ...
```


如果需要修改网络接口数据，那么就建议使用--cap-add=NET_ADMIN，而不是使用--privileged。
$ docker run -t -i --rm  ubuntu:14.04 ip link add dummy0 type dummy
RTNETLINK answers: Operation not permitted
$ docker run -t -i --rm --cap-add=NET_ADMIN ubuntu:14.04 ip link add dummy0 type dummy

如果要挂载一个FUSE文件系统，那么就需要--cap-add和--device了。
```sh
$ docker run --rm -it --cap-add SYS_ADMIN sshfs sshfs sven@10.10.10.20:/home/sven /mnt
fuse: failed to open /dev/fuse: Operation not permitted
$ docker run --rm -it --device /dev/fuse sshfs sshfs sven@10.10.10.20:/home/sven /mnt
fusermount: mount failed: Operation not permitted
$ docker run --rm -it --cap-add SYS_ADMIN --device /dev/fuse sshfs
# sshfs sven@10.10.10.20:/home/sven /mnt
The authenticity of host '10.10.10.20 (10.10.10.20)' can't be established.
ECDSA key fingerprint is 25:34:85:75:25:b0:17:46:05:19:04:93:b5:dd:5f:c6.
Are you sure you want to continue connecting (yes/no)? yes
sven@10.10.10.20's password:
root@30aa0cfaf1b5:/# ls -la /mnt/src/docker
total 1516
drwxrwxr-x 1 1000 1000   4096 Dec  4 06:08 .
drwxrwxr-x 1 1000 1000   4096 Dec  4 11:46 ..
-rw-rw-r-- 1 1000 1000     16 Oct  8 00:09 .dockerignore
-rwxrwxr-x 1 1000 1000    464 Oct  8 00:09 .drone.yml
drwxrwxr-x 1 1000 1000   4096 Dec  4 06:11 .git
-rw-rw-r-- 1 1000 1000    461 Dec  4 06:08 .gitignore
```
如果Docker守护进程在启动时选择了lxc lxc-driver（docker -d --exec-driver=lxc），那么就可以使用--lxc-conf来设定LXC参数。但需要注意的是，未来主机上的Docker deamon有可能不会使用LXC，所以这些参数有可能会包含一些没有实现的配置功能。这意味着，用户在操作这些参数时必须要十分熟悉LXC。

特别注意：当你使用--lxc-conf修改容器参数后，Docker deamon将不再管理这些参数，那么用户必须自行进行管理。比如说，你使用--lxc-conf修改了容器的IP地址，那么在/etc/hosts里面是不会自动体现的，需要你自行维护。


## Introducing the Kubernetes kubelet in CoreOS Linux

* [Introducing the Kubernetes kubelet in CoreOS Linux | CoreOS ](https://coreos.com/blog/introducing-the-kubelet-in-coreos.html)

CoreOS Linux ships with reasonable defaults for the kubelet, which have been optimized for security and ease of use. However, we are going to loosen the security restrictions in order to enable support for privileged containers. This is required to run the proxy component in a single node Kubernetes cluster, which needs access to manipulate iptables to facilitate the Kubernetes service discovery model.

## 官方文档 kubelet

* [kubelet - Kubernetes ](https://kubernetes.io/docs/admin/kubelet/)

## kubelet 组件功能

* [kubernetes 简介： kubelet 组件功能 - 推酷 ](http://www.tuicool.com/articles/eaeyqiF)

|参数|解释|默认值|
|-|-|-|
|–address|kubelet 服务监听的地址|0.0.0.0|
|–port|kubelet 服务监听的端口|10250|
|–read-only-port|只读端口，可以不用验证和授权机制，直接访问|10255|
|**–allow-privileged**|是否允许容器运行在 privileged 模式|false|
|–api-servers|以逗号分割的 API Server 地址，用于和集群中数据交互|[]|
|–cadvisor-port|当前节点 cadvisor 运行的端口|4194|
|–config|本地 manifest 文件的路径或者目录|””|
|–file-check-frequency|轮询本地 manifest 文件的时间间隔|20s|
|–container-runtime|后端容器 runtime，支持 docker 和 rkt|docker|
|–enable-server|是否启动 kubelet HTTP server|true|
|–healthz-bind-address|健康检查服务绑定的地址，设置成 0.0.0.0 可以监听在所有网络接口|127.0.0.1|
|–healthz-port|健康检查服务的端口|10248|
|–hostname-override|指定 hostname，如果非空会使用这个值作为节点在集群中的标识|””|
|–log-dir|日志文件，如果非空，会把 log 写到该文件|””|
|–logtostderr|是否打印 log 到终端|true|
|–max-open-files|允许 kubelet 打开文件的最大值|1000000|
|–max-pods|允许 kubelet 运行 pod 的最大值|110|
|**–pod-infra-container-image**|基础镜像地址，每个 pod 最先启动的容器，会配置共享的网络|gcr.io/google_containers/pause-amd64:3.0|
|–root-dir|kubelet 保存数据的目录|/var/lib/kubelet|
|–runonce|从本地 manifest 或者 URL 指定的 manifest 读取并运行结束就退出，和 --api-servers 、 --enable-server 参数不兼容||
|–v|日志 level|0