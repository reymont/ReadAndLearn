

http://xiaorui.cc/2015/06/09/通过elasticsearch自动化创建kibana的visualize图表及dashboard


最近系统因为几处连锁的bug造成数据的缺失，有个几百万条有效数据吧。 这边基于metric的报警还完善，自己写得关于量级判断还没上线，SO，在这样监控不给力的情况下，就需要产品经理自己去统计下。

文章写的不是很严谨，欢迎来喷，另外该文后续有更新的，请到原文地址查看更新.

http://xiaorui.cc/2015/06/09/%E9%80%9A%E8%BF%87elasticsearch%E8%87%AA%E5%8A%A8%E5%8C%96%E5%88%9B%E5%BB%BAkibana%E7%9A%84visualize%E5%9B%BE%E8%A1%A8%E5%8F%8Adashboard/

这边的对于数据日志的统计基本统一在了elk上了。  产品经理需要定期的登入到kibana上，想看相关的处理量级。  业务本身有任务的优先级，对于优先级高的网站，我们需要统一的统计，重点的网站不少，差不多有20多个。 我们对于监控的维度主要关注两个条件，一个是成功，一个是失败，所以需要在一个图上画出成功和失败的线条。 

刚介绍了我这次的任务，就是配合PM做出一个业务的dashboard来，因为20个，确实有些多。  所以就想到了用批量脚本的方式添加。 但是没有搜到相关的文章，貌似kibana也没有什么现成的api可以用，难道大家都不关心批量添加图表的功能么？   我们每次调整kibana数据后，都会做保存处理，但是kibana的配置会存在哪里？   客户端？ 但是他又怎么把这配置共享给别人呢 。  kibana4的服务端？ kibana就是一堆的angular js组成的接口调度。  最后在es里面看到了kibana的配置，他的index名字是.kibana

那么我们用postman来测试下，http://192.168.1.103:9000/.kibana/visualization/太平洋汽车 ，请求Method用get 。  返回的信息里面含有关于百度知道的条件.

,"params":{"filters":[{"input":{"query":{"query_string":{"query":"httpcode:200","analyze_wildcard":true}}}},{"input":{"query":{"query_string":{"query":"ERROR timeout","analyze_wildcard":true}}}}]

"kibanaSavedObjectMeta": {
"searchSourceJSON": "{"index":"logstash-*","query":{"query_string":{"analyze_wildcard":true,"query":"spider AND zhidao.baidu.com"}},"filter":[]}"

,"params":{"filters":[{"input":{"query":{"query_string":{"query":"httpcode:200","analyze_wildcard":true}}}},{"input":{"query":{"query_string":{"query":"ERROR timeout","analyze_wildcard":true}}}}]
 
 
 
"kibanaSavedObjectMeta": {
"searchSourceJSON": "{"index":"logstash-*","query":{"query_string":{"analyze_wildcard":true,"query":"spider AND zhidao.baidu.com"}},"filter":[]}"
}
下面是完整的返回的集合,信息涵盖了我们手动操作的配置，比如X轴的时间timestamp,Y轴的数据，然后针对Y轴的数据，还做了filters过滤。 


#xiaorui.cc
{
    "_index": ".kibana",
    "_type": "visualization",
    "_id": "太平洋汽车",
    "_version": 1,
    "found": true,
    "_source": {
        "title": "太平洋汽车",
        "visState": "{\"type\":\"area\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"mode\":\"overlap\",\"defaultYExtents\":false},\"aggs\":[{\"id\":\"1\",\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"2\",\"type\":\"date_histogram\",\"schema\":\"segment\",\"params\":{\"field\":\"@timestamp\",\"interval\":\"auto\",\"min_doc_count\":1,\"extended_bounds\":{}}},{\"id\":\"3\",\"type\":\"filters\",\"schema\":\"group\",\"params\":{\"filters\":[{\"input\":{\"query\":{\"query_string\":{\"query\":\"httpcode:200\",\"analyze_wildcard\":true}}}},{\"input\":{\"query\":{\"query_string\":{\"query\":\"ERROR timeout\",\"analyze_wildcard\":true}}}}]}}],\"listeners\":{}}",
        "description": "",
        "version": 1,
        "kibanaSavedObjectMeta": {
            "searchSourceJSON": "{\"index\":\"logstash-*\",\"query\":{\"query_string\":{\"analyze_wildcard\":true,\"query\":\"spider AND *pcauto.com.cn\"}},\"filter\":[]}"
        }
    }
}

#xiaorui.cc
{
    "_index": ".kibana",
    "_type": "visualization",
    "_id": "太平洋汽车",
    "_version": 1,
    "found": true,
    "_source": {
        "title": "太平洋汽车",
        "visState": "{\"type\":\"area\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"mode\":\"overlap\",\"defaultYExtents\":false},\"aggs\":[{\"id\":\"1\",\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"2\",\"type\":\"date_histogram\",\"schema\":\"segment\",\"params\":{\"field\":\"@timestamp\",\"interval\":\"auto\",\"min_doc_count\":1,\"extended_bounds\":{}}},{\"id\":\"3\",\"type\":\"filters\",\"schema\":\"group\",\"params\":{\"filters\":[{\"input\":{\"query\":{\"query_string\":{\"query\":\"httpcode:200\",\"analyze_wildcard\":true}}}},{\"input\":{\"query\":{\"query_string\":{\"query\":\"ERROR timeout\",\"analyze_wildcard\":true}}}}]}}],\"listeners\":{}}",
        "description": "",
        "version": 1,
        "kibanaSavedObjectMeta": {
            "searchSourceJSON": "{\"index\":\"logstash-*\",\"query\":{\"query_string\":{\"analyze_wildcard\":true,\"query\":\"spider AND *pcauto.com.cn\"}},\"filter\":[]}"
        }
    }
}
怎么写入kibana的配置，可以用python，curl，或者是postman这样的调试工具。 

http://192.168.1.103:9000/.kibana/visualization/太平洋汽车   ，请求用 POST模式

                                                         (_index)       (type)                    (id)


{
    "title": "太平洋汽车",
    "visState": "{\"type\":\"area\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"mode\":\"overlap\",\"defaultYExtents\":false},\"aggs\":[{\"id\":\"1\",\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"2\",\"type\":\"date_histogram\",\"schema\":\"segment\",\"params\":{\"field\":\"@timestamp\",\"interval\":\"auto\",\"min_doc_count\":1,\"extended_bounds\":{}}},{\"id\":\"3\",\"type\":\"filters\",\"schema\":\"group\",\"params\":{\"filters\":[{\"input\":{\"query\":{\"query_string\":{\"query\":\"httpcode:200\",\"analyze_wildcard\":true}}}},{\"input\":{\"query\":{\"query_string\":{\"query\":\"ERROR timeout\",\"analyze_wildcard\":true}}}}]}}],\"listeners\":{}}",
    "description": "",
    "version": 1,
    "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"index\":\"logstash-*\",\"query\":{\"query_string\":{\"analyze_wildcard\":true,\"query\":\"spider AND *pcauto.com.cn\"}},\"filter\":[]}"
    }
}

{
    "title": "太平洋汽车",
    "visState": "{\"type\":\"area\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"mode\":\"overlap\",\"defaultYExtents\":false},\"aggs\":[{\"id\":\"1\",\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"2\",\"type\":\"date_histogram\",\"schema\":\"segment\",\"params\":{\"field\":\"@timestamp\",\"interval\":\"auto\",\"min_doc_count\":1,\"extended_bounds\":{}}},{\"id\":\"3\",\"type\":\"filters\",\"schema\":\"group\",\"params\":{\"filters\":[{\"input\":{\"query\":{\"query_string\":{\"query\":\"httpcode:200\",\"analyze_wildcard\":true}}}},{\"input\":{\"query\":{\"query_string\":{\"query\":\"ERROR timeout\",\"analyze_wildcard\":true}}}}]}}],\"listeners\":{}}",
    "description": "",
    "version": 1,
    "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"index\":\"logstash-*\",\"query\":{\"query_string\":{\"analyze_wildcard\":true,\"query\":\"spider AND *pcauto.com.cn\"}},\"filter\":[]}"
    }
}
用postman适合做Elasticsearch的调试，如果真的要实现批量添加，还是需要你自己用python来操作 。 



#!/usr/bin/python
from elasticsearch import Elasticsearch
es = Elasticsearch()


doc = {
   你要插入的内容，可以把上面的东西复制过来
}
res = es.index(index=".kibana", doc_type="visualization", id=2, body=doc)
print(res['created'])

#!/usr/bin/python
from elasticsearch import Elasticsearch
es = Elasticsearch()
 
 
doc = {
   你要插入的内容，可以把上面的东西复制过来
}
res = es.index(index=".kibana", doc_type="visualization", id=2, body=doc)
print(res['created'])
需要注意的是，POST的时候你的结构体需要是Json，注意下格式就好了。 http://jsonlint.com/  可以到这边格式化你的格式。 

上面是怎么自动化添加图表，那怎么把图表加到dashboard里面。 方法也简单，用python的es模块获取数据，然后json.loads  panelsJSON,接着追加你要加入该dashboard的visualize图表。 


{
    "_index": ".kibana",
    "_type": "dashboard",
    "_id": "buzz-Dashboard",
    "_version": 24,
    "found": true,
    "_source": {
        "title": "buzz-Dashboard",
        "hits": 0,
        "description": "",
        "panelsJSON": "[{\"col\":1,\"id\":\"Weixin-Buzz\",\"row\":13,\"size_x\":6,\"size_y\":4,\"type\":\"visualization\"},{\"col\":1,\"id\":\"spider-http-code-Visualization\",\"row\":1,\"size_x\":6,\"size_y\":4,\"type\":\"visualization\"},{\"col\":1,\"id\":\"BabyTree-Buzz\",\"row\":25,\"size_x\":4,\"size_y\":4,\"type\":\"visualization\"},{\"col\":7,\"id\":\"buzz_httpcost\",\"row\":1,\"size_x\":6,\"size_y\":4,\"type\":\"visualization\"},{\"col\":7,\"id\":\"汽车之家_爬虫\",\"row\":13,\"size_x\":6,\"size_y\":4,\"type\":\"visualization\"},{\"col\":7,\"id\":\"buzz_emotion\",\"row\":5,\"size_x\":6,\"size_y\":4,\"type\":\"visualization\"},{\"col\":1,\"id\":\"buzz_brief\",\"row\":9,\"size_x\":6,\"size_y\":4,\"type\":\"visualization\"},{\"col\":1,\"id\":\"buzz_keywordscost\",\"row\":5,\"size_x\":6,\"size_y\":4,\"type\":\"visualization\"},{\"col\":7,\"id\":\"buzz_extractorPushRedis\",\"row\":9,\"size_x\":6,\"size_y\":4,\"type\":\"visualization\"},{\"col\":5,\"id\":\"百度贴吧\",\"row\":17,\"size_x\":4,\"size_y\":4,\"type\":\"visualization\"},{\"col\":9,\"id\":\"新浪博客\",\"row\":17,\"size_x\":4,\"size_y\":4,\"type\":\"visualization\"},{\"col\":1,\"id\":\"百度知道\",\"row\":17,\"size_x\":4,\"size_y\":4,\"type\":\"visualization\"},{\"col\":5,\"id\":\"爱卡汽车\",\"row\":21,\"size_x\":4,\"size_y\":4,\"type\":\"visualization\"},{\"col\":9,\"id\":\"和讯网\",\"row\":21,\"size_x\":4,\"size_y\":4,\"type\":\"visualization\"},{\"col\":1,\"id\":\"中关村\",\"row\":21,\"size_x\":4,\"size_y\":4,\"type\":\"visualization\"},{\"col\":9,\"id\":\"摇篮网\",\"row\":25,\"size_x\":4,\"size_y\":4,\"type\":\"visualization\"}]",
        "version": 1,
        "kibanaSavedObjectMeta": {
            "searchSourceJSON": "{\"filter\":[{\"query\":{\"query_string\":{\"analyze_wildcard\":true,\"query\":\"*\"}}}]}"
        }
    }
}

{
    "_index": ".kibana",
    "_type": "dashboard",
    "_id": "buzz-Dashboard",
    "_version": 24,
    "found": true,
    "_source": {
        "title": "buzz-Dashboard",
        "hits": 0,
        "description": "",
        "panelsJSON": "[{\"col\":1,\"id\":\"Weixin-Buzz\",\"row\":13,\"size_x\":6,\"size_y\":4,\"type\":\"visualization\"},{\"col\":1,\"id\":\"spider-http-code-Visualization\",\"row\":1,\"size_x\":6,\"size_y\":4,\"type\":\"visualization\"},{\"col\":1,\"id\":\"BabyTree-Buzz\",\"row\":25,\"size_x\":4,\"size_y\":4,\"type\":\"visualization\"},{\"col\":7,\"id\":\"buzz_httpcost\",\"row\":1,\"size_x\":6,\"size_y\":4,\"type\":\"visualization\"},{\"col\":7,\"id\":\"汽车之家_爬虫\",\"row\":13,\"size_x\":6,\"size_y\":4,\"type\":\"visualization\"},{\"col\":7,\"id\":\"buzz_emotion\",\"row\":5,\"size_x\":6,\"size_y\":4,\"type\":\"visualization\"},{\"col\":1,\"id\":\"buzz_brief\",\"row\":9,\"size_x\":6,\"size_y\":4,\"type\":\"visualization\"},{\"col\":1,\"id\":\"buzz_keywordscost\",\"row\":5,\"size_x\":6,\"size_y\":4,\"type\":\"visualization\"},{\"col\":7,\"id\":\"buzz_extractorPushRedis\",\"row\":9,\"size_x\":6,\"size_y\":4,\"type\":\"visualization\"},{\"col\":5,\"id\":\"百度贴吧\",\"row\":17,\"size_x\":4,\"size_y\":4,\"type\":\"visualization\"},{\"col\":9,\"id\":\"新浪博客\",\"row\":17,\"size_x\":4,\"size_y\":4,\"type\":\"visualization\"},{\"col\":1,\"id\":\"百度知道\",\"row\":17,\"size_x\":4,\"size_y\":4,\"type\":\"visualization\"},{\"col\":5,\"id\":\"爱卡汽车\",\"row\":21,\"size_x\":4,\"size_y\":4,\"type\":\"visualization\"},{\"col\":9,\"id\":\"和讯网\",\"row\":21,\"size_x\":4,\"size_y\":4,\"type\":\"visualization\"},{\"col\":1,\"id\":\"中关村\",\"row\":21,\"size_x\":4,\"size_y\":4,\"type\":\"visualization\"},{\"col\":9,\"id\":\"摇篮网\",\"row\":25,\"size_x\":4,\"size_y\":4,\"type\":\"visualization\"}]",
        "version": 1,
        "kibanaSavedObjectMeta": {
            "searchSourceJSON": "{\"filter\":[{\"query\":{\"query_string\":{\"analyze_wildcard\":true,\"query\":\"*\"}}}]}"
        }
    }
}
最后，用python写成一个脚本实现了kibana批量的添加。  下面是添加后的效果图。



写博客之前，我在kibana github提了个问题，就是关于kibana，这哥们给我答复了，居然跟我的方法是一样的….    不太明白为毛不开放个批量的接口 。

关于kibana批量添加的文章，出处 http://xiaorui.cc/?p=1570


希望kibana 赶紧出个管理api, 这样就不用蛋疼的直接改es了.

END.   