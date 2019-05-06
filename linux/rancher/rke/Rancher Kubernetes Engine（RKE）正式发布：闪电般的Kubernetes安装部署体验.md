

Rancher Kubernetes Engine（RKE）正式发布：闪电般的Kubernetes安装部署体验 
http://mp.weixin.qq.com/s/TauaF8X9oCr0PNkrH-e6lA

作为Rancher 2.0的重要组件，Rancher Kubernetes Engine（RKE）现已正式全面发布！这是Rancher Labs推出的新的开源项目，一个极致简单易用、闪电般快速、支持一切基础架构（公有云、私有云、VM、物理机等）的Kubernetes安装程序。

为何做一个全新的K8s安装程序？

在过去两年中，Rancher已经成为最为流行和受欢迎的创建和管理Kubernetes集群的平台之一。因为易于上手的特性和极致简单的用户体验，Rancher作为创建与管理Kubernetes的平台深受全球大量用户青睐 。Rancher将etcd、Kubernetes master和worker节点操作完全自动化。然而，因为Rancher 1.x自主实现了容器间网络通信，所以Rancher管理面板若发生故障，可能会导致Kubernetes集群运行的中断。
 
现阶段市场中有不少可供用户选择的用于创建Kubernetes集群的安装程序。据我们所见，其中两个最受欢迎的安装程序是kops和Kubespray：
 
Kops也许是使用最广泛的Kubernetes安装程序。事实上，它不仅仅是一个安装程序。Kops为用户备好了所有可能需要的云资源，它能用来安装Kubernetes，还可以连接云监控服务，以确保Kubernetes集群的持续运行。不过，Kops与底层云基础架构集成过于紧密，在AWS上表现最为优秀，而对GCE和vSphere等其他基础架构平台的就不能提供支持。
Kubespray是用Ansible编写的独立Kubernetes安装程序，它可以在任何服务器上安装Kubernetes集群，非常受用户欢迎。尽管Kubespray与各种云API具有一定程度的集成，但它基本上是独立于云的，因此可以与任何云、虚拟化集群或裸机服务器协同工作。目前，Kubespray已经发展成一个由大量开发人员参与的复杂项目。

Kubeadm是另一个跟随Kubernetes主版本分发的安装工具。然而，Kubeadm还不支持像HA集群这样的功能。尽管在 kops和Kubespray等项目中使用了 kubeadm 某些代码，但若作为生产级的Kubernetes安装程序，kubeadm还不适合。
 
Rancher 2.0可以支持并纳管任何Kubernetes集群。我们鼓励用户使用GKE和AKS等公有云云托管服务。对于想要自行建立自己的集群的用户，我们正在考虑将kops或Kubespray集成到我们的产品阵容中。Kops不符合我们的需求，因为它并不适用于所有云提供商。其实，Kubespray已经很接近我们的需要了，尤其是 Kubespray可以在任何地方安装Kubernetes的这一特性。但最终，我们决定不采用Kubespray，而是构建自己的轻量级安装程序，原因有两个:
 
我们可以重新起步，利用Kubernetes本身的优势建立一个更简易的系统。
与在Rancher 1.6中安装Kubernetes一样，通过使用基于容器的方法，我们可以拥有更快的安装程序。

RKE如何工作

RKE是一个独立的可执行文件，它可以从集群配置文件中读取并启动、关闭或升级Kubernetes群集。 如下是一个示例配置文件：

---
auth:
  strategy: x509

network:
  plugin: flannel

ssh_key_path: /home/user/.ssh/id_rsa

nodes:
  - address: server1
    user: ubuntu
    role: [controlplane, etcd]
  - address: server2
    user: ubuntu
    role: [worker]

services:
  etcd:
    image: quay.io/coreos/etcd:latest
  kube-api:
    image: rancher/k8s:v1.8.3-rancher2
    service_cluster_ip_range: 10.233.0.0/18
    extra_args:
      v: 4
  kube-controller:
    image: rancher/k8s:v1.8.3-rancher2
    cluster_cidr: 10.233.64.0/18
    service_cluster_ip_range: 10.233.0.0/18
  scheduler:
    image: rancher/k8s:v1.8.3-rancher2
  kubelet:
    image: rancher/k8s:v1.8.3-rancher2
    cluster_domain: cluster.local
    cluster_dns_server: 10.233.0.3
    infra_container_image: gcr.io/google_containers/pause-amd64:3.0
  kubeproxy:
    image: rancher/k8s:v1.8.3-rancher2

addons: |-
    ---
    apiVersion: v1
    kind: Pod
    metadata:
      name: my-nginx
      namespace: default
    spec:
      containers:
      - name: my-nginx
        image: nginx
        ports:
        - containerPort: 80

如上所示，我们通过指定认证策略、网络模型和本地SSH密钥路径来启动文件。集群配置文件的主体由以下三部分组成：
 
节点部分描述了组成Kubernetes集群的所有服务器。每个节点都承担三个角色中的一个或多个角色：controlplane、etcd和worker。您可以通过更改节点部分并重新运行RKE命令来添加或删除Kubernetes集群中的节点。
服务部分描述了在Kubernetes集群上运行的所有系统服务。RKE将所有系统服务打包为容器。
插件部分描述了在Kubernetes集群上运行的用户级程序。因此，RKE用户可以在同一文件中指定Kubernetes集群配置和应用程序配置。
 
RKE不是一个可以长时间运行的、可以监控和操作Kubernetes集群的服务。RKE需要与像Rancher 2.0这样的完整的容器管理系统或像AWS CloudWatch、Datadog或Sysdig等一样的独立监控系统配合使用。配合使用时，您就可以构建自己的脚本来监控RKE集群的健康状况了。

RKE：嵌入式Kubernetes安装程序

当用户需要构件一个分布式应用系统时，常常不得不处理后端数据库、数据访问层、集群和扩展等方面的问题。现在，越来越多的开发人员不再使用传统的应用程序服务器，而是开始使用Kubernetes作为分布式应用程序平台：
 
开发人员使用etcd作为后端数据库。
开发人员使用Kubernetes Custom Resource Definition（CRD）作为数据访问层，并使用kubectl在其数据模型上执行基本的CRUD操作。
开发人员将应用程序打包为容器，并使用Kubernetes完成集群和伸缩工作。
 
以这种方式构建的应用程序将作为Kubernetes YAML文件发送给用户。如果用户已经运行Kubernetes集群，或可以访问公有云托管的Kubernetes服务（如GKE或AKS），就可以轻松运行这些应用程序。但是，那些希望在虚拟化或裸机服务器上安装应用程序的用户该怎么办呢？
 
通过将RKE作为嵌入式Kubernetes安装程序捆绑到应用程序中，应用程序开发人员就可以解决上述需求。通过调用RKE，应用程序安装便可以启动，且会为用户创建一个Kubernetes集群。而我们已注意到，将诸如RKE之类的轻量级安装程序嵌入到分布式应用程序中，满足了很多来自用户的兴趣与需求。

为Kubernetes落地普及而前行

Rancher Kubernetes Engine（RKE）秉承了Rancher产品一贯易于上手、操作简单、体验友好的特性，使用户创建Kubernetes集群的过程变得更加简单，且我们相信通过云管理平台进行Kubernetes安装是大多数Kubernetes用户的最佳选择。
 
在Rancher Labs，我们希望Kubernetes有朝一日成为所有云服务商支持的标准化的基础架构，且一直在为了实现这个愿景而努力。已推出技术预览版、将于2018年初正式发布的Rancher 2.0，将可以同时纳管和导入任何类型、来自任何云提供商的Kubernetes集群，包括RKE、AWS EKS、Google Container Engine (GKE)、Azure Container Service (AKS)等等。

下一步，一起走吧

秉承Rancher一贯100%开源的风格，你可以直接从GitHub上下载RKE：http://rancher.com/announcing-rke-lightweight-kubernetes-installer/

我们也将持续发布更多技术文章，让您更深入了解和学习使用RKE，敬请保持关注。

12月13日，我们将举办针对RKE的Online Training，为您培训和演示RKE的使用，点击「阅读原文」，即可在跳转链接中报名参加！

在Rancher容器管理平台功能日臻完善、受到越来越多支持与认可的背后，我们深知，这一切都离不开广大用户一如既往的支持、持续提供的反馈。

谢谢你们❤️愿Rancher不负你们所望❤️

“ 
关于Rancher Labs

Rancher Labs是来自硅谷的容器管理平台提供商，由硅谷云计算泰斗、CloudStack之父梁胜创建。Rancher Labs致力于打造创新的开源软件，帮助企业利用容器技术加快软件开发周期，改善IT操作流程。其旗舰产品Rancher是一个开源的全栈化企业级容器管理平台，产品最主要特点是简单易用，凭借优异的基础设施服务管理能力和强大的容器协调能力，允许用户在任何基础设施上可以轻松管理生产中运行容器的方方面面，进而成为帮助企业把Docker和Kubernetes在生产环境中落地的最佳选择。
 
Rancher作为世界范围内唯一完全开源的容器管理平台，在全球已有6000万次下载和超过10000个生产环境部署，且在全球范围内已经拥有包含迪斯尼、IBM、乐高、美国农业部、SONY、中国平安、海航集团在内数百家大中型政府及企业客户。