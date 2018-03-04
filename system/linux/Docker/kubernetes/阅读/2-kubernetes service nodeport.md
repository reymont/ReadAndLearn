kubernetes service - CSDN博客 http://blog.csdn.net/jiankunking/article/details/78849102

Service 是一个抽象的概念，它定义了Pod的逻辑分组和一种可以访问它们的策略，这组Pod能被Service访问，使用YAML （优先）或JSON 来定义Service，Service所针对的一组Pod通常由LabelSelector实现 
可以通过type在ServiceSpec中指定一个需要的类型的 Service，Service的四种type：

ClusterIP（默认） - 在集群中内部IP上暴露服务。此类型使Service只能从群集中访问。
NodePort - 通过每个 Node 上的 IP 和静态端口（NodePort）暴露服务。NodePort 服务会路由到 ClusterIP 服务，这个 ClusterIP 服务会自动创建。通过请求<NodeIP>:<NodePort>，可以从集群的外部访问一个 NodePort 服务。
LoadBalancer - 使用云提供商的负载均衡器（如果支持），可以向外部暴露服务。外部的负载均衡器可以路由到 NodePort 服务和 ClusterIP 服务。
ExternalName - 通过返回 CNAME 和它的值，可以将服务映射到 externalName 字段的内容，没有任何类型代理被创建。这种类型需要v1.7版本或更高版本kube-dnsc才支持。
      Kubernetes Service 是一个抽象层，它定义了一组逻辑的Pods，借助Service，应用可以方便的实现服务发现与负载均衡。 
这里写图片描述

service type

k8s中service主要有三种：

ClusterIP: use a cluster-internal IP only - this is the default and is discussed above. Choosing this value means that you want this service to be reachable only from inside of the cluster.
NodePort: on top of having a cluster-internal IP, expose the service on a port on each node of the cluster (the same port on each node). You’ll be able to contact the service on any :NodePort address.
LoadBalancer: on top of having a cluster-internal IP and exposing service on a NodePort also, ask the cloud provider for a load balancer which forwards to the Service exposed as a :NodePort for each Node.
clusterIP

clusterIP主要作用是方便pod到pod之间的调用。

[minion@te-yuab6awchg-0-z5nlezoa435h-kube-master-udhqnaxpu5op ~]$ kubectl describe service redis-sentinel 
Name:           redis-sentinel
Namespace:      default
Labels:         name=sentinel,role=service
Selector:       redis-sentinel=true
Type:           ClusterIP
IP:         10.254.142.111
Port:           <unnamed>   26379/TCP
Endpoints:      <none>
Session Affinity:   None
No events.
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
clusterIP主要在每个node节点使用iptables，将发向clusterIP对应端口的数据，转发到kube-proxy中。

[minion@te-yuab6awchg-0-z5nlezoa435h-kube-master-udhqnaxpu5op ~]$ sudo iptables -S -t nat
...
-A KUBE-PORTALS-CONTAINER -d 10.254.142.111/32 -p tcp -m comment --comment "default/redis-sentinel:" -m tcp --dport 26379 -j REDIRECT --to-ports 36547
-A KUBE-PORTALS-HOST -d 10.254.142.111/32 -p tcp -m comment --comment "default/redis-sentinel:" -m tcp --dport 26379 -j DNAT --to-destination 10.0.0.5:36547
1
2
3
4
然后kube-proxy自己内部实现有负载均衡的方法，并可以查询到这个service下对应pod的地址和端口，进而把数据转发给对应的pod的地址和端口。

nodePort/LoadBalancer

nodePort跟LoadBalancer其实是同一种方式。

区别在于LoadBalancer比nodePort多了一步，就是可以调用cloud provider去创建LB来向节点导流。cloud provider好像支持了openstack、gce等系统。

nodePort的原理在于在node上开了一个端口，将向该端口的流量导入到kube-proxy，然后由kube-proxy进一步导给对应的pod。

所以service采用nodePort的方式，正确的方法是在前面有一个lb，然后lb的后端挂上所有node的对应端口。这样即使node1挂了。lb也可以把流量导给其他node的对应端口。

我们使用这样的一个manifest来创建service

apiVersion: v1
kind: Service
metadata:
  labels:
    name: ssh
    role: service
  name: ssh-service1
spec:
  ports:
    - port: 2222
      targetPort: 22
      nodePort: 30239
  type: NodePort
  selector:
    ssh-service: "true"
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
使用get service可以看到虽然type是NodePort，但是依然为其分配了一个clusterIP。分配clusterIP的作用还是如上文所说，是方便pod到service的数据访问。

[minion@te-yuab6awchg-0-z5nlezoa435h-kube-master-udhqnaxpu5op ~]$ kubectl get service NAME LABELS SELECTOR IP(S) PORT(S) kubernetes component=apiserver,provider=kubernetes   <none>                10.254.0.1       443/TCP
ssh-service1     name=ssh,role=service                     ssh-service=true      10.254.132.107   2222/
1
2
使用describe可以查看到详细信息。可以看到暴露出来的NodePort端口，正是指定的30239

[minion@te-yuab6awchg-0-z5nlezoa435h-kube-master-udhqnaxpu5op ~]$ kubectl describe service ssh-service1 
Name:           ssh-service1
Namespace:      default
Labels:         name=ssh,role=service
Selector:       ssh-service=true
Type:           LoadBalancer
IP:         10.254.132.107
Port:           <unnamed>   2222/TCP
NodePort:       <unnamed>   30239/TCP
Endpoints:      <none>
Session Affinity:   None
No events.
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
nodePort的工作原理与clusterIP大致相同，是发送到node上指定端口的数据，通过iptables重定向到kube-proxy对应的端口上。然后由kube-proxy进一步把数据发送到其中的一个pod上。

[minion@te-yuab6awchg-0-z5nlezoa435h-kube-master-udhqnaxpu5op ~]$ sudo iptables -S -t nat
...
-A KUBE-NODEPORT-CONTAINER -p tcp -m comment --comment "default/ssh-service1:" -m tcp --dport 30239 -j REDIRECT --to-ports 36463
-A KUBE-NODEPORT-HOST -p tcp -m comment --comment "default/ssh-service1:" -m tcp --dport 30239 -j DNAT --to-destination 10.0.0.5:36463
-A KUBE-PORTALS-CONTAINER -d 10.254.0.1/32 -p tcp -m comment --comment "default/kubernetes:" -m tcp --dport 443 -j REDIRECT --to-ports 53940
-A KUBE-PORTALS-CONTAINER -d 10.254.132.107/32 -p tcp -m comment --comment "default/ssh-service1:" -m tcp --dport 2222 -j REDIRECT --to-ports 36463
-A KUBE-PORTALS-HOST -d 10.254.0.1/32 -p tcp -m comment --comment "default/kubernetes:" -m tcp --dport 443 -j DNAT --to-destination 10.0.0.5:53940
-A KUBE-PORTALS-HOST -d 10.254.132.107/32 -p tcp -m comment --comment "default/ssh-service1:" -m tcp --dport 2222 -j DNAT --to-destination 10.0.0.5:36463
1
2
3
4
5
6
7
8
原文地址： 
http://docs.kubernetes.org.cn/703.html 
https://xuxinkun.github.io/2016/03/27/k8s-service/

个人微信公众号： 