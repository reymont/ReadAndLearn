

http://www.infoq.com/cn/news/2015/01/big-data-apache-flink-project

Close亲爱的读者：我们最近添加了一些个人消息定制功能，您只需选择感兴趣的技术主题，即可获取重要资讯的邮件和网页通知。
Apache Flink是一个高效、分布式、基于Java实现的通用大数据分析引擎，它具有分布式 MapReduce一类平台的高效性、灵活性和扩展性以及并行数据库查询优化方案，它支持批量和基于流的数据分析，且提供了基于Java和Scala的API。从Apache官方博客中得知，Flink已于近日升级成为Apache基金会的顶级项目。Flink项目的副总裁对此评论到：

Flink能够成为基金会的顶级项目，自己感到非常高兴。自己认为社区的驱动将是Flink成长的最好保证。Flink逐渐的成长以及众多新人加入该社区真是一件大好事。

从Flink官网得知，其具有如下主要特征：

1. 快速

Flink利用基于内存的数据流并将迭代处理算法深度集成到了系统的运行时中，这就使得系统能够以极快的速度来处理数据密集型和迭代任务。

2. 可靠性和扩展性

当服务器内存被耗尽时，Flink也能够很好的运行，这是因为Flink包含自己的内存管理组件、序列化框架和类型推理引擎。

3. 表现力

利用Java或者Scala语言能够编写出漂亮、类型安全和可为核心的代码，并能够在集群上运行所写程序。开发者可以在无需额外处理就使用Java和Scala数据类型

4. 易用性

在无需进行任何配置的情况下，Flink内置的优化器就能够以最高效的方式在各种环境中执行程序。此外，Flink只需要三个命令就可以运行在Hadoop的新MapReduce框架Yarn上，

5. 完全兼容Hadoop

Flink支持所有的Hadoop所有的输入/输出格式和数据类型，这就使得开发者无需做任何修改就能够利用Flink运行历史遗留的MapReduce操作

Flink主要包括基于Java和Scala的用于批量和基于流数据分析的API、优化器和具有自定义内存管理功能的分布式运行时等，其主要架构如下：



更多关于Flink的相关信息，请读者登录其托管在GitHub的主页和其官网查看。另外，开源的大数据分析平台除了Flink外，还包括Apache推出Google Dremel的开源版本Apache Drill（2014年12月份升级成为Apache基金会的顶级项目）、来自NSA（美国国家安全局）Apache Nifi（2014年12月份贡献给Apache基金会）、来自Cloudera公司开发的实时分析系统Impala（受Google Dremel启发）、加州伯克利大学AMPLab开发的大数据分析系统Shark 、Facebook开源的分布式SQL查询引擎Presto、Hortonworks开源的实时且类SQL的即时查询系统Stinger等等。

感谢郭蕾对本文的审校。

给InfoQ中文站投稿或者参与内容翻译工作，请邮件至editors@cn.infoq.com。也欢迎大家通过新浪微博（@InfoQ）或者腾讯微博（@InfoQ）关注我们，并与我们的编辑和其他读者朋友交流。