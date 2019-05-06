

Netflix Spinnaker：实现全局部署 
http://www.infoq.com/cn/news/2016/03/netflix-spinnaker

Netflix最近将他们的持续交付平台Spinnaker作为开源项目进行了发布。Spinnaker允许使用者通过创建管道（pipeline）的方式展现一个交付流程，并执行这些管道以完成一次部署。Spinnaker能够向前兼容Asgard，因此无需一次性完全迁移至Spinnaker。



用户可在Spinnaker中从创建一个部署单元（例如一个JAR文件或是Docker镜像）开始，直至将应用部署至云环境中。Spinnaker支持多种云平台，包括AWS、Google Could Platform以及Cloud Foundry。Spinnaker通常是在一个持续集成作业完成之后启动的，但也可以通过一个cron作业、一个Git库或者由其他管道进行手动触发。

Spinnaker还为用户提供了管理服务器集群的功能，通过应用视图，用户可以对新的服务器组、负载均衡器以及安全组进行编辑、规模调整、删除、禁用以及部署等操作。



Spinnaker是由基于JVM的服务（由Spring Boot和 Groovy所实现），以及由AngularJS所创建的UI所组成的。

为了进一步了解Spinnaker及其开源现状，InfoQ与来自Netflix的Spinnaker团队进行了一次访谈，受访者包括负责交付工程的经理Andy Glover，以及高级软件工程师Cameron Fieber和Chris Berry。

InfoQ：Spinnaker发布已经有一个多月了，社区对此的反响如何？

Glover：社区对Spinnaker的接纳程度令人震惊！这个平台内置了对多个云提供商的兼容，并且能够通过一种可扩展的模型接入其中。这意味着我们打造了一个大型社区，而不是一系列专注于不同分支的微型社区。这种方式的优势在于社区中的每个人都可以利用各种创新的特性。我们已看到许多来自于新社区成员的pull request，并且我相信，随着我们继续提升项目的可适配性，将会看到越来越多的贡献。

InfoQ：许多云提供商似乎都建议使用者上传单一的部署文件，并通过他们的API或UI进行扩展。Spinnaker的不同之处又体现在哪里呢？

Fieber：Spinnaker推荐使用不可变基础设施风格的部署方式，它提供了对各种云提供商（AWS AMI、Google Compute
Engine Images等等）的镜像格式的原生支持。Spinnaker还支持通过Quick Patch进行已排编代码的push，让团队能够快速地迭代，在现有的实例中进行软件包的推送以及安装，从而减免了新虚拟机上线的等待时间。常见的使用方式是快速地部署一个测试环境以运行测试，或发布一些有状态服务，例如数据存储的补丁。

InfoQ：你知道是否有用户已经开始使用Spinnaker对多个云环境进行部署吗？

Glover：我知道有一家非常著名的公司已经在多个云提供商环境中进行部署了，不过他们希望我不要提起他们的名字。我觉得应该有其他用户也会这样做，并且随着社区的发展，我们将进一步了解有哪些公司将采取多个云环境的策略。

InfoQ：你怎样比较Spinnaker与Heroku的管道特性？

Glover：我认为Spinnaker与Heroku的管道相比最大的区别在于：（1）Spinnaker支持多种可适配的部署端点，例如AWS、GCE、Pivotal CloudFoundry等等。（2）Spinnaker的管道模型非常之灵活，它支持多种不同类型的阶段（stage），而且社区也可以自行开发各种管道并将其接入Spinnaker平台。Heroku管道的设计目标是为了Heroku本身服务的，并且他们的管道模型非常僵化。另一方面，Heroku的管道是通过命令行驱动的。我们目前还没有发布Spinnaker的命令行客户端。

InfoQ：从Spinnaker在GitHub上的项目来看，“gate”这个项目似乎是由Groovy编写的，并且使用了Spring Boot。为什么你们选用了Groovy而不是Java 8呢？

Fieber：Spinnaker其实就是Asgard项目的后继者（我们还有一个名为Mimir的内部工具。译注：Asgard与Mimir都来源于北欧神话），他们都是由Grails编写的应用。我们团队对于Groovy有充分的了解，感觉它比Grails更为轻量级，并且更专注于操作性，因此值得投入精力进行研究。Spring
Boot是一种很自然的选择，并且Groovy很适合应用在这个环境中。由于选择了Groovy，我们就能够从Asgard中选取经过了充分测试的AWS代码并在Spinnaker中重用。

InfoQ：Spinnaker的UI项目“deck”是由AngularJS（1.4版本）编写的，你们的开发过程是否顺利？

Berry：刚开始的时候是比较顺利的。当我们在18个月之前启动这个项目的时候，Angular表现得十分稳定。并且有大量的库（UI Bootstrap、UI Router和 Restangular等等）让UI能够十分快速地进行创建与迭代。React也是一门非常激动人心的技术，但当时它才刚刚出现不久，而且它的规范与模式还没有Angular那么充实。

但随后这个开发过程逐渐变得令人痛苦起来。其中部分原因在于Netflix的规模很大，我们某些应用需要在一个屏幕中渲染上千种元素，而Angular 1.x在处理这种数量的DOM节点时性能跟不上。对于这些页面，我们选择以纯JS进行重写，再用一些比较粗糙的方式进行性能对比。最终发现纯JS的结果能够满足性能的要求，即便一次性渲染几千个实例也没问题。但这种方式写出来的代码非常脆弱，毕竟Angular已经为你完成各种任务铺平了道路。

另一个难题在于如何让UI实现模块化与可适配性，让不同的云提供商能够按照他们的需求创建UI模块，并且让外部用户能够创建自定义的管道组件。我们在这两方面的工作做得还可以，它不算很差，但也绝对谈不上出色。我们从UI Router中直接抄用了大量的代码与概念，让我们的代码能够运行起来，但除了我们团队之外，我并没有看到像Google、微软和Pivotal尝试开发任何自定义的实现。我想一定有某些人已经在做这件事了，只是我们还没看到罢了。

以上这些并不是说我们对于选择Angular 1.x感到后悔。在当时来说，它对于我们确实是正确的选择。现在回过头来看，如果我们能够回到18个月之前，那我们或许会对代码进行一些重写，但大概还是会用Angular吧。

InfoQ：你们是否计划将UI项目迁移至Angular 2？

Berry：我们确实有进行迁移的打算，但估计要到5至6个月之后才会开始。毕竟Angular 2还只发布了beta版本，并且在工具方面也缺乏支持。那些编写UI特性的非Netflix用户有许多都不是专职的前端开发者，我们希望确保他们能够轻易地找到构建特性的正确方式，并且在遇到问题时能够方便地进行调试。

我很乐于看到Angular 2在明年的发展，并且想多了解一些从1.x迁移至2的案例。我们只是想对此采取一种相对谨慎的态度，并且从其他人身上多学习一点经验。

InfoQ：Spinnaker是怎样改善Netflix的部署工作的？

Glover：首先，也是最重要的一点是它为所有人提供了一个标准的交付平台。Spinnaker让用户能够方便地进行交付，并且对于流程具备充分的信心，这正是团队最需要的东西。通过这个平台，整个Netflix服务能够更频繁地进行部署，并且在运维上具备更大的弹性。Spinnaker本身与来自Netflix的大量其他服务与工具进行了集成，使这些特性更易于为用户所用。举例来说，我们有一个名为ACA（Automated Canary Analysis —— 自动化金丝雀分析）的内部服务，这是由Netflix的另一个团队所维护的。尽管如此，它也是一个原生的Spinnaker管道阶段，能够提供测试服务。在Spinnaker出现之前，如果有哪个团队需要使用ACA，就不得不自行寻找将ACA集成进自己的管道的方式。如今随着Spinnaker的出现，就为ACA的使用定义了一种标准方法，这也最终使ACA的使用得到了突飞猛进式的增长，这也提高了我们在AWS上的生产环境的可靠性。如果新创建的工具与服务能够提供更好的测试、数据采集或运维的弹性，就可以将它们接入Spinnaker平台，让每个人都能够充分利用这些工具与服务。

InfoQ：你对Spinnaker的哪个特性最中意？

Glover：Spinnaker支持一种表达式语言，能够让用户对管道进行参数化。它允许用户创建一些非常复杂的管道，最重要的是还能够进行重用。它们能够在全球范围内进行构建的提送（promote）、测试与部署。

InfoQ：你对于Spinnaker还有什么想补充的吗？

Glover：虽然Spinnaker是由Netflix所开发的，但是这个项目的成功离不开与Google、微软、Pivotal和Kenzan良好的合作与他们的贡献。我们目前的良好发展状况以及将来的发展前景让我们非常振奋。我们目前正在开发的内容包括对容器更深层的支持、整体可适配性与灵活性的增长、以及UI和UX的改进。而Spinnaker社区的发展也让我们觉得非常激动。

Greg Turnquist是来自Pivotal的高级软件工程师，他在一篇博客文章中描述了Spinnaker如何与Cloud Foundry进行结合工作。我们很有兴趣了解其他人是如何整合使用Spinnaker的。

InfoQ：你在什么时机下会建议Cloud Foundry用户尝试使用Spinnaker进行部署工作？

Turnquist：对于Cloud Foundry的支持是在Spinnaker的master分支中开发的，其中包括大量的特性。我们目前正在计划通过活跃的客户进行beta级别的测试。在我看来，这对于Cloud Foundry的用户，无论是PCF、PWS还是其他CF的认证实例都已经成熟了。

如果你觉得目前手动将新的版本发布到CF的时间太长，而希望转而使用管道进行部署、冒烟测试与验证，那么现在正是使用Spinnaker，剔除你的发布流程中低效部分的时机。

InfoQ：Spinnaker能否简便地与Cloud Foundry进行整合？

Turnquist：我觉得“简便”这种表述或许不够准确，这个词似乎暗示着整合这两个平台只需很少的工作。实际上我花了很多时间去学习Spinnaker的底层概念，并将这些概念与Cloud Foundry的概念进行一一对应。随着经验的积累，我开始认识到Cloud Foundry能够完美地与Spinnaker平台进行配合。我需要学习大量CF的API方面的知识（实际上我是在Spring团队工作，而不是在CF团队中工作），但我学到的东西越多，这两者的结合就做得越好。

Cloud Foundry与Spinnaker两者都支持将应用的多个版本进行分组以进行统一的升级或回滚、在新版本与旧版本之间实现负载均衡，并且支持开发实例、预发布实例与生产环境的实例。它展现了Spinnaker架构的长处与灵活性，并且也展现了Cloud Foundry这个平台强大的能力。

InfoQ：Greg，你对于Spinnaker的哪个特性最中意？

Turnquist：当我谈到这个平台的时候，给我最多惊喜的是UI的管道编辑器，它让我能够进行各种随意的变更。在“Cloud Foundry After Dark”这个webcast中，我设计了一个简单的管道，其中只包含一个步骤：部署至生产环境。在我进行描述的同时，主持人Andrew要求我进行一些调整，让它能够实现部署至预发布环境、进行冒烟测试以及部署至生产环境。每当他话音刚落，我就已经完成了调整。随后我们开始运行管道并通过一个对用户十分友好的界面阅读它的输出。这个平台让用户能够随意塑造流程，这是我们不应低估的一个强大特性。

InfoQ再次感谢Spinnaker团队与Greg Turnquist能够回答我们的这些问题。在GitHub上可以找到Spinnaker的源代码。如果读者想要与Spinnaker社区进行交流，可以加入它的Slack频道、查看Stack Overflow上有关Spinnaker的问题，或关注它的Twitter账号@spinnakerio。

查看英文原文：Netflix Spinnaker: Enabling Global Deployments