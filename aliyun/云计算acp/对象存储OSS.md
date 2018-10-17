

1. https://help.aliyun.com/product/31815.html

1. https://help.aliyun.com/document_detail/31817.html
# 1. 产品简介
## 1.4 使用场景
https://help.aliyun.com/document_detail/31819.html
# 2. 产品定价
## 2.2 计量项和计费项
https://help.aliyun.com/document_detail/59636.html
OSS产品的账单费用由以下四部分组成。其中，数据处理会根据您的使用情况单独计量计费，不使用不计费。
1. 存储费用
2. 流量费用
3. 请求费用
4. 数据处理费用

# 4. 开发指南
## 4.8 管理存储空间
### 4.8.4 设置存储空间读写权限（ACL）
https://help.aliyun.com/document_detail/31843.html
public-read-write 公共读写
public-read 公共读，私有写
private	私有读写
## 4.11 管理文件
### 4.11.3 拷贝对象
https://help.aliyun.com/document_detail/31861.html
拷贝对象即复制Bucket中的文件。在有些情况下，您可能需要仅仅只是将一些Object从一个Bucket复制到另外一个Bucket，不改变内容。这种情况一般的做法是将Object重新下载然后上传。但是因为数据实际上都是一样的，因此浪费了很多网络带宽。因此`OSS提供了CopyObject的功能来实现OSS的内部拷贝，这样在用户和OSS之间就无需传输大量的数据`。
OSS提供了CopyObject来节省网络带宽
# 5. 最佳实践
## 5.8 存储空间管理
### 5.8.4 防盗链
https://help.aliyun.com/document_detail/31937.html
# 9 图片处理指南
## 9.1 快速使用OSS图片服务
https://help.aliyun.com/document_detail/44686.html
# 12. 常见问题
## 12.7 域名/网络
[ECS用户如何正确使用OSS内网地址](https://help.aliyun.com/knowledge_detail/39584.html)
* `同地域的ECS可以通过内网访问OSS`。
* 跨账户的ECS和OSS可以内网互连。
* 不同地域的ECS与OSS无法通过内网访问。
## 12.9  存储空间（bucket）管理
### 12.9 OSS中可以重命名bucket吗？是否支持object迁移？
https://help.aliyun.com/knowledge_detail/39588.html