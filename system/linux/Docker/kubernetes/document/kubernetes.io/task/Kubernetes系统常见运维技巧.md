

Kubernetes系统常见运维技巧 - 技术分享 - 社区 - 好雨，让云落地 
https://t.goodrain.com/t/kubernetes/131

# Node的隔离和恢复

```yml
apiVersion: v1
kind: Node
metadata:
  name: kubernetes-minion1
  labels:
    kubernetes.io/hostname: kubernetes-minion1
spec:
  unschedulable: true
```

通过kubectl replace命令完成对Node状态的修改：
$ kubectl replace -f unschedule_node.yaml 
查看Node的状态，可以观察到在Node的状态中增加了一项SchedulingDisabled：
$ kubectl get nodes
NAME                 LABELS                                      STATUS
kubernetes-minion1   kubernetes.io/hostname=kubernetes-minion1   Ready, SchedulingDisabled
对于后续创建的Pod，系统将不会再向该Node进行调度。

另一种方法是不使用配置文件，直接使用kubectl patch命令完成：

$ kubectl patch node kubernetes-minion1 -p '{＂spec＂:{＂unschedulable＂:true}}'
需要注意的是，将某个Node脱离调度范围时，在其上运行的Pod并不会自动停止，管理员需要手动停止在该Node上运行的Pod。

同样，如果需要将某个Node重新纳入集群调度范围，则将unschedulable设置为false，再次执行kubectl replace或kubectl patch命令就能恢复系统对该Node的调度。

# Node的扩容

在实际生产系统中会经常遇到服务器容量不足的情况，这时就需要购买新的服务器，然后将应用系统进行水平扩展来完成对系统的扩容。

在Kubernetes集群中，对于一个新Node的加入是非常简单的。可以在Node节点上安装Docker、Kubelet和kube-proxy服务，然后将Kubelet和kube-proxy的启动参数中的Master URL指定为当前Kubernetes集群Master的地址，最后启动这些服务。基于Kubelet的自动注册机制，新的Node将会自动加入现有的Kubernetes集群中，如图1所示。
新节点自动注册完成扩容

Kubernetes Master在接受了新Node的注册之后，会自动将其纳入当前集群的调度范围内，在之后创建容器时，就可以向新的Node进行调度了。

通过这种机制，Kubernetes实现了集群的扩容。

# Pod动态扩容和缩放
在实际生产系统中，我们经常会遇到某个服务需要扩容的场景，也可能会遇到由于资源紧张或者工作负载降低而需要减少服务实例数的场景。此时我们可以利用命令kubectl scale rc来完成这些任务。以redis-slave RC为例，已定义的最初副本数量为2，通过执行下面的命令将redis-slave RC控制的Pod副本数量从初始的2更新为3：

$ kubectl scale rc redis-slave --replicas=3
执行kubectl get pods命令来验证Pod的副本数量增加到3：
$ kubectl get pods
将--replicas设置为比当前Pod副本数量更小的数字，系统将会“杀掉”一些运行中的Pod，即可实现应用集群缩容：
$ kubectl scale rc redis-slave --replicas=1
$ kubectl get pods

# 更新资源对象的Label
Label（标签）作为用户可灵活定义的对象属性，在已创建的对象上，仍然可以随时通过kubectl label命令对其进行增加、修改、删除等操作。

例如，我们要给已创建的Pod“redis-master-bobr0”添加一个标签role=backend：
$ kubectl label pod redis-master-bobr0 role=backend
$ kubectl get pods -Lrole
删除一个Label，只需在命令行最后指定Label的key名并与一个减号相连即可：
$ kubectl label pod redis-master-bobr0 role-
修改一个Label的值，需要加上--overwrite参数：
$ kubectl label pod redis-master-bobr0 role=master --overwrite

# 将Pod调度到指定的Node
我们知道，Kubernetes的Scheduler服务（kube-scheduler进程）负责实现Pod的调度，整个调度过程通过执行一系列复杂的算法最终为每个Pod计算出一个最佳的目标节点，这一过程是自动完成的，我们无法知道Pod最终会被调度到哪个节点上。有时我们可能需要将Pod调度到一个指定的Node上，此时，我们可以通过Node的标签（Label）和Pod的nodeSelector属性相匹配，来达到上述目的。

首先，我们可以通过kubectl label命令给目标Node打上一个特定的标签，下面是此命令的完整用法：
kubectl label nodes <node-name> <label-key>=<label-value>
这里，我们为kubernetes-minion1节点打上一个zone=north的标签，表明它是“北方”的一个节点：

$ kubectl label nodes kubernetes-minion1 zone=north
上述命令行操作也可以通过修改资源定义文件的方式，并执行kubectl replace -f xxx.yaml命令来完成。

然后，在Pod的配置文件中加入nodeSelector定义，以redis-master-controller.yaml为例：

```yml
apiVersion: v1
kind: ReplicationController
metadata:
  name: redis-master
  labels:
    name: redis-master
spec:
  replicas: 1
  selector:
    name: redis-master
  template:
    metadata:
      labels:
        name: redis-master
    spec:
      containers:
      - name: master
        image: kubeguide/redis-master
        ports:
        - containerPort: 6379
      nodeSelector:
        zone: north
```

运行kubectl create -f命令创建Pod，scheduler就会将该Pod调度到拥有zone=north标签的Node上去。

使用kubectl get pods -o wide命令可以验证Pod所在的Node：

# kubectl get pods -o wide
NAME                 READY     STATUS    RESTARTS   AGE       NODE
redis-master-f0rqj   1/1       Running   0          19s       kubernetes-minion1
如果我们给多个Node都定义了相同的标签（例如zone=north），则scheduler将会根据调度算法从这组Node中挑选一个可用的Node进行Pod调度。

这种基于Node标签的调度方式灵活性很高，比如我们可以把一组Node分别贴上“开发环境”“测试验证环境”“用户验收环境”这三组标签中的一种，此时一个Kubernetes集群就承载了3个环境，这将大大提高开发效率。

需要注意的是，如果我们指定了Pod的nodeSelector条件，且集群中不存在包含相应标签的Node时，即使还有其他可供调度的Node，这个Pod也最终会调度失败。

# 应用的滚动升级
当集群中的某个服务需要升级时，我们需要停止目前与该服务相关的所有Pod，然后重新拉取镜像并启动。如果集群规模比较大，则这个工作就变成了一个挑战，而且先全部停止然后逐步升级的方式会导致较长时间的服务不可用。Kubernetes提供了rolling-update（滚动升级）功能来解决上述问题。

滚动升级通过执行kubectl rolling-update命令一键完成，该命令创建了一个新的RC，然后自动控制旧的RC中的Pod副本数量逐渐减少到0，同时新的RC中的Pod副本数量从0逐步增加到目标值，最终实现了Pod的升级。需要注意的是，系统要求新的RC需要与旧的RC在相同的命名空间（Namespace）内，即不能把别人的资产偷偷转移到自家名下。

以redis-master为例，假设当前运行的redis-master Pod是1.0版本，则现在需要升级到2.0版本。

创建redis-master-controller-v2.yaml的配置文件如下：

```yml
apiVersion: v1
kind: ReplicationController
metadata:
  name: redis-master-v2
  labels:	
    name: redis-master
    version: v2
spec:
  replicas: 1
  selector:
    name: redis-master
    version: v2
  template:
    metadata:
      labels:
        name: redis-master
        version: v2
    spec:
      containers:
      - name: master
        image: kubeguide/redis-master:2.0
        ports:
        - containerPort: 6379
```

在配置文件中有几处需要注意：
（1）RC的名字（name）不能与旧的RC的名字相同；
（2）在selector中应至少有一个Label与旧的RC的Label不同，以标识其为新的RC。

本例中新增了一个名为version的Label，以与旧的RC进行区分。

运行kubectl rolling-update命令完成Pod的滚动升级：

kubectl rolling-update redis-master -f redis-master-controller-v2.yaml
等所有新的Pod启动完成后，旧的Pod也被全部销毁，这样就完成了容器集群的更新。

另一种方法是不使用配置文件，直接用kubectl rolling-update命令，加上--image参数指定新版镜像名称来完成Pod的滚动升级：

kubectl rolling-update redis-master --image=redis-master:2.0
与使用配置文件的方式不同，执行的结果是旧的RC被删除，新的RC仍将使用旧的RC的名字。

`Kubectl通过新建一个新版本Pod，停掉一个旧版本Pod，逐步迭代来完成整个RC的更新。`

更新完成后，查看RC：
$ kubectl get rc	
可以看到，Kubectl给RC增加了一个key为“deployment”的Label（这个key的名字可通过--deployment-label-key参数进行修改），Label的值是RC的内容进行Hash计算后的值，相当于签名，这样就能很方便地比较RC里的Image名字及其他信息是否发生了变化，它的具体作用可以参见第6章的源码分析。

如果在更新过程中发现配置有误，则用户可以中断更新操作，并通过执行Kubectl rolling-update –rollback完成Pod版本的回滚：

$ kubectl rolling-update redis-master --image=kubeguide/redis-master:2.0 --rollback
到此，可以看到Pod恢复到更新前的版本了。

# Kubernetes集群高可用方案
Kubernetes作为容器应用的管理中心，通过对Pod的数量进行监控，并且根据主机或容器失效的状态将新的Pod调度到其他Node上，实现了应用层的高可用性。针对Kubernetes集群，高可用性还应包含以下两个层面的考虑：etcd数据存储的高可用性和Kubernetes Master组件的高可用性。

1．etcd高可用性方案
etcd在整个Kubernetes集群中处于中心数据库的地位，为保证Kubernetes集群的高可用性，首先需要保证数据库不是单故障点。一方面，etcd需要以集群的方式进行部署，以实现etcd数据存储的冗余、备份与高可用性；另一方面，etcd存储的数据本身也应考虑使用可靠的存储设备。

etcd集群的部署可以使用静态配置，也可以通过etcd提供的REST API在运行时动态添加、修改或删除集群中的成员。本节将对etcd集群的静态配置进行说明。关于动态修改的操作方法请参考etcd官方文档的说明。

首先，规划一个至少3台服务器（节点）的etcd集群，在每台服务器上安装好etcd。

部署一个由3台服务器组成的etcd集群，其配置如表1所示，其集群部署实例如图2所示。

然后修改每台服务器上etcd的配置文件/etc/etcd/etcd.conf。

以etcd1为创建集群的实例，需要将其ETCD_INITIAL_CLUSTER_STATE设置为“new”。etcd1的完整配置如下：

# [member]
ETCD_NAME=etcd1            #etcd实例名称
ETCD_DATA_DIR=＂/var/lib/etcd/etcd1＂   #etcd数据保存目录
ETCD_LISTEN_PEER_URLS=＂http://10.0.0.1:2380＂   #集群内部通信使用的URL
ETCD_LISTEN_CLIENT_URLS=＂http://10.0.0.1:2379＂   #供外部客户端使用的URL
……
#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS=＂http://10.0.0.1:2380＂   #广播给集群内其他成员使用的URL
ETCD_INITIAL_CLUSTER=＂etcd1=http://10.0.0.1:2380,etcd2=http://10.0.0.2:2380, etcd3=http://10.0.0.3:2380＂     #初始集群成员列表
ETCD_INITIAL_CLUSTER_STATE=＂new＂     #初始集群状态，new为新建集群
ETCD_INITIAL_CLUSTER_TOKEN=＂etcd-cluster＂   #集群名称
ETCD_ADVERTISE_CLIENT_URLS=＂http://10.0.0.1:2379＂   #广播给外部客户端使用的URL
启动etcd1服务器上的etcd服务：

$ systemctl restart etcd
启动完成后，就创建了一个名为etcd-cluster的集群。

etcd2和etcd3为加入etcd-cluster集群的实例，需要将其ETCD_INITIAL_CLUSTER_STATE设置为“exist”。etcd2的完整配置如下（etcd3的配置略）：

# [member]
ETCD_NAME=etcd2            #etcd实例名称
ETCD_DATA_DIR=＂/var/lib/etcd/etcd2＂   #etcd数据保存目录
ETCD_LISTEN_PEER_URLS=＂http://10.0.0.2:2380＂   #集群内部通信使用的URL
ETCD_LISTEN_CLIENT_URLS=＂http://10.0.0.2:2379＂   #供外部客户端使用的URL
……
#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS=＂http://10.0.0.2:2380＂   #广播给集群内其他成员使用的URL
ETCD_INITIAL_CLUSTER=＂etcd1=http://10.0.0.1:2380,etcd2=http://10.0.0.2:2380,etcd3=http://10.0.0.3:2380＂     #初始集群成员列表
ETCD_INITIAL_CLUSTER_STATE=＂exist＂       # existing表示加入已存在的集群
ETCD_INITIAL_CLUSTER_TOKEN=＂etcd-cluster＂   #集群名称
ETCD_ADVERTISE_CLIENT_URLS=＂http://10.0.0.2:2379＂   #广播给外部客户端使用的URL
启动etcd2和etcd3服务器上的etcd服务：

$ systemctl restart etcd
启动完成后，在任意etcd节点执行etcdctl cluster-health命令来查询集群的运行状态：

$ etcdctl cluster-health
cluster is healthy
member ce2a822cea30bfca is healthy
member acda82ba1cf790fc is healthy
member eba209cd0012cd2 is healthy
在任意etcd节点上执行etcdctl member list命令来查询集群的成员列表：

$ etcdctl member list
ce2a822cea30bfca: name=default peerURLs=http://10.0.0.1:2380,http://10.0.0.1: 7001 clientURLs=http://10.0.0.1:2379,http://10.0.0.1:4001
acda82ba1cf790fc: name=default peerURLs=http://10.0.0.2:2380,http://10.0.0.2: 7001 clientURLs=http://10.0.0.2:2379,http://10.0.0.2:4001
eba209cd40012cd2: name=default peerURLs=http://10.0.0.3:2380,http://10.0.0.3: 7001 clientURLs=http://10.0.0.3:2379,http://10.0.0.3:4001
至此，一个etcd集群就创建成功了。

以kube-apiserver为例，将访问etcd集群的参数设置为：

--etcd-servers=http://10.0.0.1:4001,http://10.0.0.2:4001,http://10.0.0.3:4001
在etcd集群成功启动之后，如果需要对集群成员进行修改，则请参考官方文档的详细说明：点击此处4

对于etcd中需要保存的数据的可靠性，可以考虑使用RAID磁盘阵列、高性能存储设备、NFS网络文件系统，或者使用云服务商提供的网盘系统等来实现。

2.Kubernetes Master组件的高可用性方案
在Kubernetes体系中，Master服务扮演着总控中心的角色，主要的三个服务kube-apiserver、kube-controller-mansger和kube-scheduler通过不断与工作节点上的Kubelet和kube-proxy进行通信来维护整个集群的健康工作状态。如果Master的服务无法访问到某个Node，则会将该Node标记为不可用，不再向其调度新建的Pod。但对Master自身则需要进行额外的监控，使Master不成为集群的单故障点，所以对Master服务也需要进行高可用方式的部署。

以Master的kube-apiserver、kube-controller-mansger和kube-scheduler三个服务作为一个部署单元，类似于etcd集群的典型部署配置。使用至少三台服务器安装Master服务，并且使用Active-Standby-Standby模式，保证任何时候总有一套Master能够正常工作。

所有工作节点上的Kubelet和kube-proxy服务则需要访问Master集群的统一访问入口地址，例如可以使用pacemaker等工具来实现。图3展示了一种典型的部署方式。
