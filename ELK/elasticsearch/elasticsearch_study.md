<h1>入门</h1>

<ul>
	<li><a href="https://www.zhihu.com/question/27214433">知乎为什么要自己开发日志聚合系统「kids」而不用更简洁方便的「ELK」？ - 知乎 </a>（2010年scribe停止开发，之后才有一大把开源日志系统出现）</li>
	<li><a href="http://blog.kazaff.me/2015/06/05/%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E6%9E%B6%E6%9E%84--ELK/">日志收集架构－ELK | kazaff&#39;s blog | 种一棵树最佳时间是十年前，其次是现在 </a></li>
	<li><a href="https://www.elastic.co/guide/index.html">Elastic Stack and Product Documentation | Elastic </a>（总文档）</li>
	<li><a href="https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html">Elasticsearch Reference [5.4] | Elastic </a></li>
	<li><a href="https://github.com/elastic/examples">elastic/examples</a>: Home for Elasticsearch examples available to everyone. It&#39;s a great way to get started.</li>
	<li><a href="https://kibana.logstash.es/content/">前言 &middot; ELKstack 中文指南 </a>（gitbook）</li>
	<li><a href="https://wizardforcel.gitbooks.io/mastering-elasticsearch/content/index.html">前言 | Mastering Elasticsearch 中文版 </a>（gitbook）</li>
</ul>

<h1>prefix</h1>

<ul>
	<li><a href="https://www.elastic.co/guide/cn/elasticsearch/guide/current/prefix-query.html">prefix 前缀查询 | Elasticsearch: 权威指南 | Elastic </a></li>
	<li><a href="https://stackoverflow.com/questions/31963643/escaping-forward-slashes-in-elasticsearch">escaping forward slashes in elasticsearch - Stack Overflow </a></li>
</ul>

<pre>
<code class="language-json">{"prefix":{"uri.keyword":"/api/v1"}}
{ "query_string": {"query":"\/api/v1","analyzer": "keyword" }}</code></pre>

<h1>集群</h1>

<ul>
	<li><a href="https://hub.docker.com/r/library/elasticsearch/">https://hub.docker.com/r/library/elasticsearch/</a></li>
	<li><a href="https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html">Install Elasticsearch with Docker | Elasticsearch Reference [5.5] | Elastic </a></li>
	<li><a href="https://github.com/docker-library/docs/blob/master/elasticsearch/README.md">docs/README.md at master &middot; docker-library/docs </a></li>
	<li><a href="https://github.com/docker-library/docs/blob/master/logstash/README.md">docs/README.md at master &middot; docker-library/docs </a></li>
	<li><a href="https://logging.apache.org/log4j/2.x/manual/layouts.html">Log4j &ndash; Log4j 2 Layouts - Apache Log4j 2 </a></li>
</ul>

<h1>Search</h1>

<ul>
	<li><a href="https://stackoverflow.com/questions/44626157/elastic-search-expected-numeric-type-on-field">elasticsearch - Elastic Search : Expected numeric type on field - Stack Overflow </a>（Integer.parseInt(doc[&quot;mlf16_txservnum&quot;].value)）</li>
	<li><a href="http://blog.zhulinpinyu.com/2016/08/22/elasticsearch-read-notes8-aggs-explore-data/">《Elasticsearch in Action》阅读笔记八：使用聚合函数探索数据 - 竹林品雨|zhulinpinyu&#39;s blog </a>（精度）</li>
</ul>

<h1>vm.max_map_count</h1>

<ul>
	<li><a href="https://stackoverflow.com/questions/41064572/docker-elk-vm-max-map-count">elasticsearch - Docker - ELK - vm.max_map_count - Stack Overflow </a>（sysctl -w vm.max_map_count=655360）</li>
	<li><a href="http://www.tuicool.com/articles/ZbIZbeR">我的ELK搭建笔记（阿里云上部署） - 推酷 </a></li>
</ul>

<h1>node.js</h1>

<ul>
	<li><a href="https://blog.raananweber.com/2015/11/24/simple-autocomplete-with-elasticsearch-and-node-js/">Getting started with elasticsearch and Express.js </a></li>
	<li><a href="https://github.com/RaananW/express.js-elasticsearch-autocomplete-demo">RaananW/express.js-elasticsearch-autocomplete-demo: A simple demo showing how simple it is to use elasticsearch with express.js </a></li>
	<li><a href="https://github.com/elastic/elasticsearch-js">elastic/elasticsearch-js: Official Elasticsearch client library for Node.js and the browser </a></li>
	<li><a href="https://www.sitepoint.com/search-engine-node-elasticsearch/">Build a Search Engine with Node.js and Elasticsearch &mdash; SitePoint </a></li>
	<li><a href="https://github.com/sitepoint-editors/node-elasticsearch-tutorial">sitepoint-editors/node-elasticsearch-tutorial: Examples for setting up and using elasticsearch in Node.js </a></li>
	<li><a href="https://stackoverflow.com/questions/22661996/example-of-angular-and-elasticsearch">javascript - Example of Angular and Elasticsearch - Stack Overflow </a></li>
	<li><a href="https://github.com/dncrews/angular-elastic-builder">dncrews/angular-elastic-builder</a>: This is an Angular.js directive for building an Elasticsearch query. You just give it the fields and can generate a query for it.</li>
	<li><a href="http://www.andrekolell.de/blog/running-nodejs-express-app-with-elasticsearch-on-docker-on-mac">Running a Node.js Express app with an Elasticsearch back end on Docker on Mac OS X | Andr&eacute; Kolell </a></li>
</ul>

<h1>golang</h1>

<ul>
	<li><a href="https://github.com/olivere/elastic">olivere/elastic: Elasticsearch client for Go. </a></li>
	<li><a href="https://gist.github.com/olivere/114347ff9d9cfdca7bdc0ecea8b82263">Getting started with elastic.v3 </a></li>
	<li><a href="https://github.com/olivere/elastic/wiki">Home &middot; olivere/elastic Wiki </a></li>
	<li><a href="https://github.com/kamorahul/golang-elastic-api">kamorahul/golang-elastic-api: A working api with golang and oliver elastic search </a></li>
	<li><a href="http://olivere.github.io/elastic/">Elastic: An Elasticsearch client for Go </a></li>
</ul>

<h1>Lucene</h1>

<ul>
	<li><a href="http://naotu.baidu.com/file/28c217f0ae265f2b7fabed2d3bda33ab?token=bf3384588c267201">百度脑图</a></li>
	<li><a href="http://www.jianshu.com/p/23512e8158da">Lucene的基本概念 - 简书</a></li>
	<li><a href="https://www.ibm.com/developerworks/cn/java/j-lo-lucene1/index.html">实战 Lucene，第 1 部分: 初识 Lucene </a></li>
</ul>

<h1>docker</h1>

<ul>
	<li><a href="http://dockone.io/article/373">Docker日志自动化: ElasticSearch、Logstash、Kibana以及Logspout - DockOne.io </a></li>
	<li><a href="https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html">Install Elasticsearch with Docker | Elasticsearch Reference [5.4] | Elastic </a>（current，官方docker安装配置文档）</li>
	<li><a href="https://github.com/docker-library/elasticsearch">docker-library/elasticsearch: Docker Official Image packaging for elasticsearch </a></li>
	<li><a href="https://github.com/dockerfile/elasticsearch">dockerfile/elasticsearch: ElasticSearch Dockerfile for trusted automated Docker builds. </a></li>
	<li><a href="https://github.com/docker-library/docs/tree/master/elasticsearch">docs/elasticsearch at master &middot; docker-library/docs </a></li>
	<li><a href="https://hub.docker.com/r/sebp/elk/">sebp/elk - Docker Hub</a>（All in one 版本）</li>
	<li><a href="http://elk-docker.readthedocs.io/">elk-docker </a>（sebp/elk文档）</li>
	<li><a href="https://github.com/spujadas/elk-docker">spujadas/elk-docker: Elasticsearch, Logstash, Kibana (ELK) Docker image </a>（sebp/elk github地址）</li>
	<li><a href="https://github.com/deviantony/docker-elk">deviantony/docker-elk: The ELK stack powered by Docker and Compose.</a>（基于官方做的docker-compose）</li>
	<li><a href="https://github.com/elastic/elasticsearch-docker">elastic/elasticsearch-docker: Official Elasticsearch Docker image </a></li>
	<li><a href="https://github.com/elastic/logstash-docker">elastic/logstash-docker: Official Logstash Docker image </a></li>
	<li><a href="https://github.com/elastic/kibana-docker">elastic/kibana-docker: Official Kibana Docker image </a></li>
</ul>

<h1>nginx</h1>

<ul>
	<li><a href="http://bbotte.blog.51cto.com/6205307/1615477">logstash通过rsyslog对nginx的日志收集和分析 - 金戈铁马行飞燕 - 51CTO技术博客 </a></li>
	<li><a href="https://www.ibm.com/developerworks/cn/opensource/os-cn-elk-filebeat/index.html">ELK+Filebeat 集中式日志解决方案详解 </a></li>
	<li><a href="http://zhengmingjing.blog.51cto.com/1587142/1907456">ELK+Filebeat+Nginx集中式日志解决方案（一） - 郑小明的技术博客 - 51CTO技术博客 </a></li>
	<li><a href="https://github.com/elastic/examples/tree/master/ElasticStack_NGINX-json">examples/ElasticStack_NGINX-json at master &middot; elastic/examples </a>（官网提供的nginx例子）</li>
</ul>

<h1>filebeat</h1>

<ul>
	<li><a href="http://tonybai.com/2016/03/25/ship-docker-container-log-with-filebeat/">使用Filebeat输送Docker容器的日志 | Tony Bai </a></li>
	<li><a href="https://www.elastic.co/guide/en/beats/filebeat/current/running-on-docker.html">Running Filebeat on Docker | Filebeat Reference [5.4] | Elastic </a></li>
	<li><a href="http://nosmoking.blog.51cto.com/3263888/1853781">初探ELK-filebeat使用小结 - 好记性不如烂笔头 - 51CTO技术博客 </a></li>
	<li><a href="http://www.cnblogs.com/linux-wangkun/p/5746107.html">Docker使用-v挂载主机目录到容器后出现Permission denied - Amei1314 - 博客园 </a></li>
</ul>
