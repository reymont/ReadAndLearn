聊聊CNCF基金会的Certified Kubernetes Administrator认证考试 - DockOne.io http://www.dockone.io/article/2966




https://www.cncf.io/certification/expert/
https://github.com/opsnull/follow-me-install-kubernetes-cluster
https://kubernetes.io/docs/home/
https://kubernetes.io/docs/reference/kubectl/cheatsheet/
http://7xj61w.com1.z0.glb.clouddn.com/CKA_Candidate_Handbook_v1.4_.pdf
https://kubernetes.io/docs/reference/kubectl/cheatsheet/
http://www.dockone.io/[https://kubernetes.io/docs/home/
https://github.com/opsnull/follow-me-install-kubernetes-cluster

最近笔者花了些时间完成了CNCF官方基金会推出的CKA（Certified Kubernetes Administrator）认证考试，这边文章就简单说一下CKA认证考试是撒，考试的大致过程以及参加考试一些准备过程。

更多详细信息，请参考本文末尾的参考资料部分的CKA candidate handbook
关于CKA考试

CKA（Certified Kubernetes Administrator）是CNCF基金会（Cloud Native Computing Foundation）官方推出的Kubernetes管理员认证计划，用于证明持有人有履行Kubernetes管理的知识，技能等相关的能力。

除了对于个人技能提供认证以外，如果企业想要加入CNCF基金会的KCSP计划（Kubernetes认证服务提供商）也需要企业至少有3名及以上工程师的通过CKA认证考试。
考试注册地址

CKA考试费用

参与人员需要支付300$的考试费用，因此一张双币信用卡是必须的。
CKA考试范围

CKA考试主要考察参与认证人员对于Kubernetes的系统管理能力，主要考察的范围以及比例大致如下：
应用生命周期管理 8%
安装，配置 & 校验 12%
核心概念 19%
网络 11%
调度管理 5%
安全 12%
集群维护 11%
日志 / 监控 5%
存储 7%
故障定位 10%

考试时，需要参与在认证系统提供的云环境中，实际完成考试题目给定的目标，如：
在提供的Kubernetes集群下完成对Kubernetes下各种资源的创建，使用以及管理
部署以及配置新的Kubernetes集群
对于已存在的Kubernetes集群故障进行问题分析，并且解决集群中的故障

因此参与考试认证的人员需要充分了解Kubernetes中的核心概念，并且有足够的实际动手操作能力，完成对Kubernetes集群以及资源的管理维护。
CKA考试形式

CKA考试时间为3个小时，在3小时内需要完成24道题目，如果正确率在75%及以上即可通过考试，得到认证。在进行考试时需要参与人员登录到考试系统，并且有专门的监考官对考试过程进行全程监督，在考试过程中需要全程打开摄像头，以及共享桌面。考试之前监考官也会通过视频对考试环境进行检查，以确保考试环境是满足要求的。

CKA考试对于考试时间和位置的选择相对比较宽松，参与考试的人员可以根据自己的实际情况选择考试时间和地点。

需要注意的几个点：
考试之前考官会要求参与考试人员出示护照或者身份证来确认参与考试人员的身份
进行考试的房间必须是比较私人的位置，并且确保考试过程中不能有任何人进出房间。因此比如咖啡馆，商店这种位置是不允许的。
桌面必须得干净的，不能有任何比如笔记本，手机，以及其他电子设备，包括水杯等
考试过程中是可以kubernetes.io/github上查找相关的资料的
过于国内参与考试的人员需要自带科学上网技能包，并且网络质量一定要高（！！！）

准备过程

手动部署过程实际操练

众所周知安装部署Kubernetes最主要的问题是关于如何在国内实现“本土化”安装，但是往往这个过程既没效率非常低，明明很简单的事情，非要做很久。AWS对于新注册的用户提供了免费一年的使用套餐（需要信用卡注册），所以直接通过在AWS利用国外虚拟主机进行练习，过程及快捷又方便。
https://github.com/opsnull/fol ... uster

Kubernetes官方文档

Kubernetes官方文档按照SETUP，CONCEPTS，TASKS，TUTORIALS，FRDERENCE几个部分，内容相对比较分散。可以利用思维导图重新整理一下Kubernetes相关的知识点。当然足够熟悉官方文档也可以在考试过程中提升效率。毕竟3个小时24道题，时间还是非常紧张的。
https://kubernetes.io/docs/home/

Command，Command，Command

由于考试时间相对紧张，使用YAML创建K8S资源效率真的很低，使用命令行可以快速创建资源，在基础结构上再对资源进行编辑可以充分提高效率
https://kubernetes.io/docs/ref ... heet/

// 创建Deployment
kubectl run nginx --image=nginx
// 创建Service
kubectl expose nginx --port=80 --target-port=8000

获取证书

在完成CKA考试，后CNCF官方会在36小时以内以邮件的形式通知考试结果，如果正确率能够在75%以上那恭喜你，通过了考试，并且邮件会附带由CNCF基金会颁发的证书。
kca.png

其它参考资料

CKA candidate handbook
Kubectl cheatsheet
Kubernetes documents
Follow me install kubernetes cluster