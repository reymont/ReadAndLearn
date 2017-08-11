#Aggregation

<!-- @import "[TOC]" {cmd:"toc", depthFrom:1, depthTo:6, orderedList:false} -->
<!-- code_chunk_output -->

* [Aggregation](#aggregation)
* [Date Histogram Aggregation](#date-histogram-aggregation)
	* [时间偏移量](#时间偏移量)

<!-- /code_chunk_output -->


#Date Histogram Aggregation

##时间偏移量

[Date Histogram Aggregation | Elasticsearch Reference [5.5] | Elastic ](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-datehistogram-aggregation.html)


The **offset** parameter is used to change the start value of each bucket by the specified positive (+) or negative offset (-) duration, such as 1h for an hour, or 1d for a day. See the section called “Time unitsedit” for more possible time duration options.

For instance, when using an interval of day, each bucket runs from midnight to midnight. Setting the offset parameter to +6h would change each bucket to run from 6am to 6am:

````json
PUT my_index/log/1?refresh
{
  "date": "2015-10-01T05:30:00Z"
}

PUT my_index/log/2?refresh
{
  "date": "2015-10-01T06:30:00Z"
}

GET my_index/_search?size=0
{
  "aggs": {
    "by_day": {
      "date_histogram": {
        "field":     "date",
        "interval":  "day",
        "offset":    "+6h"
      }
    }
  }
}
```
Instead of a single bucket starting at midnight, the above request groups the documents into buckets starting at 6am:

```json
{
  ...
  "aggregations": {
    "by_day": {
      "buckets": [
        {
          "key_as_string": "2015-09-30T06:00:00.000Z",
          "key": 1443592800000,
          "doc_count": 1
        },
        {
          "key_as_string": "2015-10-01T06:00:00.000Z",
          "key": 1443679200000,
          "doc_count": 1
        }
      ]
    }
  }
}
```
Note
The start offset of each bucket is calculated after the time_zone adjustments have been made.