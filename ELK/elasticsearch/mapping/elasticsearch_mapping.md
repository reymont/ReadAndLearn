#映射与模板

<!-- @import "[TOC]" {cmd:"toc", depthFrom:1, depthTo:6, orderedList:false} -->
<!-- code_chunk_output -->

* [映射与模板](#映射与模板)
	* [自定义映射](#自定义映射)
		* [精确索引](#精确索引)
		* [时间格式](#时间格式)
		* [多重索引](#多重索引)
	* [特殊字段](#特殊字段)
	* [动态模板映射](#动态模板映射)
		* [match_mapping_type](#match_mapping_type)
		* [match and unmatch](#match-and-unmatch)
		* [match_pattern](#match_pattern)
		* [path_match and path_unmatch](#path_match-and-path_unmatch)
		* [Disabled norms](#disabled-norms)
	* [索引模板](#索引模板)
* [Mapping参数](#mapping参数)
* [参考](#参考)

<!-- /code_chunk_output -->



Elasticsearch是一个schema-less的系统，但并不代表no schema，而是会尽量根据JSON源数据的基础类型猜测你想要的字段类型映射【1】。

##自定义映射

###精确索引

类型（type）和索引方式（index）

index有三个可设置项
- analyzed默认，以标准的全文索引方式，分析字符串，完成索引
- not_analyzed精确索引，不对字符串做分析，直接索引字段数据的精确内容
- no不索引该字段

###时间格式

@timestamp这个时间格式在Nginx中叫$time_iso8601，在Rsyslog中叫date-rfc3339,在Elasticsearch中叫dateOptionalTime。Elasticsearch默认的时间字段格式dateOptionalTime，还有UNIX_S毫秒级UNIX时间戳【1】

###多重索引

在数据写入时，自动生成两个字段。可以做分词与不分词结果的环境下。

2.x
```json
"title" : {
	"type" : "string",
	"fields" : {
		"raw" : {
			"type" : "string",
			"index" : "not_analyzed"		
		}
	}
}
```

在title字段数据写入的时候，Elasticsearch会自动生成两个字段，分别是title和title.raw

##特殊字段

1. _all存储了各字段的数据内容
2. _source存储了该条记录的JSON源数据内容，并不经过索引过程。不参与Query阶段，只用于Fetch阶段。


##动态模板映射

一类相似的数据字段，统一设置映射。

“match”
"match_mapping_type"


Dynamic templates allow you to define custom mappings that can be applied to dynamically added fields based on:
动态模板允许定义自定义映射，这些映射可以应用于动态添加的字段

- 通过[match_mapping_type](#match_mapping_type)，被Elasticsearch检测到的**数据类型（datatype）**。
- 通过[match and unmatch](#match-and-unmatch)或者[match_pattern](#match_pattern)，匹配字段名称（field name）。
- 通过[path_match and path_unmatch](#path_match-and-path_unmatch)，检测全点路径（full dotted path）。
The original field name {name} and the detected datatype {dynamic_type} template variables can be used in the mapping specification as placeholders.

Important
Dynamic field mappings are only added when a field contains a concrete value — not null or an empty array. This means that if the null_value option is used in a dynamic_template, it will only be applied after the first document with a concrete value for the field has been indexed.

Dynamic templates are specified as an array of named objects:
```json
  "dynamic_templates": [
    {
      "my_template_name": { 
        ...  match conditions ... 
        "mapping": { ... } 
      }
    },
    ...
  ]
```

The template name can be any string value.



The match conditions can include any of : match_mapping_type, match, match_pattern, unmatch, path_match, path_unmatch.



The mapping that the matched field should use.

Templates are processed in order — the first matching template wins. New templates can be appended to the end of the list with the PUT mapping API. If a new template has the same name as an existing template, it will replace the old version.

The match conditions can include any of : match_mapping_type, match, match_pattern, unmatch, path_match, path_unmatch【8】.

###match_mapping_type


###match and unmatch
The match parameter uses a pattern to match on the fieldname, while unmatch uses a pattern to exclude fields matched by match.

The following example matches all string fields whose name starts with long_ (except for those which end with _text) and maps them as long fields:
```json
PUT my_index
{
  "mappings": {
    "my_type": {
      "dynamic_templates": [
        {
          "longs_as_strings": {
            "match_mapping_type": "string",
            "match":   "long_*",
            "unmatch": "*_text",
            "mapping": {
              "type": "long"
            }
          }
        }
      ]
    }
  }
}

PUT my_index/my_type/1
{
  "long_num": "5", 
  "long_text": "foo" 
}
```


The long_num field is mapped as a long.



The long_text field uses the default string mapping.

###match_pattern
The match_pattern parameter adjusts the behavior of the match parameter such that it supports full Java regular expression matching on the field name instead of simple wildcards, for instance:
```json
  "match_pattern": "regex",
  "match": "^profit_\d+$"
```

###path_match and path_unmatch
The path_match and path_unmatch parameters work in the same way as match and unmatch, but operate on the full dotted path to the field, not just the final name, e.g. some_object.*.some_field.
比如：对象间的嵌套关系，some_object.*.some_field.

This example copies the values of any fields in the name object to the top-level full_name field, except for the middle field:
```json
PUT my_index
{
  "mappings": {
    "my_type": {
      "dynamic_templates": [
        {
          "full_name": {
            "path_match":   "name.*",
            "path_unmatch": "*.middle",
            "mapping": {
              "type":       "text",
              "copy_to":    "full_name"
            }
          }
        }
      ]
    }
  }
}

PUT my_index/my_type/1
{
  "name": {
    "first":  "Alice",
    "middle": "Mary",
    "last":   "White"
  }
}
```

###Disabled norms

Norms are index-time scoring factors. If you do not care about scoring, which would be the case for instance if you never sort documents by score, you could disable the storage of these scoring factors in the index and save some space.

norms参数用于标准化文档，以便查询时计算文档的相关性。norms虽然对评分有用，但是会消耗较多的磁盘空间，如果不需要对某个字段进行评分，最好不要开启norms【9】。

```json
PUT my_index
{
  "mappings": {
    "my_type": {
      "dynamic_templates": [
        {
          "strings_as_keywords": {
            "match_mapping_type": "string",
            "mapping": {
              "type": "text",
              "norms": false,
              "fields": {
                "keyword": {
                  "type": "keyword",
                  "ignore_above": 256
                }
              }
            }
          }
        }
      ]
    }
  }
}
```


##索引模板
避免手动创建映射的重复工作。

模板中的内容包括两大类，setting（设置）和mapping（映射）。setting部分，多维在elasticsearch.yml中可以设置全局配置的部分。

#Mapping参数



#参考
1. 饶琛琳. ELK stack权威指南[M]. 机械工业出版社, 2015.
2. [Elasticsearch学习笔记（四）Mapping映射 · ELK stack权威指南 · 看云 ](https://www.kancloud.cn/digest/elkstack/125564)
3. [类型和映射 | Elasticsearch: 权威指南 | Elastic ](https://www.elastic.co/guide/cn/elasticsearch/guide/current/mapping.html)
4. [映射 | Elasticsearch: 权威指南 | Elastic ](https://www.elastic.co/guide/cn/elasticsearch/guide/current/mapping-intro.html)
5. [映射 | Elasticsearch权威指南（中文版） ](https://es.xiaoleilu.com/052_Mapping_Analysis/45_Mapping.html)
6. [Mapping | Elasticsearch Reference [5.5] | Elastic ](https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping.html)
7. [Field datatypes | Elasticsearch Reference [5.5] | Elastic ](https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-types.html)
8. [Dynamic templates | Elasticsearch Reference [5.5] | Elastic ](https://www.elastic.co/guide/en/elasticsearch/reference/current/dynamic-templates.html)
9. [Elasticsearch 5.4 Mapping详解 - 姚攀的博客 - CSDN博客 ](http://blog.csdn.net/napoay/article/details/73100110)
10. [Dynamic Mapping | Elasticsearch Reference [5.5] | Elastic ](https://www.elastic.co/guide/en/elasticsearch/reference/current/dynamic-mapping.html)
11. [复合类型 | Elasticsearch权威指南（中文版） ](https://es.xiaoleilu.com/052_Mapping_Analysis/50_Complex_datatypes.html)