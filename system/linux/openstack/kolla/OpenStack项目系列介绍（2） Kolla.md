

OpenStack项目系列介绍（2） Kolla – 陈沙克日志 http://www.chenshake.com/openstack-project-series-2-kolla/

一直都计划写篇文章介绍Kolla项目。可能是因为了解太多，不知道如何写，还有一种可能，就因为追求写的太正经，导致一直没写。

有一次和朋友介绍Kolla的时候，开玩笑说，其实我也不愿意让你知道kolla，因为这个东西太革命，把我以前积累的安装和部署的经验，全部都报废。不过也确实没啥办法，这是社区的项目，如果真的是革命性，那么你知道只是早晚的事情，为了保持我的专家身份，我也就只能提前告诉你了。

2015年4月份有位朋友去参加温哥华峰会的感受就是：如果OpenStack不支持Docker，那么这很可能是最后一次峰会。OpenStack基金会及时调整方向，全面支持容器。

kolla实现OpenStack容器化
Magnum管理容器和COE （Mesos、 Google的Kubernetes、 Docker Swarm）
Solum实现开发容器化
Murano实现App store 容器化
OpenStack要向外界证明自己有能力管理容器，就必须吃自己的狗食，先把自己容器化。作为OpenStack厂商谈论容器的时候，OpenStack本是没有容器化，那是比较讽刺一件事情。

Contents [hide]
1 基本介绍
2 Kolla架构
3 Kolla的生态
4 Kolla解决的问题
5 资料
基本介绍
Kolla项目是2014年9月份，Steven Dake提交的，这位老兄以前是HeatPTL，还是Corosync作者，牛的一塌糊涂。对于OpenStack的项目是非常熟悉，并且以前是红帽工程师，目前跳槽到思科，代表思科推出Kolla项目。

Kolla的目标，就是要做到100个节点开箱即用，所有的组件的HA都具备。简单说，Fuel装完是什么，他就是什么样子。实现的代价肯定比Fuel小很多。

Kolla，就是把目前OpenStack项目用到的所有组件都容器化。

kolla

图片来自刘光亚文章

其实上面图片还可以增强一下，包括下面组件，也实现的容器化

libvirt
qemu
OVS 和linux bridge
Ceph
HAproxy，Keeplived
MariaDB
ELK ( Heka )
MongoDB
rabbitmq
进行了非常彻底的容器化。

把OpenStack组件容器化，其实技术上的挑战最大在于网络OVS和Qemu。目前这些技术难点都已经搞定，剩下就是体力活，对一个一个组件进行容器打包。

目前OpenStack大帐篷管理下的项目，大概是50多个，http://governance.openstack.org/reference/projects/index.html

Kolla项目会对大帐篷里的项目进行build 镜像。这个工作，估计到明年4月份，就能基本完成。目前大家常用的组件

nova
glance
keystone
cinder
heat
neutron
horizon
上面7个组件，包括控制节点的HA，目前已经经过了我的反复测试。后续的Newton版本，应该会集成更多的组件。

Kolla架构
其实我不搞开发，我就说一下我的理解，OpenStack的项目，都会根据功能进行拆分，每个模块做一件事情。社区目前的规划大概是

Kolla，主要是负责Docker的镜像制作
kolla-Ansible负责容器的配置管理
Kolla-Kubernetes，也是负责容器的配置管理
kolla的Docker镜像制作，非常有意思，支持红帽的rpm包，Ubuntu和Debian的Deb包，还能支持源码的方式。理论上你源码制作的镜像，是可以跑在所有的支持容器的操作系统。

你可以选择ansible来做容器的管理，也可以选择Kubernetes来管理。目前ansible已经比较完善，Kubernetes还在积极开发中，估计怎么都还需要1年后，才能真正投入使用。

目前阶段，Kolla还没有安装操作系统的功能。社区的初步考虑是把ironic放到一个容器里，通过这个容器来安装操作系统。

https://blueprints.launchpad.net/kolla/+spec/bifrost-support

希望Newton版本可以实现。

Kolla的生态
Kolla对于所有的OpenStack创业公司，包括Mirantis的Fuel，都是革命性的东西，以前很辛苦写的东西，很可能都作废。个人预测，2017年，OpenStack部署，都会采用容器的方式。

红帽目前的Liberty产品，计算节点已经支持使用kolla的容器来部署
Fuel，也已经开始考虑采用Docker来部署OpenStack
Rackspace已经采用LXC来部署OpenStack
Canonical采用LXD来部署OpenStack
Snap4

从上面可以看到，红帽，思科，九州云，Intel，IBM和Oracle,都是投入在积极开发。从Mitaka，Newton版本，项目的热门程度（Review，Commit，人天投入）都是排名前十，这是非常不容易的做到的。

 

Kolla解决的问题
过去，无论是OpenStack创业公司，还是企业尝试OpenStack，在安装和部署，都花费和消耗大量的精力。这其实也是影响OpenStack推广的一个重要障碍。如何才能让大家从安装部署中解脱出来呢？如何才能让大家把精力放到如何用好OpenStack上呢？用好OpenStack，才能真正体现出OpenStack的价值。

采用Kolla来部署OpenStack，装好系统后，你大概只需要10分钟的时间，就可以搭建完成full feature的功能OpenStack。各种社区的最佳实践，高可用，都集成在上面。而且全都是运维人员都明白的python语言。

容器化后的OpenStack，让人感觉真的像积木一样，你需要什么，就拿过来放上去就可以。

这样说可能大家比较容易接受，Kolla让以前很多OpenStack的部署，安装，升级的问题，解决起来更加优雅。

上周见一位朋友谈起OpenStack升级，总结的很好，所谓升级就是把以前的删掉，再装新的版本。如果你是采用包的安装,例如rdo，那你就慢慢熬夜搞定吧，对于容器来说，做到这点就太简单了，非常优雅。

对于部署，已经没有安装的过程，你只需要把相应的容器放到相应的位置，配置管理推送过去就可以。对于升级，你只需要做一个容器的替换就可以实现升级，只需要集中精力去处理数据库的问题就可以。

build image的过程，其实可以官方提供，大家直接使用就可以。

资料
目前kolla的资料不多，官方文档以外，就2位的blog，大家可以参考

kolla项目的Croe 张雷同学的blog http://xcodest.me/

Kolla项目的PTL blog：https://sdake.io/