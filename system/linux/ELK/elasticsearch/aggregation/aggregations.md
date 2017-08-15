

* [Aggregations | Elasticsearch Reference [5.5] | Elastic ](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations.html)

```json
"aggregations" : {
    "<aggregation_name>" : {
        "<aggregation_type>" : {
            <aggregation_body>
        }
        [,"meta" : {  [<meta_data_body>] } ]?
        [,"aggregations" : { [<sub_aggregation>]+ } ]?
    }
    [,"<aggregation_name_2>" : { ... } ]*
}
```