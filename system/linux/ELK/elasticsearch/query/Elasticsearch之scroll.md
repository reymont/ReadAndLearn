Elasticsearch之scroll，elasticsearch_云计算 | 帮客之家 
http://www.bkjia.com/yjs/989211.html

Elasticsearch之scroll，elasticsearch


一个search请求只能返回结果的一个单页（10条记录），而scroll API能够用来从一个单一的search请求中检索大量的结果（甚至全部）
，这种行为就像你在一个传统数据库内使用一个游标一样。
scrolling目的不是为了实用用户请求，而是为了处理大量数据。比如为了将一个索引的内容重新插入到一个具有不同配置的新索引中。
scroll请求返回的结果反映了初始search请求建立时索引的状态。它就像一个实时的快照，后续对文本的改变（插入，更新或者删除）
都仅仅影响了后来的search请求。
为了使用scrolling,初始的search 请求必须在query字符串中指定scroll参数，以告诉Elasticsearch必须将‘搜索上下文’保持存在多久（查阅Keeping the search context alive）。比如scroll=1m
curl -XGET 'localhost:9200/twitter/tweet/_search?scroll=1m' -d '
{
    "query": {
        "match" : {
            "title" : "elasticsearch"
        }
    }
}
'


以上查询的结果会包括一个 ‘_scroll_id’
 "_scroll_id" : "cXVlcnlUaGVuRmV0Y2g7NTs2OkZlNEJsY014VHBHVFNEelA0ZlI3Ync7NzpGZTRCbGNNeFRwR1RTRHpQNGZSN2J3Ozg6RmU0Qmx
jTXhUcEdUU0R6UDRmUjdidzs5OkZlNEJsY014VHBHVFNEelA0ZlI3Ync7MTA6RmU0QmxjTXhUcEdUU0R6UDRmUjdidzswOw==",
  "took" : 1,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 0,
    "max_score" : null,
    "hits" : [ ]
  }
,为了检索下一批结果，这个id必须要传递到scroll API。
curl -XGET  'localhost:9200/_search/scroll?scroll=1m'   \
     -d       ‘cXVlcnlUaGVuRmV0Y2g7NTs2OkZlNEJsY014VHBHVFNEelA0ZlI3Ync7NzpGZTRCbGNNeFRwR1RTRHpQNGZSN2J3Ozg6RmU0Q
mxjTXhUcEdUU0R6UDRmUjdidzs5OkZlNEJsY014VHBHVFNEelA0ZlI3Ync7MTA6RmU0QmxjTXhUcEdUU0R6UDRmUjdidzswOw==’
URL不能包括index或者type名字，而是应该在原始search请求时指定。
scroll参数通知Elasticsearch将搜索上下文再保持1分钟（1m）
scroll_id能够在请求体内部传递或者在query字符串里作为?’scroll_id’=传递。
每一次对scrollAPI的请求都会返回结果的下一批直到没有更多的结果返回为止。比如，当hits数组为空的时候。
初始search请求和每一个后续的scroll请求都会返回一个新的scroll_id——必须使用最新的scroll_id。
切记：如果请求指定了聚合，那么只有初始的search返回会包含聚合结果。
使用Scroll-Scan实现高效率的scrolling.
在这个例子中，使用from 和size——比如？size=10&from=10000实现深度分页是非常低效的。因为仅仅为了返回10个结果，
必须从每个shard检索出100,000个排好序的结果。并且每次分页请求的时候这个过程都必须重复。
scroll API能够跟踪已经返回的那些结果，因此能够比深度分页更加有效的返回已排序好的结果。然而，对结果排序（默认会执行）仍然有代价
通常来说，你仅仅想要检索所有结果而不在乎顺序。Scrolling能够合并扫描查询类型来取消评分和排序，以最可能有效的方法返回结果。
所有这些都只需要在原始search请求的query字符串中增加‘search_type=scan’:
curl 'localhost:9200/twitter/tweet/_search?scroll=1m&search_type=scan' ①-d '
{
    "query": {
        "match" : {
            "title" : "elasticsearch"
        }
    }
}
'
①将search_type设置为scan,禁止了排序，使得scrolling更有效。


一个 扫描scroll请求和一个标准scroll请求在以下四个方面不同：
1.不计算分值，不排序。索引中是怎么样的顺序，返回的结果就是什么顺序；
2.不支持聚合。
3.原始search请求的返回在hits内不包含任何结果。初始结果会在第一次scroll请求中返回。
4.size参数不控制每个请求的结果数，而是控制每个shard的结果数，因此size=10 且命中5个shard会在每次scroll请求中返回最大50个结果。
如果你想评分，即使没有排序，将track_scores参数设置为true就行了。
保持搜索上下文活跃
scroll参数（传给search请求和每一个scroll请求）告知Elasticsearch必须将搜索上下文保持多久。它的值（比如1m）,并不需要足够长来处理
所有数据——它只需要满足能够处理前期批次的结果就行了。每一次scroll请求都会通过scoll参数来设置一个新的延期时间。
通常，后台合并进程通过将很小的分块合并成新的更大的分块，同时小分块被删除的方法来优化索引。在scrolling期间，这个进程会继续。
但是如果发现老的分块还在用的话，一个开放的搜索上下文会阻止它们被删除。这就是Elasticsearch能够忽视文本的后续修改，返回初始search
请求的结果的原因。
保持旧的分块活跃意味着需要更多文件句柄。所以要确保你在节点中配置了足够空闲的文件句柄。
可以使用节点stats API查看开放了多少个搜索上下文：
curl -XGET localhost:9200/_nodes/stats/indices/search?pretty


清除scroll API
当已经检索出所有结果或者scroll执行超时，搜索上下文就会自动移除。当然，你也可以使用clear-scroll API手动清除一个搜索上下文。
curl -XDELETE localhost:9200/_search/scroll \
     -d 'c2Nhbjs2OzM0NDg1ODpzRlBLc0FXNlNyNm5JWUc1'


scroll_id能够在请求体或者query字符串中传递。
多个scroll ID能够已逗号分开的值来传递。
curl -XDELETE localhost:9200/_search/scroll \
     -d 'c2Nhbjs2OzM0NDg1ODpzRlBLc0FXNlNyNm5JWUc1,aGVuRmV0Y2g7NTsxOnkxaDZ'
所有搜索上下文能够通过_all参数一次删除：
curl -XDELETE localhost:9200/_search/scroll/_all


原文：http://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-scroll.html
