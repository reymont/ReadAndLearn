

容器网络 Calico 进阶实践 - 推酷 
https://www.tuicool.com/articles/RVba2yr


Calico 是一个三层的数据中心网络方案，而且方便集成 OpenStack 这种 IaaS 云架构，能够提供高效可控的 VM、容器、裸机之间的通信。

Calico 的核心组件：
* Felix，Calico agent，跑在每台需要运行 workload 的节点上，主要负责配置路由及 ACLs 等信息来确保 endpoint 的连通状态；
* etcd，分布式键值存储，主要负责网络元数据一致性，确保 Calico 网络状态的准确性；
* BGP Client(BIRD), 主要负责把 Felix 写入 kernel 的路由信息分发到当前 Calico 网络，确保 workload 间的通信的有效性；
* BGP Route Reflector(BIRD), 大规模部署时使用，摒弃所有节点互联的 mesh 模式，通过一个或者多个 BGP Route Reflector 来完成集中式的路由分发；

* 原理
  * 通过将整个互联网的可扩展 IP 网络原则压缩到数据中心级别
  * Calico 在每一个计算节点利用 Linux kernel 实现了一个高效的 `vRouter` 来`负责数据转发 `
  * 每个 vRouter 通过 BGP 协议负责把自己上运行的 workload 的`路由信息向整个 Calico 网络内传播`
  * 小规模部署可以直接互联，大规模下可通过指定的 BGP route reflector 来完成。
  * Calico 基于 iptables 还提供了丰富而灵活的网络 policy, 
  * 保证通过各个节点上的 ACLs 来提供 workload 的多租户隔离、安全组以及其他可达性限制等功能

http://edgedef.com/docker-networking.html 
http://dockone.io/article/1489

* Canal
  * 面向 CNI 的基于访问控制的容器网络方案
  * Container Network Interface CNI 容器网络 spec 是由 CoreOS 提出的，被 Mesos， Kubernetes 以及 rkt 等接受引入 使用
  * 主推 Canal 将 Calico 的 policy 功能加入到 Flannel 的网络中，为和 k8s 的网络提供更好的 ACL 控制