

* [非技术咖眼中： Kubernetes 为什么那么重要？ - V2EX ](https://www.v2ex.com/t/296769)
* [非技术咖眼中：Kubernetes为什么那么重要？ - DockOne.io ](http://dockone.io/article/1207)


* Kubernetes改进应用程序开发
  * 容器将应用环境封装，从应用程序开发者和基础设施层面抽象掉很多机器和操作系统的细节
  * 管理API从面向机器转到面向应用程序
  * 应用程序API的转换可以让团队无需担心机器和操作系统的细节特性
  * 程序建立在pod，ReplicationsSets, 部署，服务之类的概念之上
* 不同的任务角色
  * 开发者Developers
    * 创建通用的应用
    * 使用集群本质的属性来完成任何应用的特定需求
  * 运维Devops
    * Deployments, replicaSets, Service帮助减轻运维
  * 管理员Admins
    * Heapster或cAdvisor获得访问权和流程容器资源
    * 检查集群的事件，API请求，检测数据，和利用Kubedash