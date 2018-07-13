

https://www.tuicool.com/articles/MvMbmaE

但通过查看/var/log/fluentd.log，我们依然能看到“问题”：

2017-03-02 03:57:58 +0000 [warn]: temporarily failed to flush the buffer. next_retry=2017-03-02 03:57:59 +0000 error_class="Fluent::ElasticsearchOutput::ConnectionFailure" error="Can not reach Elasticsearch cluster ({:host=>\"elasticsearch-logging\", :port=>9200, :scheme=>\"http\"})!" plugin_id="object:3fd99fa857d8"
  2017-03-02 03:57:58 +0000 [warn]: suppressed same stacktrace
2017-03-02 03:58:00 +0000 [warn]: temporarily failed to flush the buffer. next_retry=2017-03-02 03:58:03 +0000 error_class="Fluent::ElasticsearchOutput::ConnectionFailure" error="Can not reach Elasticsearch cluster ({:host=>\"elasticsearch-logging\", :port=>9200, :scheme=>\"http\"})!" plugin_id="object:3fd99fa857d8"
2017-03-02 03:58:00 +0000 [info]: process finished code=9
2017-03-02 03:58:00 +0000 [error]: fluentd main process died unexpectedly. restarting.
由于ElasticSearch logging还未创建，这是连不上elasticsearch所致。