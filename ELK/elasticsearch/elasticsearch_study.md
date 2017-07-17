# 入门

- [知乎为什么要自己开发日志聚合系统「kids」而不用更简洁方便的「ELK」？ - 知乎](https://www.zhihu.com/question/27214433) （2010年scribe停止开发，之后才有一大把开源日志系统出现）
- [日志收集架构－ELK | kazaff's blog | 种一棵树最佳时间是十年前，其次是现在](http://blog.kazaff.me/2015/06/05/%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E6%9E%B6%E6%9E%84--ELK/)
- [Elastic Stack and Product Documentation | Elastic](https://www.elastic.co/guide/index.html) （总文档）
- [Elasticsearch Reference [5.4] | Elastic](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [elastic/examples](https://github.com/elastic/examples): Home for Elasticsearch examples available to everyone. It's a great way to get started.
- [前言 · ELKstack 中文指南](https://kibana.logstash.es/content/) （gitbook）
- [前言 | Mastering Elasticsearch 中文版](https://wizardforcel.gitbooks.io/mastering-elasticsearch/content/index.html) （gitbook）

# prefix

- [prefix 前缀查询 | Elasticsearch: 权威指南 | Elastic](https://www.elastic.co/guide/cn/elasticsearch/guide/current/prefix-query.html)
- [escaping forward slashes in elasticsearch - Stack Overflow](https://stackoverflow.com/questions/31963643/escaping-forward-slashes-in-elasticsearch)

    {"prefix":{"uri.keyword":"/api/v1"}}
    { "query_string": {"query":"\/api/v1","analyzer": "keyword" }}

# 集群

- [https://hub.docker.com/r/library/elasticsearch/](https://hub.docker.com/r/library/elasticsearch/)
- [Install Elasticsearch with Docker | Elasticsearch Reference [5.5] | Elastic](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html)
- [docs/README.md at master · docker-library/docs](https://github.com/docker-library/docs/blob/master/elasticsearch/README.md)
- [docs/README.md at master · docker-library/docs](https://github.com/docker-library/docs/blob/master/logstash/README.md)
- [Log4j – Log4j 2 Layouts - Apache Log4j 2](https://logging.apache.org/log4j/2.x/manual/layouts.html)

# Search

- [elasticsearch - Elastic Search : Expected numeric type on field - Stack Overflow](https://stackoverflow.com/questions/44626157/elastic-search-expected-numeric-type-on-field) （Integer.parseInt(doc["mlf16_txservnum"].value)）
- [《Elasticsearch in Action》阅读笔记八：使用聚合函数探索数据 - 竹林品雨|zhulinpinyu's blog](http://blog.zhulinpinyu.com/2016/08/22/elasticsearch-read-notes8-aggs-explore-data/) （精度）

# vm.max_map_count

- [elasticsearch - Docker - ELK - vm.max_map_count - Stack Overflow](https://stackoverflow.com/questions/41064572/docker-elk-vm-max-map-count) （sysctl -w vm.max_map_count=655360）
- [我的ELK搭建笔记（阿里云上部署） - 推酷](http://www.tuicool.com/articles/ZbIZbeR)

# node.js

- [Getting started with elasticsearch and Express.js](https://blog.raananweber.com/2015/11/24/simple-autocomplete-with-elasticsearch-and-node-js/)
- [RaananW/express.js-elasticsearch-autocomplete-demo: A simple demo showing how simple it is to use elasticsearch with express.js](https://github.com/RaananW/express.js-elasticsearch-autocomplete-demo)
- [elastic/elasticsearch-js: Official Elasticsearch client library for Node.js and the browser](https://github.com/elastic/elasticsearch-js)
- [Build a Search Engine with Node.js and Elasticsearch — SitePoint](https://www.sitepoint.com/search-engine-node-elasticsearch/)
- [sitepoint-editors/node-elasticsearch-tutorial: Examples for setting up and using elasticsearch in Node.js](https://github.com/sitepoint-editors/node-elasticsearch-tutorial)
- [javascript - Example of Angular and Elasticsearch - Stack Overflow](https://stackoverflow.com/questions/22661996/example-of-angular-and-elasticsearch)
- [dncrews/angular-elastic-builder](https://github.com/dncrews/angular-elastic-builder): This is an Angular.js directive for building an Elasticsearch query. You just give it the fields and can generate a query for it.
- [Running a Node.js Express app with an Elasticsearch back end on Docker on Mac OS X | André Kolell](http://www.andrekolell.de/blog/running-nodejs-express-app-with-elasticsearch-on-docker-on-mac)

# golang

- [olivere/elastic: Elasticsearch client for Go.](https://github.com/olivere/elastic)
- [Getting started with elastic.v3](https://gist.github.com/olivere/114347ff9d9cfdca7bdc0ecea8b82263)
- [Home · olivere/elastic Wiki](https://github.com/olivere/elastic/wiki)
- [kamorahul/golang-elastic-api: A working api with golang and oliver elastic search](https://github.com/kamorahul/golang-elastic-api)
- [Elastic: An Elasticsearch client for Go](http://olivere.github.io/elastic/)

# Lucene

- [百度脑图](http://naotu.baidu.com/file/28c217f0ae265f2b7fabed2d3bda33ab?token=bf3384588c267201)
- [Lucene的基本概念 - 简书](http://www.jianshu.com/p/23512e8158da)
- [实战 Lucene，第 1 部分: 初识 Lucene](https://www.ibm.com/developerworks/cn/java/j-lo-lucene1/index.html)

# docker

- [Docker日志自动化: ElasticSearch、Logstash、Kibana以及Logspout - DockOne.io](http://dockone.io/article/373)
- [Install Elasticsearch with Docker | Elasticsearch Reference [5.4] | Elastic](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html) （current，官方docker安装配置文档）
- [docker-library/elasticsearch: Docker Official Image packaging for elasticsearch](https://github.com/docker-library/elasticsearch)
- [dockerfile/elasticsearch: ElasticSearch Dockerfile for trusted automated Docker builds.](https://github.com/dockerfile/elasticsearch)
- [docs/elasticsearch at master · docker-library/docs](https://github.com/docker-library/docs/tree/master/elasticsearch)
- [sebp/elk - Docker Hub](https://hub.docker.com/r/sebp/elk/)（All in one 版本）
- [elk-docker](http://elk-docker.readthedocs.io/) （sebp/elk文档）
- [spujadas/elk-docker: Elasticsearch, Logstash, Kibana (ELK) Docker image](https://github.com/spujadas/elk-docker) （sebp/elk github地址）
- [deviantony/docker-elk: The ELK stack powered by Docker and Compose.](https://github.com/deviantony/docker-elk)（基于官方做的docker-compose）
- [elastic/elasticsearch-docker: Official Elasticsearch Docker image](https://github.com/elastic/elasticsearch-docker)
- [elastic/logstash-docker: Official Logstash Docker image](https://github.com/elastic/logstash-docker)
- [elastic/kibana-docker: Official Kibana Docker image](https://github.com/elastic/kibana-docker)

# nginx

- [logstash通过rsyslog对nginx的日志收集和分析 - 金戈铁马行飞燕 - 51CTO技术博客](http://bbotte.blog.51cto.com/6205307/1615477)
- [ELK+Filebeat 集中式日志解决方案详解](https://www.ibm.com/developerworks/cn/opensource/os-cn-elk-filebeat/index.html)
- [ELK+Filebeat+Nginx集中式日志解决方案（一） - 郑小明的技术博客 - 51CTO技术博客](http://zhengmingjing.blog.51cto.com/1587142/1907456)
- [examples/ElasticStack_NGINX-json at master · elastic/examples](https://github.com/elastic/examples/tree/master/ElasticStack_NGINX-json) （官网提供的nginx例子）

# filebeat

- [使用Filebeat输送Docker容器的日志 | Tony Bai](http://tonybai.com/2016/03/25/ship-docker-container-log-with-filebeat/)
- [Running Filebeat on Docker | Filebeat Reference [5.4] | Elastic](https://www.elastic.co/guide/en/beats/filebeat/current/running-on-docker.html)
- [初探ELK-filebeat使用小结 - 好记性不如烂笔头 - 51CTO技术博客](http://nosmoking.blog.51cto.com/3263888/1853781)
- [Docker使用-v挂载主机目录到容器后出现Permission denied - Amei1314 - 博客园](http://www.cnblogs.com/linux-wangkun/p/5746107.html)