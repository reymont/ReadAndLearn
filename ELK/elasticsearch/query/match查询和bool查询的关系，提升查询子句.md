

[Elasticsearch] 全文搜索 (三) - match查询和bool查询的关系，提升查询子句 - dm_vincent的专栏 - 博客频道 - CSDN.NET 
http://blog.csdn.net/dm_vincent/article/details/41743955

match查询是如何使用bool查询的
现在，你也许意识到了使用了match查询的多词查询只是简单地将生成的term查询包含在了一个bool查询中。通过默认的or操作符，每个term查询都以一个语句被添加，所以至少一个should语句需要被匹配。以下两个查询是等价的：
{
    "match": { "title": "brown fox"}
}

{
  "bool": {
    "should": [
      { "term": { "title": "brown" }},
      { "term": { "title": "fox"   }}
    ]
  }
}
使用and操作符时，所有的term查询都以must语句被添加，因此所有的查询都需要匹配。以下两个查询是等价的：
{
    "match": {
        "title": {
            "query":    "brown fox",
            "operator": "and"
        }
    }
}

{
  "bool": {
    "must": [
      { "term": { "title": "brown" }},
      { "term": { "title": "fox"   }}
    ]
  }
}
如果指定了minimum_should_match参数，它会直接被传入到bool查询中，因此下面两个查询是等价的：
{
    "match": {
        "title": {
            "query":                "quick brown fox",
            "minimum_should_match": "75%"
        }
    }
}

{
  "bool": {
    "should": [
      { "term": { "title": "brown" }},
      { "term": { "title": "fox"   }},
      { "term": { "title": "quick" }}
    ],
    "minimum_should_match": 2 
  }
}
因为只有3个查询语句，minimum_should_match的值75%会被向下舍入到2。即至少两个should语句需要匹配。
当然，我们可以通过match查询来编写这类查询，但是理解match查询的内部工作原理能够让你根据需要来控制该过程。有些行为无法通过一个match查询完成，比如对部分查询词条给予更多的权重。在下一节中我们会看到一个例子。


提升查询子句(Boosting Query Clause)
当然，bool查询并不是只能合并简单的单词(One-word)match查询。它能够合并任何其它的查询，包括其它的bool查询。它通常被用来通过合并数个单独的查询的分值来调优每份文档的相关度_score。
假设我们需要搜索和"full-text search"相关的文档，但是我们想要给予那些提到了"Elasticsearch"或者"Lucene"的文档更多权重。更多权重的意思是，对于提到了"Elasticsearch"或者"Lucene"的文档，它们的相关度_score会更高，即它们会出现在结果列表的前面。
一个简单的bool查询能够让我们表达较为复杂的逻辑：
GET /_search
{
    "query": {
        "bool": {
            "must": {
                "match": {
                    "content": { 
                        "query":    "full text search",
                        "operator": "and"
                    }
                }
            },
            "should": [ 
                { "match": { "content": "Elasticsearch" }},
                { "match": { "content": "Lucene"        }}
            ]
        }
    }
}
1.	content字段必须含有full，text和search这三个词条
2.	如果content字段也含有了词条Elasticsearch或者Lucene，那么该文档会有一个较高的_score
should查询子句的匹配数量越多，那么文档的相关度就越高。目前为止还不错。
但是如果我们想给含有Lucene的文档多一些权重，同时给含有Elasticsearch的文档更多一些权重呢？
我们可以通过指定一个boost值来控制每个查询子句的相对权重，该值默认为1。一个大于1的boost会增加该查询子句的相对权重。因此我们可以将上述查询重写如下：
GET /_search
{
    "query": {
        "bool": {
            "must": {
                "match": {  
                    "content": {
                        "query":    "full text search",
                        "operator": "and"
                    }
                }
            },
            "should": [
                { "match": {
                    "content": {
                        "query": "Elasticsearch",
                        "boost": 3 
                    }
                }},
                { "match": {
                    "content": {
                        "query": "Lucene",
                        "boost": 2 
                    }
                }}
            ]
        }
    }
}
NOTE
boost参数被用来增加一个子句的相对权重(当boost大于1时)，或者减小相对权重(当boost介于0到1时)，但是增加或者减小不是线性的。换言之，boost设为2并不会让最终的_score加倍。
相反，新的_score会在适用了boost后被归一化(Normalized)。每种查询都有自己的归一化算法(Normalization Algorithm)，算法的细节超出了本书的讨论范围。但是能够说一个高的boost值会产生一个高的_score。
如果你在实现你自己的不基于TF/IDF的相关度分值模型并且你需要对提升过程拥有更多的控制，你可以使用function_score查询，它不通过归一化步骤对文档的boost进行操作。
在下一章中，我们会介绍其它的用于合并查询的方法，多字段查询(Multifield Search)。但是，首先让我们看看查询的另一个重要特定：文本分析(Text Analysis)。
