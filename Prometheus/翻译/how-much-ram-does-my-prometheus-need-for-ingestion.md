
# 普罗米修斯需要多少内存?

原文：[How much RAM does my Prometheus need for ingestion? | Robust Perception ](https://www.robustperception.io/how-much-ram-does-my-prometheus-need-for-ingestion/)

Brian Brazil January 9, 2017
计算普罗米修斯内存使用量可能令人困惑。让我们一步步分解理解。

我一直在做负载测试。目的是，无论在规模的大小，普罗米修斯都能良好的运行。我已经提炼出一些简单的规则，来帮助配置普罗米修斯。依据负载测试的结果，我对普罗米修斯进行调优，而这些配置只适用于普罗米修斯1.5.x。普罗米修斯1.6.x，配置的发生了变化，但总的原则仍然适用。

有两个数字你需要确定。第一个是，持久性缓冲区，即准备并等待写入磁盘的数据，需要多少`块chunks`。获取数据后，立即将数据写到数百万个文件上，而文件数据不容易扩展。所以普罗米修斯将它们存储在内存中，并以6小时左右的周期更新它们。直到普罗米修斯已经运行了至少6小时，然后计算`(increase(prometheus_local_storage_chunk_ops_total{job="prometheus",type="create"}[6h]) / 2 / .8 * 1.6)`。这段的含义是：从配置`-storage.local.max-chunks-to-persist`获取值；除以2；然后除以0.8；避免`匆忙模式()rushed mode`，然后给60%迟缓系数(slack)，以允许随着时间的变化。

第二个数字是，在给定的6小时内期望写入多少时间序列。`max_over_time(prometheus_local_storage_memory_series{job="prometheus"}[6h])`就是一个很好的参考值。

这两个数字加在一起，就是配置中`-storage.local.memory-chunks`的最小值。这适用于仍在填充的块，以及已经填充并等待写入的块。

使用RSS内存每个本地内存`块(chunk)`至少要2.6kib。块本身有1024个字节，在普罗米修斯里面有30%的开销，然后在额外需要GO的GC的100%空间。

# 深入理解Complications

对于普通的设置，以上是正确的。然而，有相当多的注意事项。

第一个是最重要，只包括摄取的情况。执行查询需要额外的内存，无论是从磁盘中加载的任何附加块，还是用于计算表达式。

下一个，并不是6小时的循环一次。其实，在有限的时间内，有10%的保留期。所以如果你在60h保留期，上述数字相应调整。

对于大多数情况下，6小时的循环时间仅仅是一个目标，它比实际完成持久本身所需的时间要慢。0.6的迟缓系数指的就是这个。建议`-storage.local.checkpoint-dirty-series-limit`和`-storage.local.memory-chunks`设置相同的值，用来避免额外的检查点。然而，在崩溃后，这可能可能需要较长时间恢复。

以上都假定进行循环持久化，这导致在非SSD或者有很多检查点的情况下，就相对困难些。可以选择让它减少块的最大数目，加快持久化，这会有额外的`IOPS (Input/Output Operations Per Second，即每秒进行读写（I/O）操作的次数)`。这通常会导致`匆忙模式(rushed mode)`，这种模式会禁用fsyncs，不执行通常的时间序列持久化步骤。在正常的持久化情况下，可以使用`-storage.local.series-sync-strategy=never`来禁用fsync。


# 翻译阅读


## 匆忙模式(rushed mode)

* [Persistence urgency and “rushed mode” | Storage | Prometheus ](https://prometheus.io/docs/operating/storage/#persistence-urgency-and-%E2%80%9Crushed-mode%E2%80%9D)
* [Prometheus的架构及持久化 - xixicat - SegmentFault ](https://segmentfault.com/a/1190000008629939)

如果等待持久化的块数量增长过多，该怎么办呢？普罗米修斯通过计算`紧急分数(a score for urgency)`以持久化数据块。分数在0到1之间，其中1对应着最高的紧迫性。根据得分，普罗米修斯会更频繁地写到磁盘上。如果得分超过0.8的临界值，普罗米修斯进入`匆忙模式(rushed mode)`（可以在日志中看到）。

`prometheus_local_storage_persistence_urgency_score`
介于0-1之间，当该值小于等于0.7时，prometheus离开rushed模式。当大于0.8的时候，进入rushed模式

`prometheus_local_storage_rushed_mode`
1表示进入了rushed mode，0表示没有。进入了rushed模式的话，prometheus会利用storage.local.series-sync-strategy以及storage.local.checkpoint-interval的配置加速chunks的持久化。