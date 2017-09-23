# 6 使用Feign实现声明式REST调用

## 6.1 Feign 简介

Feign是Netflix开发的声明式、模板化的HTTP客户端

## 6.2 为服务消费者整合Feign

* 添加@FeignClient注解

## 6.3 自定义Feign配置

* Feign的默认配置类是FeignClientsConfiguration，定义了Feign默认使用的编码器、解码器、所使用的契约等
* Feign默认使用契约是SpringMnvContract
* 为Feign添加拦截器，可添加基于Http Basic认证。new BasicAuthRequestInterceptor("user", "password")

## 6.4 手动创建 Feign

* Feign Builder API

### 6.4.1 修改用户微服务

### 6.4.2 修改电影微服务

## 6.5 Feign对继承的支持

* Feign使用继承，将公共操作分组到父接口中
* 不建议在服务器端与客户端之间共享接口

## 6.6 Feign对压缩的支持

* 对请求或响应进行压缩
  * feign.compression.request.enabled=true
  * feign.compression.response.enabled=true
* 请求压缩详细的配置
  * feign.compression.request.enabled=true
  * feign.compression.request.mime-types=text/xml,application/xml,application/json支持的媒体列表
  * feign.compression.request.min-request-size=2048设置请求的最小阈值
  
## 6.7 Feign 的日志

* 日志
  * `日志打印`只会对DEBUG级别做出响应
* Logger.Level级别
  * NONE：不记录任何日志
  * BASIC：仅记录请求方法、URL、响应状态代码以及执行时间
  * HEADERS：BASIC基础上，记录请求和响应的header
  * FULL：记录请求和响应的header，body和元数据

## 6.8 使用Feign构造多参数请求

* RequestMethod.GET
  * @RequestParam Map<String, Object> map
* RequestMethod.POST
  * @RequestBody User user