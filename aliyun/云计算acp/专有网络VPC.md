

1. https://help.aliyun.com/product/27706.html

# 3. 用户指南
## 3.1 管理专有网络
https://help.aliyun.com/document_detail/65398.html
路由器和交换机是VPC的两个基础组件：
* 路由器（VRouter）可以连接VPC内的各个交换机，同时也是连接VPC和其他网络的网关设备。每个专有网络创建成功后，系统会自动创建一个路由器。每个路由器关联一张路由表。详情参见路由。
* 交换机（VSwitch）是组成专有网络的基础网络设备，用来连接不同的云产品实例。创建专有网络之后，您可以通过创建交换机为专有网络划分一个或多个子网。您可以将应用部署在不同可用区的交换机内，提高应用的可用性。同一个VPC内不同可用区的交换机默认内网互通。详情参见管理交换机。

## 3.4 路由表
https://help.aliyun.com/document_detail/87057.html

# 4. 最佳实践
## 4.6 经典网络迁移到VPC
### 4.6.1 网络规划
https://help.aliyun.com/document_detail/54095.html
### 4.6.5 ECS实例迁移
https://help.aliyun.com/document_detail/57954.html
# 5. API参考
1. https://help.aliyun.com/document_detail/34964.html

# 8. 老版控制台操作文档 
## 8.2 用户指南 
### 8.2.3 管理路由表
https://help.aliyun.com/document_detail/53682.html
1. 路由器是专有网络的枢纽。作为专有网络中重要的功能组件，`它可以连接VPC内的各个交换机`，同时也是连接VPC与其它网络的网关设备。
2. `您不可以直接创建或删除路由器和路由表`。当您删除了一个VPC后，系统会将该VPC关联的路由器和路由表删除。
3. `创建VPC时，系统会自动为VPC创建一个路由器和一个路由表`。路由表中的每一项是一条路由条目，路由条目定义了通向指定目标网段的网络流量的下一跳地址。`路由表根据具体的路由条目的设置来转发网络流量`。