

# 9 防火墙与 NAT 服务器

## 9.3 Linux 的封包过滤软件： iptables

### 9.3.1 不同 Linux 核心版本的防火墙软件

查看核心`uname -r`

### 9.3.2 封包进入流程：规则顺序的重要性！

* iptables
  * 利用封包过滤的机制
  * 根据表头数据与定义的“规则”来决定该封包是否可以进入主机
  * 根据封包的分析资料`对比`预先定义的规则内存，如果相同则执行，否则继续下一条规则对比
  * 规则是有顺序的
  * 所有的规则都不符合，就会透过预设动作（封包策略，Policy）来决定这个封包的去向
  * 当规则顺序排列错误时，就会产生很严重的错误

### 9.3.3 iptables 的表格 (table) 与链 (chain)

* iptables表格
  * 管理本机进出的filter：开放客户端WWW响应，需要处理filter的INPUT链
  * 管理后端主机的nat（防火墙内部的其他主机）：作为局域网的路由器，要分析nat的各个链及filter的FORWARD链
  * 管理特殊旗标使用的mangle
  * 自定义额外的链
* filter（过滤器）
  * INPUT：进入主机的封包相关
  * OUTPUT：主机要发送的封包有关
  * FORWARD：传递封包
* nat（地址转换）Network Address Translation：来源与目的IP或port的转换
  * PREROUTING：路由判断前进行的规则（DNAT/REDIRECT）
  * POSTROUTING：路由判断后进行的规则（SNAT/MASQUERADE）
  * OUTPUT：发送的封包
* mangle（破坏者）
* 封包流向
  * 封包进入Linux主机使用资源：透过filter的INPUT链
  * 封包经由Linux主机转递，没有使用主机资源，向后端主机流动：经过filter的FORWARD以及nat的POSTROUTING、PREROUTING
  * 封包由Linux主机发送出去：透过filter的OUTPUT链传送，最终经过nat的POSTROUTING

### 9.3.4 本机的 iptables 语法  