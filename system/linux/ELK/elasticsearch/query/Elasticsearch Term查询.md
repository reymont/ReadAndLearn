Elasticsearch Term查询 - taizhen/blog - 博客频道 - CSDN.NET 
http://blog.csdn.net/taizhenba/article/details/52457102



例如： put mapping
PUT my_index
{
  "mappings": {
    "my_type": {
      "properties": {
        "full_text": {
          "type":  "string"  
        },
        "exact_value": {
          "type":  "string",
          "index": "not_analyzed"  
        }
      }
    }
  }
当你put 一条数据时：
{
  "full_text":   "Quick Foxes!",  
  "exact_value": "Quick Foxes!"   
}
去查询时：
{"query":{"term":{"full_text":"Quick Foxes"}}}
 这样是没有数据的
因为full_text 是分词的没有Quick Foxes的它只有 Quick 和
 Foxes
{"query":{"term":{"exact_value":"Quick Foxes"}}}
 这样是有数据的


{"query":{"term":{"full_text":"
 Foxes"}}} 也是有数据的

{"query":{"match":{"full_text":"Quick
 Foxes"}}} 改成match 这样也是有数据的
