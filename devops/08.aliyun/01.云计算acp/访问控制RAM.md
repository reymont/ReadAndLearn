
1. https://help.aliyun.com/product/28625.html

# 1. 产品简介
## 1.1 什么是RAM
https://help.aliyun.com/document_detail/28627.html
RAM 允许在一个云账户下创建并管理多个用户身份，并允许给单个身份或一组身份（Identity）分配不同的授权策略（Policy），从而实现不同用户拥有不同的云资源访问权限。
> 云账户 vs RAM 用户
* 从 归属关系 上看，云账户与 RAM 用户是一种主子关系。
  * 云账户是阿里云资源归属、资源使用计量计费的基本主体。
  * RAM 用户只能存在于某个云账户下的 RAM 实例中。RAM 用户不拥有资源，在被授权操作时所创建的资源归属于主账户；RAM 用户不拥有账单，被授权操作时所发生的费用也计入主账户账单。
* 从 权限角度 看，云账户与 RAM 用户是一种 root 与 user 的关系（类比 Linux系统）。
  * Root 对资源拥有一切操作控制权限。
  * User 只能拥有被 root 所授予的某些权限，而且 root 在任何时刻都可以撤销 user 身上的权限。