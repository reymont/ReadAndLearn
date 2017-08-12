
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [1 前言](#1-前言)
* [2 kube2sky源码修改与解析](#2-kube2sky源码修改与解析)
* [3 制作kube2sky镜像](#3-制作kube2sky镜像)
* [4 部署skyDNS](#4-部署skydns)
* [5 测试](#5-测试)

<!-- /code_chunk_output -->


* [在k8s中搭建可解析hostname的DNS服务 - openxxs - 博客园 ](http://www.cnblogs.com/openxxs/p/5015734.html)

上篇文章总结k8s中搭建hbase时，遇到Pod中hostname的DNS解析问题，本篇将通过修改kube2sky源码来解决这个问题。

# 1 前言

kube2sky在Github上的项目（戳这里）一直在更新，放在DockerHub平台上的镜像滞后较多，有重新构建的必要。虽然新版kube2sky加入了对Pod的DNS解析，域名格式为`\<pod-ip-address\>.\<namespace\>.pod.\<cluster-name\>`，并不能直接通过hostname来访问对应的Pod。因此对kube2sky源码进行了修改，增加了对pod中容器的hostname的域名解析，以及集群中运行kube-proxy的主机hostname的解析。

# 2 kube2sky源码修改与解析

修改后的kube2sky.go(戳这里)

kube2sky监控kubernetes中services、endpoints、pods、nodes的变化，将IP地址和域名的对应关系写入到ETCD中；集群中的skyDNS从ETCD中读取这些对应关系进行域名解析。所以kube2sky和skyDNS间唯一的交流方式就是ETCD，增加hostname的解析即往ETCD中增加hostname与IP地址的对应关系。kube2sky通过访问kube-apiserver来获取集群信息，同时通过watch函数来监听IP地址是否发生了变化，如果发生了变化即更新ETCD中的记录。

在源码中有个细节可以注意下：对于传入的--domain参数，如果参数不带最后一点，则程序中会自动加上这一点。即"--domain=domeos.sohu"和"--domain=domeos.sohu."是一样的。

# 3 制作kube2sky镜像

1) 安装go

$ yum install go
2) 创建相应目录

$ mkdir /tmp/kube2sky
$ export GOPATH=/tmp/kube2sky
$ cd /tmp/kube2sky
3) 编译安装skyDNS

$ go get github.com/skynetservices/skydns
$ cd $GOPATH/src/github.com/skynetservices/skydns
$ go build -v
$ cp $GOPATH/bin/skydns /usr/bin
4) 安装godep

$ go get github.com/tools/godep
$ cp $GOPATH/bin/godep /usr/bin
5) 下载kube2sky编译依赖

$ go get -d github.com/GoogleCloudPlatform/kubernetes/cluster/addons/dns/kube2sky
kube2sky依赖整个k8s项目，因此要在该项目下进行编译。文件很多速度很慢，耐心等待。

结束后会发现报缺少两个依赖包，原因是GFW的存在导致下不下来，因此需要手工下载并放到相应路径下：

依赖包	下载地址	目录位置	注意事项
golang.org/x/net	https://github.com/golang/net	$GOPATH/
src/golang.org/x/net

要将目录名改一致
golang.org/x/crypto	https://github.com/golang/crypto	$GOPATH/
src/golang.org/x/crypto

要将目录名改一致
 然后在$GOPATH目录下再执行一次：

$ go get -d github.com/GoogleCloudPlatform/kubernetes/cluster/addons/dns/kube2sky
此时显示已经正常下载。

6) 编译kube2sky

进入 $GOPATH/src/github.com/GoogleCloudPlatform/kubernetes/cluster/addons/dns/kube2sky/ 目录，用之前修改过的kube2sky.go替换此处的kube2sky.go。

使用docker container来编译则直接：make kube2sky。

查看Makefile文件可以发现实际上是使用cgo来编译的，所以也可以直接在主机上编译，但这种编译出来的kube2sky程序与主机平台相关：

$ GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -a -installsuffix cgo --ldflags '-w' ./kube2sky.go
编译完成后在该目录下即生成了kube2sky可执行文件。

7) 创建kube2sky镜像

kube2sky的Dockerfile:

复制代码
FROM private-registry.sohucs.com/sohucs/base-rh7:1.0
MAINTAINER openxxs <openxxs@gmail.com>
COPY kube2sky.go /
COPY kube2sky /
RUN chmod +x /kube2sky
CMD ["/kube2sky"]
复制代码
skyDNS的Dockerfile:

FROM private-registry.sohucs.com/sohucs/base-rh7:1.0
MAINTAINER openxxs <openxxs@gmail.com>
COPY skydns /
RUN chmod +x /skydns
CMD ["/skydns"]
构建并放入私有仓库中：

复制代码
$ cd kube2sky/build/path

$ docker build -t private-registry.sohucs.com/domeos/kube2sky:1.1 .

$ docker push private-registry.sohucs.com/domeos/kube2sky:1.1
$ cd skydns/build/path 

$ docker build -t private-registry.sohucs.com/domeos/skydns:1.0 . 

$ docker push private-registry.sohucs.com/domeos/skydns:1.0
复制代码
# 4 部署skyDNS

启动kubelet时加DNS配置参数：--cluster_dns=172.16.40.1 --cluster_domain=domeos.sohu。这里尝试过加多个--cluster_dns地址，但只有最后加的配置有效。在部署时尝试过service形式部署和HostPort形式部署，对于集群内的域名解析两种方式都可以正常工作。如果希望在主机节点上也使用这套DNS解析，HostPort形式更适合。

1）以service形式部署

与上篇文章的部署方式不同，本文不再将ETCD、kube2sky和skyDNS放在同一个Pod中，而是独立出来。例子如下：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: skydns-svc
  labels:
    app: skydns-svc
    version: v9
spec:
  selector:
    app: skydns
    version: v9
  type: ClusterIP
  clusterIP: 172.16.40.1
  ports:
    - name: dns
      port: 53
      protocol: UDP
    - name: dns-tcp
      port: 53
      protocol: TCP
---
apiVersion: v1
kind: ReplicationController
metadata:
  name: skydns
  labels:
    app: skydns
    version: v9
spec:
  replicas: 1
  selector:
    app: skydns
    version: v9
  template:
    metadata:
      labels:
        app: skydns
        version: v9
    spec:
      containers:
        - name: skydns
          image: private-registry.sohucs.com/domeos/skydns:1.0
          command:
            - "/skydns"
          args:
            - "--machines=http://10.16.42.200:4012"
            - "--domain=domeos.sohu"
            - "--addr=0.0.0.0:53"
          ports:
            - containerPort: 53
              name: dns-udp
              protocol: UDP
            - containerPort: 53
              name: dns-tcp
              protocol: TCP
---
apiVersion: v1
kind: ReplicationController
metadata:
  name: kube2sky
  labels:
    app: kube2sky
    version: v9
spec:
  replicas: 1
  selector:
    app: kube2sky
    version: v9
  template:
    metadata:
      labels:
        app: kube2sky
        version: v9
    spec:
      containers:
        - name: kube2sky
          image: private-registry.sohucs.com/domeos/kube2sky:1.1
          command:
            - "/kube2sky"
          args:
            - "--etcd-server=http://10.16.42.200:4012"
            - "--domain=domeos.sohu"
            - "--kube_master_url=http://10.16.42.200:8080"
```
上述yaml文件中创建了服务地址为172.16.40.1的DNS服务，并创建了与之对应的kube2sky和skyDNS的RC。skyDNS中的--machines参数为ETCD的地址，这里直接用k8s集群的ETCD；--domain为域名的后缀；--addr为域名服务的地址和端口。kube2sky中--etcd-server为ETCD地址，--kube_master_url为k8s的apiserver地址。

复制代码
$ kubectl create -f dns.yaml
$ kubectl get pods | grep -E "skydns|kube2sky"
kube2sky-yylub                                                    1/1       Running          0          1d

skydns-dteml                                                      1/1       Running          0          1d

  $ kubectl get service | grep skydns

skydns-svc                172.16.40.1      <none>        53/UDP,53/TCP      app=skydns,version=v9       1d

复制代码
可以看到skyDNS已经正常运行了。

2）以HostPort形式部署

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: skydns
  labels:
    app: skydns
    version: v9
spec:
  replicas: 1
  selector:
    app: skydns
    version: v9
  template:
    metadata:
      labels:
        app: skydns
        version: v9
    spec:
      containers:
        - name: skydns
          image: private-registry.sohucs.com/domeos/skydns:1.0
          command:
            - "/skydns"
          args:
            - "--machines=http://10.16.42.200:4012"
            - "--domain=domeos.sohu"
            - "--addr=0.0.0.0:53"
          ports:
            - containerPort: 53
              hostPort: 53
              name: dns-udp
              protocol: UDP
            - containerPort: 53
              hostPort: 53
              name: dns-tcp
              protocol: TCP
      dnsPolicy: ClusterFirst
      nodeName: bx-42-197
      hostNetwork: true
      restartPolicy: Always
---
apiVersion: v1
kind: ReplicationController
metadata:
  name: kube2sky
  labels:
    app: kube2sky
    version: v9
spec:
  replicas: 1
  selector:
    app: kube2sky
    version: v9
  template:
    metadata:
      labels:
        app: kube2sky
        version: v9
    spec:
      containers:
        - name: kube2sky
          image: private-registry.sohucs.com/domeos/kube2sky:1.1
          command:
            - "/kube2sky"
          args:
            - "--etcd-server=http://10.16.42.200:4012"
            - "--domain=domeos.sohu"
            - "--kube_master_url=http://10.16.42.200:8080"
      dnsPolicy: ClusterFirst
      restartPolicy: Always
```

HostPort形式并不需要创建service，创建skyDNS时需要设置hostNetwork属性为true，同时设置nodeName以指定skyDNS运行在哪个节点上（例子中指定为bx-42-197的节点上）。在启动kubelet时的--cluster_dns参数值为bx-42-197的IP地址，即--cluster_dns=10.16.42.197。这里要注意skyDNS占用了53端口，因此bx-42-197的53端口必须是可用的。同时，需要手工将skyDNS的服务地址和search域写入到各个node节点的/etc/resolv.conf文件中，内容如下：

nameserver 10.16.42.197
search default.svc.domeos.sohu svc.domeos.sohu domeos.sohu 
# 5 测试

查看ETCD中的相关记录主要有三类：

```sh
$ etcdctl --peers=10.16.42.200:4012 ls --recursive /skydns
......
# 这一类为pod的DNS记录，下例中kafka-1-wkfa1为pod的名字，而19d074a1为运行在pod中的一个container的hostname
/skydns/sohu/domeos/kafka-1-wkfa1
/skydns/sohu/domeos/kafka-1-wkfa1/19d074a1
......
# 这一类为service的DNS记录
/skydns/sohu/domeos/svc/default/kafka-svc-1
/skydns/sohu/domeos/svc/default/kafka-svc-1/b56639fb
......
# 这一类为主机的DNS记录
  /skydns/sohu/domeos/bx-42-198

  /skydns/sohu/domeos/bx-42-198/adc8794b

  ......

$ etcdctl --peers=10.16.42.200:4012 get /skydns/sohu/domeos/kafka-1-wkfa1/19d074a1 
{"host":"172.28.0.12","priority":10,"weight":10,"ttl":30} 
$ etcdctl --peers=10.16.42.200:4012 get /skydns/sohu/domeos/svc/default/kafka-svc-1/b56639fb 
{"host":"172.16.50.1","priority":10,"weight":10,"ttl":30}
$ etcdctl --peers=10.16.42.200:4012 get /skydns/sohu/domeos/bx-42-198/adc8794b
{"host":"10.16.42.198","priority":10,"weight":10,"ttl":30}
```

可以看到Pod的hostname和主机节点的hostname被加入了记录，service的DNS记录依旧保留。

通过 docker exec 进入任一运行中的container进行测试：

```sh
$ docker exec -it 0d0874df9e15 /bin/sh
# 查看resolv.conf文件，可以看到DNS服务被加进来了
$ cat /etc/resolv.conf
nameserver 172.16.40.1
nameserver 192.168.132.1
search default.svc.domeos.sohu svc.domeos.sohu domeos.sohu
options ndots:5
# 测试解析其它container的hostname，解析成功
$ ping kafka-1-wkfa1 -c 1
PING kafka-1-wkfa1.domeos.sohu (172.28.0.12) 56(84) bytes of data.
# 测试解析k8s的service，解析成功
$ ping kafka-svc-1 -c 1
PING kafka-svc-1.default.svc.domeos.sohu (172.16.50.1) 56(84) bytes of data.
# 测试解析主机的hostname，解析成功
$ ping bx-42-198 -c 1
PING bx-42-198.domeos.sohu (10.16.42.198) 56(84) bytes of data.
```
通过hostname访问成功！

标签: kubernetes, skyDNS, kube2sky, DNS, hostname