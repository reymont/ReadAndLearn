

* [Kubernetes 针对资源紧缺处理方式的配置_Kubernetes中文社区 ](https://www.kubernetes.org.cn/1150.html)

如何在资源紧缺的情况下，保证 Node 的稳定性，是 Kubelet 需要面对的一个重要的问题。尤其对于内存和磁盘这种不可压缩的资源，紧缺就相当于不稳定。

驱逐策略

Kubelet 能够监控资源消耗，来防止计算资源被耗尽。一旦出现资源紧缺的迹象，Kubelet 就会主动终止一或多个 Pod 的运行，以回收紧俏资源。当一个 Pod 被终止时，其中的容器会全部停止，Pod 状态会被置为 Failed。

驱逐信号

下文中提到了一些信号，kubelet 能够利用这些信号作为决策依据来触发驱逐行为。描述列中的内容来自于 Kubelet summary API。

驱逐信号	描述
memory.available	memory.available := node.status.capacity[memory] – node.stats.memory.workingSet
nodefs.available	nodefs.available := node.stats.fs.available
nodefs.inodesFree	nodefs.inodesFree := node.stats.fs.inodesFree
imagefs.available	imagefs.available := node.stats.runtime.imagefs.available
imagefs.inodesFree	imagefs.inodesFree := node.stats.runtime.imagefs.inodesFree
上面的每个信号都支持整数值或者百分比。百分比的分母部分就是各个信号的总量。kubelet 支持两种文件系统分区。

nodefs：保存 kubelet 的卷和守护进程日志等。
imagefs：在容器运行时，用于保存镜像以及可写入层。
imagefs 是可选的。Kubelet 能够利用 cAdvisor 自动发现这些文件系统。Kubelet 不关注其他的文件系统。所有其他类型的配置，例如保存在独立文件系统的卷和日志，都不被支持。

因为磁盘压力已经被驱逐策略接管，因此未来将会停止对现有 垃圾收集 方式的支持。

驱逐阈（yù，音同“预”）值：

一旦超出阈值，就会触发 kubelet 进行资源回收的动作。阈值的定义方式如下：

上面的表格中列出了可用的 eviction-signal.
仅有一个 operator 可用：<
quantity 需要符合 Kubernetes 中的描述方式。
例如如果一个 Node 有 10Gi 内存，我们希望在可用内存不足 1Gi 时进行驱逐，就可以选取下面的一种方式来定义驱逐阈值：

memory.available<10%
memory.available<1Gi
驱逐软阈值

软阈值需要和一个宽限期参数协同工作。当系统资源消耗达到软阈值时，这一状况的持续时间超过了宽限期之前，Kubelet 不会触发任何动作。如果没有定义宽限期，Kubelet 会拒绝启动。

另外还可以定义一个 Pod 结束的宽限期。如果定义了这一宽限期，那么 Kubelet 会使用pod.Spec.TerminationGracePeriodSeconds 和最大宽限期这两个值之间较小的那个（进行宽限），如果没有指定的话，kubelet 会不留宽限立即杀死 Pod。

软阈值的定义包括以下几个参数：

eviction-soft：描述一套驱逐阈值（例如 memory.available<1.5Gi ），如果满足这一条件的持续时间超过宽限期，就会触发对 Pod 的驱逐动作。
eviction-soft-grace-period：包含一套驱逐宽限期（例如 memory.available=1m30s），用于定义达到软阈值之后，持续时间超过多久才进行驱逐。
eviction-max-pod-grace-period：在因为达到软阈值之后，到驱逐一个 Pod 之前的最大宽限时间（单位是秒），
驱逐硬阈值

硬阈值没有宽限期，如果达到了硬阈值，kubelet 会立即杀掉 Pod 并进行资源回收。

硬阈值的定义：

eviction-hard：描述一系列的驱逐阈值（比如说 memory.available<1Gi），一旦达到这一阈值，就会触发对 Pod 的驱逐，缺省的硬阈值定义是：
–eviction-hard=memory.available<100Mi

驱逐监控频率

Housekeeping interval 参数定义一个时间间隔，Kubelet 每隔这一段就会对驱逐阈值进行评估。

housekeeping-interval：容器检查的时间间隔。
节点状况

Kubelet 会把驱逐信号跟节点状况对应起来。

如果触发了硬阈值，或者符合软阈值的时间持续了与其对应的宽限期，Kubelet 就会认为当前节点压力太大，下面的节点状态定义描述了这种对应关系。

节点状况	驱逐信号	描述
MemoryPressure	memory.available	节点的可用内存达到了驱逐阈值
DiskPressure	nodefs.available, nodefs.inodesFree, imagefs.available, imagefs.inodesFree	节点的 root 文件系统或者镜像文件系统的可用空间达到了驱逐阈值
Kubelet 会持续报告节点状态的更新过程，这一频率由参数 –node-status-update-frequency 指定，缺省情况下取值为 10s。

节点状况的波动

如果一个节点的状况在软阈值的上下波动，但是又不会超过他的宽限期，将会导致该节点的状态持续的在是否之间徘徊，最终会影响降低调度的决策过程。

要防止这种状况，下面的标志可以用来通知 Kubelet，在脱离压力状态之前，必须等待。

eviction-pressure-transition-period 定义了在跳出压力状态之前要等待的时间。

Kubelet 在把压力状态设置为 False 之前，会确认在周期之内，该节点没有达到逐出阈值。

回收节点级别的资源

如果达到了驱逐阈值，并且超出了宽限期，那么 Kubelet 会开始回收超出限量的资源，直到驱逐信号量回到阈值以内。

Kubelet 在驱逐用户 Pod 之前，会尝试回收节点级别的资源。如果服务器为容器定义了独立的 imagefs，他的回收过程会有所不同。

有 Imagefs

如果 nodefs 文件系统到达了驱逐阈值，kubelet 会按照下面的顺序来清理空间。

删除死掉的 Pod/容器
如果 imagefs 文件系统到达了驱逐阈值，kubelet 会按照下面的顺序来清理空间。

删掉所有无用镜像
没有 Imagefs

如果 nodefs 文件系统到达了驱逐阈值，kubelet 会按照下面的顺序来清理空间。

删除死掉的 Pod/容器
删掉所有无用镜像
驱逐用户 Pod

如果 Kubelet 无法获取到足够的资源，就会开始驱逐 Pod。

Kubelet 会按照下面的标准对 Pod 的驱逐行为进行评判：

根据服务质量
根据 Pod 调度请求的被耗尽资源的消耗量
接下来，Pod 按照下面的顺序进行驱逐：

BestEffort：消耗最多紧缺资源的 Pod 最先失败。
Burstable：相对请求（request）最多紧缺资源的 Pod 最先被驱逐，如果没有 Pod 超出他们的请求，策略会瞄准紧缺资源消耗量最大的 Pod。
Guaranteed：相对请求（request）最多紧缺资源的 Pod 最先被驱逐，如果没有 Pod 超出他们的请求，策略会瞄准紧缺资源消耗量最大的 Pod。
Guaranteed Pod 绝不会因为其他 Pod 的资源消费被驱逐。如果系统进程（例如 kubelet、docker、journald 等）消耗了超出 system-reserved 或者 kube-reserved 的资源，而且这一节点上只运行了 Guaranteed Pod，那么为了保证节点的稳定性并降低异常消费对其他 Guaranteed Pod 的影响，必须选择一个 Guaranteed Pod 进行驱逐。

本地磁盘是一个 BestEffort 资源。如有必要，kubelet 会在 DiskPressure 的情况下，kubelet 会按照 QoS 进行评估。如果 Kubelet 判定缺乏 inode 资源，就会通过驱逐最低 QoS 的 Pod 的方式来回收 inodes。如果 kubelet 判定缺乏磁盘空间，就会通过在相同 QoS 的 Pods 中，选择消耗最多磁盘空间的 Pod 进行驱逐。

有 Imagefs

如果 nodefs 触发了驱逐，Kubelet 会用 nodefs 的使用对 Pod 进行排序 – Pod 中所有容器的本地卷和日志。

如果 imagefs 触发了驱逐，Kubelet 会根据 Pod 中所有容器的消耗的可写入层进行排序。

没有 Imagefs

如果 nodefs 触发了驱逐，Kubelet 会对各个 Pod 的所有容器的总体磁盘消耗进行排序 —— 本地卷 + 日志 + 写入层。

在某些场景下，驱逐 Pod 可能只回收了很少的资源。这就导致了 kubelet 反复触发驱逐阈值。另外回收资源例如磁盘资源，是需要消耗时间的。

要缓和这种状况，Kubelet 能够对每种资源定义 minimum-reclaim。kubelet 一旦发现了资源压力，就会试着回收至少 minimum-reclaim 的资源，使得资源消耗量回到期望范围。

例如下面的配置：

--eviction-hard=memory.available<500Mi,nodefs.available<1Gi,imagefs.available<100Gi
--eviction-minimum-reclaim="memory.available=0Mi,nodefs.available=500Mi,imagefs.available=2Gi"`
如果 memory.available 被触发，Kubelet 会启动回收，让 memory.available 至少有 500Mi。
如果是 nodefs.available，Kubelet 就要想法子让 nodefs.available 回到至少 1.5Gi。
而对于 imagefs.available， kubelet 就要回收到最少 102Gi。
缺省情况下，所有资源的 eviction-minimum-reclaim 为 0。

调度器

在节点资源紧缺的情况下，节点会报告这一状况。调度器以此为信号，不再继续向此节点部署新的 Pod。

节点状况	调度行为
MemoryPressure	不再分配新的 BestEffort Pod 到这个节点
DiskPressure	不再向这一节点分配 Pod
节点的 OOM 行为

如果节点在 Kubelet 能够回收内存之前，遭遇到了系统的 OOM (内存不足)，节点就依赖oom_killer 进行响应了。

kubelet 根据 Pod 的 QoS 为每个容器设置了一个 oom_score_adj 值。

QoS	oom_score_adj
Guaranteed	-998
BestEffort	1000
Burstable	min(max(2, 1000 – (1000 * memoryRequestBytes) / machineMemoryCapacityBytes), 999)
如果 kubelet 无法在系统 OOM 之前回收足够的内存，oom_killer 就会根据根据内存使用比率来计算 oom_score，得出结果和 oom_score_adj 相加，最后得分最高的 Pod 会被首先驱逐。

这一行为的思路是，QoS 最低，相对于调度的 Reqeust 来说又消耗最多内存的 Pod 会被首先清除，来保障内存的回收。

跟 Pod 驱逐不同，如果一个 Pod 的容器被 OOM 杀掉，他是可能被 kubelet 根据 RestartPolicy重启的。

最佳时间

可调度的资源和驱逐策略

我们想象如下的场景：

节点内存容量：10Gi
保留 10% 的内存容量给系统服务（内核，kubelet 等）。
在 95% 内存使用率的时候驱逐 Pod，来降低系统 OOM 的发生率。
所以我们用这样的参数启动 Kubelet：

--eviction-hard=memory.available<500Mi
--system-reserved=memory=1.5Gi
这个配置中隐含了一个设定就是，系统保留涵盖了驱逐标准。

要达到这一容量，可能是有的 Pod 使用了超出其请求的数量，或者系统占用了超过 500Mi。

这样的配置保证了调度器不会向即将发生内存压力的节点分配 Pod，避免触发驱逐。

DaemonSet

因为 DaemonSet 中的 Pod 会立即重建到同一个节点，所以 Kubelet 不应驱逐 DaemonSet 中的 Pod。

但是目前 Kubelet 无法分辨一个 Pod 是否由 DaemonSet 创建。如果/当 Kubelet 能够识别这一点，那么就可以先从驱逐候选列表中过滤掉 DaemonSet 的 Pod。

一般来说，强烈建议 DaemonSet 不要创建 BestEffort Pod，而是使用 Guaranteed Pod，来避免进入驱逐候选列表。

弃用的现存回收磁盘的选项

为了保证节点的稳定性，Kubelet 已经尝试来释放磁盘空间了。

因为基于磁盘的驱逐方式已经成熟，下列的 Kubelet 参数会被标记为弃用。

现有参数	新参数
–image-gc-high-threshold	–eviction-hard or eviction-soft
–image-gc-low-threshold	–eviction-minimum-reclaim
–maximum-dead-containers	弃用
–maximum-dead-containers-per-container	弃用
–minimum-container-ttl-duration	弃用
–low-diskspace-threshold-mb	–eviction-hard or eviction-soft
–outofdisk-transition-frequency	–eviction-pressure-transition-period
已知问题

Kubelet 无法及时观测到内存压力

Kubelet 目前从 cAdvisor 定时获取内存使用状况统计。如果内存使用在这个时间段内发生了快速增长，Kubelet 就无法观察到 MemoryPressure，可能会触发 OOMKiller。我们正在尝试将这一过程集成到 memcg 通知 API 中，来降低这一延迟，而不是让内核首先发现这一情况。

如果用户不是希望获得终极使用率，而是作为一个过量使用的衡量方式，对付这一个问题的较为可靠的方式就是设置驱逐阈值为 75% 容量。这样就提高了避开 OOM 的能力，提高了驱逐的标准，有助于集群状态的平衡。

Kubelet 可能驱逐超出需要的更多 Pod

这也是因为状态搜集的时间差导致的。未来会加入功能，让根容器的统计频率和其他容器分别开来（https://github.com/google/cadvisor/issues/1247）。

Kubelet 如何在 inode 耗尽的时候评价 Pod 的驱逐

目前不可能知道一个容器消耗了多少 inode。如果 Kubelet 觉察到了 inode 耗尽，他会利用 QoS 对 Pod 进行驱逐评估。在 cadvisor 中有一个 issue，来跟踪容器的 inode 消耗，这样我们就能利用 inode 进行评估了。例如如果我们知道一个容器创建了大量的 0 字节文件，就会优先驱逐这一 Pod。

原文:  http://kubernetes.io/docs/admin/out-of-resource/#eviction-policy
译文：http://blog.fleeto.us/translation/configuring-out-resource-handling