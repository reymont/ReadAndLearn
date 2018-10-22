1. https://help.aliyun.com/product/27537.html

# 2. 产品简介
## 2.1 什么是负载均衡
https://help.aliyun.com/document_detail/27539.html
> 负载均衡由以下三个部分组成：
  * 负载均衡实例 （Server Load Balancer instances）
    * 一个负载均衡实例是一个运行的负载均衡服务，用来接收流量并将其分配给后端服务器。要使用负载均衡服务，您必须创建一个负载均衡实例，并至少添加一个监听和两台ECS实例。
  * 监听 （Listeners）
    * 监听用来检查客户端请求并将请求转发给后端服务器。监听也会对后端服务器进行健康检查。
  * 后端服务器（Backend Servers）
    * 一组接收前端请求的ECS实例。您可以单独添加ECS实例到服务器池，也可以通过虚拟服务器组或主备服务器组来批量添加和管理。
## 2.2 基础架构
https://help.aliyun.com/document_detail/27544.html
阿里云当前提供四层（TCP协议和UDP协议）和七层（HTTP和HTTPS协议）的负载均衡服务。
* 四层采用开源软件LVS（Linux Virtual Server）+ keepalived的方式实现负载均衡，并根据云计算需求对其进行了个性化定制。
* 七层采用Tengine实现负载均衡。Tengine是由淘宝网发起的Web服务器项目，它在Nginx的基础上，针对有大访问量的网站需求，添加了很多高级功能和特性。
## 2.3 功能概述
https://help.aliyun.com/document_detail/32460.html
> 调度算法
  * 负载均衡支持轮询
  * 加权轮询（WRR）
  * 加权最小连接数（WLC）
  * 一致性哈希（CH）调度算法。
# 5. 用户指南
## 5.2 监听
### 5.2.4 添加HTTPS监听
https://help.aliyun.com/document_detail/86438.html
> 在上传证书前，请注意：
  * 上传的证书格式必须是PEM。详情参见证书要求。
  * 证书上传到负载均衡后，`负载均衡即可管理证书，不需要在后端ECS上绑定证书`。
### 5.2.8 监听介绍
https://help.aliyun.com/document_detail/85943.html
* 负载均衡提供四层（TCP/UDP协议）和七层（HTTP/HTTPS协议）监听
## 5.5 转换证书格式
### 5.5.5 转换证书格式
https://help.aliyun.com/document_detail/85970.html
* 负载均衡只支持PEM格式的证书，其它格式的证书需要转换成PEM格式后，才能上传到负载均衡。建议使用Open SSL进行转换。
## 5.8 监控
### 5.8.2 设置报警规则
https://help.aliyun.com/document_detail/85933.html
https://help.aliyun.com/document_detail/32470.html （旧）
# 6. API参考
## 6.1 API概览
https://help.aliyun.com/document_detail/27566.html
ModifyLoadBalancerInternetSpec	修改负载均衡实例的计费方式或规格。
## 6.4 RAM鉴权
https://help.aliyun.com/document_detail/27575.html
> 可授权的负载均衡资源类型
  * LoadBalancer
  * Certificate
  * ACL
## 6.9 后端服务器
https://help.aliyun.com/document_detail/27635.html
> ServerHealthStatus 后端服务器的健康状况：
  * normal：后端服务器健康。
  * abnormal：后端服务器不健康。
  * `unavailable`：未完成健康检查。
# 8 扩展阅读
## 8.2 常见问题
### 8.2.12 HTTPS/HTTP监听常见问题
https://help.aliyun.com/knowledge_detail/55201.html
7. 可以使用PKCS#12（PFX）格式的证书么？
可以。但在上传证书前，您需要将证书转换为PEM格式，详情参见转换证书格式。

# 其他
[SLB 配置获取真实IP](https://help.aliyun.com/knowledge_detail/60529.html)
X-Forwarded-For 是一个 HTTP 扩展头部，用来表示 HTTP 请求端真实 IP。
规划和准备
[规划与准备](https://help.aliyun.com/document_detail/27548.html)
> 为了提供更加稳定可靠的负载均衡服务，阿里云负载均衡已在各地域部署了多可用区以实现同地域下的跨机房容灾。此外，您也可以在不同地域创建多个负载均衡实例，`通过DNS轮询的方式对外提供服务，从而提高跨地域的可用性`。
* 为了减少延迟并提高下载速度，建议选择离您客户最近的地域。
* 由于负载均衡不支持跨地域部署，因此应选择与后端ECS实例相同的地域。
