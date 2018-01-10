
用 Spinnaker 构建更安全，低风险的部署环境 
http://mp.weixin.qq.com/s/1U0QtW9m8Ix6KGQjgyaA0g
https://blog.spinnaker.io/can-i-push-that-building-safer-low-risk-deployments-with-spinnaker-a27290847ac4?gi=feb8db5dd1a3

Spinnaker 是 Netflix 开源的持续交付平台。Netflix 的服务运行在超过100000个 AWS 云实例上，Spinnaker 用于部署超过95％的 AWS 云实例。

Spinnaker 主要用于降低新部署带来的风险，Netflix 公司并不希望一个新的 Push 影响到主体服务的运作，建立一个新的微服务很简单，难点是不断升级和维护拥有数百万用户的微服务，当出现问题时，还需要快速的回滚，在这篇文章中，将重点介绍 Spinnaker 提供的一些技术和工具。

更加方便的回滚

Spinnaker 最简单的保护措施是在通过红黑（也称为蓝/绿）部署策略部署服务时启用简单回滚。

在 Spinnaker 中创建新的集群时，只需选择 "red/black"部署策略： 



这个操作将保持 Spinnaker 中的最后一个集群可用，但是被禁用（即没有流量）。



如果上线时发生什么事情（事故）需要将代码回滚到上一个可用的版本，只需在侧栏中选择 Rollback 操作即可： 



回滚对话框将询问你要回滚到哪个禁用的集群：



使用红/黑部署策略可以让回到最后一个已知的可用的版本，如果部署失败或出现问题是可以撤销的。

限制并发执行

Spinnaker 中另一个限制部署风险的策略是它能够限制 Pipeline 的执行。

默认的 Pipeline 一般会修改和部署相同的自动生成的备用的 Pipeline。

Spinnaker 可以配置一次只运行一个 Pipeline：



启用 NOT_STARTED 标志后，只要已经有一个正在运行的 Pipeline，任何新的 Pipeline 都将处于同一个状态，一旦这条 Pipeline 完成，等待的 Pipeline 将启动。

执行部署

我们可以限制 Spinnaker 中特定阶段的执行时间。

限制一个阶段的执行时间有两种可能的用途：

1）只有当有人能够手动干预时 
2）在服务器不是采取高峰流量时。

Netflix 在一天中对流量的需求往往是周期性的。人们一般时在晚上下班后回家观看视频。Netflix 确保在流量高峰时间不会触发部署动作。为了让部署过程更加透明，Netflix 将一个名为 SPS（每秒部署，下面会介绍）的度量合并到部署报表中，并突出显示与此度量相关的部署窗口。



禁用 Pipeline

如果给定的 Pipeline 产生不正确的输出，或者由于其他系统问题而不能运行，则可以禁用该 Pipeline。

禁用的 Pipeline 将不会自动触发，并且会导致触发它的任何父 Pipeline 失败。



禁用的 Pipeline 不能手动触发，直到再次启用的时候。

检查先决条件

Spinnaker 提供了一个名为 Check Preconditions 的阶段，如果不符合某些要求，将会停止 Pipeline。

第一种形式是检查一个集群的大小:



第二种形式允许指定一个灵活的程序化表达式，称为 Pipeline 表达式。



可以通过运行 Jenkins Job 或 Docker 容器来执行更复杂的检查（例如冒烟测试），这两个阶段在 Spinnaker 中都得到很好的支持。



任何 Spinnarker 阶段可以通过配置 Conditional On Expression 使其成为可选项。这允许添加可由 Pipeline 参数控制的可选阶段，并提供额外的自动质量关卡。

手动判断

Spinnaker 提供了一个 Manual Judgment 的选项，确保运维工程师或 QA 可以轻松完成需要人工的步骤。



当一个 Pipeline 到达人工判断阶段时，它会停下来等待负责人进来并点击 Continue。这可以在需要时进行额外的验证。

手动判断阶段使用 Spinnaker 内置的现有通知机制，因此可以向需要批准流水线的用户发送电子邮件，SMS 或 Slack 通知。 



我们也可以指定判断条件。判断条件可以用来决定管道的下一个步骤。在上面的例子中，如果用户选择了输入 Continue，那么后面的步骤将会运行。

通过流水线触发器自动清理

Spinnaker 允许用一条 Pipeline 的结果调用另外的 Pipeline，这样做的一个用途是自动将应用程序的状态恢复到已知的良好状态。

这可以通过设置 Pipeline 自动触发器来完成，该触发器只会运行另一个失败或被取消的 Pipeline。

流量监控

如果不小心摧毁了最后一个好的集群，导致流量中断。流量监控来确保总是提供可用的集群。

在应用程序的配置中设置了一个流量监控。它会告诉你哪些集群将被保护。 



现在，当 Pipeline 或人为销毁或禁用受保护群集中的最后一个集群时，他们将看到下面的错误消息或其 Pipeline 执行失败： 



自动金丝雀分析

Netflix 采用的先进技术之一是自动金丝雀分析（ACA）。在 ACA 中，实时流量被发送到基线和金丝雀集群对，以查看它们发出的指标是否满足可接受的偏差。ACA 非常擅长捕捉传统单元测试或集成测试无法跟踪的问题。

在 Spinnaker 中建立 Canary 分析阶段非常简单：

首先，定义基线（当前）群集和金丝雀（新代码）群集。



然后选择金丝雀分析的细节并定义可接受的分数，然后运行 Pipeline：



Spinnaker 将启动每个基线和金丝雀集群的一个新实例，并将每 x 分钟产生一个 Canary 得分（在例子中为15）。

成功的金丝雀 



金丝雀得分 



在 Spinnaker 添加金丝雀分析之前，不同的团队会以不同的方式做金丝雀。 有些会启动新的集群，其他则会重新利用其生产集群中的现有指标。通过 Spinnaker 处理 ACA 的部署，Spinnaker 的用户能够专注于他们需要捕获的分析和指标。还可以确保基线/金丝雀集群提供了最佳的一组可比较的指标。

Canary Analysis 只是一个简单的阶段，可以插入到 Pipeline 中，Spinnaker 鼓励使用这种技术，代码失败的 ACA 是不会进一步部署的。

自动的“Chaos”测试

Chaos 实验

Netflix 的“Chaos Engineering”工程是一个相对较新的实践。这个想法是运行自动控制的实验，确保能够达到预期的回退行为。

Spinnaker 与“Chaos”自动化平台（ChAP）集成，以确保使用“Chaos Engineering”工程实践创建的测试案例作为部署和验证 Pipeline 的一部分运行： 



在 Spinnaker 中运行 ChAP 就是要确保"失败转移"行为作为部署过程的一部分进行测试。这种持续不断的测试对于那些本来就处于休眠状态的系统性弱点是至关重要的。

Chaos Monkey



Chaos Monkey V2 与 Spinnaker 深度整合，并支持使用 Spinnaker API。

Spinnaker 还通过托管它的配置来帮助 Chaos Monkey，如果用户没有做好准备，用户可以选择退出这个野蛮的状态。 



通过启用 Chaos Monkey，可以确保代码对实例的故障转移具有适应性。其中插入在 Netflix 中做更大规模的故障转移测试，以确保 Netflix 可以生存在 Chaos Monkey 中。

原文链接：https://blog.spinnaker.io/can-i-push-that-building-safer-low-risk-deployments-with-spinnaker-a27290847ac4

上期活动中奖名单：





恭喜以上中奖的小伙伴们！我们将会联系您，把"JFrog大礼包"给您寄到家 ~