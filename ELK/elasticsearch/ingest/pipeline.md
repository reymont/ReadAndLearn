#管道的定义

- [Pipeline Definition | Elasticsearch Reference [5.5] | Elastic ](https://www.elastic.co/guide/en/elasticsearch/reference/current/pipeline.html)

Ingest APIs  » Pipeline Definition
  
管道是一系列`进程processors`的定义，这些`进程processors`的执行顺序与声明的顺序相同。管道由两个主要字段组成：描述和列表:
```json
{
  "description" : "...",
  "processors" : [ ... ]
}
```
描述是一个特殊的字段，用来保存管道作用的描述。

`进程processors`参数定义要按顺序执行的列表。