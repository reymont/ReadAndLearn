
* [OpenStack、OpenNebula、Eucalyptus、CloudStack社区活跃度比较-CSDN.NET ](http://www.csdn.net/article/2013-07-04/2816105-OpenStack-OpenNebula-Eucalyptus-CloudStack)
* [openstack 和cloudstack之间的比较 - 从菜鸟到菜菜鸟 - CSDN博客 ](http://blog.csdn.net/carolzhang8406/article/details/56480024)

|比较|OpenStack|CloudStack|
|-|-|-|
|服务类型|Iaas|Iaas|
|授权协议|Apache 2.0|Apache 2.0|
|许可证|不需要|不需要|
|动态资源调配|无现成功能，需要通过Nova-Scheduler组件实现|主机Maintainance模式下自动迁移VM|
|VM模板|支持|支持|
|VM Console|支持|支持|
|开发语言|Python|JAVA|
|用户界面|DashBoard，较简单|Web Console，功能较完善|
|负载均衡|软件负载均衡（Nova-Network或Openstack Load Balance API）、硬件负载均衡|软件负载均衡（Virtual Router）、硬件负载均衡|
|虚拟化技术|XenServer，Oracl VM，ESX/ESXi，KVM，LXC等|XenServer，Oracl VM，vShpere，KVM，Bare Metal|
|最小部署|支持ALL in one|一个管理节点，一个主机节点|
|支持数据库|PostgreSQL，MySQL，SQLite|MySQL|
|组件|Nova,Glance,Keystone,Horizon,Swift|Console Proxy VM, Second Storage VM, Virtual Router VM, HostAgent, Management Server|
|网络形版|VLAN, FLAT, FlatDHCP|Isolation (VLAN), Share|
|版本问题|存在各个版本兼容性问题|版本发布稳定，不存在兼容性问题|
|VLAN|支持VLAN间互访|不能VLAN间互访|


penStack和CloudStack虽然都对VMware的ESXi虚拟化技术提供支持，但支持方式是不一样的，如图所示。CloudStack要经过vCenter才可以实现对ESXi宿主机上虚拟机的管理；而OpenStack支持直接和ESXi通信，实现对虚拟机的基本管理，只有高级功能才需要vCenter的支持。针对目前中小企业普遍采用VMware的免费虚拟化技术而没有vCenter的现状，这也是在平台选择时需要考虑的。

![](http://img.blog.csdn.net/20170222102131922?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvY2Fyb2x6aGFuZzg0MDY=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)