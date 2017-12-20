Elasticsearch 2.3.0 DSL Span查询和查询重写参数 - 赛克蓝德的个人页面 - 开源中国社区 
https://my.oschina.net/secisland/blog/668798

SpanQuery是按照词在文章中的距离或者查询几个相邻词的查询。打个比方：如“中华人民共和国”    用“中国“做为关键字， 跨度为某个值，如5。跨度代表 中 和国之间的长度。这是比较底层的位置查询，通常用于实现非常具体的法律文件或专利的查询。处了span_multi查询外，跨度查询和非跨度查询不能在一起混合查询。跨度查询包括以下几种。
span_term查询：词距查询的基础，结果和TermQuery相似，只不过是增加了查询结果中单词的距离信息。例如：
{
    "span_term" : { "user" : "kimchy" }
}
{
    "span_term" : { "user" : { "value" : "kimchy", "boost" : 2.0 } }
}
{
    "span_term" : { "user" : { "term" : "kimchy", "boost" : 2.0 } }
}
span_multi查询：可以包含Term，范围，前缀，通配符，正则表达式，或模糊查询的组合查询。例如：
{
    "span_multi":{
        "match":{
            "prefix" : { "user" :  { "value" : "ki" } }
        }
    }
}
{
    "span_multi":{
        "match":{
            "prefix" : { "user" :  { "value" : "ki", "boost" : 1.08 } }
        }
    }
}
span_first查询：在指定距离可以找到第一个单词的查询。例如：
{
    "span_first" : {
        "match" : {
            "span_term" : { "user" : "kimchy" }
        },
        "end" : 3
    }
}
span_near查询：查询的几个语句之间保持者一定的距离。例如：
{
    "span_near" : {
        "clauses" : [
            { "span_term" : { "field" : "value1" } },
            { "span_term" : { "field" : "value2" } },
            { "span_term" : { "field" : "value3" } }
        ],
        "slop" : 12,
        "in_order" : false,
        "collect_payloads" : false
    }
}
clauses表示一个或多个其他的跨越式查询。
slop控制插入的允许最大数目的位置。
span_or查询：同时查询几个词句查询。
{
    "span_or" : {
        "clauses" : [
            { "span_term" : { "field" : "value1" } },
            { "span_term" : { "field" : "value2" } },
            { "span_term" : { "field" : "value3" } }
        ]
    }
}
span_not查询：从一个词距查询结果中，去除一个词距查询。
{
    "span_not" : {
        "include" : {
            "span_term" : { "field1" : "hoya" }
        },
        "exclude" : {
            "span_near" : {
                "clauses" : [
                    { "span_term" : { "field1" : "la" } },
                    { "span_term" : { "field1" : "hoya" } }
                ],
                "slop" : 0,
                "in_order" : true
            }
        }
    }
}
span_containing查询：返回在另一个范围内查询的匹配结果，从大到小包含。例如：
{
    "span_containing" : {
        "little" : {
            "span_term" : { "field1" : "foo" }
        },
        "big" : {
            "span_near" : {
                "clauses" : [
                    { "span_term" : { "field1" : "bar" } },
                    { "span_term" : { "field1" : "baz" } }
                ],
                "slop" : 5,
                "in_order" : true
            }
        }
    }
}
little和big可为任意跨度类型查询。
span_within查询：返回在另一个范围内查询的匹配结果，从小到大包含。例如：
{
    "span_within" : {
        "little" : {
            "span_term" : { "field1" : "foo" }
        },
        "big" : {
            "span_near" : {
                "clauses" : [
                    { "span_term" : { "field1" : "bar" } },
                    { "span_term" : { "field1" : "baz" } }
                ],
                "slop" : 5,
                "in_order" : true
            }
        }
    }
}
查询重写机制

    在多条件查询时，如通配符和前缀，最终会有一个查询重写的过程。系统可以通过参数控制他们用何种方式进行重写。
constant_score：系统默认参数，和constant_score_boolean 类似，如果有少量匹配项则显示匹配的文档，否则按顺序访问所有匹配项并标记文档，匹配的文档会分配一个查询到的固定分值。
scoring_boolean :该重写方法将对应的关键词转换成布尔查询的布尔Should子句，它有可能是CPU密集型的(因为每个关键词都需要计算得分)，而且如果关键词数量太多，则会超出布尔查询的限制，限制条件的上限是1024。与此同时，该类型的查询语句还保存计算的得分。布尔查询的默认数量限制可以通过修改elasticsearch.yml文件中的index.query.bool.max_clause_count属性值来修改。但始终要记住的是，产生的布尔查询子句越多，查询的性能越低。
constant_score_boolean:该重写方法与上面提到的scoring_boolean重写方法类似，但是CPU消耗要低很多，因为它不计算得分，每个关键词的得分就是查询的权重，默认是1，也可以通过权重属性来设置其它的值。与scoring_boolean重写方法类似，该方法也受到布尔查询数量的限制。
top_terms_N:该重写方法将对应的关键词转换成布尔查询的布尔Should子句，同时保存计算得分。只是与scoring_boolean不同点在于，它只保留前N个关键词，来避免触发布尔子句数量的上限。
top_terms_boost_N:该重写方法与top_terms_N类似，只是得分的计算只与权重有关，与查询词无关。
top_terms_blended_freqs_N：该重写方法将对应的关键词转换成布尔查询的布尔Should子句，如果他们有相同的频率则计算所有的查询分数，所使用的频率是所有匹配项的最大频率。此重写方法只使用最高评分条款，所以它不会溢出布尔最大子句计数。N参数控制使用的最高评分条款的大小。
赛克蓝德(secisland)后续会逐步对Elasticsearch的最新版本的各项功能进行分析，近请期待。也欢迎加入secisland公众号进行关注。

© 著作权归作者所有
•	分类：Elasticsearch
 
•	字数：1217
标签： Elasticsearch 赛克蓝德 日志分析 SeciLog

