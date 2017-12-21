

Linkerd + Namerd，实现Kubernetes 集群的灰度发布 - CSDN博客 
http://blog.csdn.net/qq_34463875/article/details/54907149
Linkerd + Namerd，实现Kubernetes 集群的灰度发布_Kubernetes中文社区 https://www.kubernetes.org.cn/1275.html

主要内容源于 https://blog.buoyant.io/2016/11/04/a-service-mesh-for-kubernetes-part-iv-continuous-deployment-via-traffic-shifting/ ，砍掉了 Jenkins 等附加部分，更换了更加易于理解的示例应用，以保证主干突出。
Kubernetes 所提供的 rolling-update 功能提供了一种渐进式的更新过程，然而其滚动过程并不容易控制，对于灰度发布的需要来说，仍稍显不足，这里介绍一种利用 Linkerd 方案进行流量切换的思路。

官网介绍：linker∙d is a transparent proxy that adds service discovery, routing, failure handling, and visibility to modern software applications。
本文从实际操作入手，上线两个版本的简单应用，利用这一组合完成流量的切换和测试过程。

测试目标

同时上线两个版本的应用。两个应用均可工作，利用不同输出进行区分。
动态调整分配给两个版本的流量。
利用 CURL 进行流量分配的测试。
准备工作

这里利用一个 1.2 以上版本的 Kubernetes 集群进行演示：

API Server / Registry：10.211.55.62
Node：10.211.66.63
另外因某些原因，需要有能力获取 Dockerhub 的镜像。

例子程序很简单，用一个 PHP 文件显示环境变量中的内容：

<?php
    echo getenv("VAR_LABEL");
Docker file 继承自 dustise/lamp:latest，文件内容如下：

FROM dustise/lamp
COPY index.php /web/codebase
利用 Docker build 创建镜像，这里命名为 lamp:gray，备用。

创建工作负载

做一个简单的 yaml 文件来加载蓝绿两组应用，名字、环境变量和端口三个位置需要更改：

---
kind: ReplicationController
apiVersion: v1
metadata:
  name: green
# 此处省略若干
        env:
        - name: VAR_LABEL
          value: 'green'
---
kind: Service
apiVersion: v1

# 此处省略若干 

  type: NodePort
  ports:
  - protocol: TCP
    nodePort: 32001
    port: 80
    targetPort: 80
    name: http
  selector:
    name: green
利用 kubectl create -f green.yaml （ 以及 blue.yaml ）之后，可以利用 curl 或者浏览器检查运行情况，如果正常，两个端口的访问应该分别会返回 green 和 blue 。

另外这里的端口命名很重要，这一名称会被后面的规则引用到。

注意，这里 NodePort 并非必须，仅为测试方便。
运行 Namerd

此处 yaml 主要来自于官网 https://raw.githubusercontent.com/BuoyantIO/linkerd-examples/master/k8s-daemonset/k8s/namerd.yml 为适应本地环境，将原有 Loadbalancer 类型的服务改为 NodePort
略微做一下讲解。

整个 yaml 由四部分组成：

ThirdPartyResource

这部分被用于做 Namerd 的存储后端。

Configmap

作为 Namerd 的配置，其中定义了这样几个内容（详情可参见 https://linkerd.io/config/0.8.5/namerd/index.html#introduction）：

管理端口 9990
storage：存储定义，通过 8001 端口同 Kube Api Server 通信，完成在 ThrdPartyResource 中的访问（8001 端口由 kubectl proxy 指令开通）
namer：定义服务发现能力由 Kubernetes 提供。
interface 部分则是定义了两种支持协议。其中 HTTP Controller 可以接收 namerctl 的控制指令。
RC

这部分不新鲜，除了 namerd 之外，还利用 kubectl proxy 提供通信端口给 namerd，颇有蛇足之嫌。正确的打开方式应该是直接和 Kube API Server 进行通信。

Service

这里注意服务类型的变更（ LoadBalancer -> NodePort ），需要暴露 4180 和 9990 两个端口，分别作为控制端口和界面端口。

利用 kubectl 启用之后，就可以在指定的端口查看管理界面了。此时的管理界面没有做任何配置，因此比较单薄。

添加规则

下面来安装 namerd 的控制工具，namerctl

go get -u github.com/buoyantio/namerctl
go install github.com/buoyantio/namerctl
接下来创建一条规则：

/host=>/#/io.l5d.k8s/default/http;
/http/*/*/*=>8*/host/blue&2*/host/green;
这段代码表示该服务同时连接 blue 和 green 两个后端服务，按照 80/20 的比例进行流量分配。

利用 namerctl dtab create [file name] --base-url 这里 base-url 取值就是我们给 namerd 设置的 Nodeport。

接下来就能够看到管理界面上显示出新的规则了。

运行 Linkerd

这里同样基于官方的 https://raw.githubusercontent.com/BuoyantIO/linkerd-examples/master/k8s-daemonset/k8s/linkerd-namerd.yml
需要注意的是，官方给出的 yaml 文件中有一处 bug，使得这个 yaml 只能在缺省的 namespace 和 domain suffix 下运行。需要纠正对 namerd 的访问方式，删除 Namerd 后面的default.svc.cloud.local 即可。

同样的，他的服务端口和管理端口都应该改用 NodePort 方式进行暴露。

运行后，同样可以看到 Linkerd 的管理界面。

测试

下面可以做一个简单的测试，来证明流量分配的有效性：

for ((i=1;i<=300;i++)); do curl -s "http://10.211.55.63:30001/";echo ""; done | grep -i blue| wc -l
可以看到，随着循环次数的增加，其结果越来越趋近于 80/20 的分配比例。

接下来，我们修改上面的 dtab 为如下内容：

/host=>/#/io.l5d.k8s/default/http;
/http/*/*/*=>8*/host/blue&8*/host/green;
重新进行测试，就可以看到，流量分配已经发生了变化。另外，还可以在 Linkerd 的管理界面上看到网络流量的变化情况。

结语

这一组合基本能够满足流量渐变分配的功能需求，同时也有如豆瓣这样的大厂使用，但他的 dtab 还是个相对复杂的东西，如果在生产上进行使用，还是需要进一步的学习。

另外，按照其文档中所陈述的功能范围内容来看，仅用来做流量分配还是颇有点大材小用的味道，从个人来说，我倾向于一些更轻量级的解决方法。

作者：崔总
本文：https://www.kubernetes.org.cn/1275.html
原文：http://blog.fleeto.us/content/linkerd-namerdshi-xian-kubernetes-ji-qun-de-hui-du-fa-bu