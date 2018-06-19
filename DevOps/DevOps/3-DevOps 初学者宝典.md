DevOps 初学者宝典_搜狐科技_搜狐网 
http://www.sohu.com/a/159609524_639793

什么是DevOps

随着软件发布迭代的频率越来越高，传统的「瀑布型」（开发—测试—发布）模式已经不能满足快速交付的需求。2009 年左右 DevOps 应运而生，简单地来说，就是更好的优化开发(DEV)、测试(QA)、运维(OPS)的流程，开发运维一体化，通过高度自动化工具与流程来使得软件构建、测试、发布更加快捷、频繁和可靠。

Devops 的好处与价值

在2016 DevOps 新趋势调查报告显示，74% 的公司在尝试接受 DevOps，那么 Devops 有哪些好处与价值呢？

代码的提交直接触发：消除等待时间，快速反馈
每个变化对应一个交付管道：使问题定位和调试变得简单
全开发流程高效自动化：稳定，快速，交付结果可预测
持续进行自动化回归测试：提升交付质量
设施共享并按需提供：资源利用最大化

以上可以看出，DevOps 的好处更多基于在于持续部署与交付，这是对于业务与产品而言。而 DevOps 始于接受 DevOps 文化与技术方法论，它是部门间沟通协作的一组流程和方法，有助于改善公司组织文化、提高员工的参与感。

# Devops与持续集成

DevOps 是一个完整的面向IT运维的工作流，以 IT 自动化以及持续集成（CI）、持续部署（CD）为基础，来优化程式开发、测试、系统运维等所有环节。

纵观各个 DevOps 实践公司的技术资料，最全面最经典的是 flickr 的10+ deploys per day最佳实践提到的 DevOps Tools 的技术关键点:

1.Automated infrastructure（自动化，系统之间的集成） 2.shared version control（SVN共享源码） 3.one step build and deploy（持续构建和部署） 4.feature flags（主干开发） 5.Shared metrics 6.IRC and IM robots（信息整合）
以上的技术要点由持续集成/部署一线贯穿，主干开发是进行持续集成的前提，自动化以及代码周边集中管理是实施持续集成的必要条件。毫无疑问，DevOps 是持续集成思想的延伸，持续集成/部署是 DevOps 的技术核心，在没有自动化测试、持续集成/部署之下，DevOps就是空中楼阁。



DevOps 的技术栈与工具链

Everything is Code，DevOps 也同样要通过技术工具链完成持续集成、持续交付、用户反馈和系统优化的整合。Elasticbox 整理了 60+ 开源工具与分类，其中包括版本控制&协作开发工具、自动化构建和测试工具、持续集成&交付工具、部署工具、维护工具、监控，警告&分析工具等等，补充了一些国内的服务，可以让你更好的执行实施 DevOps 工作流。

版本控制&协作开发：GitHub、GitLab、BitBucket、SubVersion、Coding、Bazaar
自动化构建和测试:Apache Ant、Maven 、Selenium、PyUnit、QUnit、JMeter、Gradle、PHPUnit
持续集成&交付:Jenkins、Capistrano、BuildBot、Fabric、Tinderbox、Travis CI、flow.ci、Continuum、LuntBuild、CruiseControl、Integrity、Gump、Go
容器平台: Docker、Rocket、Ubuntu（LXC）、第三方厂商如（AWS/阿里云）
配置管理：Chef、Puppet、CFengine、Bash、Rudder、Powershell、RunDeck、Saltstack、Ansible
微服务平台：OpenShift、Cloud Foundry、Kubernetes、Mesosphere
服务开通：Puppet、Docker Swarm、Vagrant、Powershell、OpenStack Heat
日志管理：Logstash、CollectD、StatsD
监控，警告&分析：Nagios、Ganglia、Sensu、zabbix、ICINGA、Graphite、Kibana


DevOps = Culture + Tools

如果想整个业务部署 DevOps，不但需要软性要求即从上而下的培养 DevOps 文化自上而下地进行探索，也有硬性工具链要求，才能获得更高质量的软件交付。

最后，不论你是技术Leader，还是一名Dev、QA 或 Ops，实现全面的 DevOps 非常理想化也十分有挑战。

原文来自： http://www.linuxprobe.com/devops.html