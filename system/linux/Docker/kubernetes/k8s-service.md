
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [概述](#概述)
* [定义一个service](#定义一个service)
* [服务代理](#服务代理)
* [服务暴露](#服务暴露)
	* [svc服务](#svc服务)
	* [k8s集群节点](#k8s集群节点)
	* [k8s证书](#k8s证书)
		* [1.k8s运行在calico集群上网络方式](#1k8s运行在calico集群上网络方式)
		* [2.flannel方式](#2flannel方式)
		* [3.布署kube-proxy.service](#3布署kube-proxyservice)
		* [4.测试网关和dns解析 以及服务访问情况](#4测试网关和dns解析-以及服务访问情况)
	* [测试访问k8s的mysql服务](#测试访问k8s的mysql服务)
* [发布Service](#发布service)
	* [NodePort Service](#nodeport-service)
	* [LoadBalancer Service](#loadbalancer-service)
	* [Ingress](#ingress)
* [pod](#pod)
* [Headless services](#headless-services)
* [Segmentation fault](#segmentation-fault)

<!-- /code_chunk_output -->
* 参考：
  * [如何在Kubernetes中暴露服务访问 - RancherLabs的博客 - CSDN博客 ](http://blog.csdn.net/rancherlabs/article/details/53991992)
  * [Google Kubernetes设计文档之服务篇 | Software Engineering Lab | Zhejiang University ](http://www.sel.zju.edu.cn/?p=360)
  * [kubernetes学习2--RC/service/pod实践 - 夢の殇 - CSDN博客 ](http://blog.csdn.net/dream_broken/article/details/53115770)

# 概述

为了适应快速的业务需求，微服务架构已经逐渐成为主流，微服务架构的应用需要有非常好的服务编排支持，k8s中的核心要素Service便提供了一套简化的服务代理和发现机制，天然适应微服务架构，任何应用都可以非常轻易地运行在k8s中而无须对架构进行改动；

k8s分配给Service一个固定IP，这是一个`虚拟IP(也称为ClusterIP)`，并不是一个真实存在的IP，而是由k8s虚拟出来的。`虚拟IP的范围`通过k8s API Server的启动参数 --service-cluster-ip-range=19.254.0.0/16配置;

虚拟IP属于k8s内部的虚拟网络，外部是寻址不到的。在k8s系统中，实际上是由`k8s Proxy`组件负责实现虚拟IP路由和转发的，所以k8s Node中都必须运行了k8s Proxy，从而在容器覆盖网络之上又实现了k8s层级的虚拟转发网络。

设想一个拥有三个节点的图片处理backend，这三个节点都可以随时替代——frontend并不关系链接的是哪一个。即使组成backend的pods发生了变动，frontend也不必关心连接到哪个backend。services将frontend和backend的链接关系解耦。

# 定义一个service

在kubernetes中，services和pods一样都是一个REST对象。同其他的REST对象一样，通过POST来创建一个service。比如，有一组pods，每个pod对外暴露9376端口 他们的label为“app=MyApp”：
```json
{
    "kind": "Service",
    "apiVersion": "v1",
    "metadata": {
        "name": "my-service"
    },
    "spec": {
        "selector": {
            "app": "MyApp"
        },
        "ports": [
            {
                "protocol": "TCP",
                "port": 80,
                "targetPort": 9376
            }
        ]
    }
}
```
上述的json将会做以下事情：创建一个叫“my-service”的service，它映射了label为“app=MyApp”的pods端口9376,这个service将会被分配一个ip（cluster ip），service用这个ip作为代理，service的selector将会一直对pods进行筛选，并将起pods结果放入一个也叫做“my-service”的Endpoints中。

注意，一个service可能将流量引入到任何一个targetPost，默认targetPort字段和port字段是相同的。有趣的是targetPort 也可以是一个string，可以设定为是一组pods所映射port的name。在每个pod中，这个name所对应的真实port都可以不同。这为部署& 升级service带来了很大的灵活性，比如 可以在

kubernetes services支持TCP & UDP协议，默认为tcp。

# 服务代理

* [k8s实战之Service - 阳台 - 博客园 ](http://www.cnblogs.com/chris-cp/p/6724057.html)

服务代理：

　　在逻辑层面上，Service被认为是真实应用的抽象，每一个Service关联着一系列的Pod。在物理层面上，Service有事真实应用的代理服务器，对外表现为一个`单一访问入口`，通过k8s Proxy转发请求到Service关联的Pod。

Service同样是根据`Label Selector`来刷选Pod进行关联的，实际上k8s在`Service和Pod之间通过Endpoint衔接`，Endpoints同Service关联的Pod；相对应，可以认为是Service的服务代理后端，k8s会根据Service关联到Pod的PodIP信息组合成一个Endpoints。

```sh
　　#kubectl get service my-nginx
　　#kubectl get pod --selector app=nginx
```

k8s创建Service的同时，会`自动创建跟Service同名的Endpoints`：

```sh
　　
　　#kubectl get endpoints my-nginx -o yaml
　　#kubectl describe service my-nginx
```

　　Service不仅可以代理Pod，还可以代理任意其他后端，比如运行在k8s外部的服务。加速现在要使用一个Service代理外部MySQL服务，不用设置Service的Label Selector。
Service的定义文件: mysql-service.yaml:
```yaml
apiVersion: v1
kind: Service
metadata:
name: mysql
spec:
ports:
- port: 3306
targetPort: 3306
protocol: TCP
```
同时定义跟Service同名的Endpoints，Endpoints中设置了MySQL的IP：192.168.3.180；
Endpoints的定义文件mysql-endpoints.yaml:
```yaml
apiVersion: v1
kind: Endpoints
metadata:
name: mysql
subsets:
- addresses:
- ip: 192.168.3.180
ports:
- port: 3306
protocol: TCP
```

微服务化应用的每一个组件都以Service进行抽象，组件与组件之间只需要访问Service即可以互相通信，而无须感知组件的集群变化。
这就是服务发现；

```sh
#kubectl create -f mysql-service.yaml -f mysql-endpoints.yaml


#kubectl exec my-pod -- nslookup my-service.my-ns --namespace=default
#kubectl exec my-pod -- nslookup my-service --namespace=my-ns
```

# 服务暴露

* [k8s-dns-gateway 网关网络扩展实战 - 小刚的博客 - CSDN博客 ](http://blog.csdn.net/idea77/article/details/73863822)

k8s服务暴露分为几种情况 
1.svc-nodeport暴露 缺点所有node上开启端口监听，需要记住端口号。 
2.ingress http 80端口暴露 必需通过域名引入。 
3.tcp–udp–ingress tcp udp 端口暴露需要配置一个ingress lb，一次只能一条规则，很麻烦，要先规划好lb节点 同样也需要仿问lb端口,无比麻烦。 
然而正常的虚拟机我们只需要一个地址+端口直接仿问即可 
那么我们能不能做到像访部虚拟机一样访部k8s集群服务呢，当然可以 以下架构实现打通k8s网络和物理网理直通，物理网 络的dns域名直接调用k8s-dns域名服务直接互访 
架构环境如下 
k8s集群网络 172.1.0.0/16 
k8s-service网络 172.1.0.0/16 
物理机网络192.168.0.0/16

## svc服务

访问k8s中的一个服务 MySQL-read 为我们要访问的svc服务如下

```sh
[root@master3 etc]# kubectl get svc -o wide|egrep 'NAME|mysql'
NAME                    CLUSTER-IP     EXTERNAL-IP   PORT(S)         AGE       SELECTOR
mysql                   None           <none>        3306/TCP        8h        app=mysql
mysql-read              172.1.86.83    <none>        3306/TCP        8h        app=mysql
[root@master3 etc]# 
```
## k8s集群节点
```sh
[root@master3 etc]# kubectl get cs -o wide
NAME                 STATUS    MESSAGE              ERROR
controller-manager   Healthy   ok                   
scheduler            Healthy   ok                   
etcd-2               Healthy   {"health": "true"}   
etcd-0               Healthy   {"health": "true"}   
etcd-1               Healthy   {"health": "true"}   
[root@master3 etc]# kubectl get node -o wide
NAME            STATUS    AGE       VERSION   EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION
jenkins-2       Ready     14d       v1.6.4    <none>        CentOS Linux 7 (Core)   4.4.71-1.el7.elrepo.x86_64
node1.txg.com   Ready     14d       v1.6.4    <none>        CentOS Linux 7 (Core)   4.4.71-1.el7.elrepo.x86_64
node2.txg.com   Ready     14d       v1.6.4    <none>        CentOS Linux 7 (Core)   4.4.71-1.el7.elrepo.x86_64
node3.txg.com   Ready     14d       v1.6.4    <none>        CentOS Linux 7 (Core)   4.4.71-1.el7.elrepo.x86_64
node4.txg.com   Ready     14d       v1.6.4    <none>        CentOS Linux 7 (Core)   3.10.0-514.6.2.el7.x86_64
[root@master3 etc]# 


[root@master3 etc]# kubectl get pod --all-namespaces -o wide |egrep 'NAME|node|mysql|udp'
NAMESPACE     NAME                                        READY     STATUS    RESTARTS   AGE       IP              NODE
default       cnetos6-7-rc-xv12x                          1/1       Running   0          7d        172.1.201.225   node3.txg.com
default       kibana-logging-3543001115-v52kn             1/1       Running   0          12d       172.1.26.70     node1.txg.com
default       mysql-0                                     2/2       Running   0          10h       172.1.201.236   node3.txg.com
default       mysql-1                                     2/2       Running   0          10h       172.1.24.230    jenkins-2
default       mysql-2                                     2/2       Running   1          10h       172.1.160.213   node4.txg.com
default       nfs-client-provisioner-278618947-wr97r      1/1       Running   0          12d       172.1.201.201   node3.txg.com
kube-system   calico-node-5r37q                           2/2       Running   3          14d       192.168.2.72    jenkins-2
kube-system   calico-node-hldk2                           2/2       Running   2          14d       192.168.2.68    node3.txg.com
kube-system   calico-node-pjdj8                           2/2       Running   4          14d       192.168.2.69    node4.txg.com
kube-system   calico-node-rqkm9                           2/2       Running   2          14d       192.168.1.68    node1.txg.com
kube-system   calico-node-zqkxd                           2/2       Running   0          14d       192.168.1.69    node2.txg.com
kube-system   heapster-v1.3.0-1076354760-6kn4m            4/4       Running   4          13d       172.1.160.199   node4.txg.com
kube-system   kube-dns-474739028-26gds                    3/3       Running   3          14d       172.1.160.198   node4.txg.com
kube-system   nginx-udp-ingress-controller-c0m04          1/1       Running   0          1d        192.168.2.72    jenkins-2
[root@master3 etc]# 
```


## k8s证书
```sh
[root@node3 kubernetes]# ls
bootstrap.kubeconfig  kubelet.kubeconfig  kube-proxy.kubeconfig  ssl  token.csv
[root@node3 kubernetes]# 

角色名称:边界网关路由器     192.168.2.71  主机名 jenkins-1     主机名自己定义
角色名称:边界dns代理服务器  192.168.2.72  主机名 jenkins-2     主机名自己定义

架构原理:  

          192.168.0.0/16                #物理网络以域名或tcp方式发起访问k8s service以及端口
                 '
                 '
  mysql-read.default.svc.cluster.local  #请求k8s服务所在空间的服务名svc名，完整域名
                 '
                 '   
          192.168.2.72                   #dns代理服务以ingress-udp pod的模式运行在此节点udp53号端口上 
                 '                       ，为物理网络提供仿问k8s-dns的桥梁解析dns
                 '                      #此节点应固定做为一个节点布署，所有外部设置dns为此192.168.2.72
                 ' 
           172.1.86.83                  #获取svc的实际clusterip
                 '
                 ' 
           192.168.2.71          #边界网关,用于物理网络连接k8s集群内内核转发开启net.ipv4.ip_forward=1
                 '               #所有外部物理机加一条静态路由访问k8s网络172网段必需经过网关192.168.2.71 
                 '               #route add -net 172.1.0.0 netmask 255.255.0.0 gw 192.168.2.71
                 '               #边界网关运行kube-proxy用于防火墙规则同步实现svc分流，此节点不运行kubele服务，不受k8s管控
    calico and flannel-Iface接口  #此节点为物理节点，只运行calico 或flanne服务 
                 '
            k8s集群网络            #流量最终到达k8s集群

#布署dns代理服务节点为外部提供服务,以 hostNetwork: true 为非k8s集群网络物理机节点提共访问53 dns服务
[root@master3 udp]# ls
nginx-udp-ingress-configmap.yaml  nginx-udp-ingress-controller.yaml

[root@master3 udp]# cd ../ ; kubectl create -f udp/
```

[root@master3 udp]# cat nginx-udp-ingress-configmap.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-udp-ingress-configmap
  namespace: kube-system
data:
  53: "kube-system/kube-dns:53"
```

[root@master3 udp]# cat nginx-udp-ingress-controller.yaml
```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx-udp-ingress-controller
  labels:
    k8s-app: nginx-udp-ingress-lb
  namespace: kube-system
spec:
  replicas: 1
  selector:
    k8s-app: nginx-udp-ingress-lb
  template:
    metadata:
      labels:
        k8s-app: nginx-udp-ingress-lb
        name: nginx-udp-ingress-lb
    spec:
      hostNetwork: true
      terminationGracePeriodSeconds: 60
      containers:
      #- image: gcr.io/google_containers/nginx-ingress-controller:0.9.0-beta.8
      - image: 192.168.1.103/k8s_public/nginx-ingress-controller:0.9.0-beta.5
        name: nginx-udp-ingress-lb
        readinessProbe:
          httpGet:
            path: /healthz
            port: 10254
            scheme: HTTP
        livenessProbe:
          httpGet:
            path: /healthz
            port: 10254
            scheme: HTTP
          initialDelaySeconds: 10
          timeoutSeconds: 1
        env:
          - name: POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
        ports:
        - containerPort: 81
          hostPort: 81
        - containerPort: 443
          hostPort: 443
        - containerPort: 53
          hostPort: 53
        args:
        - /nginx-ingress-controller
        - --default-backend-service=$(POD_NAMESPACE)/default-http-backend
        - --udp-services-configmap=$(POD_NAMESPACE)/nginx-udp-ingress-configmap
```      

布署gateway 边界网关节点，此节点只运行 calico 或者flannel 和kube-proxy
echo 'net.ipv4.ip_forward=1' >>/etc/sysctl.conf ;sysctl -p
### 1.k8s运行在calico集群上网络方式

calico集群安装方式详见本人另一篇文章 http://blog.csdn.net/idea77/article/details/73090403

本次安装的节点为docker方式运行
[root@jenkins-1 ~]# cat calico-docker.sh 

```sh
systemctl start docker.service
/usr/bin/docker rm -f calico-node
/usr/bin/docker run --net=host --privileged --name=calico-node -d --restart=always \
  -v /etc/kubernetes/ssl:/etc/kubernetes/ssl \
  -e ETCD_ENDPOINTS=https://192.168.1.65:2379,https://192.168.1.66:2379,https://192.168.1.67:2379 \
  -e ETCD_KEY_FILE=/etc/kubernetes/ssl/kubernetes-key.pem \
  -e ETCD_CERT_FILE=/etc/kubernetes/ssl/kubernetes.pem \
  -e ETCD_CA_CERT_FILE=/etc/kubernetes/ssl/ca.pem \
  -e NODENAME=${HOSTNAME} \
  -e IP= \
  -e CALICO_IPV4POOL_CIDR=172.1.0.0/16 \ 
  -e NO_DEFAULT_POOLS= \
  -e AS= \
  -e CALICO_LIBNETWORK_ENABLED=true \
  -e IP6= \
  -e CALICO_NETWORKING_BACKEND=bird \
  -e FELIX_DEFAULTENDPOINTTOHOSTACTION=ACCEPT \
  -v /var/run/calico:/var/run/calico \
  -v /lib/modules:/lib/modules \
  -v /run/docker/plugins:/run/docker/plugins \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/log/calico:/var/log/calico \
192.168.1.103/k8s_public/calico-node:v1.1.3

#192.168.1.103/k8s_public/calico-node:v1.3.0
[root@jenkins-1 ~]# 注意此入为-e CALICO_IPV4POOL_CIDR=172.1.0.0/16  k8s集群网络的网段一致

注意，calicocatl 我是安装在k8s的master服务器上的，在主控节点上运行创建边界路由器
此处在master3服务器上执行开通边界网关这台机的calicoctl用于管理BGP 的命令。它主要面向在私有云上运行的用户，并希望与其底层基础架构对等。
[root@master3 calico]# cat bgpPeer.yaml 

apiVersion: v1
kind: bgpPeer
metadata:
  peerIP: 192.168.2.71
  scope: global
spec:
  asNumber: 64512


[root@master3 calico]#  calicoctl  create -f bgpPeer.yaml

#查看node情况
[root@master3 kubernetes]# calicoctl node status
Calico process is running.

IPv4 BGP status
+--------------+-------------------+-------+----------+-------------+
| PEER ADDRESS |     PEER TYPE     | STATE |  SINCE   |    INFO     |
+--------------+-------------------+-------+----------+-------------+
| 192.168.2.71 | node-to-node mesh | up    | 04:08:47 | Established |
| 192.168.2.71 | global            | start | 04:08:43 | Idle        |
| 192.168.2.72 | node-to-node mesh | up    | 04:08:47 | Established |
| 192.168.1.61 | node-to-node mesh | up    | 04:08:47 | Established |
| 192.168.1.62 | node-to-node mesh | up    | 04:08:47 | Established |
| 192.168.1.68 | node-to-node mesh | up    | 04:08:48 | Established |
| 192.168.1.69 | node-to-node mesh | up    | 04:08:47 | Established |
| 192.168.2.68 | node-to-node mesh | up    | 04:08:47 | Established |
| 192.168.2.69 | node-to-node mesh | up    | 04:08:47 | Established |
+--------------+-------------------+-------+----------+-------------+

 #查看全局对等体节点
 [root@master3 calico]# calicoctl get bgpPeer --scope=global
SCOPE    PEERIP         NODE   ASN     
global   192.168.2.71          64512   

[root@master3 calico]# ok calico配置完成 192.168.2.71 为路由转发节点
```

### 2.flannel方式

2.flannel方式，如果k8s集群是运行在flannel网络基础上的 在此节点安装flannel 
直接启动flannel即可 systemctl start flanneld.service 

> echo 'net.ipv4.ip_forward=1' >>/etc/sysctl.conf ;sysctl -p


### 3.布署kube-proxy.service


kube-proxy.service 需要证书`kube-proxy.kubeconfig` ，复制k8s node上的kubeconfig /etc/kubernetes/kube-proxy.kubeconfig 到此节点处即可

> 复制kube-proxy的二进至文件到些处即可
```sh 
[root@jenkins-1 ~]#  mkdir -p /var/lib/kube-proxy
[root@jenkins-1 ~]#  rsync -avz node3:/bin/kube-proxy /bin/kube-proxy
# kube-proxy服务
[root@jenkins-1 ~]# cat /lib/systemd/system/kube-proxy.service 
[Unit]
Description=Kubernetes Kube-Proxy Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target
[Service]
WorkingDirectory=/var/lib/kube-proxy
ExecStart=/bin/kube-proxy \
--bind-address=192.168.2.71 \
--hostname-override=jenkins-1 \
--cluster-cidr=172.1.0.0/16 \
--kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig \
--logtostderr=true \
--proxy-mode=iptables \
--v=2
Restart=on-failure
RestartSec=5
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
[root@jenkins-1 ~]# 
#启动 systemctl start kube-proxy.service
```

### 4.测试网关和dns解析 以及服务访问情况

```sh
# 上面我说过了，所有K8S集群外机器要想访问必需要加一条静态路由
# linux 机器命令 ，找台集群外的机器来验证，这台机器只有一个网卡，没有安装calico和 flannel

[root@247 ~]#route add -net 172.1.0.0 netmask 255.255.0.0 gw 192.168.2.71
检查路由 route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.5.1     0.0.0.0         UG    0      0        0 eth0
169.254.0.0     0.0.0.0         255.255.0.0     U     1002   0        0 eth0
172.1.0.0       192.168.2.71    255.255.0.0     UG    0      0        0 eth0 #注意看此处已经设置了网段路由生效了
192.168.0.0     0.0.0.0         255.255.0.0     U     0      0        0 eth0
192.168.1.0     0.0.0.0         255.255.255.0   U     0      0        0 eth0

linux 服务器dns设置为该机dns 192.168.2.72 为了能解析K8Sdns服务名
[root@247 ~]# egrep 'DNS' /etc/sysconfig/network-scripts/ifcfg-eth0 
IPV6_PEERDNS="yes"
DNS1="192.168.2.72"
[root@247 ~]# nslookup  kubernetes-dashboard.kube-system.svc.cluster.local
Server:     192.168.2.72
Address:    192.168.2.72#53

Non-authoritative answer:
Name:   kubernetes-dashboard.kube-system.svc.cluster.local
Address: 172.1.8.71

#dns成功解析
访问一下 curl  成功访问
[root@247 ~]# curl -v kubernetes-dashboard.kube-system.svc.cluster.local
* About to connect() to kubernetes-dashboard.kube-system.svc.cluster.local port 80 (#0)
*   Trying 172.1.8.71...
* Connected to kubernetes-dashboard.kube-system.svc.cluster.local (172.1.8.71) port 80 (#0)
> GET / HTTP/1.1
> User-Agent: curl/7.29.0
> Host: kubernetes-dashboard.kube-system.svc.cluster.local
> Accept: */*
> 
< HTTP/1.1 200 OK
< Accept-Ranges: bytes
< Cache-Control: no-store
< Content-Length: 848
< Content-Type: text/html; charset=utf-8
< Last-Modified: Thu, 16 Mar 2017 13:30:10 GMT
< Date: Thu, 29 Jun 2017 06:45:47 GMT
< 
 <!doctype html> <html ng-app="kubernetesDashboard"> <head> <meta charset="utf-8"> <title ng-controller="kdTitle as $ctrl" ng-bind="$ctrl.title()"></title> <link rel="icon" type="image/png" href="assets/images/kubernetes-logo.png"> <meta name="viewport" content="width=device-width"> <link rel="stylesheet" href="static/vendor.4f4b705f.css"> <link rel="stylesheet" href="static/app.93b90a74.css"> </head> <body> <!--[if lt IE 10]>
      <p class="browsehappy">You are using an <strong>outdated</strong> browser.
      Please <a href="http://browsehappy.com/">upgrade your browser</a> to improve your
      experience.</p>
* Connection #0 to host kubernetes-dashboard.kube-system.svc.cluster.local left intact
    <![endif]--> <kd-chrome layout="column" layout-fill> </kd-chrome> <script src="static/vendor.6952e31e.js"></script> <script src="api/appConfig.json"></script> <script src="static/app.8a6b8127.js"></script> </body> </html> 
```




windows机器用管理员打开cmd命令运行 route ADD -p 172.1.0.0 MASK 255.255.0.0 192.168.2.71 

角色名称:边界dns代理服务器  192.168.2.72  主机名 jenkins-2     主机名自己定义

windowsip配置里面 dns 服务器设置为该机dns  192.168.2.72


## 测试访问k8s的mysql服务 

mysql-read 为我们要访问的svc服务,k8s master上查看mysql svc 

```sh
[root@master3 etc]# kubectl get svc -o wide|egrep 'NAME|mysql'
NAME                    CLUSTER-IP     EXTERNAL-IP   PORT(S)         AGE       SELECTOR
mysql                   None           <none>        3306/TCP        8h        app=mysql
mysql-read              172.1.86.83    <none>        3306/TCP        8h        app=mysql
cmd 命令行运行

C:\Users\op>nslookup mysql-read.default.svc.cluster.local
服务器:  UnKnown
Address:  192.168.2.72

非权威应答:
名称:    mysql-read.default.svc.cluster.local
Address:  172.1.86.83

#成功访问dns 并解析出域名
如果知道容器ip 和端口直接访问即可，如ssh web服务 等
[root@master3 udp]# kubectl get pod,svc -o wide|egrep 'NAME|kibana'
NAME                                        READY     STATUS    RESTARTS   AGE       IP              NODE
po/kibana-logging-3543001115-v52kn          1/1       Running   0          12d       172.1.26.70     node1.txg.com

NAME                        CLUSTER-IP     EXTERNAL-IP   PORT(S)         AGE       SELECTOR
svc/kibana-logging          172.1.166.83   <nodes>       5601:8978/TCP   12d       k8s-app=kibana-logging
[root@master3 udp]# 


[root@master3 udp]# kubectl get pod -o wide
NAME                                     READY     STATUS    RESTARTS   AGE       IP              NODE
cnetos6-7-rc-xv12x                       1/1       Running   0          8d        172.1.201.225   node3.txg.com
kibana-logging-3543001115-v52kn          1/1       Running   0          12d       172.1.26.70     node1.txg.com

**如果你不想一台台机器加路由和dns
你可以把路由信息加入物理路由器上，这样就不用每台机都加路由和dns了，直接打通所有链路**
```


接下来在windows只接仿问dashboard 和用navicat仿问k8s服务，完美成功访问 
这对于在windows用开发工具调试访问k8s服务提供了捷径 
直接浏览器仿问kubernetes-dashboard.kube-system.svc.cluster.local 
直接用mysql工具仿问mysql服务 mysql-read.default.svc.cluster.local 
直接用浏览器访问kibana http://172.1.26.70 :5601 

# 发布Service

　　k8s提供了NodePort Service、 LoadBalancer Service和Ingress可以发布Service；

## NodePort Service

　　　　NodePort Service是类型为NodePort的Service， k8s除了会分配给NodePort Service一个内部的虚拟IP，另外会在每一个Node上暴露端口NodePort，外部网络可以通过[NodeIP]:[NodePort]访问到Service。

## LoadBalancer Service 　　

(需要底层云平台支持创建负载均衡器,比如GCE)

　　LoadBalancer Service是类型为LoadBalancer的Service，它是建立在NodePort Service集群基础上的，k8s会分配给LoadBalancer；Service一个内部的虚拟IP，并且暴露NodePort。除此之外，k8s请求底层云平台创建一个负载均衡器，将每个Node作为后端，负载均衡器将转发请求到[NodeIP]:[NodePort]。

apiVersion: v1
kind: Service
metadata:
name: my-nginx
spec:
selector:
app: nginx
ports:
- name: http
port: 80
targetPort: 80
protocol: TCP
type: LoadBalancer
负载均衡器由底层云平台创建提供，会包含一个LoadBalancerIP， 可以认为是LoadBalancer Service的外部IP，查询LoadBalancer Service：
```sh
#kubectl get svc my-nginx
```

## Ingress

　　k8s提供了一种HTTP方式的路由转发机制，称为Ingress。Ingress的实现需要两个组件支持， Ingress Controller和HTTP代理服务器。HTTP代理服务器将会转发外部的HTTP请求到Service，而Ingress Controller则需要监控k8s API，实时更新HTTP代理服务器的转发规则；

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
name: my-ingress
spec:
rules:
- host: my.example.com
http:
paths:
- path: /app
backend:
serviceName: my-app
servicePort: 80
　　　　Ingress 定义中的.spec.rules 设置了转发规则，其中配置了一条规则，当HTTP请求的host为my.example.com且path为/app时，转发到Service my-app的80端口；
```
#kubectl create -f my-ingress.yaml; kubectl get ingress my-ingress
NAME　　　　 RULE 　　 BACKEND 　　	ADDRESS
my-ingress 　　	-    
　　　　　　my.example.com
　　　　　　/app 　　　　	my-app:80
```

当Ingress创建成功后，需要Ingress Controller根据Ingress的配置，设置HTTP代理服务器的转发策略，外部通过HTTP代理服务就
可以访问到Service；

# pod


```bash
kubectl get pods
kubectl get pod php-test -o wide
```


* [Kubernetes应用部署模型解析（部署篇）-CSDN.NET ](http://www.csdn.net/article/2015-06-12/2824937)

```yaml
$ cat nginx-service-nodeport.yaml 
apiVersion: v1 
kind: Service 
metadata: 
  name: nginx-service-nodeport 
spec: 
  ports: 
    - port: 8000
      targetPort: 80 
      protocol: TCP 
  type: NodePort
  selector: 
    name: nginx 
```




# Headless services

* [Services - Kubernetes ](https://kubernetes.io/docs/concepts/services-networking/service/)
* [kubernetes.github.io/service.md at master · kubernetes/kubernetes.github.io ](https://github.com/kubernetes/kubernetes.github.io/blob/master/docs/concepts/services-networking/service.md)
* [Services in Kubernetes - Herman.Liu - SegmentFault ](https://segmentfault.com/a/1190000002892825)

Sometimes you don’t need or want load-balancing and a single service IP. In this case, you can create `“headless”` services by specifying "None" for the cluster IP (`spec.clusterIP`).
有时候你不想做负载均衡 或者 在意只有一个cluster ip。这时，你可以创建一个”headless“类型的service，将spec.clusterIP字段设置为”None“。

This option allows developers to reduce coupling to the Kubernetes system by allowing them freedom to do discovery their own way. Applications can still use a self-registration pattern and adapters for other discovery systems could easily be built upon this API.
对于这样的service，不会为他们分配一个ip，也不会在pod中创建其对应的全局变量。DNS则会为service 的name添加一系列的A记录，直接指向后端映射的pod。此外，kube proxy也不会处理这类service，没有负载均衡也没有请求映射。endpoint controller则会依然创建对应的endpoint。

For such Services, a cluster IP is not allocated, kube-proxy does not handle these services, and there is no load balancing or proxying done by the platform for them. How DNS is automatically configured depends on whether the service has selectors defined.
这个操作目的是为了用户想减少对kubernetes系统的依赖，比如想自己实现自动发现机制等等。Application可以通过api轻松的结合其他自动发现系统。


# Segmentation fault

重新拷贝二进制