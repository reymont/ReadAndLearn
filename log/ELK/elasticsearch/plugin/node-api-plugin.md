

https://www.elastic.co/guide/en/elasticsearch/reference/6.0/cluster-nodes-info.html

```sh
# return just process
curl -XGET 'localhost:9200/_nodes/process?pretty'
# same as above
curl -XGET 'localhost:9200/_nodes/_all/process?pretty'
# return just jvm and process of only nodeId1 and nodeId2
curl -XGET 'localhost:9200/_nodes/nodeId1,nodeId2/jvm,process?pretty'
# same as above
curl -XGET 'localhost:9200/_nodes/nodeId1,nodeId2/info/jvm,process?pretty'
# return all the information of only nodeId1 and nodeId2
curl -XGET 'localhost:9200/_nodes/nodeId1,nodeId2/_all?pretty'
# plugins - if set, the result will contain details about the installed plugins and modules per node:
curl -XGET 'localhost:9200/_nodes/plugins?pretty'
```
