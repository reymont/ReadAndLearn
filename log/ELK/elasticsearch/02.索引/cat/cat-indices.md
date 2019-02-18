

## 1. Sort 排序

```sh
#按index升序，docs.count降序
GET _cat/indices?v&h=index,docs.count,store.size&bytes=kb&format=json&pretty&s=index,docs.count:desc

[
  {
    "index": ".kibana",
    "docs.count": "1",
    "store.size": "7"
  },
  {
    "index": ".monitoring-es-6-2018.08.25",
    "docs.count": "608",
    "store.size": "1068"
  },
  {
    "index": ".monitoring-kibana-6-2018.08.25",
    "docs.count": "33",
    "store.size": "163"
  },
  {
    "index": ".security-6",
    "docs.count": "3",
    "store.size": "19"
  }
]
```

## 参考

1. https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-indices.html
2. [Elasticsearch Cat 命令](https://blog.csdn.net/wangpei1949/article/details/82287444)