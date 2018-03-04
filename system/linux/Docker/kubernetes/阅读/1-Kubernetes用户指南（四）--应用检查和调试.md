Kubernetes用户指南（四）--应用检查和调试 - CSDN博客 http://blog.csdn.net/qq1010885678/article/details/49405435

一、调试

当你的应用开始运行，那么DEBUG是不可避免的问题。
早些时候，我们在描述的是如何通过kubectl get pods来获得Pod的简单状态信息。
但是现在，这里有更多的方式来获得关于你的应用的更多信息。

1、使用kubectl describe pod来获得Pod的详细信息

在这个例子中，我们将会像之前的例子一样使用RC来创建两个Pod：
apiVersion: v1
kind: ReplicationController
metadata:
  name: my-nginx
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 80

$ kubectl create -f ./my-nginx-rc.yaml
replicationcontrollers/my-nginx

$ kubectl get pods
NAME             READY     REASON    RESTARTS   AGE
my-nginx-gy1ij   1/1       Running   0          1m
my-nginx-yv5cn   1/1       Running   0          1m

我们可以通过kubectl describe pod来获得每个Pod的详细信息，例如：

$ kubectl describe pod my-nginx-gy1ij
Name:               my-nginx-gy1ij
Image(s):           nginx
Node:               kubernetes-minion-y3vk/10.240.154.168
Labels:             app=nginx
Status:             Running
Reason:             
Message:           
IP:             10.244.1.4
Replication Controllers:    my-nginx (2/2 replicas created)
Containers:
  nginx:
    Image:  nginx
    Limits:
      cpu:      500m
      memory:       128Mi
    State:      Running
      Started:      Thu, 09 Jul 2015 15:33:07 -0700
    Ready:      True
    Restart Count:  0
Conditions:
  Type      Status
  Ready     True 
Events:
  FirstSeen             LastSeen            Count   From                    SubobjectPath               Reason      Message
  Thu, 09 Jul 2015 15:32:58 -0700   Thu, 09 Jul 2015 15:32:58 -0700 1   {scheduler }                                    scheduled   Successfully assigned my-nginx-gy1ij to kubernetes-minion-y3vk
  Thu, 09 Jul 2015 15:32:58 -0700   Thu, 09 Jul 2015 15:32:58 -0700 1   {kubelet kubernetes-minion-y3vk}    implicitly required container POD   pulled      Pod container image "gcr.io/google_containers/pause:0.8.0" already present on machine
  Thu, 09 Jul 2015 15:32:58 -0700   Thu, 09 Jul 2015 15:32:58 -0700 1   {kubelet kubernetes-minion-y3vk}    implicitly required container POD   created     Created with docker id cd1644065066
  Thu, 09 Jul 2015 15:32:58 -0700   Thu, 09 Jul 2015 15:32:58 -0700 1   {kubelet kubernetes-minion-y3vk}    implicitly required container POD   started     Started with docker id cd1644065066
  Thu, 09 Jul 2015 15:33:06 -0700   Thu, 09 Jul 2015 15:33:06 -0700 1   {kubelet kubernetes-minion-y3vk}    spec.containers{nginx}          pulled      Successfully pulled image "nginx"
  Thu, 09 Jul 2015 15:33:06 -0700   Thu, 09 Jul 2015 15:33:06 -0700 1   {kubelet kubernetes-minion-y3vk}    spec.containers{nginx}          created     Created with docker id 56d7a7b14dac
  Thu, 09 Jul 2015 15:33:07 -0700   Thu, 09 Jul 2015 15:33:07 -0700 1   {kubelet kubernetes-minion-y3vk}    spec.containers{nginx}          started     Started with docker id 56d7a7b14dac

你可以看到容器和Pod（标签和资源需求量等等）的配置信息，也可以看到他们的状态信息（包括声明、是否准备就绪、重启次数和发生的事件等等）。

容器的state是Waiting、Running或者Terminated其中一个，根据这个状态信息，系统会告诉你正在运行的容器是什么时候启动的。

Ready说明了容器是否通过了它的最后一个就绪检查。（假如，容器没有准备就绪状态检查的探针，那么这个容器将会被认为是处于Ready状态的。）

Restart Count说明了容器重启了多少次，在检查容器中因为配置重启的政策为“总是”的循环崩溃时这是非常有用的信息。

当前有关Pod的唯一信息是Pod的Ready状态，表明了当前Pod有能力为请求服务，并且加入到负载均衡池中提供给所有匹配到的SVC。

最后，你可以看到一大堆有关你的Pod最近发生的事件，系统通过指明该事件第一次、最后一次发送的时间和发送的次数来压缩处理相同的事件。
“From”字段指明了哪个组件发生了这些事件，“SubobjectPath”字段告诉你哪个Object（例如，Pod中的容器）是被引用的，“Reason”和“Message”字段告诉你发生的事件是什么。


2、例子：调试处于Pending状态的Pods

通过观察事件信息来发现异常的一个常见的场景是：当你创建了一个Pod，但是它在任何节点上都不正常运行。
例如，这个Pod可能请求的资源量超出了节点上的空闲资源数，或者它可能指定了一个不能够匹配所有节点的Label Selector。

假设我们在一个拥有4个节点、每个节点都有1个CPU核心的集群上，通过5个replicas创建了之前的RC（之前是2个replicas），并且请求了600millicores代替之前的500。
假设其中的一个Pod将不会被调度。（注意，这是因为集群上装了例如，fluentd、skydns等等的插件，如果我们请求超过1000millicores那么所有Pod都将不会被调度。）

$ kubectl get pods
NAME             READY     REASON    RESTARTS   AGE
my-nginx-9unp9   0/1       Pending   0          8s
my-nginx-b7zs9   0/1       Running   0          8s
my-nginx-i595c   0/1       Running   0          8s
my-nginx-iichp   0/1       Running   0          8s
my-nginx-tc2j9   0/1       Running   0          8s

为了找出第一个Pod为什么没有处于running状态，我们可以使用kubectl describe pod查看处于pending状态的Pod的事件：

$ kubectl describe pod my-nginx-9unp9 
Name:               my-nginx-9unp9
Image(s):           nginx
Node:               /
Labels:             app=nginx
Status:             Pending
Reason:             
Message:           
IP:             
Replication Controllers:    my-nginx (5/5 replicas created)
Containers:
  nginx:
    Image:  nginx
    Limits:
      cpu:      600m
      memory:       128Mi
    State:      Waiting
    Ready:      False
    Restart Count:  0
Events:
  FirstSeen             LastSeen            Count   From        SubobjectPath   Reason          Message
  Thu, 09 Jul 2015 23:56:21 -0700   Fri, 10 Jul 2015 00:01:30 -0700 21  {scheduler }            failedScheduling    Failed for reason PodFitsResources and possibly others

在这里你可以看到，由Scheduler产生的事件说明了这个Pod调度失败是因为PodFitsResources（也有可能是其他）。
PodFitsResources说明了在任何节点上都没有足够的资源给这个Pod。
根据事件产生的形式，也有可能是其他的原因导致调度失败。

为了纠正这种情况，你可以使用kubectl scale来更新RC来定义使用4个或者更少的replicas。（或者你可以直接放弃这个Pod，这是没有影响的。）

例如你使用kubectl describe pod看到的事件都将持久化到etcd中，并且在集群发生什么事情的时候提供一个high-level的信息。
你可以使用

kubectl get events

来列出所有事件。

但是你必须记住，事件也是有命名空间的。
这意味着如果你对一些命名空间下的Object（例如，在my-namespace中Pod发生的事情）的事件感兴趣，你需要在命令行中明确地指定这个命名空间：

kubectl get events --namespace=my-namespace

可以使用--all-namespace参数看所有命名空间的事件。

除了kubectl describe pod之外，另外一种获得有关Pod的额外信息（超出kubectl get pod所提供的信息）的方式可以是，为kubectl get pod指定格式化输出标识，-o yaml。
这将会通过yaml格式给你提供比kubectl describe pod更多的信息，这基本上是系统中有关Pod的所有信息了。
在这里你将会看到类似注解的东西（一种k8s系统内部使用的，没有Label限制的键值对元数据）、重启政策、端口和卷。

$ kubectl get pod my-nginx-i595c -o yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubernetes.io/created-by: '{"kind":"SerializedReference","apiVersion":"v1","reference":{"kind":"ReplicationController","namespace":"default","name":"my-nginx","uid":"c555c14f-26d0-11e5-99cb-42010af00e4b","apiVersion":"v1","resourceVersion":"26174"}}'
  creationTimestamp: 2015-07-10T06:56:21Z
  generateName: my-nginx-
  labels:
    app: nginx
  name: my-nginx-i595c
  namespace: default
  resourceVersion: "26243"
  selfLink: /api/v1/namespaces/default/pods/my-nginx-i595c
  uid: c558e44b-26d0-11e5-99cb-42010af00e4b
spec:
  containers:
  - image: nginx
    imagePullPolicy: IfNotPresent
    name: nginx
    ports:
    - containerPort: 80
      protocol: TCP
    resources:
      limits:
        cpu: 600m
        memory: 128Mi
    terminationMessagePath: /dev/termination-log
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: default-token-zkhkk
      readOnly: true
  dnsPolicy: ClusterFirst
  nodeName: kubernetes-minion-u619
  restartPolicy: Always
  serviceAccountName: default
  volumes:
  - name: default-token-zkhkk
    secret:
      secretName: default-token-zkhkk
status:
  conditions:
  - status: "True"
    type: Ready
  containerStatuses:
  - containerID: docker://9506ace0eb91fbc31aef1d249e0d1d6d6ef5ebafc60424319aad5b12e3a4e6a9
    image: nginx
    imageID: docker://319d2015d149943ff4d2a20ddea7d7e5ce06a64bbab1792334c0d3273bbbff1e
    lastState: {}
    name: nginx
    ready: true
    restartCount: 0
    state:
      running:
        startedAt: 2015-07-10T06:56:28Z
  hostIP: 10.240.112.234
  phase: Running
  podIP: 10.244.3.4
  startTime: 2015-07-10T06:56:21Z


3、例子：调试挂掉的节点

有时候，查看节点的状态在调试时是非常有用的，例如你可以从这个节点获得Pod的一些奇怪的行为信息，或者找出为什么Pod没有在这个节点上被调度的原因。
和Pod的一些命令一样，你也可以使用kubectl describe node和kubectl get node -o yaml来获得有关节点的详细信息。

例如，这里是一些在节点挂掉的时候你可以看到的信息（网络连接断开或者kubelet进程挂掉了而且没有重启等情况）。
注意，节点的事件信息说明了节点的状态为NotReady，并且节点上的Pods也不再是运行的状态了（这些Pod将会节点处于NotReady状态在5分钟后停止）。

$ kubectl get nodes
NAME                     LABELS                                          STATUS
kubernetes-minion-861h   kubernetes.io/hostname=kubernetes-minion-861h   NotReady
kubernetes-minion-bols   kubernetes.io/hostname=kubernetes-minion-bols   Ready
kubernetes-minion-st6x   kubernetes.io/hostname=kubernetes-minion-st6x   Ready
kubernetes-minion-unaj   kubernetes.io/hostname=kubernetes-minion-unaj   Ready

$ kubectl describe node kubernetes-minion-861h
Name:           kubernetes-minion-861h
Labels:         kubernetes.io/hostname=kubernetes-minion-861h
CreationTimestamp:  Fri, 10 Jul 2015 14:32:29 -0700
Conditions:
  Type      Status      LastHeartbeatTime           LastTransitionTime          Reason                  Message
  Ready     Unknown     Fri, 10 Jul 2015 14:34:32 -0700     Fri, 10 Jul 2015 14:35:15 -0700     Kubelet stopped posting node status.   
Addresses:  10.240.115.55,104.197.0.26
Capacity:
 cpu:       1
 memory:    3800808Ki
 pods:      100
Version:
 Kernel Version:        3.16.0-0.bpo.4-amd64
 OS Image:          Debian GNU/Linux 7 (wheezy)
 Container Runtime Version: docker://Unknown
 Kubelet Version:       v0.21.1-185-gffc5a86098dc01
 Kube-Proxy Version:        v0.21.1-185-gffc5a86098dc01
PodCIDR:            10.244.0.0/24
ExternalID:         15233045891481496305
Pods:               (0 in total)
  Namespace         Name
Events:
  FirstSeen             LastSeen            Count   From                    SubobjectPath   Reason      Message
  Fri, 10 Jul 2015 14:32:28 -0700   Fri, 10 Jul 2015 14:32:28 -0700 1   {kubelet kubernetes-minion-861h}            NodeNotReady    Node kubernetes-minion-861h status is now: NodeNotReady
  Fri, 10 Jul 2015 14:32:30 -0700   Fri, 10 Jul 2015 14:32:30 -0700 1   {kubelet kubernetes-minion-861h}            NodeNotReady    Node kubernetes-minion-861h status is now: NodeNotReady
  Fri, 10 Jul 2015 14:33:00 -0700   Fri, 10 Jul 2015 14:33:00 -0700 1   {kubelet kubernetes-minion-861h}            starting    Starting kubelet.
  Fri, 10 Jul 2015 14:33:02 -0700   Fri, 10 Jul 2015 14:33:02 -0700 1   {kubelet kubernetes-minion-861h}            NodeReady   Node kubernetes-minion-861h status is now: NodeReady
  Fri, 10 Jul 2015 14:35:15 -0700   Fri, 10 Jul 2015 14:35:15 -0700 1   {controllermanager }                    NodeNotReady    Node kubernetes-minion-861h status is now: NodeNotReady


$ kubectl get node kubernetes-minion-861h -o yaml
apiVersion: v1
kind: Node
metadata:
  creationTimestamp: 2015-07-10T21:32:29Z
  labels:
    kubernetes.io/hostname: kubernetes-minion-861h
  name: kubernetes-minion-861h
  resourceVersion: "757"
  selfLink: /api/v1/nodes/kubernetes-minion-861h
  uid: 2a69374e-274b-11e5-a234-42010af0d969
spec:
  externalID: "15233045891481496305"
  podCIDR: 10.244.0.0/24
  providerID: gce://striped-torus-760/us-central1-b/kubernetes-minion-861h
status:
  addresses:
  - address: 10.240.115.55
    type: InternalIP
  - address: 104.197.0.26
    type: ExternalIP
  capacity:
    cpu: "1"
    memory: 3800808Ki
    pods: "100"
  conditions:
  - lastHeartbeatTime: 2015-07-10T21:34:32Z
    lastTransitionTime: 2015-07-10T21:35:15Z
    reason: Kubelet stopped posting node status.
    status: Unknown
    type: Ready
  nodeInfo:
    bootID: 4e316776-b40d-4f78-a4ea-ab0d73390897
    containerRuntimeVersion: docker://Unknown
    kernelVersion: 3.16.0-0.bpo.4-amd64
    kubeProxyVersion: v0.21.1-185-gffc5a86098dc01
    kubeletVersion: v0.21.1-185-gffc5a86098dc01
    machineID: ""
    osImage: Debian GNU/Linux 7 (wheezy)
    systemUUID: ABE5F6B4-D44B-108B-C46A-24CCE16C8B6E

二、k8s用户界面

k8s拥有一个web界面以图形化的形式为用户展示集群的状态信息。

1、访问用户界面

默认情况下，UI是以集群插件的形式部署的。
访问
https://<kubernetes-master>/ui
将会重定向到
https://<kubernetes-master>/api/v1/proxy/namespaces/kube-system/services/kube-ui/#/dashboard/

如果你无法访问集群的UI界面，可能是因为kube-ui进程并没有在你的集群中启动，这样的话，你可以通过手动来启动：

kubectl create -f cluster/addons/kube-ui/kube-ui-rc.yaml --namespace=kube-system
kubectl create -f cluster/addons/kube-ui/kube-ui-svc.yaml --namespace=kube-system

一般情况下，这应该是运行在Master节点上的kube-addons.sh脚本自动进行的操作。


2、使用用户界面

k8s的UI可以用来反馈集群当前的信息，例如，检查多少资源被分配了或者查看错误信息。
但是，你不能使用UI界面来修改你的集群配置。

3、节点资源的使用情况

在访问UI界面之后，你将会看到一个主界面，动态列出了集群中的所有节点，相关信息包括：内部IP地址、CPU使用、内存使用和文件系统使用情况等信息。



4、仪表板视图

点击右上角的“Views”按钮可以看到其他可用的视图，包括：Explore, Pods, Nodes, Replication Controllers, Services和Events.

5、探索视图

“Explore”视图允许你方便地查看当前集群中的Pods、RCs和SVCs。
“Group by”下拉列表允许你根据一些因素对这些资源进行分组，例如：类型、名称和主机等等。


你也可以通过点击任一资源实例上向下的三角形来创建过滤器，选择好你想要的过滤器类型即可。

点击任一资源实例可以看到更多详细信息。


6、其他视图

其他视图（包括Pods, Nodes, Replication Controllers, Services和Events）只是简单地列出了每个资源的类型信息，你可以通过点击来获得更详细的信息。



7、更多UI的介绍信息

请看Kubernetes UI development document

三、日志信息

1、k8s组件记录的日志

k8s的组件，例如kubelet和apiserver都是使用glog日志库，开发商约定的日志级别描述请看：
docs/devel/logging.md

2、检查运行中容器的日志

运行中的容器产生的日志信息可以通过kubectl logs来获得。
例如，现在有一个根据这个配置文件 counter-pod.yaml来生成的Pod，其中有一个容器每秒会输出一些文本信息（你可以在这里here找到不同的Pod声明）。

apiVersion: v1
kind: Pod
metadata:
  name: counter
spec:
  containers:
  - name: count
    image: ubuntu:14.04
    args: [bash, -c, 
           'for ((i = 0; ; i++)); do echo "$i: $(date)"; sleep 1; done']

Download example

我们运行这个Pod：

$ kubectl create -f ./counter-pod.yaml
pods/counter

然后获取它的日志信息：

$ kubectl logs counter
0: Tue Jun  2 21:37:31 UTC 2015
1: Tue Jun  2 21:37:32 UTC 2015
2: Tue Jun  2 21:37:33 UTC 2015
3: Tue Jun  2 21:37:34 UTC 2015
4: Tue Jun  2 21:37:35 UTC 2015
5: Tue Jun  2 21:37:36 UTC 2015
...

如果Pod中不止只有一个容器，那么你需要指明哪个容器的日志文件是你想要获取的。

$ kubectl logs kube-dns-v3-7r1l9 etcd
2015/06/23 00:43:10 etcdserver: start to snapshot (applied: 30003, lastsnap: 20002)
2015/06/23 00:43:10 etcdserver: compacted log at index 30003
2015/06/23 00:43:10 etcdserver: saved snapshot at index 30003
2015/06/23 02:05:42 etcdserver: start to snapshot (applied: 40004, lastsnap: 30003)
2015/06/23 02:05:42 etcdserver: compacted log at index 40004
2015/06/23 02:05:42 etcdserver: saved snapshot at index 40004
2015/06/23 03:28:31 etcdserver: start to snapshot (applied: 50005, lastsnap: 40004)
2015/06/23 03:28:31 etcdserver: compacted log at index 50005
2015/06/23 03:28:31 etcdserver: saved snapshot at index 50005
2015/06/23 03:28:56 filePurge: successfully removed file default.etcd/member/wal/0000000000000000-0000000000000000.wal
2015/06/23 04:51:03 etcdserver: start to snapshot (applied: 60006, lastsnap: 50005)
2015/06/23 04:51:03 etcdserver: compacted log at index 60006
2015/06/23 04:51:03 etcdserver: saved snapshot at index 60006
...

3、Google云日志系统

Cluster Level Logging to Google Cloud Logging这个入门指南展示了容器的日志是如何被记录到Google Cloud Logging中的，并且会说明如何查询这些日志。

4、Elasticsearch和Kibana

Cluster Level Logging with Elasticsearch and Kibana 入门指南描述了如何将集群日志记录到Elasticsearch中，然后使用Kibana来查看。

集群级别的日志只收集处于运行状态的容器中容器的标准输出和标准错误信息。
Collecting log files within containers with Fluentd这个指南阐述了如何将容器的日志信息也记录到Google云日志系统中。

5、已知的问题

k8s会会将k8s组件和Docker中容器的日志轮询记录，kubectl logs目前只能查询最后的日志，并不是所有的历史记录。

四、监控

1、在k8s中使用资源监控

对与应用的扩展，并且提供一个高可靠的服务来说，在部署的时候明确地知道应用的行为是至关重要的。
在k8s集群中，应用的性能可以按照不同级别来检查，可分为：容器、Pods、SVCs和整个集群。
在这些不同的级别上，我们想为用户提供正在运行的程序详细的资源使用情况。
这将会使用户对他们的应用是如何运行的，并且找出应用的瓶颈会有深刻的见解。
Heapster这个项目旨在为k8s以供一个基本的监控平台。

2、概述

Heapster是一个集群范围的监控和事件信息整合者，当前原生支持k8s，并且在各种安装方式中都可以工作。
Heapster在集群上以一个Pod的形式运行，就像k8s上任何一个应用一样。
Heapster这个Pod会发现集群上的所有节点，并且向节点上的kubelet查询使用信息，就像k8s的机器代理一样。
kubelet本身通过cAdvisor来获得数据，Heapster将这些信息按Pod有关的Label进行分组，之后这些数据将会被可视化并推送到一个可配置的后端存储。
目前支持的后端包括：InfluxDB（使用Grafana进行可视化）和Google Cloud Monitoring。
服务的总体构架如下如：

现在来看看其中的组件的详细信息。

3、cAdvisor

cAdvisor是一个开源的容器资源使用和性能分析代理，它是为容器而建造的，原生支持Docker容器。
在k8s中cAdvisor被集成在kubelet中。
cAdvisor会自动发现机器上的所有容器，并收集CPU、内存、文件系统和网络使用情况的统计数据。
cAdvisor还可以通过分析“根”容器来提供整个机器的总体使用情况。

在大多数k8s集群上，cAdvisor通过机器上的容器暴露端口号4194提供一个简单的UI界面。
下面是一个部分cAdvisor UI界面的快照，显示的是机器的总体使用情况：


4、Kubelet

Kubelet类似于k8s主节点和从节点之间的一个桥梁。
它管理着机器上运行的Pods和容器，Kubelet将每个Pod转换为其自己的容器，并且从cAdvisor上获得每个容器的使用情况统计。
之后，它将会通过REST API来暴露这些整合过的Pods资源使用情况统计。

5、后端存储

InfluxDB和Grafana

在开源世界，使用InfluxDB和Grafana进行监控是一个十分受欢迎的组合。
InfluxDB通过暴露一个使用起来很简单的API来输出和获取时间序列的数据。
在大多数k8s集群上Heapster默认设置使用InfluxDB作为后端存储工具。
一个详细的设置指南可以看这里：
here
InfluxDB和Grafana都在Pod中运行，这些Pod将会以SVC的形式暴露出来，这样Heapster就能够找到它。

Grafana容器提供了一个配置界面叫做：GrafanaUI。
k8s默认的可视化仪表形式的界面包含一个 集群上的监视器和其中的Pods的资源使用示例视图。
这个视图可以根据需要进行扩展和定制。
点击这里查看InfluxDB的存储模式：
here

下面的视频展示了如何使用heapster, InfluxDB和Grafana来监控集群：
http://www.youtube.com/watch?v=SZgqjMrxo3g

下面是一个k8s默认的Grafana仪板视图，显示了整个集群、Pod和容器的CPU和内存使用。


Google Cloud Monitoring

Google Cloud Monitoring是一个把控监视的服务，允许你在应用中将重要的指标可视化和警报。
Heapster可以设置为自动推送所有收集到的指标到Google Cloud Monitoring中。
之后这些指标可以在Cloud Monitoring Console中获得。
这个后端存储是最容易安装和维护的。
监视控制台允许你使用导出的数据很简单地创建和定制仪表视图。

下面的视频介绍了如何安装和运行Google Cloud Monitoring为Heapster服务：
https://www.youtube.com/watch?v=xSMNR2fcoLs

下面是一个Google Cloud Monitoring仪表视图的快照，显示了集群层面的资源使用：


6、尝试操作！

现在，你已经学习了一些关于Heapster的知识，可以随意在你的集群上尝试使用它。
Heapster repository可以通过Github获得，它包含了安装Heapster和其后端存储的详细说明。
Heapster在大多数k8s集群上都是默认运行的，所以你可能已经拥有Heapster了。


五、通过exec进入容器

开发者可以通过exec进入容器中运行命令，这个指南将会演示两个例子。

1、使用kubectl exec来检查容器的环境变量

k8s通过环境变量暴露services。
可以使用kubectl exec方便地检查这些环境变量。

首先我们创建一个Pod和一个SVC：

$ kubectl create -f examples/guestbook/redis-master-controller.yaml
$ kubectl create -f examples/guestbook/redis-master-service.yaml
等待Pod处于运行和准备状态：

$ kubectl get pod
NAME                 READY     REASON       RESTARTS   AGE
redis-master-ft9ex   1/1       Running      0          12s

之后我们可以检查Pod的环境变量：

$ kubectl exec redis-master-ft9ex env
...
REDIS_MASTER_SERVICE_PORT=6379
REDIS_MASTER_SERVICE_HOST=10.0.0.219
...

我们可以在应用中使用这些环境变量来发现SVC。

2、使用kubectl exec检查挂载的卷

如果卷像预期的一样被成功挂载，那么可以使用kubectl exec方便地进行检查，首先我们创建一个Pod，其有一个卷被挂载在/data/redis目录下：

kubectl create -f docs/user-guide/walkthrough/pod-redis.yaml
等待Pod处于运行和准备状态：

$ kubectl get pods
NAME      READY     REASON    RESTARTS   AGE
storage   1/1       Running   0          1m

使用kubectl exec验证卷是否有成功挂载：

$ kubectl exec storage ls /data
redis
3、使用kubectl exec在Pod中打开一个bash终端

检查Pod最好的方式肯定是打开一个bash终端进去检查，假设一个pod/storage一直是运行状态的，执行：

$ kubectl exec -ti storage -- bash
root@storage:/data#

六、使用kubectl proxy和apiserver proxy连接到容器

现在你已经看过了关于kubectl proxy和apiserver proxy的基本信息（basics）。
这个指南将会展示如何使用它们进入一个运行在k8s集群上的服务（kube-ui）。

1、获得kube-ui的apiserver proxy的url

kube-ui通过插件的形式部署，通过下面的方式可以获得apiserver proxy的url：

$ kubectl cluster-info | grep "KubeUI"
KubeUI is running at https://173.255.119.104/api/v1/proxy/namespaces/kube-system/services/kube-ui

如果这个命令无法找到url，请看这里：
here

2、在本地工作站连接到kube-ui service

上面说的代理url是一个连接到apiserver提供的kube-ui服务。
为了连接它，你仍然需要验证apiserver，kubectl proxy可以进行验证：

$ kubectl proxy --port=8001
Starting to serve on localhost:8001

现在你在本地工作站可以连接到kube-ui服务：
http://localhost:8001/api/v1/proxy/namespaces/kube-system/services/kube-ui

七、kubectl port-forward连接应用

kubectl port-forward 转发本地端口到Pod中的端口。
其主页面可以通过这里获得：
here
和kubectl proxy,相对比，kubectl port-forward的作用更为广泛，因为它能够转发TCP流量而kubectl proxy只能转发HTTP流量。
这个指南演示了如何使用kubectl port-forward来连接到一个redis数据库，这在调试数据库的时候是很有用的。

1、创建一个Redis Master

$ kubectl create examples/redis/redis-master.yaml
pods/redis-master
等待Redis Master处于运行和就绪状态：

$ kubectl get pods
NAME           READY     STATUS    RESTARTS   AGE
redis-master   2/2       Running   0          41s

2、连接到Redis Master

验证Redis Master监听6397端口：

$ kubectl get pods redis-master -t='{{(index (index .spec.containers 0).ports 0).containerPort}}{{"\n"}}'
6379
之后，将本地6379端口转发到Pod中的6379端口：

$ kubectl port-forward redis-master 6379:6379
I0710 14:43:38.274550    3655 portforward.go:225] Forwarding from 127.0.0.1:6379 -> 6379
I0710 14:43:38.274797    3655 portforward.go:225] Forwarding from [::1]:6379 -> 6379

在本地执行redis-cli来验证连接是否成功：

$ redis-cli
127.0.0.1:6379> ping
PONG
现在就可以从本地来调试这个数据库了 