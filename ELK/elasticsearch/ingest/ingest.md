# Ingest Node

- [Ingest Node | Elasticsearch Reference [5.5] | Elastic ](https://www.elastic.co/guide/en/elasticsearch/reference/current/ingest.html)

在实际的索引发生之前，可以将ingest节点用于预处理文档。这种预处理发生在一个ingest节点，该节点拦截批量和索引请求，应用转换，然后将文档传递回索引或批量api。

可以在任何节点上启用ingest，甚至配置节点专门做ingest。节点默认启用Ingest。想在节点上禁用ingest，可以在elasticsearch.yml文件中中设置:
```yml
node.ingest: false
```
在索引之前对预处理文档进行定义，定义了指定一系列处理器的管道。每个进程以某种方式转换文档。例如，可能有一条由一个进程组成的管道，它从文档中删除一个字段，然后再由另一个进程重命名一个字段。

要使用管道，只需在索引或批量请求中指定管道参数，告诉正在使用管道的ingest节点。例如:

```bash
curl -XPUT 'localhost:9200/my-index/my-type/my-id?pipeline=my_pipeline_id&pretty' -H 'Content-Type: application/json' -d'
{
  "foo": "bar"
}
'
```