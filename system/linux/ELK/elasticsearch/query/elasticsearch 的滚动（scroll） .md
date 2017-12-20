
elasticsearch 的滚动（scroll） - 简书 
http://www.jianshu.com/p/14aa8b09c789

Scroll
________________________________________
search 请求返回一个单一的结果“页”，而 scroll API 可以被用来检索大量的结果（甚至所有的结果），就像在传统数据库中使用的游标 cursor。
滚动并不是为了实时的用户响应，而是为了处理大量的数据，例如，为了使用不同的配置来重新索引一个 index 到另一个 index 中去。
client 支持：Perl 和 Python
注意：从 scroll 请求返回的结果反映了 search 发生时刻的索引状态，就像一个快照。后续的对文档的改动（索引、更新或者删除）都只会影响后面的搜索请求。
为了使用 scroll，初始搜索请求应该在查询中指定 scroll 参数，这可以告诉 Elasticsearch 需要保持搜索的上下文环境多久（参考Keeping the search context alive），如 ?scroll=1m。
curl -XGET 'localhost:9200/twitter/tweet/_search?scroll=1m' -d '
{
    "query": {
        "match" : {
            "title" : "elasticsearch"
        }
    }
}
'
使用上面的请求返回的结果中包含一个 scroll_id，这个 ID 可以被传递给 scroll API 来检索下一个批次的结果。
curl -XGET  'localhost:9200/_search/scroll'  -d'
{
    "scroll" : "1m", 
    "scroll_id" : "c2Nhbjs2OzM0NDg1ODpzRlBLc0FXNlNyNm5JWUc1" 
}
'
•	GET 或者 POST 可以使用
•	URL不应该包含 index 或者 type 名字——这些都指定在了原始的 search 请求中。
•	scroll 参数告诉 Elasticsearch 保持搜索的上下文等待另一个 1m 
•	scroll_id 参数
每次对 scroll API 的调用返回了结果的下一个批次知道没有更多的结果返回，也就是直到 hits 数组空了。
为了向前兼容，scroll_id 和 scroll 可以放在查询字符串中传递。scroll_id 则可以在请求体中传递。
curl -XGET 'localhost:9200/_search/scroll?scroll=1m' -d 'c2Nhbjs2OzM0NDg1ODpzRlBLc0FXNlNyNm5JWUc1'
注意：初始搜索请求和每个后续滚动请求返回一个新的 _scroll_id——只有最近的 _scroll_id 才能被使用。
如果请求指定了聚合（aggregation），仅仅初始搜索响应才会包含聚合结果。
使用 scroll-scan 的高效滚动
使用 from and size 的深度分页，比如说 ?size=10&from=10000 是非常低效的，因为 100,000 排序的结果必须从每个分片上取出并重新排序最后返回 10 条。这个过程需要对每个请求页重复。
scroll API 保持了哪些结果已经返回的记录，所以能更加高效地返回排序的结果。但是，按照默认设定排序结果仍然需要代价。
一般来说，你仅仅想要找到结果，不关心顺序。你可以通过组合 scroll 和 scan 来关闭任何打分或者排序，以最高效的方式返回结果。你需要做的就是将 search_type=scan 加入到查询的字符串中：
curl -XGET 'localhost:9200/twitter/tweet/_search?scroll=1m&search_type=scan' -d '
{
    "query": {
        "match" : {
            "title" : "elasticsearch"
        }
    }
}
'
•	设置 search_type 为 scan 可以关闭打分，让滚动更加高效。
扫描式的滚动请求和标准的滚动请求有四处不同：
•	不算分，关闭排序。结果会按照在索引中出现的顺序返回。
•	不支持聚合
•	初始 search 请求的响应不会在 hits 数组中包含任何结果。第一批结果就会按照第一个 scroll 请求返回。
•	参数 size 控制了每个分片上而非每个请求的结果数目，所以 size 为 10 的情况下，如果命中了 5 个分片，那么每个 scroll 请求最多会返回 50 个结果。
如果你想支持打分，即使不进行排序，将 track_scores 设置为 true。
保持搜索上下文存活
参数 scroll （传递给 search 请求还有每个 scroll 请求）告诉 Elasticsearch 应该需要保持搜索上下文多久。这个值（比如说 1m，详情请见the section called “Time units）并不需要长到可以处理所有的数据——仅仅需要足够长来处理前一批次的结果。每个 scroll 请求（包含 scroll 参数）设置了一个新的失效时间。
一般来说，背后的合并过程通过合并更小的分段创建更大的分段来优化索引，同时会删除更小的分段。这个过程在滚动时进行，但是一个打开状态的搜索上下文阻止了旧分段在使用的时候不会被删除。这就是 Elasticsearch 能够不管后续的文档的变化，返回初始搜索请求的结果的原因。
保持旧的分段存活意味着会产生更多的文件句柄。确保你配置了节点有空闲的文件句柄。参考File Descriptors
你可以检查有多少搜索上下文开启了，
curl -XGET localhost:9200/_nodes/stats/indices/search?pretty
清除 scroll API
搜索上下文当 scroll 超时就会自动移除。但是保持 scroll 存活需要代价，如在前一节讲的那样，所以 scrolls 当scroll不再被使用的时候需要被用 clear-scroll 显式地清除：
curl -XDELETE localhost:9200/_search/scroll -d '
{ 
  "scroll_id" : ["c2Nhbjs2OzM0NDg1ODpzRlBLc0FXNlNyNm5JWUc1"]
}'
2.0.0-beta1 中加入。基于请求体的参数在 2.0.0 中加入。
多个 scroll ID 可按照数据传入：
curl -XDELETE localhost:9200/_search/scroll -d '
{ 
  "scroll_id" : ["c2Nhbjs2OzM0NDg1ODpzRlBLc0FXNlNyNm5JWUc1", "aGVuRmV0Y2g7NTsxOnkxaDZ"]
}'
2.0.0 中加入。
所有搜索上下文可以通过 _all 参数而清除：
curl -XDELETE localhost:9200/_search/scroll/_all
scroll_id 也可以使用一个查询字符串的参数或者在请求的body中传递。多个scroll ID 可以使用逗号分隔传入：
curl -XDELETE localhost:9200/_search/scroll \ -d 'c2Nhbjs2OzM0NDg1ODpzRlBLc0FXNlNyNm5JWUc1,aGVuRmV0Y2g7NTsxOnkxaDZ'
推荐拓展阅读

文／Not_GOD（简书作者）
原文链接：http://www.jianshu.com/p/14aa8b09c789
著作权归作者所有，转载请联系作者获得授权，并标注“简书作者”。
