RKE快速上手指南：开源的轻量级K8S安装程序 | Rancher https://www.cnrancher.com/an-introduction-to-rke/


by Shirley Huang on 12月 5, 2017

安装Kubernetes是公认的对运维和DevOps而言最棘手的问题之一。因为Kubernetes可以在各种平台和操作系统上运行，所以在安装过程中需要考虑很多因素。

在这篇文章中，我将介绍一种新的、用于在裸机、虚拟机、公私有云上安装Kubernetes的轻量级工具——Rancher Kubernetes Engine（RKE）。RKE是一个用Golang编写的Kubernetes安装程序，极为简单易用，用户不再需要做大量的准备工作，即可拥有闪电般快速的Kubernetes安装部署体验。

如何安装RKE
你可以从官方的GitHub仓库安装RKE。 RKE可以在Linux和MacOS机器上运行。安装完成后，运行以下代码，确保您使用的是最新版本：

1

RKE安装的准备工作
RKE是一个基于容器的安装程序，这意味着它需要在远程服务器上安装Docker，目前需要在服务器上安装Docker 1.12版本。

RKE的工作方式是通过SSH连接到每个服务器，并在此服务器上建立到Docker socket的隧道，这意味着SSH用户必须能够访问此服务器上的Docker引擎。要启用对SSH用户的访问，您可以将此用户添加到Docker组：

usermod -aG docker
要启动Kubernetes的安装，以上是远程服务器需要的唯一准备工作。

RKE入门使用
如下示例假定用户已配置三台服务器：

node-1: 192.168.1.5
node-2: 192.168.1.6
node-3: 192.168.1.7
集群配置文件
默认情况下，RKE将查找名为cluster.yml的文件，该文件中包含有关将在服务器上运行的远程服务器和服务的信息。最小文件应该是这样的：

2

集群配置文件包含一个节点列表。每个节点至少应包含以下值：

地址 – 服务器的SSH IP / FQDN
用户 – 连接到服务器的SSH用户
角色 – 主机角色列表：worker，controlplane或etcd
另一节是“服务”，其中包含有关将在远程服务器上部署的Kubernetes组件的信息。

有三种类型的角色可以使用主机：

etcd – 这些主机可以用来保存集群的数据。
controlplane – 这些主机可以用来存放运行K8s所需的Kubernetes API服务器和其他组件。
worker – 这些是您的应用程序可以部署的主机。
运行RKE
要运行RKE，首先要确保cluster.yml文件在同一个目录下，然后运行如下命令：

➜ ./rke up
若想指向另一个配置文件，运行如下命令：

➜ ./rke up --config /tmp/config.yml
输出情况将如下所示：

3

连接到集群
RKE会在配置文件所在的目录下部署一个本地文件，该文件中包含kube配置信息以连接到新生成的群集。默认情况下，kube配置文件被称为.kube_config_cluster.yml。将这个文件复制到你的本地~/.kube/config，就可以在本地使用kubectl了。

需要注意的是，部署的本地kube配置名称是和集群配置文件相关的。例如，如果您使用名为mycluster.yml的配置文件，则本地kube配置将被命名为.kube_config_mycluster.yml。

4

A Peek Under the Hood
RKE默认使用x509身份验证方法来设置Kubernetes组件和用户之间的身份验证。RKE会首先为每个组件和用户组件生成证书。

5

生成证书后，RKE会将生成的证书部署到/etc/kubernetes/ssl服务器，并保存本地kube配置文件，其中包含主用户证书，在想要删除或升级集群时可以与RKE一起使用。

然后，RKE会将每个服务组件部署为可以相互通信的容器。RKE还会将集群状态保存在Kubernetes中作为配置映射以备后用。

RKE是一个幂等工具，可以运行多次，且每次均产生相同的输出。如下的网络插件它均可以支持部署：

Calico
Flannel (default)
Canal
要使用不同的网络插件，您可以在配置文件中指定：

network:
  plugin: calico
插件
RKE支持在集群引导程序中使用可插拔的插件。用户可以在cluster.yml文件中指定插件的YAML。

RKE在集群启动后会部署插件的YAML。RKE首先会将这个YAML文件作为配置映射上传到Kubernetes集群中，然后运行一个Kubernetes作业来挂载这个配置映射并部署这些插件。

请注意，RKE暂不支持删除插件。插件部署完成后，就不能使用RKE来改变它们了。
要开始使用插件，请使用集群配置文件中的addons:选项，例如：

6

请注意，我们使用|-</code，因为插件是一个多行字符串选项，您可以在其中指定多个YAML文件并用“—”将它们分开。

高可用性
RKE工具是满足高可用的。您可以在集群配置文件中指定多个控制面板主机，RKE将在其上部署主控组件。默认情况下，kubelets被配置为连接到nginx-proxy服务的地址——127.0.0.1:6443，该代理会向所有主节点发送请求。

要启动HA集群，只需使用controlplane角色指定多个主机，然后正常启动集群即可。

添加或删除节点
RKE支持为角色为worker和controlplane的主机添加或删除节点。要添加其他节点，只需要更新具有其他节点的集群配置文件，并使用相同的文件运行集群配置即可。

要删除节点，只需从集群配置文件中的节点列表中删除它们，然后重新运行rke up命令。

集群删除命令
RKE支持rke remove命令。该命令执行以下操作：

连接到每个主机并删除部署在其上的Kubernetes服务。
从服务所在的目录中清除每个主机：
/etc/kubernetes/ssl
/var/lib/etcd
/etc/cni
/opt/cni
请注意，这个命令是不可逆的，它将彻底摧毁Kubernetes集群。
结语
Rancher Kubernetes Engine（RKE）秉承了Rancher产品一贯易于上手、操作简单、体验友好的特性，使用户创建Kubernetes集群的过程变得更加简单，且我们相信通过云管理平台进行Kubernetes安装是大多数Kubernetes用户的最佳选择。

在Rancher Labs，我们希望Kubernetes有朝一日成为所有云服务商支持的标准化的基础架构，且一直在为了实现这个愿景而努力。已推出技术预览版、将于2018年初正式发布的Rancher 2.0，将可以同时纳管和导入任何类型、来自任何云提供商的Kubernetes集群，包括RKE、AWS EKS、Google Container Engine (GKE)、Azure Container Service(AKS)等等。

秉承Rancher一贯100%开源的风格，你可以直接从GitHub上下载RKE