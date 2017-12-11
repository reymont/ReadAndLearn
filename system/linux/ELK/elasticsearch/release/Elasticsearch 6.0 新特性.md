

https://oschina.net/news/90590/elasticsearch-6-0-0-released
https://www.elastic.co/blog/elasticsearch-6-0-0-released
https://gitee.com/mirrors/elasticsearch

在 Elasticsearch 5.0.0 发布之后，Elasticsearch 在333个 commite、2236 个合并请求下，发布了基于 Lucene 7.0.1 的 Elasticsearch 6.0.0 正式版。

Elasticsearch 6.0.0 下载地址

Elasticsearch 6.0 重大改变

Elasticsearch 6.0.0 发行说明

Elasticsearch X-Pack 6.0 重大改变

Elasticsearch X-Pack 6.0.0 发行说明

Elasticsearch 6.0.0 部分亮点如下：

# 无宕机升级：

使之能够从 5 的最后一个版本滚动升级到 6 的最后一个版本，不需要集群的完整重启。无宕机在线升级，无缝滚动升级。

# 跨多个 Elasticsearch 群集搜索

和以前一样，Elasticsearch 6.0 能够读取在 5.x 中创建的 Indices ，但不能读取在 2.x 中创建的 Indices 。不同的是，现在不必重新索引所有的旧 Indices ，你可以选择将其保留在 5.x 群集中，并使用跨群集搜索同时在 6.x 和 5.x 群集上进行搜索。

# 迁移助手

Kibana X-Pack 插件提供了一个简单的用户界面，可帮助重新索引旧 Indices ，以及将 Kibana、Security 和 Watcher 索引升级到 6.0 。 群集检查助手在现有群集上运行一系列检查，以帮助在升级之前更正任何问题。 你还应该查阅弃用日志，以确保您没有使用 6.0 版中已删除的功能。

# 使用序列号更快地重启和还原

6.0 版本中最大的一个新特性就是序列 ID，它允许基于操作的分片恢复。 以前，如果由于网络问题或节点重启而从集群断开连接的节点，则节点上的每个分区都必须通过将分段文件与主分片进行比较并复制任何不同的分段来重新同步。 这可能是一个漫长而昂贵的过程，甚至使节点的滚动重新启动非常缓慢。 使用序列 ID，每个分片将只能重放该分片中缺少的操作，使恢复过程更加高效。

# 使用排序索引更快查询

通过索引排序，只要收集到足够的命中，搜索就可以终止。它对通常用作过滤器的低基数字段（例如 age, gender, is_published）进行排序时可以更高效的搜索，因为所有潜在的匹配文档都被分组在一起。

稀疏区域改进

以前，每个列中的每个字段都预留了一个存储空间。如果只有少数文档出现很多字段，则可能会导致磁盘空间的巨大浪费。现在，你付出你使用的东西。密集字段将使用与以前相同的空间量，但稀疏字段将显着减小。这不仅可以减少磁盘空间使用量，还可以减少合并时间并提高查询吞吐量，因为可以更好地利用文件系统缓存。

完整更新内容请点此查阅

相关链接
ElasticSearch 的详细介绍：点击查看
ElasticSearch 的下载地址：点击下载