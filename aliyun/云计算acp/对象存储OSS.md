

1. https://help.aliyun.com/product/31815.html

1. https://help.aliyun.com/document_detail/31817.html
# 1. 产品简介
## 1.2 产品优势
|对比项  |云服务器                                         |传统IDC                              |
|-------|------------------------------------------------|-------------------------------------|
|安全   |提供企业级多层次安全防护。                         |需要另外购买清洗和黑洞设备。           |
|安全   |多用户资源隔离机制，支持异地容灾机制。              |需要单独实现安全机制。                 |
|安全   |提供多种鉴权和授权机制及白名单、防盗链、主子账号功能。|                                    |
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
# 3. 快速入门 
## 3.4 创建存储空间
https://help.aliyun.com/document_detail/31885.html
* 存储空间创建后`无法更换所属地域`
# 4. 开发指南
## 4.6 访问与控制
### 4.6.3 绑定自定义域名
https://help.aliyun.com/document_detail/31836.html
您的文件上传到OSS后，会自动生该文件的访问地址。您可以使用此地址访问OSS文件。如果您想要通过自定义域名访问OSS文件，需要将自定义域名访问绑定在文件所在的Bucket上，即CNAME。按照中国《互联网管理条例》的要求，所有需要开通这项功能的用户，必须提供工信部备案号，域名持有者身份证等有效资料，经由阿里云审批通过后才可以使用。在开通CNAME功能后，OSS将自动处理对该域名的访问请求。

## 4.8 管理存储空间
### 4.8.4 设置存储空间读写权限（ACL）
https://help.aliyun.com/document_detail/31843.html
public-read-write 公共读写
public-read 公共读，私有写
private	私有读写
## 4.11 管理文件
### 4.11.3 拷贝对象
https://help.aliyun.com/document_detail/31861.html
* 拷贝对象即复制Bucket中的文件。在有些情况下，您可能需要仅仅只是将一些Object从一个Bucket复制到另外一个Bucket，不改变内容。这种情况一般的做法是将Object重新下载然后上传。但是因为数据实际上都是一样的，因此浪费了很多网络带宽。因此`OSS提供了CopyObject的功能来实现OSS的内部拷贝，这样在用户和OSS之间就无需传输大量的数据`。
* OSS提供了CopyObject来节省网络带宽。
* `由于OSS不提供重命名功能`，因此如果需要对Object进行重命名的话，最佳的方法就是调用OSS的CopyObject接口先将原来的数据拷贝成新的文件名，然后删除原Object
# 5. 最佳实践
## 5.8 存储空间管理
### 5.8.4 防盗链
https://help.aliyun.com/document_detail/31937.html
> 目前OSS提供的防盗链方法主要有以下两种：
* 设置Referer。该操作通过控制台和SDK均可进行，用户可根据自身需求进行选择。
* 签名URL，适合习惯开发的用户。
# 7. API 参考 
## 7.7. 访问控制
### 7.7.4 临时授权访问
https://help.aliyun.com/document_detail/31953.html
* OSS可以通过阿里云STS服务，临时进行授权访问。阿里云STS（Security Token Service）是为云计算用户提供临时访问令牌的Web服务。通过STS，您可以为第三方应用或联邦用户（用户身份由您自己管理）`颁发一个自定义时效和权限的访问凭证`。

# 9 图片处理指南
## 9.1 快速使用OSS图片服务
https://help.aliyun.com/document_detail/44686.html
> 图片处理提供以下功能：
* 获取图片信息
* 图片格式转换
* `图片缩放、裁剪、旋转`
* `图片添加图片、文字、图文混合水印`
* 自定义图片处理样式
* 通过管道顺序调用多种图片处理功能
# 12. 常见问题
## 12.3 计量计费
[云服务器与OSS 上传文件，流量与请求次数是否收费？](https://help.aliyun.com/knowledge_detail/39679.html)
* 云服务器与OSS之间通过内网地址上传或下载数据，属内网流量，是免费的
* 云服务器与OSS每次请求所产生的请求次数，不分内外网都会计费。
## 12.7 域名/网络
[ECS用户如何正确使用OSS内网地址](https://help.aliyun.com/knowledge_detail/39584.html)
* `同地域的ECS可以通过内网访问OSS`。
* 跨账户的ECS和OSS可以内网互连。
* 不同地域的ECS与OSS无法通过内网访问。
## 12.9  存储空间（bucket）管理
1. [OSS中可以重命名bucket吗？是否支持object迁移？](https://help.aliyun.com/knowledge_detail/39588.html)
2. [如何删除bucket](https://help.aliyun.com/knowledge_detail/65468.html)
* 对于空bucket，您可通过控制台右上角的“删除Bucket”或API/SDK的 DeleteBucket 接口直接删除。
* 对于非空的bucket，您可以使用以下方式删除：
  * 使用oss的生命周期异步删除Object，请参考这里，然后将bucket删除。
  * 直接调用 osscmd 的 deletewholebucket 接口进行删除，请参考这里。注意该命令十分危险，将会删除所有的数据，并且不可恢复。请慎重使用。