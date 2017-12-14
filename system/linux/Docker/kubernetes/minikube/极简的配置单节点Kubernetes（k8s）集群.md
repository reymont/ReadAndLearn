

极简的配置单节点Kubernetes（k8s）集群_Kubernetes中文社区 https://www.kubernetes.org.cn/1348.html


在传统的概念当中，Docker是简单易用的，Kubernetes是复杂强大的。 深入了解之后会发现Docker的简单是因为用户可以从基本功能开始用起， 只需要一台Linux主机，运行一下apt-get install docker-engine 或者yum install docker-engine，立马就可以用docker run启动一个新的容器， 整个过程与用户之前积累的Linux软件使用体验高度一致。 而Kubernetes则要求用户要分别配置SDN，ssl证书，etcd，kubelet，apiserver， controller-manager，scheduler，proxy，kubectl等多个组件， 刚刚接触对架构还不了解的新人一下就懵了。 过高的早期门槛把许多对Kubernetes感兴趣的用户挡在了外面，给人留下一种难以上手的感觉。

事实上，当整个系统扩展到多个节点，需要通盘考虑身份认证，高可用， 服务发现等高级功能后，Docker Swarm与Kubernetes的复杂度是接近的。 也许我们最初的比较出现了一点偏差， 将位于更高阶的集群管理和调度系统Kubernetes和位于底层的容器引擎Docker Engine直接比较并不恰当。

现在我们了解到Kubernetes的复杂是因为它提供了更多的功能， 但是如果我们无法解决Kubernetes的上手困难问题，始终会有推广上的障碍。 对此，Kubernetes社区做出了许多努力。比如：

minikube可以方便的在本机用虚拟机创建一个开箱即用的Kubernetes集群
kubeadm可以自动化的将多台Ubuntu或者CentOS主机组建成集群
nanokube，kid等自动初始化脚本
充分利用已有的工具， 我们可以在单台服务器上把Kubernetes的上手体验简化到与Docker接近的程度， 新用户可以不再纠结于安装和配置，尽快开始使用Kubernetes完成工作， 在业务需求增长时，再扩展集群成为多节点高可用的完整集群。

下图是一张学习曲线的示意图，可以看到当引入单节点Kubernetes作为过渡之后， 整个学习曲线更加平滑，在早期简单环境时更接近Docker， 在后期环境完整时又能够充分利用Kubernetes的优势。20170204141929

有多种方法可以创建单节点的Kubernetes集群，接下来分享其中一个比较简单方便的。

准备工作

首先准备一台Linux服务器，根据Docker中文文档安装好Docker。

接着下载localkube和kubectl:

$ curl -o localkube https://storage.googleapis.com/minikube/k8sReleases/v1.5.1/localkube-linux-amd64
$ chmod +x localkube
$ curl -O https://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kubectl
$ chmod +x kubectl
localkube将Kubernetes所有的依赖程序全部打包成为了一个独立的可执行文件， 使用它可以省略掉几乎所有的配置流程，直接将Kubernetes跑起来。

目前localkube已经被合并进了minikube，最新的版本需要从minikube中下载。

kubectl是Kubernetes的客户端程序，可以用它控制集群。

启动Kubernetes

使用localkube启动集群非常简单:

$ ./localkube
当不加任何参数时，localkube会使用默认参数启动， 它所监听的localhost:8080将被用于接受控制指令。

这里并没有在后台运行localkube，如果你需要后台运行， 可以自行使用Linux上已有的各种工具完成。

使用kubectl控制集群

接下来的操作与多节点的集群完全一样。我们可以用kubectl来控制集群，比如：

$ ./kubectl run nginx --image nginx
是不是和docker run nginx几乎一样？在这里我们不详细介绍Kubernetes的操作， 请参考官方文档学习Kubernetes的使用方法。

需要指出的是，由于是极简的配置，并没有配置远程控制所需要的证书， 所以不能在本地电脑上控制这个集群，而需要ssh到服务器上进行控制。 这和默认的Docker配置是一致的。

总结

从上面的流程可以看到，Kubernetes也可以变得很简单，仅仅需要将所有组件合并到一起就可以了。 而这也恰恰是Docker选择的策略，在Docker的二进制文件中，被打包进了Docker Engine， 分布式存储，Docker Swarm等功能，使用起来只需要一个docker指令就可以完成全部的操作。 接下来需要思考的问题是，既然合并到一起会更加简单，那为什么Kubernetes会把各个组件拆开呢？ 今后在详细介绍Kubernetes架构的时候会再给大家做详细的分析，这里就暂时留给大家下来自己思考了。

在刚接触Kubernetes的时候，使用all in one的localkube是有好处的。 可以把它整个看作Kubernetes，直接上手开始学习Pod，Service，ReplicaSet这些抽象概念， 而不用特别去关注里面的组件划分。虽然暂时只能在一台服务器上运行， 不能完全的展现Kubernetes编排和调度的能力，但是用于学习和测试已经完全足够了。

待对Kubernetes建立了基本的概念之后，再进行多节点的集群部署， 在那时再来折腾SDN，ssl证书这些更偏重运维的组件时，才会有比较合理的投入产出预期。

还在等什么？快点把你的Docker主机升级为Kubernetes主机吧。就算没有联网形成集群， 使用更高的抽象来构建你的业务，也将为今后的发展打下良好的基础。

