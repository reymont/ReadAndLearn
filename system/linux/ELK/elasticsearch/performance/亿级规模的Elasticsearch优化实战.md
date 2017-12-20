

亿级规模的Elasticsearch优化实战 http://mp.weixin.qq.com/s/MbrpfnmcxIoCbqqRpfcHDA

本文根据王卫华老师在“高可用架构”微信群所做的《Elasticsearch实战经验分享》整理而成，转发请注明出处。

王卫华，百姓网资深开发工程师、架构师，具有10年＋互联网从业经验，曾获得微软2002-2009 MVP荣誉称号。2008年就职百姓网，负责后端代码开发和Elasticsearch & Solr维护工作。

Elasticsearch 的基本信息大致如图所示，这里就不具体介绍了。


本次分享主要包含两个方面的实战经验：索引性能和查询性能。

一. 索引性能（Index Performance）

首先要考虑的是，索引性能是否有必要做优化？

索引速度提高与否？主要是看瓶颈在什么地方，若是 Read DB（产生DOC）的速度比较慢，那瓶颈不在 ElasticSearch 时，优化就没那么大的动力。实际上 Elasticsearch 的索引速度还是非常快的。

我们有一次遇到 Elasticsearch 升级后索引速度很慢，查下来是新版 IK 分词的问题，修改分词插件后得到解决。

如果需要优化，应该如何优化？

SSD 是经济压力能承受情况下的不二选择。减少碎片也可以提高索引速度，每天进行优化还是很有必要的。在初次索引的时候，把 replica 设置为 0，也能提高索引速度。

bulk 是不是一定需要呢？

若是 Elasticsearch 普通索引已经导致高企的 LA，IO 压力已经见顶，这时候 bulk 也无法提供帮助，SSD 应该是很好的选择。

在 create doc 速度能跟上的时候，bulk 是可以提高速度的。

记得 threadpool.index.queue_size ++，不然会出现索引时队列不够用的情况。

indices.memory.index_buffer_size:10% 这个参数可以进行适当调整。

调整如下参数也可以提高索引速度：index.translog.flush_threshold_ops:50000 和 refresh_interval。

二. 查询性能（Query Perofrmance）

王道是什么？routing，routing，还是 routing。

我们为了提高查询速度，减少慢查询，结合自己的业务实践，使用多个集群，每个集群使用不同的 routing。比如，用户是一个routing维度。

在实践中，这个routing 非常重要。

我们碰到一种情况，想把此维度的查询（即用户查询）引到非用户routing 的集群，结果集群完全顶不住！

在大型的本地分类网站中，城市、类目也是一个不错的维度。我们使用这种维度进行各种搭配。然后在前端分析查询，把各个不同查询分别引入合适的集群。这样做以后，每个集群只需要很少的机器，而且保持很小的 CPU Usage 和 LA。从而查询速度够快，慢查询几乎消灭。

分合？

分别（索引和routing）查询和合并（索引和routing）查询，即此分合的意思。

索引越来越大，单个 shard 也很巨大，查询速度也越来越慢。这时候，是选择分索引还是更多的shards？

在实践过程中，更多的 shards 会带来额外的索引压力，即 IO 压力。

我们选择了分索引。比如按照每个大分类一个索引，或者主要的大城市一个索引。然后将他们进行合并查询。如：http://cluster1:9200/shanghai,beijing/_search?routing=fang，自动将查询中城市属性且值为上海或北京的查询，且是房类目的，引入集群 cluster1，并且routing等于fang。

http://cluster1:9200/other/_search?routing=jinan,linyi。小城市的索引，我们使用城市做 routing，如本例中同时查询济南和临沂城市。

http://cluster1:9200/_all/_search，全部城市查询。

再如： http://cluster2:9200/fang,che/_search?routing=shanghai_qiche,shanghai_zufang,beijing_qiche,beijing_zufang。查询上海和北京在小分类汽车、整租的信息，那我们进行如上合并查询。并将其引入集群 cluster2。

使用更多的 shards？

除了有 IO 压力，而且不能进行全部城市或全部类目查询，因为完全顶不住。

Elastic 官方文档建议：一个 Node 最好不要多于三个 shards。

若是 "more shards”，除了增加更多的机器，是没办法做到这一点的。
分索引，虽然一个 Node 总的shards 还是挺多的，但是一个索引可以保持3个以内的shards。

我们使用分索引时，全量查询是可以顶住的，虽然压力有点儿高。

索引越来越大，资源使用也越来越多。若是要进行更细的集群分配，大索引使用的资源成倍增加。

有什么办法能减小索引？显然，创建 doc 时，把不需要的 field 去掉是一个办法；但是，这需要对业务非常熟悉。

有啥立竿见影的办法？

根据我们信息的特点，内容（field:description）占了索引的一大半，那我们就不把 description 索引进 ES，doc 小了一倍，集群也小了一倍，所用的资源（Memory, HD or SSD, Host, snapshot存储，还有时间）大大节省，查询速度自然也更快。

那要查 description 怎么办？

上面的实例中，我们可以把查询引入不同集群，自然我们也可以把 description 查询引入一个非实时（也可以实时）集群，这主要是我们业务特点决定的，因为description查询所占比例非常小，使得我们可以这样做。

被哪些查询搞过？第一位是 Range 查询，这货的性能真不敢恭维。在最热的查询中，若是有这货，肯定是非常痛苦的，网页变慢，查询速度变慢，集群 LA 高企，严重的时候会导致集群 shard 自动下线。所以，建议在最热的查询中避免使用 Range 查询。

Facet 查询，在后续版本这个被 aggregations 替代，我们大多数时候让它在后端进行运算。

三. 其他

1)线程池

线程池我们默认使用 fixed，使用 cached 有可能控制不好。主要是比较大的分片 relocation时，会导致分片自动下线，集群可能处于危险状态。在集群高压时，若是 cached ，分片也可能自动下线。自 1.4 版本后，我们就一直 fixed，至于新版是否还存在这个问题，就没再试验了。

两个原因：一是 routing王道带来的改善，使得集群一直低压运行；二是使用fixed 后，已经极少遇到自动下线shard了。

我们前面说过，user 是一个非常好的维度。这个维度很重要，routing 效果非常明显。其他维度，需要根据业务特点，进行组合。

所以我们的集群一直是低压运行，就很少再去关注新版本的 使用 cached 配置问题。

hreadpool.search.queue_size 这个配置是很重要的，一般默认是够用了，可以尝试提高。

2）优化

每天优化是有好处的，可以大大改善查询性能。max_num_segments 建议配置为1。虽然优化时间会变长，但是在高峰期前能完成的话，会对查询性能有很大好处。

3) JVM GC的选择：选择 G1还是 CMS？

应该大多数人还是选择了 CMS，我们使用的经验是 G1 和 CMS 比较接近；但和 CMS 相比，还是有一点距离，至少在我们使用经验中是如此。

JVM 32G 现象？

128G内存的机器配置一个 JVM，然后是巨大的 heapsize （如64G）？
还是配多个 JVM instance，较小的 heapsize（如32G）？

我的建议是后者。实际使用中，后者也能帮助我们节省不少资源，并提供不错的性能。具体请参阅 “Don’t Cross 32 GB!" （https://www.elastic.co/guide/en/elasticsearch/guide/current/heap-sizing.html#compressed_oops）

跨 32G 时，有一个现象，使用更多的内存，比如 40G，效果还不如31G！

这篇文档值得大家仔细阅读。

JVM 还有一个配置 bootstrap.mlockall: true，比较重要。这是让 JVM 启动的时候就 锁定 heap 内存。

有没有用过 较小的 heapsize，加上SSD？我听说有人使用过，效果还不错，当然，我们自己还没试过。

4）插件工具

推荐 kopf，是一个挺不错的工具，更新及时，功能完备，可以让你忘掉很多 API :)。






上面是 kopf 的图片。管理Elasticsearch 集群真心方便。以前那些 API ，慢慢要忘光了:)

索引，查询，和一些重要的配置，是今天分享的重点。


Q&A

Q1：您建议生产环境JVM采用什么样的参数设置？FULL GC频率和时间如何？

CMS 标准配置。
ES_HEAP_NEWSIZE=?G
JAVA_OPTS="$JAVA_OPTS -XX:+UseCondCardMark"
JAVA_OPTS="$JAVA_OPTS -XX:CMSWaitDuration=250"
JAVA_OPTS="$JAVA_OPTS -XX:+UseParNewGC"
JAVA_OPTS="$JAVA_OPTS -XX:+UseConcMarkSweepGC"

JAVA_OPTS="$JAVA_OPTS -XX:CMSInitiatingOccupancyFraction=75"
JAVA_OPTS="$JAVA_OPTS -XX:+UseCMSInitiatingOccupancyOnly"

Full GC 很少去care 它了。我们使用 Elasticsearch 在JVM上花的时间很少。

Q2：生产环境服务器如何配置性价比较高？单机CPU核数、主频？内存容量？磁盘容量？

内存大一些，CPU 多核是必要的，JVM 和 Elasticsearch 会充分使用内存和多核的。 关于内存容量的问题，很多是 JVM Tunning 的问题。 磁盘容量没啥要求。

Q3： 分组统计(Facet 查询或 aggregations )大多数时候让它在后端进行运算，怎么实现？应用如果需要实时进行统计而且并发量较大，如何优化？

因为我们是网站系统，所以对于 Facet 请求，引导到后端慢慢计算，前端初始的时候可能没数据，但是此后就会有了。

如果是精确要求的话，那就只能从 提高 facet 查询性能去下手，比如 routing、filter、cache、更多的内存...

Q4：存进Elasticsearch的数据，timestamp是UTC时间，Elasticsearch集群会在UTC 0点，也就是北京时间早上8点自动执行优化？如何改参数设置这个时间？

我们没有使用Elasticsearch的自动优化设置。自己控制优化时间。

Q5：我的Java程序，log4j2 Flume appender，然后机器上的Flume agent ，直接Elasticsearch 的sink avro到 es节点上，多少个agent 连在单个Elasticsearch节点比较合适 ？

ElasticSearch本身是一个分布式计算集群，所以，请求平均分配到每个 node 即可。

Q6：我代码里直接用 Java API 生成Flume appender 格式，Flume agent 里interceptor去拆分几个字段，这样是不是太累了？比较推荐的做法是不是还是各业务点自己控制字段，调用Elasticsearch API 生成索引内容？

业务点自己控制生成的文档吧？如果需要产生不同routing，并且分了索引，这些其实是业务相关的。routing和不同索引，都是根据业务情况哪些查询比较集中而进行处理的。

Q7：您见过或管理过的生产环境的Elasticsearch数据量多大？

我们使用 Elasticsearch 进行某些业务处理，数据量过亿。

Q8：SSD性能提升多少？

SSD 对索引帮助非常大，效果当当的，提高几十倍应该是没问题。不过，我们没有试过完全使用SSD顶查询，而是使用内存，内存性价比还是不错的。

Q9：我们现在有256个shard，用uid做routing，所有查询都是走routing。每个shard有30多G，每次扩容很慢，有什么建议？

可以考虑使用分合查询吗？ 或者使用更多的维度？ 256个 shard 确实比较难以控制。但是如果是分索引和查询，比more shards(256) 效果应该会好不少。

Q10：Elasticsearch排序等聚合类的操作需要用到fielddata，查询时很慢。新版本中doc values聚合查询操作性能提升很大，你们有没有用过？

Facet 查询需要更大的内存，更多的 CPU 资源。可以考虑routing、filter、cache等多种方式提高性能。

Aggs 将来是要替换 Facet，建议尽快替换原来的facet API。

Q11：Elasticsearch配置bootstrap.mlockall，我们在使用中发现会导致启动很慢，因为Elasticsearch要获取到足够的内存才开始启动。

启动慢是可以接受的，启动慢的原因也许是内存没有有效释放过，比如文件 cached了。 内存充足的情况下，启动速度还是蛮快的，可以接受。 JVM 和 Lucene 都需要内存，一般是JVM 50%, 剩下的50% 文件cached 为Lucene 使用。

Q12：优化是一个开销比较大的操作，每天优化的时候是否会导致查询不可用？如何优化这块？

优化是开销很大的。不会导致查询不可用。优化是值得的，大量的碎片会导致查询性能大大降低。 如果非常 care 查询，可以考虑多个集群。在优化时，查询 skip 这个集群就可以。

Q13：Elasticsearch适合做到10亿级数据查询，每天千万级的数据实时写入或更新吗？

10亿是可以做到的，如果文档轻量，10亿所占的资源还不是很多。
ELK 使用 Elasticsearch ，进行日志处理每天千万是小case吧？
不过我们除了使用 ELK 进行日志处理，还进行业务处理，10亿级快速查询是可以做到，不过，需要做一些工作，比如索引和shards的分分合合：）

Q14：Elasticsearch相比Solr有什么优势吗？

我们当年使用 Solr 的时候，Elasticsearch 刚出来。他们都是基于 Lucene的。 Elasticsearch 相对于 solr ，省事是一个优点。而且现在 Elasticsearch 相关的应用软件也越来越多。Solr 和 Lucene 集成度很高，更新版本是和Lucene一起的，这是个优点。

很多年没用 Solr了，毕竟那时候数据量还不大，所以折腾的就少了，主要还是折腾 JVM。所以，就不再过多的比较了。

Q15：分词用的什么组件？Elasticsearch自带的吗？

我们使用 IK 分词，不过其他分词也不错。IK分词更新还是很及时的。而且它可以远程更新词典。：）

Q16： reindex有没有好的方法？

reindex 这个和 Lucene 有关，它的 update 就是 delete+ add。

Q17：以上面的两个例子为例 ： 是存储多份同样的数据么？

是两个集群。第一个集群使用大城市分索引，不过，还有大部分小城市合并一个索引。大城市还是用类目进行routing，小城市合并的索引就使用城市进行routing 。

第二个集群，大类分得索引，比如fang、che，房屋和车辆和其他类目在一个集群上，他们使用 city+二级类目做routing。

Q18：集群部署有没有使用 Docker ？ 我们使用的时候 ，同一个服务器 节点之间的互相发现没有问题 ，但是跨机器的时候需要强制指定network.publish_host 和 discovery.zen.ping.unicast.hosts 才能解决集群互相发现问题。

我们使用puppet进行部署。暂没使用 Docker。 强制指定network.publish_host 和 discovery.zen.ping.unicast.hosts 才能解决集群，跨IP段的时候是有这个需要。

Q19：您建议采用什么样的数据总线架构来保证业务数据按routing写入多个Elasticsearch集群，怎么保证多集群Elasticsearch中的数据与数据库中数据的一致性？

我们以前使用 php在web代码中进行索引和分析 query，然后引导到不同集群。 现在我们开发了一套go rest系统——4sea，使用 redis + elastic 以综合提高性能。

索引时，更新db的同时，提交一个文档 ID 通知4sea 进行更新，然后根据配置更新到不同集群。

数据提交到查询时，就是分析 query 并引导到不同集群。

这套 4sea 系统，有机会的可以考虑开源，不算很复杂的。

Q20： 能介绍一下Elasticsearch的集群rebanlance、段合并相关的原理和经验吗？

“段”合并？，我们是根据业务特点，产生几个不一样的集群，主要还是 routing 不一样。

shards 比较平均很重要的，所以选择routing 维度是难点，选择城市的话，大城市所在分片会非常大，此时可以考虑 分索引，几个大城市几个索引，然后小城市合并一个索引。

如果 shards 大小分布平均的话，就不关心如何 allocation 了。

Q21：关于集群rebalance，其实就是cluster.routing.allocation配置下的那些rebalance相关的设置，比如allow_rebalance／cluster_concurrent_rebalance／node_initial_primaries_recoveries，推荐怎么配置？

分片多的情况下，这个才是需要的吧。

分片比较少时，allow_rebalance disable，然后手动也可以接受的。

分片多，一般情况会自动平衡。我们对主从不太关心。只是如果一台机器多个 JVM instance （多个 Elasticsearch node）的话，我们写了个脚本来避免同一shard 在一台机器上。

cluster_concurrent_rebalance 在恢复的时候根据情况修改。正常情况下，再改成默认就好了。

node_initial_primaries_recoveries，在保证集群低压的情况下，不怎么care。

kopf 上面有好多这种配置，你可以多试试。

Q22：合并查询是异步请求还是同步请求？做缓存吗？

合并查询是 Elasticsearch 自带 API。

Q23：用httpurlconnection请求的时候，会发现返回请求很耗时，一般怎么处理？

尽可能减少慢查询吧？我们很多工作就是想办法如何减少慢查询，routing和分分合合，就是这个目的。

Q24：生产环境单个节点存储多少G数据？

有大的，有小的。小的也几十G了。不过根据我们自己的业务特点，某些集群就去掉了全文索引。唯一的全文索引，使用基本的routing（比较平衡的routing，比如user。城市的话，就做不到平衡了，因为大城市数据很多），然后做了 快照，反正是增量快照，1小时甚至更短时间都可以考虑！！！去掉全文索引的其他业务集群，就小多了。

（完）

想和群内专家继续交流Elasticsearch相关技术，请关注公众号后，回复arch，申请进群。

本文策划 庆丰@微博, 内容由Kaitlyn编辑，臧秀涛校对与发布，Tim审校，其他多位志愿者对本文亦有贡献。读者可以通过搜索“ArchNotes”或长按下面图片，关注“高可用架构”公众号，查看更多架构方面内容，获取通往架构师之路的宝贵经验。转载请注明来自“高可用架构（ArchNotes）”公众号，敬请包含二维码！