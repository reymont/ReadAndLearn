
* [自动化运维工具Ansible详细部署 - 人生理想在于坚持不懈 - 51CTO技术博客 ](http://sofar.blog.51cto.com/353572/1579894)

* ansible
  * 集合众多运维工具的优点（puppet, cfengine, chef, func, fabric）
  * 批量系统配置、批量程序部署、批量运行命令
  * 基于模块工作，本身没有批量部署的能力
  * 批量部署能力由ansible运行的模块提供
* 框架
  * 连接插件connection plugins：负责和被监控端实现通信
  * host inventory：配置文件里定义监控的主机
  * 核心模块、command模块、自定义模块
  * 借助于插件完成记录日志邮件等功能
  * playbook：剧本执行多个任务时，可让节点一次性运行多个任务
* 特性
  * no agents：不需要在被管控主机上安装任何客户端；
  * no server：无服务器端，使用时直接运行命令即可；
  * modules in any languages：基于模块工作，可使用任意语言开发模块；
  * yaml，not code：使用yaml语言定制剧本playbook；
  * ssh by default：基于SSH工作；
  * strong multi-tier solution：可实现多级指挥。