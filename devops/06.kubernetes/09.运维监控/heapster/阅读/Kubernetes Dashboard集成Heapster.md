Kubernetes Dashboard集成Heapster | Tony Bai 
http://tonybai.com/2017/01/20/integrate-heapster-for-kubernetes-dashboard/

Kubernetes Dashboard集成Heapster
一月 20, 2017 11 条评论
默认安装后的Kubernetes dashboard如下图所示，是无法图形化展现集群度量指标信息的：

img{512x368}

图形化展示度量指标的实现需要集成k8s的另外一个Addons组件：Heapster。

Heapster原生支持K8s(v1.0.6及以后版本)和CoreOS，并且支持多种存储后端，比如：InfluxDB、ElasticSearch、Kafka等，这个风格和k8s的确很像：功能先不管完善与否，先让自己在各个平台能用起来再说^0^。这里我们使用的数据存储后端是InfluxDB。

一、安装步骤

我们的Heapster也是要放在pod里运行的。当前，Heapster的最新stable版本是v1.2.0，我们可以下载其源码包到K8s cluster上的某个Node上。解压后，我们得到一个名为”heapster-1.2.0″的目录，进入该目录，我们可以看到如下内容：

root@node1:~/k8stest/dashboardinstall/heapster-1.2.0# ls
code-of-conduct.md  CONTRIBUTING.md  docs    Godeps   hooks     integration  LICENSE   metrics    riemann  version
common              deploy           events  grafana  influxdb  kafka        Makefile  README.md  vendor
以InfluxDB为存储后端的Heapster部署yaml在deploy/kube-config/influxdb下面：

root@node1:~/k8stest/dashboardinstall/heapster-1.2.0# ls -l deploy/kube-config/influxdb/
total 28
-rw-r--r-- 1 root root  414 Sep 14 12:47 grafana-service.yaml
-rw-r--r-- 1 root root  942 Jan 20 15:15 heapster-controller.yaml
-rw-r--r-- 1 root root  249 Sep 14 12:47 heapster-service.yaml
-rw-r--r-- 1 root root 1465 Jan 19 21:39 influxdb-grafana-controller.yaml
-rw-r--r-- 1 root root  259 Sep 14 12:47 influxdb-service.yaml
这里有五个yaml（注意：与heapster源码库中最新的代码已经有所不同，最新代码将influxdb和grafana从influxdb-grafana-controller.yaml拆分开了）。其中的一些docker image在墙外，如果你有加速器，那么你可以直接执行create命令；否则最好找到一些替代品： 比如：用signalive/heapster_grafana:2.6.0-2替换gcr.io/google_containers/heapster_grafana:v2.6.0-2。

创建pod的操作很简单：

~/k8stest/dashboardinstall/heapster-1.2.0# kubectl create -f deploy/kube-config/influxdb/
service "monitoring-grafana" created
replicationcontroller "heapster" created
service "heapster" created
replicationcontroller "influxdb-grafana" created
service "monitoring-influxdb" created

如果image pull顺利的话，那么这些pod和service的启动是会很正常的。

//kube get pods -n kube-system
... ...
kube-system                  heapster-b1dwa                          1/1       Running   0          1h        172.16.57.9    10.46.181.146   k8s-app=heapster,version=v6
kube-system                  influxdb-grafana-8c0e0                  2/2       Running   0          1h        172.16.57.10   10.46.181.146   name=influxGrafana
... ...
我们用浏览器打开kubernetes的Dashboard，期待中的图形化和集群度量指标信息到哪里去了呢？Dashboard还是一如既往的如上面图示中那样“简朴”，显然我们遇到问题了！

二、TroubleShooting

问题在哪？我们需要逐个检视相关Pod的日志：

# kubectl logs -f pods/influxdb-grafana-xxxxxx influxdb -n kube-system
# kubectl logs -f pods/influxdb-grafana-xxxxxx grafana -n kube-system
# kubectl logs -f pods/heapster-xxxxx -n kube-system
在heapster-xxxxx这个pod中，我们发现了大量失败日志：

E0119 13:14:37.838900       1 reflector.go:203] k8s.io/heapster/metrics/heapster.go:319: Failed to list *api.Pod: the server has asked for the client to provide credentials (get pods)
E0119 13:14:37.838974       1 reflector.go:203] k8s.io/heapster/metrics/processors/node_autoscaling_enricher.go:100: Failed to list *api.Node: the server has asked for the client to provide credentials (get nodes)
E0119 13:14:37.839516       1 reflector.go:203] k8s.io/heapster/metrics/processors/namespace_based_enricher.go:84: Failed to list *api.Namespace: the server has asked for the client to provide credentials (get namespaces)
heapster无法连接apiserver，获取不要想要的信息。从kube-apiserver的日志(/var/log/upstart/kube-apiserver.log)也印证了这一点：

E0120 09:15:30.833928   12902 handlers.go:54] Unable to authenticate the request due to an error: crypto/rsa: verification error
E0120 09:15:30.834032   12902 handlers.go:54] Unable to authenticate the request due to an error: crypto/rsa: verification error
E0120 09:15:30.835324   12902 handlers.go:54] Unable to authenticate the request due to an error: crypto/rsa: verification error

从apiserver的日志来看，heapster是通过apiserver的secure port连接的，由于我们的API server设置有https client端证书校验机制，因此两者连接失败。

三、通过insecure-port连接kube-apiserver

现在我们就来解决上述问题。

首先，我们会想到：能否让heapster通过kube APIServer的insecure-port连接呢？在《Kubernetes集群的安全配置》一文中我们提到过，kube-apiserver针对insecure-port接入的请求没有任何限制机制，这样heapster就可以获取到它所想获取到的所有有用信息。

在heapster doc中的“Configuring Source”中，我们找到了连接kube-apiserver insecure-port的方法。不过在修改yaml之前，我们还是要先来看看当前heapster的一些启动配置的含义：

//deploy/kube-config/influxdb/heapster-controller.yaml
command:
        - /heapster
        - --source=kubernetes:https://kubernetes.default
        - --sink=influxdb:http://monitoring-influxdb:8086
我们看到heapster启动时有两个启动参数：
–source指示数据源，heapster是支持多种数据源的，这里用的是“kubernetes”类型的数据源，地址是：kubernetes.default。这个域名的全名是：kubernetes.default.svc.cluster.local，就是service “kubernetes”在cluster中的域名，而”kubernetes”服务就是kube-apiserver，它的信息如下：

# kubectl get services
NAME           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes     192.168.3.1     <none>        443/TCP        99d
... ...

# kubectl describe svc/kubernetes
Name:            kubernetes
Namespace:        default
Labels:            component=apiserver
            provider=kubernetes
Selector:        <none>
Type:            ClusterIP
IP:            192.168.3.1
Port:            https    443/TCP
Endpoints:        xxx.xxx.xxx.xxx:6443
Session Affinity:    ClientIP
No events.
因此，该域名在k8s DNS中会被resolve为clusterip:192.168.3.1。外加https的默认端口是443，因此实际上heapster试图访问的apiserver地址是：https://192.168.3.1:443。

heapster启动的另外一个参数是–sink，这个传入的就是存储后端，我们使用了InfluxDB，这里传入的就是上面创建的InfluxDB service的域名和端口号，我们在cluster中也能查找到该Service的信息：

# kubectl get services -n kube-system
NAME                   CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
monitoring-influxdb    192.168.3.228   <none>        8083/TCP,8086/TCP   1h
... ...
前面提到过，我们的APIServer在secure port上是有client端证书校验的，那么以这样的启动参数启动的heapster连接不上kube-apiserver就“合情合理”了。

接下来，我们按照”Configuring Source”中的方法，将heapster与kube-apiserver之间的连接方式改为通过insecure port进行：

// kube-config/influxdb/heapster-controller.yaml
... ...
command:
        - /heapster
        - --source=kubernetes:http://10.47.136.60:8080?inClusterConfig=false
        - --sink=influxdb:http://monitoring-influxdb:8086
修改后重新create。重新启动后的heapster pod的日志输出如下：

# kubectl logs -f pod/heapster-hco5i  -n kube-system
I0120 02:03:46.014589       1 heapster.go:71] /heapster --source=kubernetes:http://10.47.136.60:8080?inClusterConfig=false --sink=influxdb:http://monitoring-influxdb:8086
I0120 02:03:46.014975       1 heapster.go:72] Heapster version v1.3.0-beta.0
I0120 02:03:46.015080       1 configs.go:60] Using Kubernetes client with master "http://10.47.136.60:8080" and version v1
I0120 02:03:46.015175       1 configs.go:61] Using kubelet port 10255
E0120 02:03:46.025962       1 influxdb.go:217] issues while creating an InfluxDB sink: failed to ping InfluxDB server at "monitoring-influxdb:8086" - Get http://monitoring-influxdb:8086/ping: dial tcp 192.168.3.239:8086: getsockopt: connection refused, will retry on use
I0120 02:03:46.026090       1 influxdb.go:231] created influxdb sink with options: host:monitoring-influxdb:8086 user:root db:k8s
I0120 02:03:46.026214       1 heapster.go:193] Starting with InfluxDB Sink
I0120 02:03:46.026286       1 heapster.go:193] Starting with Metric Sink
I0120 02:03:46.051096       1 heapster.go:105] Starting heapster on port 8082
I0120 02:04:05.211382       1 influxdb.go:209] Created database "k8s" on influxDB server at "monitoring-influxdb:8086"
之前的错误消失了！

我们再次打开Dashboard查看pod信息（这里需要等上一小会儿，因为采集cluster信息也是需要时间的），我们看到集群度量指标信息以图形化的方式展现在我们面前了(可对比本文开头那幅图示)：

img{512x368}

四、通过secure port连接kube-apiserver

kube-apiserver的–insecure-port更多用来调试，生产环境下可是说关就关的，因此通过kube-apiserver的secure port才是“长治久安”之道。但要如何做呢？在heapster的”Configure Source”中给了一种使用serviceaccount的方法，但感觉略有些复杂啊。这里列出一下我自己探索到的方法: 使用kubeconfig文件！在《Kubernetes集群Dashboard插件安装》一文中，我们已经配置好了kubeconfig文件（默认位置：~/.kube/config），对于kubeconfig配置项还不是很了解的童鞋可以详细参考那篇文章，这里就不赘述了。

接下来，我们来修改heapster-controller.yaml：

// deploy/kube-config/influxdb/heapster-controller.yaml

... ...
spec:
      containers:
      - name: heapster
        image: kubernetes/heapster:canary
        volumeMounts:
        - mountPath: /srv/kubernetes
          name: auth
        - mountPath: /root/.kube
          name: config
        imagePullPolicy: Always
        command:
        - /heapster
        - --source=kubernetes:https://kubernetes.default?inClusterConfig=false&insecure=true&auth=/root/.kube/config
        - --sink=influxdb:http://monitoring-influxdb:8086
      volumes:
      - name: auth
        hostPath:
          path: /srv/kubernetes
      - name: config
        hostPath:
          path: /root/.kube
... ...

从上述文件内容中–source的值我们可以看到，我们又恢复到初始kubernetes service的地址：https://kubernetes.default，但后面又跟了几个参数：

inClusterConfig=false : 不使用service accounts中的kube config信息；
insecure=true：这里偷了个懒儿：选择对kube-apiserver发过来的服务端证书做信任处理，即不校验；
auth=/root/.kube/config：这个是关键！在不使用serviceaccount时，我们使用auth文件中的信息来对应kube-apiserver的校验。
上述yaml中，我们还挂载了两个path，以便pod可以访问到相应的配置文件(~/.kube/config）和/srv/kubernetes下的证书。

保存并重新创建相关pod后，Dashboard下的集群度量指标信息依然能以图形化的方式展现出来，可见这种方法是ok的！

© 2017, bigwhite. 版权所有.