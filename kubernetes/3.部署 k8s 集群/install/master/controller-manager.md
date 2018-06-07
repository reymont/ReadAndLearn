
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [kubernetes Master部署之ControllerManager部署(4)](#kubernetes-master部署之controllermanager部署4)
* [Kubernetes集群的安全配置](#kubernetes集群的安全配置)
	* [一、集群现状](#一-集群现状)
		* [1. node](#1-node)
		* [2、kubernetes核心组件的启动参数](#2-kubernetes核心组件的启动参数)
		* [3、私钥文件和公钥证书](#3-私钥文件和公钥证书)
	* [二、集群环境](#二-集群环境)
	* [三、目标](#三-目标)
		* [1、Cluster -> Master(apiserver)](#1-cluster-masterapiserver)
			* [a) kubernetes component on master node -> apiserver](#a-kubernetes-component-on-master-node-apiserver)
			* [b) kubernetes component on worker node -> apiserver](#b-kubernetes-component-on-worker-node-apiserver)
			* [c) componet in pod for kubernetes -> apiserver](#c-componet-in-pod-for-kubernetes-apiserver)
			* [d) user service in pod -> apiserver](#d-user-service-in-pod-apiserver)
		* [2、Master(apiserver) -> Cluster](#2-masterapiserver-cluster)
	* [四、Kubernetes的安全机制](#四-kubernetes的安全机制)

<!-- /code_chunk_output -->


# kubernetes Master部署之ControllerManager部署(4)

* [kubernetes Master部署之ControllerManager部署(4) - Go_小易 - 博客园 ](http://www.cnblogs.com/yangxiaoyi/p/6947306.html)


# Kubernetes集群的安全配置

* [Kubernetes集群的安全配置 | Tony Bai ](http://tonybai.com/2016/11/25/the-security-settings-for-kubernetes-cluster/)

## 一、集群现状

### 1. node

```sh
kubectl cluster-info
#Kubernetes master is running at http://localhost:8080
#KubeDNS is running at #http://localhost:8080/api/v1/proxy/namespaces/kube-system/services/kube-dns
# 获取节点
kubectl get node --show-labels=true
```

### 2、kubernetes核心组件的启动参数

master

```sh
#controller-manager
/opt/bin/kube-controller-manager --master=127.0.0.1:8080 --root-ca-file=/srv/kubernetes/ca.crt --service-account-private-key-file=/srv/kubernetes/server.key --logtostderr=true
#apiserver
/opt/bin/kube-apiserver --insecure-bind-address=0.0.0.0 --insecure-port=8080 --etcd-servers=http://127.0.0.1:4001 --logtostderr=true --service-cluster-ip-range=192.168.3.0/24 --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,SecurityContextDeny,ResourceQuota --service-node-port-range=30000-32767 --advertise-address=10.47.136.60 --client-ca-file=/srv/kubernetes/ca.crt --tls-cert-file=/srv/kubernetes/server.cert --tls-private-key-file=/srv/kubernetes/server.key
#scheduler
/opt/bin/kube-scheduler --logtostderr=true --master=127.0.0.1:8080
#proxy
/opt/bin/kube-proxy --hostname-override=10.47.136.60 --master=http://10.47.136.60:8080 --logtostderr=true
#kubelet
/opt/bin/kubelet --hostname-override=10.47.136.60 --api-servers=http://10.47.136.60:8080 --logtostderr=true --cluster-dns=192.168.3.10 --cluster-domain=cluster.local --config=
```

从master node的核心组件kube-apiserver 的启动命令行参数也可以看出我们在开篇处所提到的那样：apiserver insecure-port开启，且bind 0.0.0.0:8080，可以任意访问，连basic_auth都没有。当然api server不只是监听这一个端口，在api server源码中，我们可以看到默认情况下，apiserver还监听了另外一个secure port，该端口的默认值是6443，通过`lsof`命令查看6443端口的监听进程也可以印证这一点：

> yum install -y lsof

```sh
//master node上
# lsof -i tcp:6443
COMMAND     PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
kube-apis 22021 root   46u  IPv6 921529      0t0  TCP *:6443 (LISTEN)
```

### 3、私钥文件和公钥证书

通过安装脚本在bare-metal上安装的k8s集群，在master node上你会发现如下文件：

```sh
root@node1:/srv/kubernetes# ls
ca.crt  kubecfg.crt  kubecfg.key  server.cert  server.key
```

这些私钥文件和公钥证书是在k8s(1.3.7)集群安装过程由安装脚本创建的，在kubernetes/cluster/common.sh中你可以发现function create-certs这样一个函数，这些文件就是它创建的。

简单描述一下这些文件的用途：

- ca.crt：the cluster's certificate authority，CA证书，即根证书，内置CA公钥，用于验证某.crt文件，是否是CA签发的证书；
- server.cert：kube-apiserver服务端公钥数字证书；
- server.key：kube-apiserver服务端私钥文件；
- kubecfg.crt 和kubecfg.key：按照 create-certs函数注释中的说法：这两个文件是为kubectl访问apiserver[双向证书验证](http://tonybai.com/2015/04/30/go-and-https/)时使用的。

再来验证一下server.cert和kubecfg.crt是否是ca.crt签发的：
```sh
# openssl verify -CAfile ca.crt kubecfg.crt
kubecfg.crt: OK
# openssl verify -CAfile ca.crt server.cert
server.cert: OK
```

在前面的apiserver的启动参数展示中，我们已经看到kube-apiserver使用了ca.crt, server.cert和server.key：
```sh
/opt/bin/kube-apiserver --insecure-bind-address=0.0.0.0 --insecure-port=8080 --etcd-servers=http://127.0.0.1:4001 --logtostderr=true --service-cluster-ip-range=192.168.3.0/24 --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,SecurityContextDeny,ResourceQuota --service-node-port-range=30000-32767 --advertise-address=10.47.136.60 --client-ca-file=/srv/kubernetes/ca.crt --tls-cert-file=/srv/kubernetes/server.cert --tls-private-key-file=/srv/kubernetes/server.key
```

## 二、集群环境

还是那句话，Kubernetes在active development中，老版本和新版本的安全机制可能有较大变动，本篇中的配置方案和步骤都是针对一定环境有效的，我们的环境如下：

```
OS：
Ubuntu 14.04.4 LTS Kernel：3.19.0-70-generic #78~14.04.1-Ubuntu SMP Fri Sep 23 17:39:18 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux

Docker：
# docker version
Client:
 Version:      1.12.2
 API version:  1.24
 Go version:   go1.6.3
 Git commit:   bb80604
 Built:        Tue Oct 11 17:00:50 2016
 OS/Arch:      linux/amd64

Server:
 Version:      1.12.2
 API version:  1.24
 Go version:   go1.6.3
 Git commit:   bb80604
 Built:        Tue Oct 11 17:00:50 2016
 OS/Arch:      linux/amd64

Kubernetes集群：1.3.7

私有镜像仓库：阿里云镜像仓库
```

## 三、目标

目前，我们尚不具备一步迈向“绝对安全”的能力，在目标设定时，我们的一致想法是在当前阶段“有限安全”的K8s集群更适合我们。在这一原则下，我们针对不同情况提出不同的目标设定。

前面说过，k8s针对`insecure port(–insecure-bind-address=0.0.0.0 –insecure-port=8080)`的流量没有任何安全机制限制，相当于k8s“裸奔”。但是走`k8s apiserver secure port(–bind-address=0.0.0.0 –secure-port=6443)`的流量，将会遇到验证、授权等安全机制的限制。具体使用哪个端口与API server的交互方式，要视情况而定。

在分情况说明之前，将api server的insecure port的bind address由0.0.0.0改为local address是必须要做的。

### 1、Cluster -> Master(apiserver)

从集群到Apiserver的流量也可以细分为几种情况：

#### a) kubernetes component on master node -> apiserver

由于master node上的components与apiserver运行在一台机器上，因此可以通过local address的insecure-port访问apiserver，无需走insecure port。从现状中当前master上的component组件的启动参数来看，目前已经符合要求，于是针对这些components，我们无需再做配置上的调整。

#### b) kubernetes component on worker node -> apiserver

目标是实现kubernetes components on worker node和运行于master上的apiserver之间的基于https的双向认证。kubernetes的各个组件均支持在命令行参数中传入tls相关参数，比如ca文件路径，比如client端的cert文件和key等。

#### c) componet in pod for kubernetes -> apiserver

像kube dns和kube dashboard这些运行于pod中的k8s 组件也是在k8s cluster范围内调度的，它们可能运行在任何一个worker node上。理想情况下，它们与master上api server的通信也应该是基于一定安全机制的。不过在本篇中，我们暂时不动它们的设置，以免对其他目标的实现造成一定障碍和更多的工作量，在后续文章中，可能会专门将dns和dashboard拿出来做安全加固说明。因此，dns和dashboard在这里仍然使用的是insecure-port：

```sh
root     10531 10515  0 Nov15 ?        00:03:02 /dashboard --port=9090 --apiserver-host=http://10.47.136.60:8080
root     2018255 2018240  0 Nov15 ?        00:03:50 /kube-dns --domain=cluster.local. --dns-port=10053 --kube-master-url=http://10.47.136.60:8080
```

#### d) user service in pod -> apiserver

我们的集群管理程序也是以service的形式运行在k8s cluster中的，这些程序如何访问apiserver才是我们关心的重点，我们希望管理程序通过secure-port，在一定的安全机制下与apiserver交互。

### 2、Master(apiserver) -> Cluster

apiserver作为client端访问Cluster，在k8s文档中，这个访问路径主要包含两种情况：

a) apiserver与各个node上kubelet交互，采集Pod的log；
b) apiserver通过自身的proxy功能访问node、pod以及集群中的各种service。

在“有限安全”的原则下，我们暂不考虑这种情况下的安全机制。

## 四、Kubernetes的安全机制

kube-apiserver是整个kubernetes集群的核心，无论是kubectl还是通过api管理集群，最终都会落到与kube-apiserver的交互，apiserver是集群管理命令的入口。kube-apiserver同时监听两个端口：`insecure-port和secure-port`。之前提到过：通过insecure-port进入apiserver的流量可以有控制整个集群的全部权限；而通过secure-port的流量将经过k8s的安全机制的重重考验，这也是这一节我们重要要说明的。insecure-port的存在一般是为了集群bootstrap或集群开发调试使用的。官方文档建议：集群外部流量都应该走secure port。insecure-port可通过firewall rule使外部流量unreachable。

下面这幅官方图示准确解释了通过secure port的流量将要通过的“安全关卡”：

![k8s-apiserver-access-control-overview.svg](img/k8s-apiserver-access-control-overview.svg)

我们可以看到外界到APIServer的请求先后经过了：

> 安全通道(tls) -> Authentication(身份验证) -> Authorization（授权）-> Admission Control(入口条件控制)

* 安全通道：即基于tls的https的安全通道建立，对流量进行加密，防止嗅探、身份冒充和篡改；

* Authentication：即身份验证，这个环节它面对的输入是整个http request。它负责对来自client的请求进行身份校验，支持的方法包括：client证书验证（https双向验证）、basic auth、普通token以及jwt token(用于serviceaccount)。APIServer启动时，可以指定一种Authentication方法，也可以指定多种方法。如果指定了多种方法，那么APIServer将会逐个使用这些方法对客户端请求进行验证，只要请求数据通过其中一种方法的验证，APIServer就会认为Authentication成功；

* Authorization：授权。这个阶段面对的输入是http request context中的各种属性，包括：user、group、request path（比如：/api/v1、/healthz、/version等）、request verb(比如：get、list、create等)。APIServer会将这些属性值与事先配置好的访问策略(access policy）相比较。APIServer支持多种authorization mode，包括AlwaysAllow、AlwaysDeny、ABAC、RBAC和Webhook。APIServer启动时，可以指定一种authorization mode，也可以指定多种authorization mode，如果是后者，只要Request通过了其中一种mode的授权，那么该环节的最终结果就是授权成功。

* Admission Control：从技术的角度看，Admission control就像a chain of interceptors（拦截器链模式），它拦截那些已经顺利通过authentication和authorization的http请求。http请求沿着APIServer启动时配置的admission control chain顺序逐一被拦截和处理，如果某个interceptor拒绝了该http请求，那么request将会被直接reject掉，而不是像authentication或authorization那样有继续尝试其他interceptor的机会。