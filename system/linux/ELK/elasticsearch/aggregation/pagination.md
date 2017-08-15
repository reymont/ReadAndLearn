

* [Paging support for aggregations · Issue #4915 · elastic/elasticsearch ](https://github.com/elastic/elasticsearch/issues/4915)

* [Pagination | Elasticsearch: The Definitive Guide [2.x] | Elastic ](https://www.elastic.co/guide/en/elasticsearch/guide/current/pagination.html)


```sh
curl -XGET 'localhost:9200/_search?size=5&pretty'
curl -XGET 'localhost:9200/_search?size=5&from=5&pretty'
curl -XGET 'localhost:9200/_search?size=5&from=10&pretty'
```

* [Elasticsearch——分页查询From&Size VS scroll - xingoo - 博客园 ](http://www.cnblogs.com/xing901022/p/5284902.html)

* [Terms Aggregation | Elasticsearch Reference [5.5] | Elastic ](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-terms-aggregation.html)