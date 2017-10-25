* [Borg, Omega和Kubernetes：谷歌十几年来从这三个容器管理系统中得到的经验教训 ](https://mp.weixin.qq.com/s?__biz=MzIzMzExNDQ3MA==&mid=402412524&idx=1&sn=61962944124a5372e7c105c1c6d16a9e&scene=21#wechat_redirect)

* Google三个容器管理系统
  * Borg
  * Omega
  * Kubernetes
* Borg
  * 长时间运行的生产服务和批处理服务
  * 对时限敏感的、且面对用户的服务和占用很多CPU资源的批处理进行提供了更好的隔离
  * 提供的功能
    * 配置和更新Job的机制
    * 能够预测资源需求
    * 动态地对在运行中的程序推送配置文件
    * 服务发现
    * 负载均衡
    * 自动扩容
    * 机器生命周期的管理
    * 额度管理
* Omega
  * 提升Borg生态系统软件工程
  * 基于Paxos存储
* Kubernetes
  * 针对Linux容器技术的开发者
  * 谷歌在公有云底层商业增长的考虑
* 容器
  * root file system隔离chroot
  * process id隔离namespaces
  * Linux control groups, cgroups
  * 容器的资源隔离特性对系统的资源使用率提升
* 面向应用的架构
  * 容器封装了应用环境，把很多机器和操作系统的细节从应用开发者和部署底层那里抽象出来
  * 因为涉及良好的容器和镜像的作用范围是一个很小的应用，因此管理容器意味着管理应用而非机器
* 应用环境
  * 