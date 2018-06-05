

Kubernetes之kubectl常用命令使用指南:2:故障排查 - CSDN博客 http://blog.csdn.net/liumiaocn/article/details/73925301

kubectl是一个用于操作kubernetes集群的命令行接口,通过利用kubectl的各种命令可以实现各种功能,是在使用kubernetes中非常常用的工具。这里我们会通过一些简单的实例来展现其中一些高频命令的使用方法。 
更为重要的是这些命令使用的场景以及能够解决什么样的问题。上篇文章我们介绍了创建和删除相关的几条命令，这篇文章我们来看一下出现问题时最常用的另外九条命令。

常用命令

kubectl故障排查相关，本文将会简单介绍一下如下命令

项番	命令	说明
No.1	version	显示客户端和服务器侧版本信息
No.2	api-versions	以group/version的格式显示服务器侧所支持的API版本
No.3	explain	显示资源文档信息
No.4	get	取得确认对象信息列表
No.5	describe	取得确认对象的详细信息
No.6	logs	取得pod中容器的log信息
No.7	exec	在容器中执行一条命令
No.8	cp	从容器考出或向容器考入文件
No.9	attach	Attach到一个运行中的容器上
事前准备

kubectl version

version命令用于确认客户端和服务器侧的版本信息，不同的版本的情况变化可能很大，所以故障排除时首先也需要确认的是现场环境的版本信息。 
从下面可以清楚地看到，本文验证时所使用的版本为1.5.2

[root@ku8-1 tmp]# kubectl version
Client Version: version.Info{Major:"1", Minor:"5", GitVersion:"v1.5.2", GitCommit:"08e099554f3c31f6e6f07b448ab3ed78d0520507", GitTreeState:"clean", BuildDate:"2017-01-12T04:57:25Z", GoVersion:"go1.7.4", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"5", GitVersion:"v1.5.2", GitCommit:"08e099554f3c31f6e6f07b448ab3ed78d0520507", GitTreeState:"clean", BuildDate:"2017-01-12T04:52:34Z", GoVersion:"go1.7.4", Compiler:"gc", Platform:"linux/amd64"}
[root@ku8-1 tmp]#
1
2
3
4
集群构成

一主三从的Kubernetes集群

项番	类型	Hostname	IP
No.1	Master	ku8-1	192.168.32.131
No.1	Node	ku8-2	192.168.32.132
No.1	Node	ku8-3	192.168.32.133
No.1	Node	ku8-4	192.168.32.134
[root@ku8-1 tmp]# kubectl get nodes
NAME             STATUS    AGE
192.168.32.132   Ready     12m
192.168.32.133   Ready     11m
192.168.32.134   Ready     11m
[root@ku8-1 tmp]# 
1
2
3
4
5
6
kubectl api-versions

使用api-versions命令可以列出当前版本的kubernetes的服务器端所支持的api版本信息。

[root@ku8-1 tmp]# kubectl api-versions
apps/v1beta1
authentication.k8s.io/v1beta1
authorization.k8s.io/v1beta1
autoscaling/v1
batch/v1
certificates.k8s.io/v1alpha1
extensions/v1beta1
policy/v1beta1
rbac.authorization.k8s.io/v1alpha1
storage.k8s.io/v1beta1
v1
[root@ku8-1 tmp]#
1
2
3
4
5
6
7
8
9
10
11
12
13
kubectl explain

使用kubectl explain可以和kubectl help一样进行辅助的功能确认，使用它可以了解各个部分的说明和组成部分。比如如下可以看到对rc的说明，在故障排除时作用并不具有太大作用，到是可以多读读加深一下对各个部分的理解。

[root@ku8-1 ~]# kubectl explain rc
DESCRIPTION:
ReplicationController represents the configuration of a replication controller.

FIELDS:
   apiVersion   <string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     http://releases.k8s.io/HEAD/docs/devel/api-conventions.md#resources

   kind <string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     http://releases.k8s.io/HEAD/docs/devel/api-conventions.md#types-kinds

   metadata <Object>
     If the Labels of a ReplicationController are empty, they are defaulted to
     be the same as the Pod(s) that the replication controller manages. Standard
     object's metadata. More info:
     http://releases.k8s.io/HEAD/docs/devel/api-conventions.md#metadata

   spec <Object>
     Spec defines the specification of the desired behavior of the replication
     controller. More info:
     http://releases.k8s.io/HEAD/docs/devel/api-conventions.md#spec-and-status

   status   <Object>
     Status is the most recently observed status of the replication controller.
     This data may be out of date by some window of time. Populated by the
     system. Read-only. More info:
     http://releases.k8s.io/HEAD/docs/devel/api-conventions.md#spec-and-status


[root@ku8-1 ~]# 
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
explain命令能够确认的信息类别

其所能支持的类别如下：

类别
clusters (仅对federation apiservers有效)
componentstatuses (缩写 cs)
configmaps (缩写 cm)
daemonsets (缩写 ds)
deployments (缩写 deploy)
endpoints (缩写 ep)
events (缩写 ev)
horizontalpodautoscalers (缩写 hpa)
ingresses (缩写 ing)
jobs
limitranges (缩写 limits)
namespaces (缩写 ns)
networkpolicies
nodes (缩写 no)
persistentvolumeclaims (缩写 pvc)
persistentvolumes (缩写 pv)
pods (缩写 po)
podsecuritypolicies (缩写 psp)
podtemplates
replicasets (缩写 rs)
replicationcontrollers (缩写 rc)
resourcequotas (缩写 quota)
secrets
serviceaccounts (缩写 sa)
services (缩写 svc)
statefulsets
storageclasses
thirdpartyresources
事前准备

剩下的一些命令需要事前作一些准备，我们还是用上篇文章所用的yaml文件创建mysql和sonarqube的Deployment和pod。

yaml文件准备

[root@ku8-1 tmp]# ls yamls
mysql.yaml  sonar.yaml
[root@ku8-1 tmp]# cat yamls/mysql.yaml 
---
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: mysql
spec:
  replicas: 1
  template:
    metadata:
      labels:
        name: mysql
    spec:
      containers:
      - name: mysql
        image: 192.168.32.131:5000/mysql:5.7.16
        ports:
        - containerPort: 3306
          protocol: TCP
        env:
          - name: MYSQL_ROOT_PASSWORD
            value: "hello123"
[root@ku8-1 tmp]# cat yamls/sonar.yaml 
---
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: sonarqube
spec:
  replicas: 1
  template:
    metadata:
      labels:
        name: sonarqube
    spec:
      containers:
      - name: sonarqube
        image: 192.168.32.131:5000/sonarqube:5.6.5
        ports:
        - containerPort: 9000
          protocol: TCP
[root@ku8-1 tmp]# 
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
启动

[root@ku8-1 tmp]# kubectl create -f yamls/
deployment "mysql" created
deployment "sonarqube" created
[root@ku8-1 tmp]# 
1
2
3
4
kubectl get

使用get命令确认所创建出来的pod和deployment的信息

确认pod

可以看到创建出来的pod的所有信息,也可以使用Kubectl get po进行确认

[root@ku8-1 tmp]# kubectl get pods
NAME                         READY     STATUS    RESTARTS   AGE
mysql-478535978-1dnm2        1/1       Running   0          34s
sonarqube-3574384362-m7mdq   1/1       Running   0          34s
[root@ku8-1 tmp]# 
1
2
3
4
5
确认deployment

可以看到创建出来的deployment的所有信息

[root@ku8-1 tmp]# kubectl get deployments
NAME        DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
mysql       1         1         1            1           41s
sonarqube   1         1         1            1           41s
[root@ku8-1 tmp]#
1
2
3
4
5
如果希望得到更加详细一点的信息，可以加上-o wide参数,比如对pods可以看到此pod在哪个node上运行，此pod的集群IP是多少也被一并显示了

[root@ku8-1 tmp]# kubectl get pods -o wide
NAME                         READY     STATUS    RESTARTS   AGE       IP             NODE
mysql-478535978-1dnm2        1/1       Running   0          2m        172.200.44.2   192.168.32.133
sonarqube-3574384362-m7mdq   1/1       Running   0          2m        172.200.59.2   192.168.32.134
[root@ku8-1 tmp]#
1
2
3
4
5
确认node信息

显示node的信息

[root@ku8-1 tmp]# kubectl get nodes -o wide
NAME             STATUS    AGE       EXTERNAL-IP
192.168.32.132   Ready     6h        <none>
192.168.32.133   Ready     6h        <none>
192.168.32.134   Ready     6h        <none>
[root@ku8-1 tmp]#
1
2
3
4
5
6
确认namespace信息

列出所有的namespace

[root@ku8-1 tmp]# kubectl get namespaces
NAME          STATUS    AGE
default       Active    6h
kube-system   Active    6h
[root@ku8-1 tmp]# 
1
2
3
4
5
get命令能够确认的信息类别

使用node/pod/event/namespaces等结合起来，能够获取集群基本信息和状况, 其所能支持的类别如下：

类别
clusters (仅对federation apiservers有效)
componentstatuses (缩写 cs)
configmaps (缩写 cm)
daemonsets (缩写 ds)
deployments (缩写 deploy)
endpoints (缩写 ep)
events (缩写 ev)
horizontalpodautoscalers (缩写 hpa)
ingresses (缩写 ing)
jobs
limitranges (缩写 limits)
namespaces (缩写 ns)
networkpolicies
nodes (缩写 no)
persistentvolumeclaims (缩写 pvc)
persistentvolumes (缩写 pv)
pods (缩写 po)
podsecuritypolicies (缩写 psp)
podtemplates
replicasets (缩写 rs)
replicationcontrollers (缩写 rc)
resourcequotas (缩写 quota)
secrets
serviceaccounts (缩写 sa)
services (缩写 svc)
statefulsets
storageclasses
thirdpartyresources
kubectl describe

确认node详细信息

一般使用get命令取得node信息，然后使用describe确认详细信息。

[root@ku8-1 tmp]# kubectl get nodes
NAME             STATUS    AGE
192.168.32.132   Ready     6h
192.168.32.133   Ready     6h
192.168.32.134   Ready     6h
[root@ku8-1 tmp]# kubectl describe node 192.168.32.132
Name:           192.168.32.132
Role:           
Labels:         beta.kubernetes.io/arch=amd64
            beta.kubernetes.io/os=linux
            kubernetes.io/hostname=192.168.32.132
Taints:         <none>
CreationTimestamp:  Wed, 28 Jun 2017 23:06:22 -0400
Phase:          
Conditions:
  Type          Status  LastHeartbeatTime           LastTransitionTime          Reason              Message
  ----          ------  -----------------           ------------------          ------              -------
  OutOfDisk         False   Thu, 29 Jun 2017 05:52:07 -0400     Wed, 28 Jun 2017 23:06:22 -0400     KubeletHasSufficientDisk    kubelet has sufficient disk space available
  MemoryPressure    False   Thu, 29 Jun 2017 05:52:07 -0400     Wed, 28 Jun 2017 23:06:22 -0400     KubeletHasSufficientMemory  kubelet has sufficient memory available
  DiskPressure      False   Thu, 29 Jun 2017 05:52:07 -0400     Wed, 28 Jun 2017 23:06:22 -0400     KubeletHasNoDiskPressure    kubelet has no disk pressure
  Ready         True    Thu, 29 Jun 2017 05:52:07 -0400     Wed, 28 Jun 2017 23:06:34 -0400     KubeletReady            kubelet is posting ready status
Addresses:      192.168.32.132,192.168.32.132,192.168.32.132
Capacity:
 alpha.kubernetes.io/nvidia-gpu:    0
 cpu:                   1
 memory:                2032128Ki
 pods:                  110
Allocatable:
 alpha.kubernetes.io/nvidia-gpu:    0
 cpu:                   1
 memory:                2032128Ki
 pods:                  110
System Info:
 Machine ID:            22718f24279240be9fe0c469187f901a
 System UUID:           9F584D56-F5B3-FAB8-3985-938D67451312
 Boot ID:           fe3b2606-37ee-4b07-8de2-438fe29bf765
 Kernel Version:        3.10.0-514.el7.x86_64
 OS Image:          CentOS Linux 7 (Core)
 Operating System:      linux
 Architecture:          amd64
 Container Runtime Version: docker://1.13.1
 Kubelet Version:       v1.5.2
 Kube-Proxy Version:        v1.5.2
ExternalID:         192.168.32.132
Non-terminated Pods:        (0 in total)
  Namespace         Name        CPU Requests    CPU Limits  Memory Requests Memory Limits
  ---------         ----        ------------    ----------  --------------- -------------
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.
  CPU Requests  CPU Limits  Memory Requests Memory Limits
  ------------  ----------  --------------- -------------
  0 (0%)    0 (0%)      0 (0%)      0 (0%)
No events.
[root@ku8-1 tmp]#
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
确认pod

确认某一pod详细信息

[root@ku8-1 tmp]# kubectl describe pod mysql-478535978-1dnm2
Name:       mysql-478535978-1dnm2
Namespace:  default
Node:       192.168.32.133/192.168.32.133
Start Time: Thu, 29 Jun 2017 05:04:21 -0400
Labels:     name=mysql
        pod-template-hash=478535978
Status:     Running
IP:     172.200.44.2
Controllers:    ReplicaSet/mysql-478535978
Containers:
  mysql:
    Container ID:   docker://47ef1495e86f4b69414789e81081fa55b837dafe9e47944894e7cb3733700410
    Image:      192.168.32.131:5000/mysql:5.7.16
    Image ID:       docker-pullable://192.168.32.131:5000/mysql@sha256:410b279f6827492da7a355135e6e9125849f62eeca76429974a534f021852b58
    Port:       3306/TCP
    State:      Running
      Started:      Thu, 29 Jun 2017 05:04:22 -0400
    Ready:      True
    Restart Count:  0
    Volume Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-dzs1w (ro)
    Environment Variables:
      MYSQL_ROOT_PASSWORD:  hello123
Conditions:
  Type      Status
  Initialized   True 
  Ready     True 
  PodScheduled  True 
Volumes:
  default-token-dzs1w:
    Type:   Secret (a volume populated by a Secret)
    SecretName: default-token-dzs1w
QoS Class:  BestEffort
Tolerations:    <none>
No events.
[root@ku8-1 tmp]# 
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
确认deployment详细信息

确认某一deployment的详细信息

[root@ku8-1 tmp]# kubectl get deployment
NAME        DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
mysql       1         1         1            1           1h
sonarqube   1         1         1            1           1h
[root@ku8-1 tmp]# kubectl describe deployment mysql
Name:           mysql
Namespace:      default
CreationTimestamp:  Thu, 29 Jun 2017 05:04:21 -0400
Labels:         name=mysql
Selector:       name=mysql
Replicas:       1 updated | 1 total | 1 available | 0 unavailable
StrategyType:       RollingUpdate
MinReadySeconds:    0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Conditions:
  Type      Status  Reason
  ----      ------  ------
  Available     True    MinimumReplicasAvailable
OldReplicaSets: <none>
NewReplicaSet:  mysql-478535978 (1/1 replicas created)
No events.
[root@ku8-1 tmp]# 
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
describe命令能够确认的信息

describe命令所能支持的类别如下：

类别
clusters (仅对federation apiservers有效)
componentstatuses (缩写 cs)
configmaps (缩写 cm)
daemonsets (缩写 ds)
deployments (缩写 deploy)
endpoints (缩写 ep)
events (缩写 ev)
horizontalpodautoscalers (缩写 hpa)
ingresses (缩写 ing)
jobs
limitranges (缩写 limits)
namespaces (缩写 ns)
networkpolicies
nodes (缩写 no)
persistentvolumeclaims (缩写 pvc)
persistentvolumes (缩写 pv)
pods (缩写 po)
podsecuritypolicies (缩写 psp)
podtemplates
replicasets (缩写 rs)
replicationcontrollers (缩写 rc)
resourcequotas (缩写 quota)
secrets
serviceaccounts (缩写 sa)
services (缩写 svc)
statefulsets
storageclasses
thirdpartyresources
kubectl logs

类似于docker logs，使用kubectl logs能够取出pod中镜像的log，也是故障排除时候的重要信息

[root@ku8-1 tmp]# kubectl get pods
NAME                         READY     STATUS    RESTARTS   AGE
mysql-478535978-1dnm2        1/1       Running   0          1h
sonarqube-3574384362-m7mdq   1/1       Running   0          1h
[root@ku8-1 tmp]# kubectl logs mysql-478535978-1dnm2
Initializing database
...
2017-06-29T09:04:37.081939Z 0 [Note] Event Scheduler: Loaded 0 events
2017-06-29T09:04:37.082097Z 0 [Note] mysqld: ready for connections.
Version: '5.7.16'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  MySQL Community Server (GPL)
[root@ku8-1 tmp]# 
1
2
3
4
5
6
7
8
9
10
11
kubectl exec

exec命令用于到容器中执行一条命令，比如下述命令用于到mysql的镜像中执行hostname命令

[root@ku8-1 tmp]# kubectl get pods
NAME                         READY     STATUS    RESTARTS   AGE
mysql-478535978-1dnm2        1/1       Running   0          1h
sonarqube-3574384362-m7mdq   1/1       Running   0          1h
[root@ku8-1 tmp]# kubectl exec mysql-478535978-1dnm2 hostname
mysql-478535978-1dnm2
[root@ku8-1 tmp]# 
1
2
3
4
5
6
7
更为常用的方式则是登陆到pod中，在有条件的时候，进行故障发生时的现场确认，这种方式是最为直接有效和快速，但是对权限要求也较多。

[root@ku8-1 tmp]# kubectl exec -it mysql-478535978-1dnm2 sh
# hostname
mysql-478535978-1dnm2
# 
1
2
3
4
kubectl cp

用于pod和外部的文件交换，比如如下示例了如何在进行内外文件交换。

在pod中创建一个文件message.log

[root@ku8-1 tmp]# kubectl exec -it mysql-478535978-1dnm2 sh
# pwd
/
# cd /tmp
# echo "this is a message from `hostname`" >message.log
# cat message.log
this is a message from mysql-478535978-1dnm2
# exit
[root@ku8-1 tmp]#
1
2
3
4
5
6
7
8
9
拷贝出来并确认

[root@ku8-1 tmp]# kubectl cp mysql-478535978-1dnm2:/tmp/message.log message.log
tar: Removing leading `/' from member names
[root@ku8-1 tmp]# cat message.log
this is a message from mysql-478535978-1dnm2
[root@ku8-1 tmp]#
1
2
3
4
5
更改message.log并拷贝回pod

[root@ku8-1 tmp]# echo "information added in `hostname`" >>message.log 
[root@ku8-1 tmp]# cat message.log 
this is a message from mysql-478535978-1dnm2
information added in ku8-1
[root@ku8-1 tmp]# kubectl cp message.log mysql-478535978-1dnm2:/tmp/message.log
[root@ku8-1 tmp]# 
1
2
3
4
5
6
确认更改后的信息

[root@ku8-1 tmp]# kubectl exec mysql-478535978-1dnm2 cat /tmp/message.log
this is a message from mysql-478535978-1dnm2
information added in ku8-1
[root@ku8-1 tmp]#
1
2
3
4
kubectl attach

类似于docker attach的功能，用于取得实时的类似于kubectl logs的信息

[root@ku8-1 tmp]# kubectl get pods
NAME                         READY     STATUS    RESTARTS   AGE
mysql-478535978-1dnm2        1/1       Running   0          1h
sonarqube-3574384362-m7mdq   1/1       Running   0          1h
[root@ku8-1 tmp]# kubectl attach sonarqube-3574384362-m7mdq
If you don't see a command prompt, try pressing enter.
1
2
3
4
5
6
7
kubectl cluster-info

使用cluster-info和cluster-info dump也能取出一些信息，尤其是你需要看整体的全部信息的时候一条命令一条命令的执行不如kubectl cluster-info dump来的快一些

[root@ku8-1 tmp]# kubectl cluster-info
Kubernetes master is running at http://localhost:8080

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
[root@ku8-1 tmp]# 
1
2
3
4
5
总结

这篇文章中介绍了九个kubectl的常用命令，利用它们在故障确认和排查中非常有效。

版权声明：本文为博主原创文章，未经博主允许欢迎转载，但请注明出处。
本文已收录于以下专栏：深入浅出kubernetes深入浅出Docker