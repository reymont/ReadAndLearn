1. https://help.aliyun.com/product/61789.html

# 1. 产品简介
## 1.1 什么是弹性公网IP
https://help.aliyun.com/document_detail/32321.html
# 5. 常见问题 
## 5.1 EIP常见问题
https://help.aliyun.com/knowledge_detail/38753.html
> EIP与ECS的公网IP有何区别？
  * 公网IP可以在ECS实例的网卡上看到， 而EIP是通过NAT方式将IP地址映射到ECS的位于私网的网卡上，所以在网卡上看不到EIP。
  * 公网IP不可以与ECS实例解绑，而EIP可以随时解绑和绑定。
  * 您可以将ECS的固定公网IP转换为EIP，详情参见ECS固定公网IP转换为EIP。
> EIP为什么在网卡上看不到？
  * EIP配置在Internet网关设备上，通过NAT方式映射到了ECS实例的私网网卡，所以在ECS实例的私网网卡上无法查看到EIP。
> 一个账号可以申请多少个EIP？
  * 一个账号最多可以申请20个EIP。如果您需更多EIP，可以提交工单申请。
> EIP当前可以绑定到哪些云产品？
  * 目前支持绑定EIP的云产品实例包括专有网络类型的ECS和SLB实例，和NAT网关。
> EIP是否支持绑在经典网络的ECS实例上？
  * `不支持`。
> 为什么无法访问EIP？
  * EIP没有绑定到云产品实例上。
  * 查看ECS实例是否有安全策略。例如ECS实例所在的安全组策略禁止80端口的访问，则无法访问该EIP的80端口。
  * 您的EIP已经欠费。
> 为什么EIP无法绑定到ECS实例上？
  * `EIP只能绑定到`专有网络类型`的ECS实例上`。如果您当前的ECS实例不是专有网络类型的，则无法绑定。
  * `EIP的地域和ECS实例的地域不同`。
  * 只有运行中或者已停止状态的ECS实例才能绑定EIP。
  * 该ECS实例已经绑定了EIP。
  * 该ECS实例已经分配了公网IP。
> 为什么EIP无法绑定到NAT网关上？
  * 对于2017年11月3日之前账号下存在NAT带宽包的用户，您仍需使用NAT带宽包为该NAT网关提供公网IP。若要绑定EIP，请提交工单。