#Logstash Study

<!-- @import "[TOC]" {cmd:"toc", depthFrom:1, depthTo:6, orderedList:false} -->
<!-- code_chunk_output -->

* [Logstash Study](#logstash-study)
* [入门](#入门)
* [nginx](#nginx)
* [plugin安装](#plugin安装)
* [ruby](#ruby)
* [split](#split)
* [template](#template)
* [document_id](#document_id)
* [setup](#setup)
* [configuration](#configuration)
* [filter](#filter)
* [input](#input)

<!-- /code_chunk_output -->

#入门

- [简介 | Logstash 最佳实践](http://udn.yyuap.com/doc/logstash-best-practice-cn/index.html)
- [Introduction | 日志收集与分析部署](https://pengqiuyuan.gitbooks.io/elkbook/index.html)
- [前言 &middot; ELKstack 中文指南](https://kibana.logstash.es/content/)
- [Introduction | Elasticsearch权威指南（中文版）]https://es.xiaoleilu.com/index.html)


#nginx
- [Logstash对nginx日志进行分析记录 - 简书]( http://www.jianshu.com/p/abca8e5b913b)
- [nginx访问日志 · ELKstack 中文指南 ](https://kibana.logstash.es/content/logstash/examples/nginx-access.html)
- [用 LEK 组合处理 Nginx 访问日志 ](http://chenlinux.com/2014/06/11/nginx-access-log-to-elasticsearch/)

#plugin安装
- [plugin的安装 · ELKstack 中文指南 ](https://kibana.logstash.es/content/logstash/get-start/install-plugins.html)
- [logstash 插件安装 - 简书]( http://www.jianshu.com/p/4fe495639a9a)
- [Logstash 插件安装 - 突破舒适区 - 51CTO技术博客 ](http://tchuairen.blog.51cto.com/3848118/1871556)
- [Offline Plugin Management | Logstash Reference [5.5] | Elastic ](https://www.elastic.co/guide/en/logstash/current/offline-plugins.html)

#ruby
- [随心所欲的 Ruby 处理 | Logstash 最佳实践 ](http://udn.yyuap.com/doc/logstash-best-practice-cn/filter/ruby.html)
- [ruby | Logstash Reference [master] | Elastic ](https://www.elastic.co/guide/en/logstash/master/plugins-filters-ruby.html)
- [Ruby filter plugin | Logstash Reference [5.5] | Elastic] (https://www.elastic.co/guide/en/logstash/current/plugins-filters-ruby.html)
- [logstash-plugins/logstash-filter-ruby] (https://github.com/logstash-plugins/logstash-filter-ruby)
- [logstash利用ruby语言写复杂的处理逻辑 - 小小邮电 - CSDN博客 ](http://blog.csdn.net/ty_0930/article/details/52609360)
##Event API
- [Event API | Logstash Reference [5.5] | Elastic ](https://www.elastic.co/guide/en/logstash/current/event-api.html)
- [New Event API proposal · Issue #5141 · elastic/logstash ](https://github.com/elastic/logstash/issues/5141)
- [logstash/event.rb at edad14c6d018fe9732e6eb41e69cdeff55688b6a · elastic/logstash ](https://github.com/elastic/logstash/blob/edad14c6d018fe9732e6eb41e69cdeff55688b6a/logstash-core/lib/logstash/event.rb)
logstash/logstash-core/lib/logstash/event.rb

#split
- [Mutate filter plugin | Logstash Reference 5.5 | Elastic](https://www.elastic.co/guide/en/logstash/current/plugins-filters-mutate.html#plugins-filters-mutate-split)
- [split 拆分事件 | Logstash 最佳实践](http://udn.yyuap.com/doc/logstash-best-practice-cn/filter/split.html)
- [mutate &middot; ELKstack 中文指南](https://kibana.logstash.es/content/logstash/plugins/filter/mutate.html)
- [nginx访问日志 &middot; ELKstack 中文指南](https://kibana.logstash.es/content/logstash/examples/nginx-access.html)

#template

- [Step 4: Loading the Index Template in Elasticsearch | Filebeat Reference [1.2] | Elastic](https://www.elastic.co/guide/en/beats/filebeat/1.2/filebeat-template.html)
- [Little Logstash Lessons: Using Logstash to help create an Elasticsearch mapping template | Elastic](https://www.elastic.co/blog/logstash_lesson_elasticsearch_mapping)
- [Index Templates | Elasticsearch Reference [5.5] | Elastic](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-templates.html)
- [映射与模板的定制 &middot; ELKstack 中文指南](https://kibana.logstash.es/content/elasticsearch/template.html)
- [logstash template 模版 | 日志收集与分析部署](https://pengqiuyuan.gitbooks.io/elkbook/chapter_2_6.html)
- [保存进 Elasticsearch | Logstash 最佳实践](http://udn.yyuap.com/doc/logstash-best-practice-cn/output/elasticsearch.html)
- [Logstash学习（六）elasticsearch插件&mdash;&mdash;设置ES的Template | birdben](https://birdben.github.io/2016/12/22/Logstash/Logstash%E5%AD%A6%E4%B9%A0%EF%BC%88%E5%85%AD%EF%BC%89elasticsearch%E6%8F%92%E4%BB%B6%E2%80%94%E2%80%94%E8%AE%BE%E7%BD%AEES%E7%9A%84Template/)

#document_id

- [_id doesn&#39;t make it through to elasticSearch &middot; Issue #12 &middot; logstash-plugins/logstash-input-couchdb_change](https://github.com/logstash-plugins/logstash-input-couchdb_changes/issues/12) （document_id =&gt; &quot;%{[@metadata][_id]}&quot;）
- [logstash - Change ID in elasticsearch - Stack Overflow ](https://stackoverflow.com/questions/30391898/change-id-in-elasticsearch)
- [logstash-output elasticsearch插件使用 - yesicatt的博客 - CSDN博客](http://blog.csdn.net/yesicatt/article/details/53393814)

<h1>logstash</h1>


- [Fluentd vs. Logstash: A Comparison of Log Collectors](https://logz.io/blog/fluentd-logstash/)
- [ELK 性能(1) &mdash; Logstash 性能及其替代方案 - Richaaaard - 博客园](http://www.cnblogs.com/richaaaard/p/6109595.html)
- [ELK 性能(2) &mdash; 如何在大业务量下保持 Elasticsearch 集群的稳定 - Richaaaard - 博客园](http://www.cnblogs.com/richaaaard/p/6117089.html)
- [ELK 性能(3) &mdash; 在 Docker 上运行高性能容错的 Elasticsearch 集群 - Richaaaard - 博客园](http://www.cnblogs.com/richaaaard/p/6118286.html)
- [ELK 性能(4) &mdash; 大规模 Elasticsearch 集群性能的最佳实践 - Richaaaard - 博客园](http://www.cnblogs.com/richaaaard/p/6121251.html)
- [三款日志管理工具横向对比：Splunk vs Sumo Logic vs Logstash](http://www.infoq.com/cn/news/2015/04/on-premises-saas)
- [Logstash：日志文件管理工具 - 资源 - 伯乐在线](http://hao.jobbole.com/logstash/)
- [日志客户端（Logstash,Fluentd, Logtail）横评-博客-云栖社区-阿里云](https://yq.aliyun.com/articles/3228)
- [Configure elasticsearch logstash filebeats with shield to monitor nginx access.log](https://z0z0.me/configure-elasticsearch-logstash-filebeats-with-shield/)
- [Logstash 处理多种格式日志](http://soft.dog/2016/01/31/logstash-mutitype-log/)
- [ELK + filebeat 日志分析工具的部署和简单应用 - 简书](http://www.jianshu.com/p/f6c7c8f1bce0)
- []()


#setup

- [Logstash Configuration Files | Logstash Reference [5.4] | Elastic](https://www.elastic.co/guide/en/logstash/current/config-setting-files.html)


#configuration

- [Configuring Logstash | Logstash Reference [5.4] | Elastic](https://www.elastic.co/guide/en/logstash/current/configuration.html)
- [Logstash Configuration Examples | Logstash Reference [5.4] | Elastic](https://www.elastic.co/guide/en/logstash/current/config-examples.html)


#filter

- [Grok 正则捕获 | Logstash 最佳实践](http://udn.yyuap.com/doc/logstash-best-practice-cn/filter/grok.html)
- [grok | Logstash Reference [5.4] | Elastic](https://www.elastic.co/guide/en/logstash/current/plugins-filters-grok.html)
- [使用Logstash的grok过滤日志文件 - Linux SA John - 51CTO技术博客](http://john88wang.blog.51cto.com/2165294/1630850)（%{SYNTAX:SEMANTIC}SYNTAX是文本要匹配的模式，SEMANTIC 是匹配到的文本片段的标识。）
- [logstash-patterns-core/patterns at master &middot; logstash-plugins/logstash-patterns-core](https://github.com/logstash-plugins/logstash-patterns-core/tree/master/patterns)（匹配的模式）
- [logstash之grok过滤 - 博客频道 - CSDN.NET](http://blog.csdn.net/yanggd1987/article/details/50486779)


#input
- [beats | Logstash Reference [5.4] | Elastic](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-beats.html)

