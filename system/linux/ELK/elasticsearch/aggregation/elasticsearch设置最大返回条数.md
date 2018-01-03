

elasticsearch设置最大返回条数 - CSDN博客 
http://blog.csdn.net/hhj724/article/details/73909813


https://segmentfault.com/q/1010000004853355

如果你不在聚合的参数里面指名具体的size，默认就是10条结果。。

 /**
     * Sets the size - indicating how many term buckets should be returned (defaults to 10)
     */
    public TermsBuilder size(int size) {
        bucketCountThresholds.setRequiredSize(size);
        return this;
    }

有两种方法：
一.可以通过url设置，方便快捷不用重启。如下：

curl -XPUT http://127.0.0.1:9200/book/_settings -d '{ "index" : { "max_result_window" : 200000000}}'
注意：
1.size的大小不能超过index.max_result_window这个参数的设置，默认为10,000。 
2.需要搜索分页，可以通过from size组合来进行。from表示从第几行开始，size表示查询多少条文档。from默认为0，size默认为10

二.通过配置文件设置
{ "order": 1, "template": "index_template*", "settings": { "index.number_of_replicas": "0", "index.number_of_shards": "1", "index.max_result_window": 2147483647 }