

* Kubernetes的目标是像管理牲畜一样管理服务，而不是像宠物那样需要细心的照顾。
  * 随机关掉一台机器，检查服务能否正常工作；
  * 减少应用的实例，检查实例是否自动迁移并恢复到其他节点；
  * 检查服务是否随着流量进行自动伸缩
* Master四个组件
  * etcd
    * 配置中心，保存所有组件的定义以及状态
  * kube-apiserver
    * 提供同外部交互的接口
    * 提供安全机制
  * kube-scheduler
    * 监听etcd中的pod目录变更
    * 调度算法分配node
  * kube-controller-manager
    * 管理node, pod, replication, service, namespace
    * 监听etcd /registry/events对应的事件，进行处理
* agent两个组件
  * kubelet
    * 容器管理，镜像管理
  * kube-proxy
    * 实现service机制
    * 提供一部分SDN功能以及集群内部的LoadBalance