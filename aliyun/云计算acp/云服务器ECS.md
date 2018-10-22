1. https://help.aliyun.com/product/25365.html


# 1. 产品简介
## 1.1 什么是云服务器ECS
https://help.aliyun.com/document_detail/25367.html
[地域和可用区](https://help.aliyun.com/document_detail/40654.html)
> 地域是指物理的数据中心。可用区是指在同一地域内，电力和网络互相独立的物理区域。
* 地域是指物理的数据中心。资源创建成功后不能更换地域。
> 可用区
* 可用区是指在同一地域内，电力和网络互相独立的物理区域。同一可用区内实例之间的网络延时更小。
* `在同一地域内可用区与可用区之间内网互通，可用区之间能做到故障隔离`。是否将实例放在同一可用区内，主要取决于对容灾能力和网络延时的要求。
* 如果您的应用需要较高的容灾能力，建议您将实例部署在同一地域的不同可用区内。
* 如果您的应用要求实例之间的网络时延较低，则建议您将实例创建在同一可用区内。
## 1.2 云服务器ECS的优势
https://help.aliyun.com/document_detail/51704.html

|对比项  |云服务器                              |传统IDC                               |
|-------|--------------------------------------|-------------------------------------|
|容灾备份|多份数据副本，单份损坏可在短时间内快速恢复|用户自行搭建，使用传统存储设备，价格高昂|
|       |用户自定义快照                          |没有提供快照功能，无法做到自动故障恢复 |
|       |快速自动故障恢复	                     |数据损坏需用户自己修复                |
## 1.3 应用场景
https://help.aliyun.com/document_detail/25371.html
## 1.5 实例
### 1.5.2 实例生命周期
https://help.aliyun.com/document_detail/25380.html
状态	状态属性	API的对应状态
准备中	中间状态	Pending
启动中	中间状态	Starting
运行中	稳定状态	Running
停止中	中间状态	Stopping
已停止	稳定状态	Stopped
已过期	`稳定状态`	Stopped
即将过期	稳定状态	Stopped
已锁定	`稳定状态`	Stopped
等待释放	稳定状态	Stopped
## 1.7 网络和安全性 
### 1.6.4 专有网络的IP
https://help.aliyun.com/document_detail/44441.html
### 1.7.8 安全组
https://help.aliyun.com/document_detail/25387.html
安全组是一个逻辑上的分组，这个分组是由同一个地域（Region）内具有相同安全保护需求并相互信任的实例组成。`每个实例至少属于一个安全组`，在创建的时候就需要指定。`同一安全组内的实例之间默认私网网络互通，不同安全组的实例之间默认私网不通。可以授权两个安全组之间互访`。
每个用户在每个地域最多可创建100个安全组，并可以根据用户会员等级的提高而增加。
一个实例中的每个弹性网卡都默认最多可以加入5个安全组。
> 安全组规则和限制
  * 安全组规则可以允许或者禁止安全组内的云服务器ECS实例的公网和内网的入出方向的访问。
  * `您可以随时添加和取消安全组规则`。您的安全组规则变更会自动应用于安全组内的ECS实例上。
### 1.7.10 DDoS基础防护
https://help.aliyun.com/document_detail/55256.html
> 在使用DDoS基础防护时，您需要设置以下阈值：
  * BPS(每秒处理的流量值)清洗阈值：当入方向流量超过BPS清洗阈值时，会触发流量清洗。
  * PPS(每秒处理的报文数量)清洗阈值：当入方向数据包数超过PPS清洗阈值时，会触发流量清洗。
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
## 5.2 ECS 使用须知
https://help.aliyun.com/document_detail/25430.html
> Linux 操作系统须知
  * 不要修改 Linux 实例默认的 /etc/issue 文件内容。否则，根据实例创建的自定义镜像的系统发行版本无法被正确识别，使用该镜像创建的实例无法正常启动。
  * 不要随意更改根目录所在分区下各个目录的权限，尤其是 /etc、/sbin、/bin、/boot、/dev、/usr和 /lib 等目录的权限。如果权限更改不当会导致系统出现异常。
  * 不要重命名、删除或禁用 Linux下的 root 账号。
  * 不要编译 Linux 系统的内核，或对内核进行任何其他操作。
  * 如果您使用普通云盘，不建议使用 swap 分区。如果是高效云盘或 SSD 云盘，可以根据实际情况使用 swap 分区。
  * `不要开启 NetWorkManager 服务。该服务会跟系统内部网络服务出现冲突，导致网络异常`。
  * 请谨慎使用root等管理账号进行fio、mkfs、fsck、扩容等操作，避免误操作引起的数据受损。
## 5.4 实例
### 5.4.1 创建实例
* 使用自定义镜像创建实例
https://help.aliyun.com/document_detail/25465.html
### 5.4.5 升降配
1. [升降配概述](https://help.aliyun.com/document_detail/25437.html)
> 预付费：
* 升级实例配置：使用 预付费实例升级配置 功能随时升级实例规格。`操作完成后，您必须 重启实例 或使用 RebootInstance 接口重启实例，新配置才能生效`。适用于包年包月实例和按周付费实例。
* 降低实例配置：使用 续费降配 功能，在续费的同时降低实例规格。进入新计费周期后，您需要在7天内在控制台 重启实例 使新的实例规格生效。适用于包年包月实例和按周付费实例。
> 按量付费：
* 使用 按量付费实例变更实例规格 功能修改按量付费实例的配置。您必须先停止实例才能使用这个功能。
3. [按量付费实例变更实例规格](https://help.aliyun.com/document_detail/60051.html)
> 变更按量付费实例的规格有以下限制：
* 两次变更操作之间的间隔不得少于5分钟。
* `不支持实例规格族内或规格族之间变更的包括`：d1、d1ne、i1、i2、ga1、gn5、f1、f2、f3、ebmc4、ebmg5、sccg5和scch5。`支持变更的规格族以及变配规则请参见 变配规格表`
4. [临时升级带宽](https://help.aliyun.com/document_detail/59717.html)
### 5.4.10 释放实例
https://help.aliyun.com/document_detail/25442.html
### 5.4.12 修改IP地址
1. [修改私有IP地址_修改IP地址](https://help.aliyun.com/document_detail/27733.html)
> 您可以`直接修改专有网络中ECS实例的私网IP`，也可以通过`更改ECS实例所属的交换机`来更改ECS实例的私网IP。
> 操作
* 在目标实例的 操作 列中，单击 更多 > 停止。
* `实例停止运行`后，单击目标实例的ID，进入 实例详情 页面。
* 在 配置信息 区域，单击 更多 > 修改私网IP。
* 在 修改私网IP 对话框，选择要更换的交换机，然后单击 修改
2. [更换公网IP地址](https://help.aliyun.com/document_detail/67236.html)
> 要访问公网，需要开启公网带宽或者绑定EIP。
> 更换分配的公网IP地址有以下限制：
* 实例必须分配了公网IP地址，即在 实例列表 里，实例的 IP地址 列会显示公网IP地址
* 如果在创建预付费实例时未分配公网IP地址，实例创建成功后，您可以通过`升降公网带宽配置分配公网IP地址`，更多信息，请参考 升降配概述
* 如果在创建按量付费实例时未分配公网IP地址，实例创建成功后，`无法再分配公网IP地址，只能 绑定弹性公网IP（EIP）地址`
## 5.6 云盘
### 5.6.2 用快照创建云盘
https://help.aliyun.com/document_detail/32317.html
* 新建的高效云盘和SSD云盘，一旦创建成功便可以达到其容量所对应的最高性能，不需要预热的过程。但是，因为快照存储在对象存储（OSS）里，使用快照创建云盘时，ECS需要从OSS取回数据并写入到云盘，这个过程需要一段时间，而且会造成首次访问时性能下降。建议您在正式使用这类云盘前，先读取云盘上所有数据块，从而避免初期的性能下降。
* 用快照创建磁盘
### 5.6.3 挂载云盘
https://help.aliyun.com/document_detail/25446.html
> 在挂载云盘前，您需要了解以下注意事项：
  * 随实例一起创建的云盘，不需要执行挂载操作。
  * 您只能挂载作数据盘用的云盘，不需要挂载作系统盘用的云盘。
  * 挂载云盘时，实例必须满足以下条件：
  * 实例状态必须为 `运行中（Running）或者 已停止（Stopped），不能为 已锁定（Locked）`。
  * 实例不欠费。
  * 挂载云盘时，云盘的状态必须为 `待挂载（Available）`。
  * 云盘只能挂载到同一地域下同一可用区内的实例上，不能跨可用区挂载。
  * 一台ECS实例最多能挂载16块云盘作数据盘用，同一时刻，一块云盘只能挂载到一个台实例上。
  * 独立创建的云盘能挂载到同一地域下同一可用区的任意实例上（包括预付费和按量付费的实例）。
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
### 5.7.5 删除快照和自动快照策略
https://help.aliyun.com/document_detail/25458.html
> 说明
  * 快照删除后，不能用任何方法恢复。请谨慎操作。
  * 如果快照用于制作自定义镜像，需要先删除关联的镜像，然后才能删除。
### 5.7.6 查看快照容量
https://help.aliyun.com/document_detail/54789.html
## 5.8 镜像
### 5.8.1 创建自定义镜像
1. [使用快照创建自定义镜像](https://help.aliyun.com/document_detail/25460.html)
您可以使用快照创建自定义镜像，将快照的操作系统、数据环境信息完整的包含在镜像中。然后使用自定义镜像创建多台具有相同操作系统和数据环境信息的实例，非常方便的复制实例
快照 -> 镜像 -> 实例
2. [使用实例创建自定义镜像](https://help.aliyun.com/document_detail/35109.html)
## 5.9 安全组
### 5.9.4 创建安全组
https://help.aliyun.com/document_detail/25468.html
* `一台ECS实例必须至少属于一个安全组`。
* VPC里的安全组，可以跨交换机，但是不能跨VPC。
## 5.15 运维与监控
### 5.15.1 监控
https://help.aliyun.com/document_detail/25482.html
目前，您可以`通过ECS自带监控服务和云监控服务监控实例`。ECS自带监控服务提供`vCPU使用率、网络流量和磁盘I/O监控`。云监控提供更加精细化的监控粒度，更多详情，请参阅监控项说明。
# 6. 最佳实践
## 6.1 安全
### 6.1.4 ECS数据安全最佳实践
https://help.aliyun.com/document_detail/51404.html
### 6.1.5 如何提高ECS实例的安全性
https://help.aliyun.com/document_detail/51849.html
* 一般可以通过设置安全组、AntiDDoS、态势感知、安装安骑士、接入Web应用防火墙等方式提高ECS实例的安全性。
> AntiDDoS
  * 阿里云云盾可以防护`SYN Flood，UDP Flood，ACK Flood，ICMP Flood，DNS Flood，CC攻击等3到7层DDoS的攻击`
  * DDoS基础防护免费为阿里云用户提供最高5G的默认DDoS防护能力。
# 8. API 参考 
## 8.3 快速入门
### 8.3.2 请求结构
https://help.aliyun.com/document_detail/25489.html
> https://ecs.aliyuncs.com/?Action=CreateSnapshot&DiskId=1033-60053321&<公共请求参数>
  * https指定了请求通信协议。
  * ecs.aliyuncs.com指定了ECS的服务接入地址（Endpoint）。
  * Action=CreateSnapshot指定了要调用的API，DiskId=1033-60053321是CreateSnapshot规定的参数。
  * <公共请求参数>是系统规定的公共参数。
### 8.3.5 返回结果
> https://help.aliyun.com/document_detail/25491.html
  * 返回结果主要有 `XML 和 JSON` 两种格式，`默认为 XML`，您可以指定公共请求参数 Format 变更返回结果的格式。更多详情，请参阅 公共参数。为了便于查看和美观，API 文档返回示例均有换行和缩进等处理，实际返回结果无换行和缩进处理。
## 8.7 磁盘
### 8.7.4 AttachDisk
> 调用该接口时，您需要注意：
  * 待挂载的ECS实例的状态必须为运行中（Running）或者已停止（Stopped）。
  * 挂载数据盘时，云盘的状态必须为待挂载（Available）。
  * 必须三个字段：Action、InstanceId、DiskId
## 8.8 镜像
### 8.8.1 CreateImage
https://help.aliyun.com/document_detail/25535.html
> 通过这种方法创建自定义镜像时，您需要注意：
  * 只能指定一个系统盘快照，`系统盘的设备名必须为/dev/xvda`。
  * 可以指定多个数据盘快照，`数据盘设备名默认由系统有序分配，从/dev/xvdb依次排序到/dev/xvdz，不能重复`。
# 10. 常见问题
## 10.2 功能相关
### 10.2.2 块存储
1. [ECS云服务器磁盘FAQ](https://help.aliyun.com/knowledge_detail/40558.html)
> 云服务器磁盘I/O速度是多少？
* 普通云盘写一般在 20-30MB/s，读一般在 80-100MB/s。
* 本地SSD盘512KB顺序读写应用，可提供高达300MB/s的吞吐量能力。
> Linux 购买了数据盘，但是系统中看不到怎么办？
* Linux 数据需要分区-格式化-挂载后才能使用和看到空间，挂载数据盘参考 格式化和挂载数据盘。
2. [ECS系统盘和数据盘二次分区FAQ](https://help.aliyun.com/knowledge_detail/40566.html)
> 系统盘能否再次划分出一个分区用作数据存储？
出于系统安全和稳定性考虑，`阿里云官方不支持系统盘二次分区`，不管是Windows还是Linux。`如果用户强行使用第三方工具进行二次分区操作，可能引发未知风险`，如系统崩溃，数据丢失等。
### 10.2.4 镜像
https://help.aliyun.com/knowledge_detail/40609.html
> 使用自定义镜像创建ECS实例时，以下原因会导致挂载磁盘失败：
  * 创建的实例没有数据盘
  * 数据盘是新磁盘，还没有进行分区格式化
  * 创建的自定义镜像没有去除/etc/fstab中磁盘挂载的条目
### 10.2.5 安全组
1. [安全组使用 FAQ](https://help.aliyun.com/knowledge_detail/40570.html)
> 什么是安全组？
* 安全组是一种虚拟防火墙。用于设置单台或多台云服务器的网络访问控制，它是重要的网络安全隔离手段，您可以在云端划分安全域。
* `每个实例至少属于一个安全组`，在创建的时候就需要指定。`同一安全组内的实例之间网络互通，不同安全组的实例之间默认内网不通，可以授权两个安全组之间互访`。
### 10.2.6 网络 
[BGP机房介绍](https://help.aliyun.com/knowledge_detail/40677.html)
使用BGP协议互联后，网络运营商的所有骨干路 由设备将会判断到IDC机房IP段的最佳路由，以保证不同网络运营商用户的高速访问
### 10.2.9 云助手FAQ
10. 执行记录存在哪些执行状态？
> 单次命令在一台实例上存在以下4种状态：
  * 执行中（Running）：命令正在目标实例中执行，或等待周期性计划执行。
  * 手动停止（Stopped）：您主动停止命令执行后产生的状态。
  * 执行完成（Finished）：命令在目标实例上执行完成，不代表执行结果成功与否。
  * 执行失败（Failed）：命令进程过了超时时间后，因为各种原因未执行完成。
> 单次命令在多台实例上存在以下5种状态：
  * 执行中（Running）：至少有一台实例在执行中。
  * 手动停止（Stopped）：所有实例均在`稳定状态`，且都是手动停止。
  * 执行完成（Finished）：所有实例均在稳定状态，且都是执行完成或停止。
  * 执行失败（Failed）：所有实例均在稳定状态，且都是执行失败。
  * 部分失败（PartialFailed）：所有实例均在稳定状态，且有部分是执行失败。
> 周期命令存在以下2种状态：
  * 周期执行中（Running）：至少有一台实例等待周期性命令执行或正在执行。
  * 手动停止（Stopped）：所有实例均在稳定状态，且都是手动停止。
## 10.3 操作运维Linux
### 10.3.4 远程登录SSH
1. [云服务器 ECS Linux SSH 无法远程登录问题排查指引](https://help.aliyun.com/knowledge_detail/41470.html)
2. [SSH 无法远程登录问题的处理思路](https://help.aliyun.com/knowledge_detail/52955.html)
### 10.3.6 系统配置
1. [如何避免升级 Linux 实例内核后无法启动](https://help.aliyun.com/knowledge_detail/59360.html)
  * 阿里云`不建议随意自行升级内核`，请参阅文档 ECS使用须知。
## 10.4 操作运维Windows
### 10.4.1 操作系统类问题
1. [配置 Windows 系统虚拟内存](https://help.aliyun.com/knowledge_detail/40995.html)
  * `增加虚拟内存会导致磁盘I/O性能下降`。如果您的云服务器ECS内存资源不足，如非必要，阿里云建议您通过升级实例规格（CPU + 内存）来解决。
# 11 APP用户指南
## 11.4 快照
### 11.4.2 回滚云盘
https://help.aliyun.com/document_detail/50511.html
> 回滚磁盘前必须确认以下信息：
  * 您已经为云盘 创建了快照，而且要回滚的云盘当前没有正在创建的快照。
  * 云盘未被释放。
  * `云盘必须已经 挂载到某台ECS实例上，而且已经 停止实例`。