
elasticsearch 安装及其插件 - xlygsh - 博客园 https://www.cnblogs.com/xuleiyang/p/5666552.html

插件作为一种普遍使用的，用来增强原系统核心功能的机制，得到了广泛的使用，elasticsearch也不例外。

1. 安装Elasticsearch插件
从0.90.2安装其实很简单，有三种方式，

1.1 在确保你网络顺畅的情况下，执行如下格式的命令即可：

1	plugin --install <org>/<user/component>/<version>
 具体的<org>/<user/component>/<version>可参加各插件的使用说明。

1.2  如果网络不太顺畅，可以下载好插件的压缩包后以如下方式安装：

1	bin/plugin --url file:///path/to/plugin --install plugin-name
 
1.3 你也可以直接将插件的相关文件拷贝到plugins目录下面，需要注意的是，这种方式需要特别留意插件的种类。

2. 如何查看当前已经加载的插件
1	`curl -XGET 'http://localhost:9200/_nodes/plugin'`
 或者可以指定某个实例

1	curl -XGET 'http://localhost:9200/_nodes/10.0.0.1/plugin'
3. 个人强力推荐的插件
要想知道整个插件的列表，请访问http://www.elasticsearch.org/guide/reference/modules/plugins/ 插件还是很多的，个人认为比较值得关注的有以下几个，其他的看你需求，比如你要导入数据当然就得关注river了。

3.1 BigDesk

该插件可以查看集群的jvm信息，磁盘IO，索引创建删除信息等，适合查找系统瓶颈，监控集群状态等，可以执行如下命令进行安装，或者访问项目地址:https://github.com/lukas-vlcek/bigdesk

1	bin/plugin -install lukas-vlcek/bigdesk
 说明：ElasticSearch HQ功能跟这个插件也很强大。

3.2 Head

可以查看索引情况，搜索索引，查看集群状态和分片分布等，可以执行如下命令进行安装，或者访问项目地址:https://github.com/mobz/elasticsearch-head

1	bin/plugin -install mobz/elasticsearch-head
 3.3 elasticsearch中文分词插件

官方的中文分词插件：Smart Chinese Analysis Plugin

Medcl开发的中午分词插件： IK Analysis Plugin  以及 Pinyin Analysis Plugin

3.4 ZooKeeper Discovery Plugin

elasticsearch 默认是使用Zen作为集群发现和存活管理的，ZooKeeper作为一个分布式高可用性的协调性系统，在这方面有着天然的优势，如果你比较信任zookeeper，那么你可以使用这个插件来替代Zen。

总结：本文主要介绍了elasticsearch的插件安装方法，如何查看当前加载的插件的方法，以及个人认为比较值得关注的一些插件。