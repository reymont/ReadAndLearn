

* [使用Telepresence在本地构建和测试Kubernetes应用程序 ](http://www.infoq.com/cn/news/2017/10/kubernetes-telepresence)
http://www.infoq.com/news/2017/10/kubernetes-telepresence

https://github.com/datawire/telepresence
https://www.telepresence.io

* telepresence
  * 借助Telepresence，在本地编写并运行服务，其他的都运行在远程Kubernetes集群上
  * 通过一个双向代理，该服务透明的集成所依赖的远程服务
  * 本地服务拥有远程集群的全部访问权限，反之亦然
  * 在Kubernetes上，每次代码变更，都得走一遍容器构建/部署流程，开发/调试周期比较长
* 纳入kubernetes整个软件开发生命周期
  * 基本的Kubernetes SDLC想成“编码、（金丝雀）部署、监控”
  * 在编码阶段，你得编写并测试服务，Telepresence可以提高你在那个阶段的生产力
  * Kubernetes有望成为类似POSIX（POSIX是云基础设施的交互操作标准）云版本
  * 最近发布的DC/OS Kubernetes
* CNCF
  * Kubernetes
  * Envoy
  * Prometheus
  * Docker
* 调度平台
  * Docker
  * Red Hat OpenShift [minishift](https://github.com/minishift/minishift)
  * Apache Mesos [minimesos](https://www.minimesos.org/)
