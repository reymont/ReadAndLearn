
term 和 terms是不同的，terms支持数组


* [Terms Query | Elasticsearch Reference [5.5] | Elastic ](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-terms-query.html)

```json
curl -XPUT 'localhost:9200/users/user/2?pretty' -H 'Content-Type: application/json' -d'
{
    "followers" : ["1", "3"]
}
'
curl -XPUT 'localhost:9200/tweets/tweet/1?pretty' -H 'Content-Type: application/json' -d'
{
    "user" : "1"
}
'
curl -XGET 'localhost:9200/tweets/_search?pretty' -H 'Content-Type: application/json' -d'
{
    "query" : {
        "terms" : {
            "user" : {
                "index" : "users",
                "type" : "user",
                "id" : "2",
                "path" : "followers"
            }
        }
    }
}
'
```