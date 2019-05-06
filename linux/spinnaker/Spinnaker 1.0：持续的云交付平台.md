
Spinnaker 1.0：持续的云交付平台-博客-云栖社区-阿里云 
https://yq.aliyun.com/articles/224854

本文讲的是Spinnaker 1.0：持续的云交付平台【编者的话】Spinnaker 1.0 发布，本文介绍了Spinnaker的一些特性和新的更新，它们让Spinnaker成为伟大的企业级发布管理方案。

【3 天烧脑式 Docker 训练营 | 上海站】随着Docker技术被越来越多的人所认可，其应用的范围也越来越广泛。本次培训我们理论结合实践，从Docker应该场景、持续部署与交付、如何提升测试效率、存储、网络、监控、安全等角度进行。

在Google，我们需要部署大量代码：每天上千个服务需要部署上万次，这些服务中有七个服务在全球有超过10亿用户。在这样的过程中，我们总结了一些有关于软件部署的最佳实践——包括自动化发布，不可变基础架构，滚动升级以及快速回滚。

从2014年开始，我们开始和创建Spinnaker的Netflix团队合作，并且将其作为发布管理平台，该平台体现了我们安全，频繁并且可靠发布的首要原则。受其可能性的激励，我们和Netflix合作将Spinnaker公开，并且在2015年11月份开源。从此之后，Spinnaker社区的成长吸引了数十家企业，包括Microsoft，Oracle，Target，Veritas，Schibsted，Armory和Kenzan等等。

今天，我们很高兴地宣布Spinnaker 1.0的发布，它是开源的多云端持续交付平台，用于Netflix，Waze，Target和Cloudera等公司的生产环境，提供了全新的开源命令行接口（CLI）工具，称为halyard，让Spinnaker自身的部署变得十分容易。本文将介绍Spinnaker能够为你自己的软件开发流程做什么。
为什么是Spinnaker？

这里介绍Spinnaker的一些特性和新的更新，它们让Spinnaker成为伟大的企业级发布管理方案。
开源，多云部署

在Google Cloud Platform（GCP），我们坚信开放的云。Spinnaker，包括其丰富的UI仪表盘，都是100%开源的。用户可以在本地，在内部或者在云上安装它，可以运行在虚拟机（VM）或者Kubernetes上。

Spinnaker通过将发布流水线和目标云供应商解耦开，来流水线化部署流程，这样可以降低从一个平台移动到另一个平台或者在多云上部署相同应用程序的复杂度。

它内建支持Google Compute Engine，Google Container Engine，Google App Engine，AWS EC2，Microsoft Azure, Kubernetes和 OpenStack，社区每年还会添加更多支持的平台，即将支持的平台包括Oracle Bare Metal和DC/OS。

无论你是想要发布到多云上或者想要避免供应商锁定，Spinnaker都能帮助你部署应用程序，达到业务上的最优化。
自动化发布

在Spinnaker里，使用自定义的发布流水线编排部署，其中的阶段可以包括几乎所有你想做的事情——集成或者系统测试，启动或者关闭一个服务器组，人工审批，等待一段时间或者运行自定义脚本或者Jenkins的job。

Spinnaker无缝集成已有的持续集成（CI）工作流。你可以从git，Jenkins，Travis CI，Docker registry，类似cron的调度器，或者甚至其他流水线里触发流水线。
部署策略最佳实践

Spinnaker开箱即用地支持精细的部署策略，比如发布canary，多阶段环境，红/黑（也称为蓝/绿）部署，流量分流并且易于回滚。

这些功能部分是由于Spinnaker使用云上不可变基础架构所带来的，云上应用程序的变更会触发整个服务器的重新部署。和传统的在运行着的机器上配置更新的方案相比，传统方案更慢，上线风险更高，并且会有难以调试的配置相关的问题。

使用Spinnaker，用户可以选择想为每个环境使用的部署策略，比如，staging环境使用红/黑策略，生产环境使用滚动红/黑策略，并且它封装了所有必需的几十个步骤。用户无需编写自己的部署工具或者维护Jenkins脚本的复杂web，就可以实现企业级的上线。
基于角色的授权和权限

大型企业通常在多个产品域都采用Spinnaker，由中央的DevOps团队管理。对于需要针对某个项目或者账号实施基于角色访问控制的管理员来说，Spinnaker支持多种授权和认证的方式，包括OAuth, SAML, LDAP, X.509 certs, GitHub teams, Azure groups 或者 Google Groups。

用户还可以基于人工判断来授权，Spinnaker stage在继续执行工作流之前要求人工审批，确保每个版本不会发生在没有得到正确人员授权之前。
简化安装并且使用halyard管理

Spinnaker 1.0里还宣告启用一种全新的CLI工具，halyard，它帮助管理员更容易地安装，配置以及升级用于生产环境的Spinnaker实例。

在halyard和Spinnaker 1.0之前，管理员必须管理组成Spinnaker的每个微服务。从1.0开始，所有新的Spinnaker版本都有单独的版本，并且遵守语义版本控制。使用halyard，升级到最新的Spinnaker版本仅仅需要运行一个CLI命令即可。
开始试用吧！

试试Spinnaker，可以让你的部署更快，更安全，并且，我们敢说，更枯燥。

更多Spinnaker相关的信息，查看全新的spinnaker.io网站，学习如何入门。

如果已经准备好试试Spinnaker了，点击这里安装并且运行Spinnaker。

任何问题，反馈或者想深入参与到Spinnaker社区，可以在Spinnaker Slack channel找到我们，向Spinnaker GitHub repository提交issue，或者在Stack Overflow上使用“spinnaker”的标签提问题。

更多参考资料

Global Continuous Delivery With Spinnaker
Netflix’s Spinnaker available now on Google Cloud Platform
Guest post: Multi-cloud continuous delivery using Spinnaker at Waze
Spinnaker: continuous delivery from first principles to production (Google Cloud Next '17)

原文链接：Spinnaker 1.0: a continuous delivery platform for cloud（翻译：崔婧雯 校对：）
＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
译者介绍
崔婧雯，现就职于IBM，高级软件工程师，负责IBM WebSphere业务流程管理软件的系统测试工作。曾就职于VMware从事桌面虚拟化产品的质量保证工作。对虚拟化，中间件技术，业务流程管理有浓厚的兴趣。

原文发布时间为：2017-06-11

本文作者：崔婧雯 

本文来自云栖社区合作伙伴Dockerone.io，了解相关信息可以关注Dockerone.io。

原文标题：Spinnaker 1.0：持续的云交付平台

如果您发现本社区中有涉嫌抄袭的内容，欢迎发送邮件至：yqgroup@service.aliyun.com 进行举报，并提供相关证据，一经查实，本社区将立刻删除涉嫌侵权内容