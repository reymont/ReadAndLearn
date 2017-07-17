#映射与模板

Elasticsearch是一个schema-less的系统，但并不代表no schema，而是会尽量根据JSON源数据的基础类型猜测你想要的字段类型映射【1】。
自定义映射
动态模板映射
索引模板，避免手动创建映射的重复工作。

#参考
1. 饶琛琳. ELK stack权威指南[M]. 机械工业出版社, 2015.
2. [Elasticsearch学习笔记（四）Mapping映射 · ELK stack权威指南 · 看云 ](https://www.kancloud.cn/digest/elkstack/125564)
3. [类型和映射 | Elasticsearch: 权威指南 | Elastic ](https://www.elastic.co/guide/cn/elasticsearch/guide/current/mapping.html)
4. [映射 | Elasticsearch: 权威指南 | Elastic ](https://www.elastic.co/guide/cn/elasticsearch/guide/current/mapping-intro.html)
5. [映射 | Elasticsearch权威指南（中文版） ](https://es.xiaoleilu.com/052_Mapping_Analysis/45_Mapping.html)
6. [Mapping | Elasticsearch Reference [5.5] | Elastic ](https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping.html)
7. [Field datatypes | Elasticsearch Reference [5.5] | Elastic ](https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-types.html)