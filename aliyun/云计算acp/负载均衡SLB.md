1. https://help.aliyun.com/product/27537.html

# 2. 产品简介
## 2.2 基础架构
https://help.aliyun.com/document_detail/27544.html
阿里云当前提供四层（TCP协议和UDP协议）和七层（HTTP和HTTPS协议）的负载均衡服务。
* 四层采用开源软件LVS（Linux Virtual Server）+ keepalived的方式实现负载均衡，并根据云计算需求对其进行了个性化定制。
* 七层采用Tengine实现负载均衡。Tengine是由淘宝网发起的Web服务器项目，它在Nginx的基础上，针对有大访问量的网站需求，添加了很多高级功能和特性。
# 5. 用户指南
## 5.5 转换证书格式
### 5.5.5 转换证书格式
https://help.aliyun.com/document_detail/85970.html
* 负载均衡只支持PEM格式的证书，其它格式的证书需要转换成PEM格式后，才能上传到负载均衡。建议使用Open SSL进行转换。
## 5.8 监控
### 5.8.2 设置报警规则
https://help.aliyun.com/document_detail/85933.html
https://help.aliyun.com/document_detail/32470.html （旧）

[SLB 配置获取真实IP](https://help.aliyun.com/knowledge_detail/60529.html)
X-Forwarded-For 是一个 HTTP 扩展头部，用来表示 HTTP 请求端真实 IP。

# 8 扩展阅读
## 8.2 常见问题
### 8.2.12 HTTPS/HTTP监听常见问题
https://help.aliyun.com/knowledge_detail/55201.html
7. 可以使用PKCS#12（PFX）格式的证书么？
可以。但在上传证书前，您需要将证书转换为PEM格式，详情参见转换证书格式。