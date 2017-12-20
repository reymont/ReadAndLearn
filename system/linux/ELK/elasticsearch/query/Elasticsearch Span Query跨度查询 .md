Elasticsearch Span Query跨度查询 - xingoo - 博客园 
http://www.cnblogs.com/xing901022/p/4982698.html


span_term查询
这个查询如果单独使用，效果跟term查询差不多，但是一般还是用于其他的span查询的子查询。
用法也很简单，只需要指定查询的字段即可：
{
    "span_term" : { "user" : "kimchy" }
}
另外，还可以指定查询出的分值倍数：
{
    "span_term" : { "user" : { "value" : "kimchy", "boost" : 2.0 } }
}
span_multi查询
span_multi可以包装一个multi_term查询，比如wildcard,fuzzy,prefix,term,range或者regexp等等，把他们包装起来当做一个span查询。
用法也比较简单，内部嵌套一个普通的multi_term查询就行了：
 
{
    "span_multi":{
        "match":{
            "prefix" : { "user" :  { "value" : "ki" } }
        }
    }
}
 
也可以使用boost乘以分值，以改变查询结果的分数：
 
{
    "span_multi":{
        "match":{
            "prefix" : { "user" :  { "value" : "ki", "boost" : 1.08 } }
        }
    }
}
 
span_first查询
这个查询用于确定一个单词相对于起始位置的偏移位置，举个例子：
如果一个文档字段的内容是：“hello,my name is tom”，我们要检索tom，那么它的span_first最小应该是5，否则就查找不到。
使用的时候，只是比span_term多了一个end界定而已：
 
{
    "span_first" : {
        "match" : {
            "span_term" : { "user" : "kimchy" }
        },
        "end" : 3
    }
}
 
span_near查询
这个查询主要用于确定几个span_term之间的距离，通常用于检索某些相邻的单词，避免在全局跨字段检索而干扰最终的结果。
查询主要由两部分组成，一部分是嵌套的子span查询，另一部分就是他们之间的最大的跨度
 
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
 
上面的例子中，value1，value2，value3最长的跨度不能超过12.
span_or查询
这个查询会嵌套一些子查询，子查询之间的逻辑关系为 或
 
{
    "span_or" : {
        "clauses" : [
            { "span_term" : { "field" : "value1" } },
            { "span_term" : { "field" : "value2" } },
            { "span_term" : { "field" : "value3" } }
        ]
    }
}
 
span_not查询
这个查询相对于span_or来说，就是排除的意思。不过它内部有几个属性，include用于定义包含的span查询；exclude用于定义排除的span查询
 
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
 
span_containing查询
这个查询内部会有多个子查询，但是会设定某个子查询优先级更高，作用更大，通过关键字little和big来指定。
 
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
 
span_within查询
这个查询与span_containing查询作用差不多，不过span_containing是基于lucene中的SpanContainingQuery，而span_within则是基于SpanWithinQuery。
分类: Elasticsearch
标签: elasticsearch, ES, Span Query, 跨度查询
