

Elasticsearch(查询详解) - wsy的个人博客 - 开源中国社区
 https://my.oschina.net/wsyblog/blog/702841

Elasticsearch查询类型
Elasticsearch支持两种类型的查询：基本查询和复合查询。 基本查询，如词条查询用于查询实际数据。 复合查询，如布尔查询，可以合并多个查询， 然而，这不是全部。除了这两种类型的查询，你还可以用过滤查询，根据一定的条件缩小查询结果。不像其他查询，筛选查询不会影响得分，而且通常非常高效。 更加复杂的情况，查询可以包含其他查询。此外，一些查询可以包含过滤器，而其他查询可同时包含查询和过滤器。这并不是全部，但暂时先解释这些工作。
1.简单查询
这种查询方式很简单，但比较局限。 查询last_name字段中含有smith一词的文档，可以这样写：
http://127.0.0.1:9200/megacorp/employee/_search
{
    "query" : {
        "query_string" : { 
            "query" : "last_name:smith" 
        }
    }
}
返回格式如下:
{
  "took": 15,
  "timed_out": false,
  "_shards": {
    "total": 5,
    "successful": 5,
    "failed": 0
  },
  "hits": {
    "total": 2,
    "max_score": 0.30685282,
    "hits": [
      {
        "_index": "megacorp",
        "_type": "employee",
        "_id": "2",
        "_score": 0.30685282,
        "_source": {
          "first_name": "Jane",
          "last_name": "Smith",
          "age": 32,
          "about": "I like to collect rock albums",
          "interests": [
            "music"
          ]
        }
      },
      {
        "_index": "megacorp",
        "_type": "employee",
        "_id": "1",
        "_score": 0.30685282,
        "_source": {
          "first_name": "John",
          "last_name": "Smith",
          "age": 25,
          "about": "I love to go rock climbing",
          "interests": [
            "sports",
            "music"
          ]
        }
      }
    ]
  }
}
pretty=true参数会让Elasticsearch以更容易阅读的方式返回响应。
2.分页和结果集大小（from、size）
Elasticsearch能控制想要的最多结果数以及想从哪个结果开始。下面是可以在请求体中添加的两个额外参数。 from：该属性指定我们希望在结果中返回的起始文档。它的默认值是0，表示想要得到从第一个文档开始的结果。 size：该属性指定了一次查询中返回的最大文档数，默认值为10。如果只对切面结果感兴趣，并不关心文档本身，可以把这个参数设置成0。 如果想让查询从第2个文档开始返回20个文档，可以发送如下查询：
{
    "version" : true,//返回版本号
    "from" : 1,//从哪个文档开始（数组所以有0）
    "size" : 20,//返回多少个文档
    "query" : {
        "query_string" : { 
            "query" : "last_name:smith" 
        }
    }
}
选择返回字段（fields）
只返回age，about和last_name字段
{
    "fields":[ "age", "about","last_name" ],
    "query" : {
        "query_string" : { 
            "query" : "last_name:Smith" 
        }
    }
}
返回格式如下:
{
  "took": 3,
  "timed_out": false,
  "_shards": {
    "total": 5,
    "successful": 5,
    "failed": 0
  },
  "hits": {
    "total": 2,
    "max_score": 0.30685282,
    "hits": [
      {
        "_index": "megacorp",
        "_type": "employee",
        "_id": "2",
        "_score": 0.30685282,
        "fields": {
          "about": [
            "I like to collect rock albums"
          ],
          "last_name": [
            "Smith"
          ],
          "age": [
            32
          ]
        }
      },
      {
        "_index": "megacorp",
        "_type": "employee",
        "_id": "1",
        "_score": 0.30685282,
        "fields": {
          "about": [
            "I love to go rock climbing"
          ],
          "last_name": [
            "Smith"
          ],
          "age": [
            25
          ]
        }
      }
    ]
  }
}
•	如果没有定义fields数组，它将用默认值，如果有就返回_source字段；
•	如果使用_source字段，并且请求一个没有存储的字段，那么这个字段将从_source字段中提取（然而，这需要额外的处理）；
•	如果想返回所有的存储字段，只需传入星号（）作为字段名字。 *从性能的角度，返回_source字段比返回多个存储字段更好。
部分字段（include、exclude）
Elasticsearch公开了部分字段对象的include和exclude属性，所以可以基于这些属性来包含或排除字段。例如，为了在查询中包括以titl开头且排除以chara开头的字段，发出以下查询：
{
    "partial_fields" : {
        "partial1" : {
            "include" : [ "titl*" ],
            "exclude" : [ "chara*" ]
        }
    },
    "query" : {
        "query_string" : { "query" : "title:crime" }
    }
}
脚本字段(script_fields)
在JSON的查询对象中加上script_fields部分，添加上每个想返回的脚本值的名字。若要返回一个叫correctYear的值，它用year字段减去1800计算得来，运行以下查询：
{
    "script_fields" : {
        "correctYear" : {
            "script" : "doc['year'].value - 1800"
        }
    },
    "query" : {
        "query_string" : { "query" : "title:crime" }
    }
}
上面的示例中使用了doc符号，它让我们捕获了返回结果，从而让脚本执行速度更快，但也导致了更高的内存消耗，并且限制了只能用单个字段的单个值。如果关心内存的使用，或者使用的是更复杂的字段值，可以用_source字段。使用此字段的查询如下所示
{
    "script_fields" : {
        "correctYear" : {
            "script" : "_source.year - 1800"
        }
    },
    "query" : {
        "query_string" : { "query" : "title:crime" }
    }
}
返回格式如下:
{
    "took" : 1,
    "timed_out" : false,
    "_shards" : {
        "total" : 5,
        "successful" : 5,
        "failed" : 0
    },
    "hits" : {
        "total" : 1,
        "max_score" : 0.15342641,
        "hits" : [ {
            "_index" : "library",
            "_type" : "book",
            "_id" : "4",
            "_score" : 0.15342641,
            "fields" : {
                "correctYear" : [ 86 ]
            }
        } ]
    }
}
传参数到脚本字段中（script_fields）
一个脚本字段的特性：可传入额外的参数。可以使用一个变量名称，并把值传入params节中，而不是直接把1800写在等式中。这样做以后，查询将如下所示：
{
    "script_fields" : {
        "correctYear" : {
            "script" : "_source.year - paramYear",
            "params" : {
                "paramYear" : 1800
            }
        }
    },
    "query" : {
        "query_string" : { "query" : "title:crime" }
    }
}
基本查询
单词条查询:
最简单的词条查询如下所示：
{
    "query" : {
        "term" : {
            "last_name" : "smith"
        }
    }
}
多词条查询:
假设想得到所有在tags字段中含有novel或book的文档。运行以下查询来达到目的：
{
    "query" : {
        "terms" : {
            "tags" : [ "novel", "book" ],
            "minimum_match" : 1
        }
    }
}
上述查询返回在tags字段中包含一个或两个搜索词条的所有文档.minimum_match属性设置为1；这意味着至少有1个词条应该匹配。如果想要查询匹配所有词条的文档，可以把minimum_match属性设置为2。
match_all 查询
如果想得到索引中的所有文档，只需运行以下查询：
{
    "query" : {
        "match_all" : {}
    }
}
match 查询
{
    "query" : {
        "match" : {
            "title" : "crime and punishment"
        }
    }
}
上面的查询将匹配所有在title字段含有crime、and或punishment词条的文档。
match查询的几种类型
1 布尔值匹配查询（operator）
{
    "query" : {
        "match" : {
            "title" : {
                "query" : "crime and punishment",
                "operator" : "and"
            }
        }
    }
}
operator参数可接受or和and,用来决定查询中的所有条件的是or还是and。
2 match_phrase查询（slop）
这个可以查询类似 a+x+b，其中x是未知的。即知道了a和b，x未知的结果也可以查询出来。
{
    "query" : {
        "match_phrase" : {
            "title" : {
                "query" : "crime punishment",
                "slop" : 1
            }
        }
    }
}
注意，我们从查询中移除了and一词，但因为slop参数设置为1，它仍将匹配我们的文档。
slop：这是一个整数值，该值定义了文本查询中的词条和词条之间可以有多少个未知词条，以被视为跟一个短语匹配。此参数的默认值是0，这意味着，不允许有额外的词条，即上面的x可以是多个。
3 match_phrase_prefix查询
{
    "query" : {
        "match_phrase_prefix" : {
            "title" : {
                "query" : "crime and punishm",
                "slop" : 1,
                "max_expansions" : 20
            }
        }
       }
}
注意，我们没有提供完整的“crime and punishment”短语，而只是提供“crime and punishm”，该查询仍将匹配我们的文档。
multi_match 查询
multi_match查询和match查询一样，但是可以通过fields参数针对多个字段查询。当然，match查询中可以使用的所有参数同样可以在multi_match查询中使用。所以，如果想修改match查询，让它针对title和otitle字段运行，那么运行以下查询：
{
    "query" : {
        "multi_match" : {
            "query" : "crime punishment",
            "fields" : [ "title", "otitle" ]
        }
    }
}
前缀查询
想找到所有title字段以cri开始的文档，可以运行以下查询：
{
    "query" : {
        "prefix" : {
            "title" : "cri"
        }
    }
}
通配符查询
这里?表示任意字符：
{
    "query" : {
        "wildcard" : {
            "title" : "cr?me"
        }
    }
}
范围查询
•	gte：范围查询将匹配字段值大于或等于此参数值的文档。
•	gt：范围查询将匹配字段值大于此参数值的文档。
•	lte：范围查询将匹配字段值小于或等于此参数值的文档。
•	lt：范围查询将匹配字段值小于此参数值的文档。
举例来说，要找到year字段从1700到1900的所有图书，可以运行以下查询：
{
    "query" : {
        "range" : {
            "year" : {
                "gte" : 1700,
                "lte" : 1900
            }
        }
    }
}
复合查询
布尔查询
•	should：被它封装的布尔查询可能被匹配，也可能不被匹配。被匹配的should节点数由minimum_should_match参数控制。
•	must：被它封装的布尔查询必须被匹配，文档才会返回。
•	must_not：被它封装的布尔查询必须不被匹配，文档才会返回。
假设我们想要找到所有这样的文档：在title字段中含有crime词条，并且year字段可以在也可以不在1900~2000的范围里，在otitle字段中不可以包含nothing词条。用布尔查询的话，类似于下面的代码：
{
    "query" : {
        "bool" : {
            "must" : {
                "term" : {
                    "title" : "crime"
                }
            },
            "should" : {
                "range" : {
                    "year" : {
                        "from" : 1900,
                        "to" : 2000
                    }
                }
            },
            "must_not" : {
                "term" : {
                    "otitle" : "nothing"
                }
            }    
        }
    }
}
过滤器（不太理解过滤器的作用）
返回给定title的所有文档，但结果缩小到仅在1961年出版的书。使用filtered查询。如下：
{
    "query": {
        "filtered" : {
            "query" : {
            "match" : { "title" : "Catch-22" }
            },
            "filter" : {
                "term" : { "year" : 1961 }
            }
        }
    }
}
Demo
1.查询wechat_customer表中mid等于$mid,且subscribe=1的人。
http://localhost:9200/wechat_v6_count/wechat_customer/_search?search_type=count
//php代码
$esjson = array();
$esjson['query']['bool']['must'][] = array("term" => array("mid" => $mid));
$esjson['query']['bool']['must'][] = array("term" => array("subscribe" => 1));
$esjson['aggs'] = array("type_count" => array("value_count" => array("field" => "id")));
{
    "query":{
        "bool":{
            "must":[
            {    
                "term":{"mid":"55"}
            },{
                "term":{"subscribe":1}
            }]
        }
    },
    "aggs":{
        "type_count":{
            "value_count":{"field":"id"}
        }
    }
}
2.查询wechat_customer 中mid等于$mid,$rule大于等于$start，且subscribe等于1的人数。（聚合默认返回的条数为10，如果加上size等于0的参数则返回所有）
$esjson['query']['bool']['must'][] = array("range" => array($rule => array("gte"=>$start)));
$esjson['query']['bool']['must'][] = array("term" => array("mid" => $mid));
$esjson['query']['bool']['must'][] = array("term" => array("subscribe" => 1));
$esjson['aggs'] = array("type_count" => array("value_count" => array("field" => "id")));
$esjson = json_encode($esjson);
$esresult = ElasticsearchClient::searchForCount($esjson);
$result = $esresult['aggregations']['type_count']['value'];


//原来的sql
//$sql = "SELECT count(*) as 'cnt' from wechat_customer where mid =:mid AND " . $rule . ">=:start AND subscribe=1;";
//$params = array(':mid' => $mid, ':start' => $start);
esjson
{
    "query":{
        "bool":{
            "must":[
                {
                    "range":{
                        "action_count":{"gte":"15"}
                    }
                },
                {
                    "term":{"mid":"55"}
                },
                {
                    "term":{"subscribe":"1"}
                }
            ]
        }
    },
    "aggs":{
        "type_count":{
            "value_count":{"field":"id"}
        }
    }
}
