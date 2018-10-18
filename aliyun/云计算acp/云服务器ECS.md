1. https://help.aliyun.com/product/25365.html


# 1. 产品简介
## 1.1 什么是云服务器ECS
https://help.aliyun.com/document_detail/25367.html
## 1.2 云服务器ECS的优势
https://help.aliyun.com/document_detail/51704.html

|对比项  |云服务器                              |传统IDC                               |
|-------|--------------------------------------|-------------------------------------|
|容灾备份|多份数据副本，单份损坏可在短时间内快速恢复|用户自行搭建，使用传统存储设备，价格高昂|
|       |用户自定义快照                          |没有提供快照功能，无法做到自动故障恢复 |
|       |快速自动故障恢复	                     |数据损坏需用户自己修复                |
## 1.3 应用场景
https://help.aliyun.com/document_detail/25371.html
## 1.6 网络和安全性
### 1.6.4 专有网络的IP
https://help.aliyun.com/document_detail/44441.html
## 1.7 网络和安全性 
### 1.7.8 安全组
https://help.aliyun.com/document_detail/25387.html
每个用户在每个地域最多可创建100个安全组，并可以根据用户会员等级的提高而增加。
一个实例中的每个弹性网卡都默认最多可以加入5个安全组。
## 1.8 快照
### 1.8.1 快照概述
https://help.aliyun.com/document_detail/25391.html
### 1.8.2 原理介绍
https://help.aliyun.com/document_detail/25392.html
每块磁盘的第一份快照是全量快照，耗时较长。之后再对同一块磁盘创建快照时，都是增量快照，耗时较短。创建一份快照需要的时间取决于需要备份的数据量。
### 1.8.5 应用场景
https://help.aliyun.com/document_detail/25395.html
### 1.8.6 快照服务费用细则（按量后付费）
https://help.aliyun.com/document_detail/56159.html
# 2. 产品定价
## 2.3 按量付费
https://help.aliyun.com/knowledge_detail/40653.html
# 5. 用户指南
## 5.4 实例
### 5.4.1 创建实例
* 使用自定义镜像创建实例
https://help.aliyun.com/document_detail/25465.html
### 5.4.5 升降配
3. [按量付费实例变更实例规格](https://help.aliyun.com/document_detail/60051.html)
> 变更按量付费实例的规格有以下限制：
* 两次变更操作之间的间隔不得少于5分钟。
* `不支持实例规格族内或规格族之间变更的包括`：d1、d1ne、i1、i2、ga1、gn5、f1、f2、f3、ebmc4、ebmg5、sccg5和scch5。`支持变更的规格族以及变配规则请参见 变配规格表`
5. [临时升级带宽](https://help.aliyun.com/document_detail/59717.html)
### 5.4.10 释放实例
https://help.aliyun.com/document_detail/25442.html
### 5.4.12 修改IP地址
1. [修改私有IP地址_修改IP地址](https://help.aliyun.com/document_detail/27733.html)
您可以`直接修改专有网络中ECS实例的私网IP`，也可以通过`更改ECS实例所属的交换机`来更改ECS实例的私网IP。
> 操作
* 在目标实例的 操作 列中，单击 更多 > 停止。
* 实例停止运行后，单击目标实例的ID，进入 实例详情 页面。
* 在 配置信息 区域，单击 更多 > 修改私网IP。
* 在 修改私网IP 对话框，选择要更换的交换机，然后单击 修改
## 5.6 云盘
### 5.6.2 用快照创建云盘
https://help.aliyun.com/document_detail/32317.html
新建的高效云盘和SSD云盘，一旦创建成功便可以达到其容量所对应的最高性能，不需要预热的过程。但是，因为快照存储在对象存储（OSS）里，使用快照创建云盘时，ECS需要从OSS取回数据并写入到云盘，这个过程需要一段时间，而且会造成首次访问时性能下降。建议您在正式使用这类云盘前，先读取云盘上所有数据块，从而避免初期的性能下降。

### 5.6.10 更换系统盘
https://help.aliyun.com/document_detail/50134.html
> 更换系统盘后，
* 您的实例会被分配一个新的系统盘，系统盘ID会更新，原系统盘被释放。
* 系统盘的云盘类型不能更换。
* 实例的`IP地址和MAC地址不变`。
* 为了保证有足够的快照额度完成新系统盘的自动快照策略，您可以 删除不需要的旧系统盘快照。
> 更换系统盘存在如下风险：
* 更换系统盘需要`停止实例`，因此会中断您的业务。
* 更换完成后，您需要在新的系统盘中重新部署业务运行环境，有可能会对您的业务造成长时间的中断。
* 更换系统盘相当于重新为您的实例分配了一个系统盘，磁盘ID会改变，所以基于旧的系统盘创建的快照将不能用于回滚新的系统盘
> 跨操作系统更换时，数据盘的文件系统格式可能会无法识别。
* Windows系统更换为Linux系统：需要单独安装软件识别，例如NTFS-3G等，因为Linux缺省情况下无法识别NTFS格式。
* Linux系统更换为Windows系统：需要单独安装软件识别，例如Ext2Read、Ext2Fsd等，因为Windows卸省情况下无法识别ext3、ext4、XFS等文件系统格式。
## 5.7 快照
### 5.7.3 为磁盘设置自动快照策略
https://help.aliyun.com/document_detail/25457.html
自动快照的命名格式为：auto_yyyyMMdd_1，比如 auto_20140418_1
### 5.7.6 查看快照容量
https://help.aliyun.com/document_detail/54789.html
## 5.8 镜像
### 5.8.1 创建自定义镜像
[使用快照创建自定义镜像](https://help.aliyun.com/document_detail/25460.html)
您可以使用快照创建自定义镜像，将快照的操作系统、数据环境信息完整的包含在镜像中。然后使用自定义镜像创建多台具有相同操作系统和数据环境信息的实例，非常方便的复制实例
快照 -> 镜像 -> 实例
## 5.9 安全组
### 5.9.4 创建安全组
https://help.aliyun.com/document_detail/25468.html
* `一台ECS实例必须至少属于一个安全组`。
* VPC里的安全组，可以跨交换机，但是不能跨VPC。
# 6. 最佳实践
## 6.1 安全
### 6.1.4 ECS数据安全最佳实践
https://help.aliyun.com/document_detail/51404.html
### 6.1.5 如何提高ECS实例的安全性
https://help.aliyun.com/document_detail/51849.html
* 一般可以通过设置安全组、AntiDDoS、态势感知、安装安骑士、接入Web应用防火墙等方式提高ECS实例的安全性。
* DDoS基础防护免费为阿里云用户提供最高5G的默认DDoS防护能力。
# 10. 常见问题
## 10.2 功能相关
### 10.2.6 网络 
[BGP机房介绍](https://help.aliyun.com/knowledge_detail/40677.html)
使用BGP协议互联后，网络运营商的所有骨干路 由设备将会判断到IDC机房IP段的最佳路由，以保证不同网络运营商用户的高速访问
## 10.3 操作运维Linux
### 10.3.4 远程登录SSH
1. [云服务器 ECS Linux SSH 无法远程登录问题排查指引](https://help.aliyun.com/knowledge_detail/41470.html)
2. [SSH 无法远程登录问题的处理思路](https://help.aliyun.com/knowledge_detail/52955.html)
