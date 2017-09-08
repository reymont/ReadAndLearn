
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [容器网络Calico进阶实践](#容器网络calico进阶实践)
	* [Calico 简介回顾](#calico-简介回顾)
		* [Calico 架构](#calico-架构)
	* [Calico 的新版变化](#calico-的新版变化)

<!-- /code_chunk_output -->


# 容器网络Calico进阶实践

* [容器网络Calico进阶实践 | 褚向阳-博客-云栖社区-阿里云 ](https://yq.aliyun.com/articles/68558)

各位晚上好,我是数人云的褚向阳,接下来要跟大家分享的主题是《容器网络Calico进阶实践》.

距离上次聊 Calico 已经过去快半年的时间了，数人云也一直在努力将容器网络方案应用到企业客户的环境中，Calico v2.0 也马上就要发布了，这次跟大家一起感受下新版.

需要说明下，本人跟 Calico 没有任何直接关系，也只是个"吃瓜群众"，做为使用者，想跟大家聊聊心得而已。

这次分享的内容主要包括：

简单总结下作为使用者我看到的 Calico 的变化，包括组件，文档和 calicoctl ；
Demo 一些简单的例子，会和 MacVLAN 做一下对比说明原理；
最后总结下适合 Calico 的使用场景；


## Calico 简介回顾

首先，还是简单的回顾下 Calico 的架构和关键组件，方便大家理解。

### Calico 架构

Calico 是一个三层的数据中心网络方案，而且方便集成 OpenStack 这种 IaaS 云架构，能够提供高效可控的 VM、容器、裸机之间的通信。

495a6f09abd5963e4075078ea21efe72207fbf62

结合上面这张图，我们来过一遍 Calico 的核心组件：

* Felix，Calico agent，跑在每台需要运行 workload 的节点上，主要负责配置路由及 ACLs 等信息来确保 endpoint 的连通状态；
* etcd，分布式键值存储，主要负责网络元数据一致性，确保 Calico 网络状态的准确性；
* BGP Client(BIRD), 主要负责把 Felix 写入 kernel 的路由信息分发到当前 Calico 网络，确保 workload 间的通信的有效性；
* BGP Route Reflector(BIRD), 大规模部署时使用，摒弃所有节点互联的 mesh 模式，通过一个或者多个 BGP Route Reflector 来完成集中式的路由分发；

通过将整个互联网的可扩展 IP 网络原则压缩到数据中心级别，Calico 在每一个计算节点利用 Linux kernel 实现了一个高效的 vRouter 来负责数据转发 而每个 vRouter 通过 BGP 协议负责把自己上运行的 workload 的路由信息像整个 Calico 网络内传播 － 小规模部署可以直接互联，大规模下可通过指定的 BGP route reflector 来完成。

这样保证最终所有的 workload 之间的数据流量都是通过 IP 包的方式完成互联的。

acd150461b4b3eeb117ff59472200649355f6f5d

Calico 节点组网可以直接利用数据中心的网络结构（支持 L2 或者 L3），不需要额外的 NAT，隧道或者 VXLAN overlay network。

![](https://yqfile.alicdn.com/4b98d511311c147f0ce38827887dd0218b7ec003.png)

如上图所示，这样保证这个方案的简单可控，而且没有**封包解包**，节约 CPU 计算资源的同时，提高了整个网络的性能。

此外，**Calico 基于 iptables 还提供了丰富而灵活的网络 policy**, 保证通过各个节点上的 ACLs 来提供 workload 的多租户隔离、安全组以及其他可达性限制等功能。

更详细的介绍大家可以参考之前的分享：

http://edgedef.com/docker-networking.html 

或者 

http://dockone.io/article/1489

## Calico 的新版变化

接下来简单介绍下 Calico 新版带来了哪些变化

组件层面:

先看一下 v2.0.0-rc2 中包含的组件列表:

v2.0.0-rc2
felix 2.0.0-rc4
calicoctl v1.0.0-rc2
calico/node v1.0.0-rc2
calico/cni v1.5.3
libcalico v0.19.0
libcalico-go v1.0.0-rc4
calico-bird v0.2.0-rc1
calico-bgp-daemon v0.1.1-rc2
libnetwork-plugin v1.0.0-rc3
calico/kube-policy-controller v0.5.1
networking-calico 889cfff
对比下 v1.5 或者之前的版本：

v1.5.0
felix v1.4.1b2
calicoctl v0.22.0
calico/node v0.22.0
calico/node-libnetwork v0.9.0
calico/cni v1.4.2
ibcalico v0.17.0
calico-bird v0.1.0
calico/kube-policy-controller v0.3.0
可以看到组件层面 Calico 也发生了比较大的变化，其中新增：

libcalico-go (Golang Calico library function, used by both calicoctl, calico-cni and felix)
calico-bgp-daemon （GoBGP based Calico BGP Daemon，alternative to BIRD）
libnetwork-plugin (Docker libnetwork plugin for Project Calico, integrated with the calico/node image)
networking-calico （OpenStack/Neutron integration for Calico networking）
总结来看，就是组件语言栈转向 Golang，包括原来 Python 的 calicoctl 也用 Golang 重写了； 顺便说一下，这也和数人云的语言栈从 Python Golang 统一到 Golang 是差不多的周期，可以看出 Golang 在容器圈的影响力之大； 同时面向开源，给使用者提供更好的扩展性（兼容 GoBGP）和集成能力（OpenStack/Neutron）。

使用层面:

更好的文档和积极响应的 Slack：

http://docs.projectcalico.org/v2.0/introduction/

开源软件的文档对于使用者来说很重要，Calico 的文档正在变的越来越好，尽量保证每种使用场景（docker，Mesos, CoreOS, K8s, OpenStack 等) 都能找到可用的参考。

除此之外，Calico 还维护了一个很快响应的 Slack，有问题可以随时到里边提问，这种交互对开源的使用者来说也是很好的体验。

重新面向 Kubernetes 改写的 calicoctl UX 模型

毫无疑问，这是 Calico 为了更好的集成到 Kubernetes 所做出的努力和改变，也是对越来越多使用 k8s 同时又想尝试 Calico 网络的用户的好消息，这样大家就可以像在 k8s 中定义 资源模型一样通过 YAML 文件来定义 Calico 中的 Pool，Policy 这些模型了，同时也支持 label&selector 模式，保证了使用上的一致性。 具体的 Calico 定义资源模型的例子在后面的 Demo 中会有体现。

Calico CNI 及 Canal

还有一个变化，就是 Canal 的出现，面向 CNI 的基于访问控制的容器网络方案。

Container Network Interface CNI 容器网络 spec 是由 CoreOS 提出的，被 Mesos， Kubernetes 以及 rkt 等接受引入 使用。

Calico 在对 Docker 家的 CNM 和 libnetwork 提供更好的支持的同时，为了更亲和 Kubernetes ，和更好的对 CNI 的支持，Metaswitch 和 CoreOS 一起组建了 新的公司 TiGERA（https://www.tigera.io/），主推 Canal 将 Calico 的 policy 功能加入到 Flannel 的网络中，为和 k8s 的网络提供更好的 ACL 控制。

Calico 组件原理 Demo

为了理解 Calico 工作原理，顺便体验新版 Calico，我们准备了两套 Demo 环境，一套是新版 Calico，另一套是对比环境 MacVLAN。

Calico 以测试为目的集群搭建，步骤很简单，这里不展开了， 大家可以直接参考 http://docs.projectcalico.org/master/getting-started/docker/installation/manual

MacVlan 的集群搭建，步骤也相对简单, 参考：https://github.com/alfredhuang211/study-docker-doc/blob/master/docker跨主机macVLAN网络配置.md

这里默认已经有了两套 Docker Demo 集群：

Calico 网络的集群，分别是：10.1.1.103(calico01) 和 10.1.1.104(calico02)
MacVLAN 集群，分别是：10.1.1.105 和 10.1.1.106


Demo 1: Calico 三层互联

calicoctl node status 截图： 


同时，已经有 IP Pool 创建好，是：192.168.0.0/16

4771e21288234d1bd336ff2f2215cceaa0dc7f51

calicoctl get pool 截图：

当前集群也已经通过使用 calico driver 和 IPAM 创建了不同的 docker network，本次 demo 只需要使用 net1

50db76238f1f1f489e531a4e2a1421372d67197f

docker network ls 截图： 

0ba411f12f6ec56889c89c96cbde6cec9919f012

calicoctl get profile 截图： 

ee4425c80b2319564ff696917cfb6e5ec09a5387



下面我们使用 net1 这个网络，在两台机器上各启动一个容器：

在 calico01 上：

docker run --net net1 --name workload-A -tid busybox

在 calico02 上：

docker run --net net1 --name workload-B -tid busybox


容器连通性测试截图：

52ee26670407a21293b55935d09bfdf5c2808a86

411d263580b12864e12449bf19b1140cbb43a0c7

Demo 2: MacVLAN 二层互联

创建 MacVLAN 网络，分别在两台主机上使用相同命令

docker network create -d macvlan --subnet=192.168.1.0/24 --gateway=192.168.1.1 -o parent=enp0s3 -o macvlan_mode=bridge 192_1

创建容器：

10.1.1.105:

docker run --net=192_1 --ip=192.168.1.168 -id --name test01 busybox sh

10.1.1.106:

docker run --net=192_1 --ip=192.168.1.188 -id --name test11 busybox sh

测试网络连通性：

docker exec test01 ping -c 4 192.168.1.188

411d263580b12864e12449bf19b1140cbb43a0c7

Calico IP 路由实现及 Wireshark 抓包

8573b0444303eb09233be6716e175bec9a7fb512

根据上面这个 Calico 数据平面概念图，结合我们的例子，我们来看看 Calico 是如何实现跨主机互通的：


两台 slave route 截图： 

de3fb18ad2bb8333203874daef205ecd5757a546

9e7a51cfec13cbb4ef18e8608687d14abb1c80f8

对照两台主机的路由表，我们就知道，如果主机 1 上的容器（192.168.147.195）想要发送数据到主机 2 上的容器（192.168.38.195）， 那它就会 match 到响应的路由规则 192.168.38.192/26 via 10.1.1.104，将数据包转发给主机 2，主机 2 在根据 192.168.38.195 dev cali2f648c3dc3f 把数据包发到对应的 veth pair 上，交给 kernel。

那整个数据流就是：

container -> calico01 -> one or more hops -> calico02 -> container

最后，让我们来看看 Wireshark 抓包的截图对比：

Calico： 

4d3d75842d23027b66a5c7437f97052ae3802a7e

4d3d75842d23027b66a5c7437f97052ae3802a7e

MacVLAN： 

66462b9088908febf326a1c89c59ccb36a5c7a6d

从上图对比中也能看出，不同于 MacVLAN，Calico 网络中容器的通信的数据包在节点之间使用节点的 MAC 地址，这样没有额外的 ARP 广播的，这是 Calico 作为三层方案的特点之一。

但这同时也表明了，节点之间网络部分如果想对于容器间通信在二层做 filter 或者控制在 Calico 方案中是不起作用的。

这样，一个简单的跨主机的 Calico 容期间三层通信就 Demo 完了，其他的 Calico 特性这里就一一介绍了，鼓励大家可以自己使用 VMs 搭起来亲自试试，遇到问题随时到 Slack 去聊聊。

Calico 使用场景

Calico 既可以用在公有云，也可以部署在私有环境，我们接下来主要集中讨论下 Calico 在私有云中的使用场景2。

二层网络

Calico 适用于二层网络，原因首先就是不会因为容器数量的变化带来 ARP 广播风暴，上面的 Demo 中，我们已经看出了，Calico 中容器间的相关通信在二层使用的是节点的 MAC 地址， 这样也就是说，广播上的增长只是主机层上的增减，这在数据中心本来就是可控的；其次，就是网络扰动，同样的道理，使用 Calico 也不用担心因为容器的频繁启动停止所带来的网络扰动； 最后，Calico 的 IP 空间使用是相对自由的，这样保证足够的 IP 资源使用。

当然，任何事情都是两面，使用 Calico 要理解，Calico 的 IP 是集群内，也就是说如果需要使用容器 IP 和 外部互联网进行通讯，还需要进行相应的配置。 比如：如果有对外通讯需求，则要开启 nat-outgoing；如果需要对内可达，需要配置和维护对应的路由规则或者通过支持 BGP 的外部交换／路由设备，具体可以参考3。

此外，上面的 Demo 也说明了，如果有需求对容器间通信二层数据包有分析和控制的化，Calico 也是没办法的，这样也就是说如果 DC 已经集成了一些商业网络控制模块或者 SDN，则要通盘考虑， 是否合适引入 Calico。

最后，提一个小点，Calico 的数据存储，需要对每个 calico node 指定唯一标示，默认需要使用 hostname ，也可以在 calicoctl node run 时通过 --name 指定， 如果使用默认的 hostname，就要求在初始化 Calico 集群之前，规划好各个主机的 hostname。

三层网络

Calico 也能使用在三层的网络中，但是相比二层是要复杂，需要更多的 net-eng 介入，个人水平有限，就不展开说了，有兴趣的可以直接参考： http://docs.projectcalico.org/master/reference/private-cloud/l3-interconnect-fabric

总结:

随着容器网络的发展，数人云会越来越多的关注如何把先进的容器网络技术更好的"落地"企业，数人云年底新版本也会加入了适配数人云的 Calico 安装配置手册给最终用户。

我们会一直关注开源，包括 Calico, Cisco Contiv, DPDK等，相信后面各个开源方案都会在易用性、易维护性上继续提升，同时也一定会加强对各个容器编排方案的支持。

回过头看 Calico 的新版本发展，也印证了这些要求：

易用性，兼容 k8s 的 calicoctl UX；

易维护性，Golang 重写；Calico 本身为三层方案，而且Calico 能够兼容二层和三层的网络设计，可以和现有 DC 网络的整合和维护；

更好的和现有方案的集成，包括 OpenStack，CNI／Canal，Mesos 等，Calico 在网络方案的适用性方案还是很有竞争力的；

2016年马上就要过去了，作为容器网络的爱好者使用者，个人希望在 2017 年数人云能将真正成熟稳定的容器网络方案带给大家。


能力所限，文中难免有错误，随时欢迎指正。谢谢！

问答环节

问题1：画网络拓扑图，有什么好用的开源工具么？最好是免费的，开源的(来自:中生代技术(成渝一家)@邹晨-佳网)

答：其实我个人不怎么画网络拓扑图的，不过如果是 windows 以前就是用 Visio，最近画图都用 Gliffy，Chrome 有插件的。如果是放在页面中的动态生成图，建议看看 D3.



问题2：calico有具体的性能数据吗？(来自:中生代技术(西安)- @李钊-ZTE-研发)

答：之前做过简单的性能对比测试，总体来看还是很不错的，具体见图：

03c781772a2dd0d2fcd1e1d3eb2d02ee4382f601

a8bcc21f689b81eec06c3cf3b4bd6fc87a37110c

问题3:遇到问题随时到 Slack 去聊聊，想请教下这个跟slack有什么关系？(来自:中生代技术(成渝一家)@邹晨-佳网)


答：这里指的是 calico 的 slack：https://slack.projectcalico.org/ ，


中生代技术群分享第四十七期

讲师：褚向阳，数人云研发工程师，接触开源及Openstack比较早，曾在红帽PnT（原HSS）部门负责红帽内部工具链的开发及维护工作。现负责数人云的研发工作，对Docker，Mesos有所研究，熟悉和热爱云计算、分布式、SDN等领域相关技术。

如果您发现本社区中有涉嫌抄袭的内容，欢迎发送邮件至：yqgroup@service.aliyun.com 进行举报，并提供相关证据，一经查实，本社区将立刻删除涉嫌侵权内容。