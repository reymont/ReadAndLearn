#属性（properties）

<!-- @import "[TOC]" {cmd:"toc", depthFrom:1, depthTo:6, orderedList:false} -->
<!-- code_chunk_output -->

* [属性（properties）](#属性properties)
* [点符号](#点符号)
* [参考](#参考)

<!-- /code_chunk_output -->

Object或者nested类型，下面还有嵌套类型，可以通过properties参数指定【2】。
映射字段、对象字段和嵌套字段中的子字段称为**属性（properties）**。
**属性（properties）**可以是任何数据类型，包括对象字段和嵌套字段。 **属性（properties）** 可以添加【1】：
- 在创建索引时显式的定义**属性（properties）**。
- 通过PUT映射API，在添加或更新映射类型时显式地定义**属性（properties）**。
- 动态地索引包含文档的新字段。
下面是向映射字段、对象字段和嵌套字段添加**属性（properties）**的示例:

```json
PUT my_index
curl -XPUT 'localhost:9200/my_index?pretty' -H 'Content-Type: application/json' -d'
{
  "mappings": {
    "my_type": { //在映射字段my_type下面的Properties
      "properties": {
        "manager": { //在对象字段manager下面的Properties
          "properties": {
            "age":  { "type": "integer" },
            "name": { "type": "text"  }
          }
        },
        "employees": { //在嵌套字段employees下面的Properties
          "type": "nested",
          "properties": {
            "age":  { "type": "integer" },
            "name": { "type": "text"  }
          }
        }
      }
    }
  }
}
'
curl -XPUT 'localhost:9200/my_index/my_type/1?pretty' -H 'Content-Type: application/json' -d'
{
  "region": "US",
  "manager": {
    "name": "Alice White",
    "age": 30
  },
  "employees": [
    {
      "name": "John Smith",
      "age": 34
    },
    {
      "name": "Peter Brown",
      "age": 26
    }
  ]
}
'
curl localhost:9200/my_index/_search?pretty
{
  "took" : 7,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 1,
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "my_index",
        "_type" : "my_type",
        "_id" : "1",
        "_score" : 1.0,
        "_source" : {
          "region" : "US",
          "manager" : {
            "name" : "Alice White",
            "age" : 30
          },
          "employees" : [
            {
              "name" : "John Smith",
              "age" : 34
            },
            {
              "name" : "Peter Brown",
              "age" : 26
            }
          ]
        }
      }
    ]
  }
}
```

Tip
The properties setting is allowed to have different settings for fields of the same name in the same index. New properties can be added to existing fields using the PUT mapping API.
**属性（properties）**允许在相同的索引中相同名称的字段拥有不同的设置。可以使用PUT映射API将新属性添加到现有的字段中。

#点符号
内部字段可以用点符号表示查询、聚合等:
```json
//可以对manager.name、manager.age做搜索、聚合等操作。
curl -XGET 'localhost:9200/my_index/_search?pretty' -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "manager.name": "Alice White" 
    }
  },
  "aggs": {
    "Employees": {
      "nested": {
        "path": "employees"
      },
      "aggs": {
        "Employee Ages": {
          "histogram": {
            "field": "employees.age", 
            "interval": 5
          }
        }
      }
    }
  }
}
'
```
注意：
必须指定到内部字段的完整路径.

#参考

1. [Dynamic templates | Elasticsearch Reference [5.5] | Elastic ](https://www.elastic.co/guide/en/elasticsearch/reference/current/dynamic-templates.html)
2. [Elasticsearch 5.4 Mapping详解 - 姚攀的博客 - CSDN博客 ](http://blog.csdn.net/napoay/article/details/73100110)
3. [Dynamic Mapping | Elasticsearch Reference [5.5] | Elastic ](https://www.elastic.co/guide/en/elasticsearch/reference/current/dynamic-mapping.html)
4. [复合类型 | Elasticsearch权威指南（中文版） ](https://es.xiaoleilu.com/052_Mapping_Analysis/50_Complex_datatypes.html)