

[《云原生应用架构实践》(网易云基础服务架构团队)【摘要 书评 试读】- 京东图书 ](https://item.jd.com/12219496.html?dist=jd)
[快速成长期的云原生应用架构实践 ](http://geek.csdn.net/news/detail/229319)

在经过了最初的业务原型验证和上线运行期之后，用户业务进入了高速成长阶段。在这一阶段，业务重点不再是方向上的调整，而是在原来基础上的不断深挖、扩展；开发不仅是功能的实现，还需要兼顾成本和性能；系统不再是单体架构，还会涉及系统的扩展和多系统之间的通信；高可用也不仅是服务自动拉起或者并行扩展，还需要考虑数据可靠、对用户影响，以及服务等级协议（SLA）。

本文将以上述挑战为出发点，介绍如何通过引入新的工具、新的架构，对原有系统进行升级和优化，来更好满足这一阶段需求，并为产品的进一步发展打下基础。

关键业务需求
随着用户业务的发展，原来的功能已经无法满足要求，需要增强或者增加新的功能。在用户数和访问量达到一定规模后，原先单体架构下的简单功能，如计数和排序，将变得复杂；随着业务深入，定期举行的秒杀、促销等活动，给系统带了巨大的压力；由于数据量的飞速增长，单纯的数据库或者内存检索已经无法满足不断增加的各种查询需求；随着业务数据量的增加，产品价值的提高，如何收集系统运行数据，分析业务运行状态也成了基本需求。接下来我们聚焦这一阶段的关键业务需求，并给出相应的解决方案。

计数与排序
在单体架构下，通过简单的内存数据和对应算法就可以实现计数和排序功能。但是在大量数据和多节点协作的环境下，基于单点内存操作的实现会遇到高并发、数据同步、实时获取等问题。在这一阶段，通用方法是使用Redis的原生命令来实现计数和排序。

计数

在Redis中可用于计数的对象有字符串（string）、哈希表（hash）和有序集合（zset）3种，对应的命令分别是incr/incrby、hincrby和zincrby。

网站可以从用户的访问、交互中收集到有价值的信息。通过记录各个页面的被访问次数，我们可以根据基本的访问计数信息来决定如何缓存页面，从而减少页面载入时间并提升页面的响应速度，优化用户体验。

计数器

要实现网页点击量统计，需要设计一个时间序列计数器，对网页的点击量按不同的时间精度（1s、5s、1min、5min、1h、5h、1d等）计数，以对网站和网页监视和分析。

数据建模以网页的地址作为KEY，定义一个有序集合（zset），内部各成员（member）分别由计数器的精度和计数器的名字组成，所有成员的分值（score）都是0。这样所有精度的计数器都保存在了这个有序集合里，不包含任何重复元素，并且能够允许一个接一个地遍历所有元素。

对于每个计数器及每种精度，如网页的点击量计数器和5s，设计使用一个哈希表（hash）对象来存储网页在每5s时间片之内获得的点击量。其中，哈希表的每个原生的field都是某个时间片的开始时间，而原生的field对应的值则存储了网页在该时间片内获得的点击量。如图1所示。

更新计数器信息示例代码。
 PRECESION = [1, 5, 60, 300, 3600, 18000, 86400]  def update_counter(conn, name, count=1, now=None): 
 ----now = now or time.time() 
 ----pipe = conn.pipeline()  ----for prec in PRECESION: 
 --------pnow = int(now / prec) * prec 
 --------hash = '%s:%s' % (prec, name) 
 --------pipe.zadd('http:/.....xxxxxx', hash, 0) 
 --------pipe.hincrby('count:' + hash, pnow, count) 
 ----pipe.execute() 
图片描述
图1 网页点击计数器的实现
获取计数器信息示例代码。
 def get_counter(conn, name, precision):  ----hash = '%s:%s' % (precision, name) 
 ----data = conn.hgetall('count:' + hash) 
 ----to_return = [] 
 ----for key, value in data.iteritems(): 
 --------to_return.append((int(key), int(value)))  ----to_return.sort() 
 ----return to_return; 
当然，这里只介绍了网页点击量数据的存储模型，如果我们一味地对计数器进行更新而不执行任何清理操作的话，那么程序最终将会因为存储了过多的数据而导致内存不足，由于我们事先已经将所有已知的计数器都记录到一个有序集合里面，所以对计数器进行清理只需要遍历这个有序集合，并删除其中的旧计数器即可。

排序

在Redis中可用于排序的有天然有序的有序集合（zset）和键（keys）类型中的SORT命令，其中SORT命令的功能非常强大，不仅可以对列表（list）、集合（set）和有序集合（zset）进行排序，还可以完成与关系型数据库中的连接查询相类似的任务，下面分别以两个例子来介绍各自的应用。

帖子排序

论坛中的帖子通常会有各种排序方式方便用户查看，比如按发帖时间排序、按回复时间排序、按回复数量排序、按阅读量排序等，这些TOP N场景对响应时间要求比较高，非常适宜用有序集合（zset）来缓存排序信息，其中排序字段即为分值（score）字段。

例子
 127.0.0.1:6379> zadd page_rank 10 google.com 8 bing.com 6 163.com 9 baidu.com 
 (integer) 4 
 127.0.0.1:6379> zrange page_rank 0 -1 withscores 
1)  "163.com" 
2)  "6" 
3)  "bing.com" 
4)  "8" 
5)  "baidu.com" 
6)  "9" 
7)  "google.com" 
8)  "10" 
SORT命令

SORT key [BY pattern] [LIMIT offset count] [GET pattern [GET pattern ...]] [ASC | DESC] [ALPHA] [STORE destination]
SORT命令提供了多种参数，可以对列表，集合和有序集合进行排序，此外还可以根据降序升序来对元素进行排序（DESC、ASC）；将元素看作是数字还是二进制字符串来进行排序（ALPHA）；使用排序元素之外的其他值作为权重来进行排序（BY pattern）。

下面代码清单展示了SORT命令的具体功能使用。

对列表（list）进行排序
1.顺序

 127.0.0.1:6379> lpush mylist 30 10 8 19 
 (integer) 4 
 127.0.0.1:6379> sort price 
1)  "8" 
2)  "10" 
3)  "19" 
4)  "30" 
2.逆序

 127.0.0.1:6379> sort price desc 
1)  "30" 
2)  "19" 
3)  "10" 
4)  "8" 
3.使用alpha修饰符对字符串进行排序

 127.0.0.1:6379> lpush website www.163.com www.kaola.com www.baidu.com 
 (integer) 3 
 127.0.0.1:6379> sort website alpha 
1)  "www.163.com" 
2)  "www.baidu.com" 
3)  "www.kaola.com" 
使用limit修饰符限制返回结果
 127.0.0.1:6379> rpush num 1 4 2 7 9 6 5 3 8 10 
 (integer) 10 
 127.0.0.1:6379> sort num limit 0 5 
1)  "1" 
2)  "2" 
3)  "3" 
4)  "4" 
5)  "5" 
使用外部key进行排序
可以使用外部key的数据作为权重，代替默认的直接对比键值的方式来进行排序。假设现在有用户数据如表1所示。

uid	user_name_{uid}	user_level_{uid}
1	helifu	888
2	netease	666
3	kaola	777
4	ncr	4444
表1 用户数据示例
以下将哈希表（hash）作为by和get的参数，by和get选项都可以用key->field的格式来获取哈希表中的域的值，其中key表示哈希表键，而field则表示哈希表的域。

1.数据输入到Redis中

 127.0.0.1:6379> hmset user_info_1 name helifu level 888 
 OK 
 127.0.0.1:6379> hmset user_info_2 name netease level 666 
 OK 
 127.0.0.1:6379> hmset user_info_3 name kaola level 777 
 OK 
 127.0.0.1:6379> hmset user_info_4 name ncr level 4444 
 OK 
2.by选项

通过使用by选项，让uid按其他键的元素来排序。

例如以下代码让uid键按照user_info_*->level的大小来排序。

 127.0.0.1:6379> sort uid by user_info_*->level 
1)  "2" 
2)  "3" 
3)  "1" 
4)  "4" 
3.get选项

使用get选项，可以根据排序的结果来取出相应的键值。

例如以下代码先让uid键按照user_info_*->level的大小来排序，然后再取出

user_info_ *->name的值。
 127.0.0.1:6379> sort uid by user_info_*->level get user_info_*->name 
1)  "netease" 
2)  "kaola" 
3)  "helifu" 
4)  "ncr" 
现在的排序结果要比只使用by选项要直观得多。

4.排序获取多个外部key

可以同时使用多个get选项，获取多个外部键的值。

 127.0.0.1:6379> sort uid get # get user_info_*->level get user_info_*->name 
1)  "1" 
2)  "888" 
3)  "helifu" 
4)  "2" 
5)  "666" 
6)  "netease" 
7)  "3" 
8)  "777" 
9)  "kaola" 
10) "4" 
11) "4444" 
12) "ncr" 
5.不排序获取多个外部key

 127.0.0.1:6379> sort uid by not-exists-key get # get user_info_*->level get user_info_*->name 
1)  "4" 
2)  "4444" 
3)  "nc" 
4)  "3" 
5)  "777" 
6)  "kaola" 
7)  "2" 
8)  "666" 
9)  "netease" 
10) "1" 
11) "888" 
12) "helifu" 
保存排序结果
 127.0.0.1:6379> lrange old 0 -1 
1)  "1" 
2)  "3" 
3)  "5" 
6)  "2" 
7)  "4" 
 127.0.0.1:6379> sort old store new 
 (integer) 5 
 127.0.0.1:6379> type new  list 
 127.0.0.1:6379> lrange new 0 -1 
1)  "1" 
2)  "2" 
3)  "3" 
4)  "4" 
5)  "5" 
SORT命令的时间复杂度用公式表示为O(N+M*log(M))，其中N为要排序的列表或集合内的元素数量，M为要返回的元素数量。如果只是使用SORT命令的get选项获取数据而没有进行排序，时间复杂度为O(N)。

云环境下的实践

在云服务中实现计数和排序，可以自己使用云主机搭建Redis服务，也可以使用云计算服务商提供的Redis服务。

对于高可用和性能有要求的场景，建议使用云计算服务商提供的Redis服务。专业的服务商会从底层到应用本身进行良好的优化，可用率、性能指标也远高于自己搭建的Redis实例。同时，由于服务商提供了各种工具，开发运维成本也更低。

以网易云为例，网易云基础服务提供了名为NCR（Netease Cloud Redis）的缓存服务，兼容开源Redis协议。并根据用户具体使用需求和场景，提供了主从版本和分布式集群版本两种架构。

主从服务版

如图2所示，主从版本实例都提供一主一从两个Redis实例，分别部署在不同可用域的节点上，以确保服务安全可靠。在单点故障时，主从服务通过主备切换来实现高可用。 
主从版本使用较低的成本提供了高可用服务，但是也存在无法并行扩展等问题，因此适合数据量有限、对高可用有要求的产品使用。

图片描述
图2 主从服务架构
分布式集群

分布式集群采用官方Redis集群方案，gossip/p2p的无中心节点设计实现，无代理设计客户端直接与Redis集群的每个节点连接，计算出Key所在节点直接在对应的Redis节点上执行命令，如图3所示，详细的过程请参考后续Redis Cluster的相关介绍。

分布式集群采用多活模式，支持并行扩展，因此在性能、可用率方面有明显优势。但是由于分布式集群最少需要3个节点，因此成本会较高，适合对可用率、性能有较高要求的用户使用。

图片描述
图3 分布式集群架构
秒杀
把秒杀服务单列出来进行分析，主要有下面两个原因。

秒杀服务的重要性：秒杀活动本身已经是很多业务推广的重要方式之一，大部分的电商类业务都会涉及这一促销方式。很多非直接秒杀的业务（如火车购票），在实际运行时也会碰到类似秒杀的场景。秒杀实际上就是在瞬时极大并发场景下如何保证系统正常运行的问题，而这种场景对很多系统都是无法避免的，因此在系统设计时，我们往往要考虑到秒杀的影响。
系统实现难度：秒杀最能考验系统负载能力，瞬间涌入平时数十倍甚至数百倍的压力，对开发和运维人员来说都是噩梦，这也为系统设计带来了巨大的挑战。针对秒杀活动的处理，是一个系统性的设计，并不是单一模块或者层面可以解决的问题，需要从系统设计整体进行考量。
处理秒杀的指导思路

秒杀的核心问题就是极高并发处理，由于系统要在瞬时承受平时数十倍甚至上百倍的流量，这往往超出系统上限，因此处理秒杀的核心思路是流控和性能优化。

流控

请求流控
尽可能在上游拦截和限制请求，限制流入后端的量，保证后端系统正常。

因为无论多少人参与秒杀，实际成交往往是有限的，而且远小于参加秒杀的人数，因此可以通过前端系统进行拦截，限制最终流入系统的请求数量，来保证系统正常进行。

客户端流控
在客户端进行访问限制，较为合适的做法是屏蔽用户高频请求，比如在网页中设置5s一次访问限制，可以防止用户过度刷接口。这种做法较为简单，用户体验也尚可，可以拦截大部分小白用户的异常访问，比如狂刷F5。关键是要明确告知用户，如果像一些抢购系统那样假装提交一个排队页面但又不回应任何请求，就是赤裸裸的欺骗了。

Web端流控
对客户端，特别是页面端的限流，对稍有编程知识或者网络基础的用户而言没有作用（可以简单修改JS或者模拟请求），因此服务端流控是必要的。服务端限流的配置方法有很多种，现在的主流Web服务器一般都支持配置访问限制，可以通过配置实现简单的流控。

但是这种限制一般都在协议层。如果要实现更为精细的访问限制（根据业务逻辑限流），可以在后端服务器上，对不同业务实现访问限制。常见做法是可以通过在内存或缓存服务中加入请求访问信息，来实现访问量限制。

后端系统流控
上述的流控做法只能限制用户异常访问，如果正常访问的用户数量很多，就有后端系统压力过大甚至异常宕机的可能，因此需要后端系统流量控制。

对于后端系统的访问限制可以通过异步处理、消息队列、并发限制等方式实现。核心思路是保证后端系统的压力维持在可以正常处理的水平。对于超过系统负载的请求，可以选择直接拒绝，以此来对系统进行保护，保证在极限压力的情况下，系统有合理范围内的处理能力。

系统架构优化

除了流控之外，提高系统的处理能力也是非常重要的，通过系统设计和架构优化，可以提高系统的吞吐量和抗压能力。关于通用系统性能的提升，已经超出本节的范围，这里只会提几点和秒杀相关的优化。

读取加速：在秒杀活动中，数据需求一般都是读多写少。20万人抢2000个商品，最后提交的订单最多也就2000个，但是在秒杀过程中，这20万人会一直产生大量的读取请求。因此可以使用缓存服务对用户请求进行缓存优化，把一些高频访问的内容放到缓存中去。对于更大规模的系统，可以通过静态文件分离、CDN服务等把用户请求分散到外围设施中去，以此来分担系统压力。
异步处理和排队：通过消息队列和异步调用的方式可以实现接口异步处理，快速响应用户请求，在后端有较为充足的时间来处理实际的用户操作，提高对用户请求的响应速度，从而提升用户体验。通过消息队列还可以隔离前端的压力，实现排队系统，在涌入大量压力的情况下保证系统可以按照正常速率来处理请求，不会被流量压垮。
无状态服务设计：相对于有状态服务，无状态服务更容易进行扩展，实现无状态化的服务可以在秒杀活动前进行快速扩容。而云化的服务更是有着先天的扩容优势，一般都可以实现分钟级别的资源扩容。
系统扩容

这项内容是在云计算环境下才成为可能，相对于传统的IT行业，云计算提供了快速的系统交付能力（min VS. day），因此可以做到按需分配，在业务需要时实现资源的并行扩展。

对一次成功的秒杀活动来说，无论如何限流，如何优化系统，最终产生数倍于正常请求的压力是很正常的。因此临时性的系统扩容必不可少，系统扩容包括以下3个方面。

增加系统规格：可以预先增加系统容量，比如提高系统带宽、购买更多流量等。
服务扩展：无状态服务+负载均衡可以直接进行水平扩展，有状态的服务则需要进行较为复杂的垂直扩展，增大实例规格。
后端系统扩容：缓存服务和数据库服务都可以进行容量扩展。
秒杀服务实践

一般来说，流控的实现，特别是业务层流控，依赖于业务自身的设计，因此云计算提供的服务在于更多、更完善的基础设计，来支持用户进行更简单的架构优化和扩容能力。

系统架构优化

通过CDN服务和对象存储服务来分离静态资源，实现静态资源的加速，避免服务器被大量静态资源请求过度占用。要实现异步的消息处理，可以使用队列服务来传输消息，以达到消息异步化和流控。

系统扩容

云服务会提供按需计费的资源分配方式和分钟级甚至秒级的资源交付能力，根据需要快速进行资源定制和交付。

内部系统可以通过负载均衡等服务实现并行扩展，在网易云基础服务中，用户可以直接使用Kubernetes的Replication Controller服务实现在线水平扩容。对于对外提供的Web系统，可以通过负载均衡服务实现水平在线扩展。

对于后端系统来说，建议使用云计算服务商提供的基础服务来实现并行扩展。例如，网易云基础服务就提供了分布式缓存服务和数据库服务，支持在线扩容。

全文检索
搜索，是用户获取信息的主要方式。在日常生活中，我们不管是购物（淘宝）、吃饭（大众点评、美团网）还是旅游（携程、去哪儿），都离不开搜索的应用。搜索几乎成为每个网站、APP甚至是操作系统的标配。在用户面前，搜索通常只是展示为一个搜索框，非常干净简洁，但它背后的原理可没那么简单，一个框的背后包含的是一整套搜索引擎的原理。假如我们需要搭建一个搜索系统为用户提供服务，我们又需要了解什么呢？

基本原理

首先，我们需要知道全文检索的基本原理，了解全文检索系统在实际应用中是如何工作的。 
通常，在文本中查找一个内容时，我们会采取顺序查找的方法。譬如现在手头上有一本计算机书籍，我们需要查找出里面包含了“计算机”和“人工智能”关键字的章节。一种方法就是从头到尾阅读这本计算机书籍，在每个章节都留心是否包含了“计算机”和“人工智能”这两个词。这种线性扫描就是最简单的计算机文档检索方式。这个过程通常称为grepping，它来自于Unix下的一个文本扫描命令grep。在文本内进行grepping扫描很快，使用现代计算机会更快，并且在扫描过程中还可以通过使用正则表达式来支持通配符查找。总之，在使用现代计算机的条件下，对一个规模不大的文档集进行线性扫描非常简单，根本不需要做额外的处理。但是，很多情况下只采用上述扫描方式是远远不够的，我们需要做更多的处理。这些情况如下所述。

大规模文档集条件下的快速查找。用户的数据正在进行爆发性的增长，我们可能需要在几十亿到上万亿规模下的数据进行查找。
有时我们需要更灵活的匹配方式。比如，在grep命令下不能支持诸如“计算机NEAR人工智能”之类的查询，这里的NEAR操作符的定义可能为“5个词之内”或者“同一句子中”。
需要对结果进行排序。很多情况下，用户希望在多个满足自己需求的文档中得到最佳答案。
此时，我们不能再采用上面的线性扫描方式。一种非线性扫描的方式是事先给文档建立索引（Index）。回到上面所述的例子，假设我们让计算机对整书本预先做一遍处理，找出书中所有的单词都出现在了哪几个章节（由于单词会重复，通常都不会呈现爆炸式增长），并记录下来。此时再查找“计算机”和“人工智能”单词出现在哪几个章节中，只需要将保存了它们出现过的章节做合并等处理，即可快速寻找出结果。存储单词的数据结构在信息检索的专业术语中叫“倒排索引”（Inverted Index），因为它和正向的从章节映射到单词关系相反，是倒着的索引映射关系。

这种先对整个文本建立索引，再根据索引在文本中进行查找的过程就是全文检索（Full-text Search）的过程。图4展示了全文检索的一般过程。

图片描述
图4 全文检索的一般过程
首先是数据收集的过程（Gather Data），数据可以来源于文件系统、数据库、Web抓取甚至是用户输入。数据收集完成后我们对数据按上述的原理建立索引（Index Documents），并保存至Index索引库中。在图的右边，用户使用方面，我们在页面或API等获取到用户的搜索请求（Get Users’ Query），并根据搜索请求对索引库进行查询（Search Index），然后对所有的结果进行打分、排序等操作，最终形成一个正确的结果返回给用户并展示（Present Search Results）。当然在实现流程中还包含了数据抓取/爬虫、链接分析、分词、自然语言处理、索引结构、打分排序模型、文本分类、分布式搜索系统等技术，这是最简单抽象的流程描述。关于索引过程和搜索过程更详细的技术就不做更多介绍了，感兴趣的同学请参考其他专业书籍。

开源框架

根据上面的描述我们知道了全文检索的基本原理，但要是想自己从头实现一套搜索系统还是很困难的，没有一个专业的团队、一定的时间基本上做出不来，而且系统实现之后还需要面临生产环境等各种问题的考验，研发和维护成本都无比巨大。不过，现代的程序开发环境早已今非昔比，开源思想深入人心，开源软件大量涌现。没有特殊的需求，没有人会重新开发一套软件。我们可以站在开源巨人的肩膀上，直接利用开源软件的优势。目前市面上有较多的开源搜索引擎和框架，比较成熟和活跃的有以下几种。

Lucene
Solr
Elasticsearch
Sphinx
我们分别介绍这几种开源方案，并比较一下它们的优劣。

Lucene

Lucene是一个Java语言开发的搜索引擎类库，也是目前最火的搜索引擎内核类库。但需要注意的是，Lucene本身还不是一套完整的搜索引擎解决方案，它作为一个类库只是包含了核心的搜索、索引等功能，如果想使用Lucene，还需要做一些额外的开发工作。

优点：

Apache顶级项目，仍在持续快速进步。
成熟的解决方案，有很多成功案例。
庞大而活跃的开发社区，大量的开发人员。
虽然它只是一个类库，但经过简单的定制和开发，就可以满足绝大部分常见的需求；经过优化，可以支持企业级别量级的搜索。
缺点：

需要额外的开发工作。系统的扩展、分布式、高可用性等特性都需要自己实现。
Solr

Solr是基于Lucene开发、并由开发Lucene的同一帮人维护的一套全文搜索系统，Solr的版本通常和Lucene一同发布。Solr是最流行的企业级搜索引擎之一。

优点：

由于和Lucene共同维护，Solr也有一个成熟、活跃的社区。
Solr支持高级搜索特性，比如短语搜索、通配符搜索、join、group等。
Solr支持高吞吐流量、高度可扩展和故障恢复。
支持REST风格API，支持JSON、XML、CSV甚至二进制格式的数据；功能强大的综合管理页面、易于监控。
Solr已比较成熟、稳定。
缺点：

系统部署、配置及管理配置上的使用较为复杂。
Elasticsearh

Elasticsearch是一个实时的分布式搜索和分析引擎，和Solr一样，它底层基于Lucene框架。但它具有简单、易用、功能/性能强大等优点，虽然晚于Solr出现，但迅速成长，已成为目前当仁不让的最热门搜索引擎系统。

优点：

支持REST风格的HTTP API，并且事件完全受API驱动，几乎所有的操作都可以通过使用JSON格式的RESTful HTTP API完成。
支持多租户/多索引（multi-tenancy），支持全面的高级搜索特性。
索引模式自由（Schema Free），支持JSON格式数据；部署、配置简单，便于使用。
强大的聚合（Aggregation）分析功能（取代Lucene传统的Facets），便于用户对数据进行统计分析。
缺点：

几乎无缺点，在性能和资源上较C++ 开发的Sphinx稍差。
Sphinx

Sphinx是基于C++ 开发的一个全文检索引擎，从最开始设计时就注重性能、搜索相关性及整合简单性等方面。Sphinx可以批量索引和搜索SQL数据库、NoSQL存储中的数据，并提供和SQL兼容的搜索查询接口。

优点：

Sphinx采用C++ 开发，因此支持高速的构建索引及高性能的搜索。
支持SQL/NoSQL搜索。
方便的应用集成。
更高级的相似度计算排序模型。
缺点：

社区、生态等不如Lucene系发达，可见的成功案例较少。
应用选型

通过上面的介绍，相信大家对各个开源搜索系统所适用的场景有了一定了解。

如果是中小型企业，想快速上手使用搜索功能，可以选择Elasticsearch或Solr。如果对搜索性能和节省资源要求比较苛刻，可以考虑尝试Sphinx。如果有很多定制化的搜索功能需求，可以考虑在Lucene基础上做自定义开发。如果用于日志搜索，或者有很多的统计、分析等需求，可以选择Elasticsearch。

开源方案实践

如上述介绍，在实际开发当中已有了很多现成的开源方案可供选择，但我们还是需要额外再做一些事情。譬如集群搭建、维护和管理、高可用设计、故障恢复、最基本的机房申请及机器采购部署等。这也需要投入较高的人力和成本（虽然较自己研发已经节省很多），并且还需要配备专业的搜索开发及运维人员。

而在网易云中，我们基于开源Elasticsearch系统提供了一套简单的方案。我们把专业、复杂的搜索系统服务化和简单化，并降低准入门槛和成本，让用户可以直接使用平台化的搜索服务。我们提供了全面的近实时、高可用、高可靠、高扩展等搜索系统强大功能，易于用户使用。用户使用网易云的云搜索后不再需要处理搜索系统的搭建与配置工作，而只需要在云搜索服务的产品管理平台申请建立服务实例并配置索引数据格式，申请完成后云搜索平台就会自动生成索引服务实例并提供全文检索服务。

日志收集
日志，一组随时间增加的有序记录，是开发人员最熟悉的一种数据。通常，日志可以用来搜索查看关键状态、定位程序问题，以及用于数据统计、分析等。

日志也是企业生产过程中产生的伟大财富。日志可以用来进行商业分析、用户行为判断和企业战略决策等，良好地利用日志可以产生巨大的价值。所以，日志的收集不管是在开发运维还是企业决策中都十分重要。

第三方数据收集服务

在日志收集领域内，目前已经存在了种类繁多的日志收集工具，比较典型的有：rsyslog、syslog-ng、Logstash、FacebookScribe、ClouderaFlume、Fluentd和GraylogCollector等。

rsyslog是syslog的增强版，Fedora、Ubuntu、RHEL6、CentOS6、Debian等诸多Linux发行版都已使用rsyslog替换syslog作为默认的日志系统。rsyslog采用C语言实现，占用的资源少，性能高。专注于安全性及稳定性，适用于企业级别日志记录需求。rsyslog可以传输100万+/s（日志条数）的数据到本地目的地。即使通过网络传输到远程目的地，也能达到几万至几十万条/每秒的级别。rsyslog默认使用inotify实现文件监听（可以更改为polling模式，实时性较弱），实时收集日志数据。

rsyslog支持实时监听日志文件、支持通配符匹配目录下的所有文件（支持输出通配符匹配的具体文件名）、支持记录文件读取位置、支持文件Rotated、支持日志行首格式判断（多行合并成一行）、支持自定义tag、支持直接输出至file/mysql/kafka/elasticsearch等、支持自定义日志输出模板，以及支持日志数据流控。

syslog-ng具有开源、可伸缩和可扩展等特点，使用syslog-ng，你可以从任何来源收集日志，以接近实时的处理，输出到各种各样的目的源。syslog-ng灵活地收集、分析、分类和关联日志，存储和发送到日志分析工具。syslog-ng支持常见的输入，支持BSDsyslog（RFC3164）、RFC5424协议、JSON和journald消息格式。数据提取灵活，内置一组解析器，可以构建非常复杂事情。简化复杂的日志数据，syslog-ng patterndb可以转化关联事件为一个统一格式。支持数据库存储，包括SQL（MySQL，PostgreSQL，Oracle）、MongoDB和Redis。syslog-ng支持消息队列，支持高级消息队列协议（AMQP）和面向简单的文本消息传递协议（STOMP）与更多的管道。syslog-ng设计原则主要包括更好消息过滤粒度和更容易在不同防火墙网段转发信息。前者能够进行基于内容和优先权/facility的过滤。后者支持主机链，即使日志消息经过了许多计算机的转发，也可以找出原发主机地址和整个转发链。

Logstash是一个开源的服务器端数据处理管道，采集多种数据源的数据，转换后发送到指定目的源。数据通常以各种格式分散在许多孤立系统上。Logstash支持种类丰富的inputs，以事件的方式从各种源获取输入，包括日志、Web应用、数据存储设备和AWS服务等。在数据流从源到存储设备途中，Logstash过滤事件，识别字段名，以便结构化数据，更有利于数据分析和创造商业价值。除了Elasticsearch，Logstash支持种类丰富的outputs，可以把数据转发到合适的目的源。表2是几个典型产品的特性对比。

名称	开发语言	性能	所占资源	支持I/O插件种类	社区活跃度
rsyslog	C	高	少	中	中
syslog-ng	C	高	少	中	中
LogStash/Beats	LogStash:Ruby Beats:Go	中	多	多	高
FacebookScribe	C++	高	少	少	中
ClouderaFlume	Java	中	多	中	中
Fluentd	Ruby	中	多	多	高
表2 典型日志收集产品特性比较
技术选型

由于日志收集的需求并非很复杂，此类工具大体上比较相似，用户只需要根据其特性选择合适自己需求的产品。

通常来说，对于日志收集客户端资源占用要求较高的，可以选择C语音开发的rsyslog、syslog-ng。对于易用性要求较高，可以选择Logstash、Beats。对于日志收集后接入的后端有特殊需求，可以参考Fluentd是否可以满足。如果公司用的是Java技术栈，可以选用Cloudera Flume。

架构实践
除了基本的功能需求之外，一个互联网产品往往还有访问性能、高可用、可扩展等需要，这些统称为非功能需求。一般来说，功能需求往往可以通过开发业务模块来满足，而非功能需求往往要从系统架构设计出发，从基础上提供支持。

随着用户的增加，系统出现问题的影响也会增大。试想一下，一个小公司的主页，或者个人开发维护的一个App的无法访问，可能不会有多少关注。而支付宝、微信的宕机，则会直接被推到新闻头条（2015年支付宝光纤被挖路机挖断），并且会给用户带来严重的影响：鼓足勇气表白却发现信息丢失？掏出手机支付却发生支付失败，关键是还没带现金！在用户使用高峰时，一次故障就会给产品带来很大的伤害，如果频繁出现故障则基本等同于死刑判决。

同样，对一个小产品来说，偶发的延时、卡顿可能并不会有大的影响（可能已经影响到了用户，只是范围、概率较小）。而对于一个较为成熟的产品，良好的性能则是影响产品生死存亡的基本问题。试想一下，如果支付宝、微信经常出现卡顿、变慢，甚至在访问高峰时崩溃，那它们还能支撑起现在的用户规模，甚至成为基础的服务设施吗？可以说，良好的访问性能，是一个产品从幼稚到成熟所必须解决的问题，也是一个成功产品的必备因素。实际上，很多有良好创意、商业前景很好的互联网产品，就是因无法满足用户增长带来的性能压力而夭折。

随着性能需求的不断增长，所需要考虑的因素越多，出问题的概率也越大。因此，用户数的不断增长带来的挑战和问题几乎呈几何倍数增加，如果没有良好的设计和规划，随着产品和业务的不断膨胀，我们往往会陷入“修改→引入新问题→继续调整→引入更多问题”的泥潭中无法自拔。

在这一阶段，架构设计的重点不再是业务本身功能实现和架构的构建，而是如何通过优化系统架构，来满足系统的高可用、并行扩展和系统加速等需要。

前端系统扩展
可扩展性是大规模系统稳定运行的基石。随着互联网用户的不断增加，一个成功产品的用户量往往是数以亿计，无论多强大的单点都无法满足这种规模的性能需求。因此系统的扩展是一个成功互联网产品的必然属性，无法进行扩展的产品，注定没有未来。

由于扩展性是一个非常大的范畴，并没有一个四海皆准的手段或者技术来实现，因此本节主要介绍较为通用的可扩展系统设计，并以网易云为例，来介绍基础设施对可扩展性的支持。

无状态服务设计
要实现系统的并行扩展，需要对原有的系统进行服务化拆分。在服务实现时，主要有两种实现方式，分别是无状态服务和有状态服务。

特点

无状态服务

指的是服务在处理请求时，不依赖除了请求本身外的其他内容，也不会有除了响应请求之外的额外操作。如果要实现无状态服务的并行扩展，只需要对服务节点进行并行扩展，引入负载均衡即可。

有状态服务

指的是服务在处理一个请求时，除了请求自身的信息外，还需要依赖之前的请求处理结果。 
对于有状态服务来说，服务本身的状态也是正确运行的一部分，因此有状态服务相对难以管理，无法通过简单地增加实例个数来实现并行扩展。

对比

从技术的角度来看，有状态服务和无状态服务只是服务的两种状态，本身并没有优劣之分。在实际的业务场景下，有状态服务和无状态服务相比，有各自的优势。

有状态服务的特性如下。

数据局部性：数据都在服务内部，不需要依赖外部数据服务强并发，有状态服务可以把状态信息都放在服务内部，在并发访问时不用考虑冲突等问题，而本地数据也可以提供更好的存取效率。因此，单个有状态服务可以提供更强的并发处理能力。
实现简单：可以把数据信息都放在本地，因此可以较少考虑多系统协同的问题，在开发时更为简单。
无状态服务的特性如下。

易扩展：可以通过加入负载均衡服务，增加实例个数进行简单的并行扩展易管理，由于不需要上下文信息，因此可以方便地管理，不需要考虑不同服务实例之间的差异。
易恢复：对于服务异常，不需要额外的状态信息，只需要重新拉起服务即可。而在云计算环境下，可以直接建立新的服务实例，替代异常的服务节点即可。
总体来看，有状态服务在服务架构较为简单时，有易开发、高并发等优势，而无状态服务的优势则体现在服务管理、并行扩展方面。随着业务规模的扩大、系统复杂度的增加，无状态服务的这些优势，会越来越明显。因此，对于一个大型系统而言，我们更推荐无状态化的服务设计。

实践

下面，我们根据不同的服务类型，来分析如何进行状态分离。

常见的状态信息

Web服务：在Web服务中，我们往往需要用户状态信息。一个用户的访问过程，我们称为一个会话（Session），这也是Web服务中最为常见的状态信息。
本地数据：在业务运行过程中，会把一些运行状态信息保留到本地内存或者磁盘中。
网络状态：一些服务在配置时，会直接使用IP地址访问，这样在服务访问时就依赖相应的网络配置。一旦地址改变，就需要修改对应的配置文件。
状态分离

要把有状态的服务改造成无状态的服务，一般有以下两种做法。

请求附带全部状态信息：这种做法适用于状态信息比较简单的情况（如用户信息，登录状态等）。优点是实现较为简单，不需要额外设施。缺点是会导致请求内容增加，因此在状态信息较多时并不适用。
状态分离：即通过将状态信息分离到外部的独立存储系统中（一般是高速缓存数据库等），来把状态信息从服务中剥离出去。
Web服务状态分离

在Web服务中，两种状态分离模式都可以实现状态分离。

使用Cookie：把会话信息保存在加密后的Cookie之中，每次请求时解析Cookie内容来判断是否登录。这种做法的优点是实现简单，不需要额外的系统支持。缺点是Cookie的大小有限制，不能保持较大的状态信息，还会增加每次请求的数据传输量，同时Cookie必须要使用可靠的加密协议进行加密，否则会有被人篡改或者伪造的风险。因此这种做法一般用来保持用户登录状态。
共享Session：将Session信息保存在外部服务（共享内存、缓存服务、数据库等）中，在请求到来时再从外部存储服务中获取状态信息。这种做法没有状态信息大小的限制，也不会增加请求大小。但是需要可靠、高效的外部存储服务来进行支持。一般来说，可以直接使用云计算服务商提供的缓存服务。
服务器本身状态分离

对于依赖本地存储的服务，优先做法是把数据保存在公共的第三方存储服务中，根据内容的不同，可以保存在对象存储服务或者数据库服务中。

如果很难把数据提取到外部存储上，也不建议使用本地盘保存，而是建议通过挂载云硬盘的方式来保持本地状态信息。这样在服务异常时可以直接把云硬盘挂载在其他节点上来实现快速恢复。

对于网络信息，最好的做法是不要通过IP地址，而是通过域名来进行访问。这样当节点异常时，可以直接通过修改域名来实现快速的异常恢复。在网易云基础服务中，我们提供了基于域名的服务访问机制，直接使用域名来访问内部服务，减少对网络配置的依赖。

在线水平扩展
在线水平扩展能力是一个分布式系统需要提供的基本能力，也是在架构设计时需要满足的重要功能点。而水平扩展能力也是业务发展的硬性需求，从产品的角度出发，产品的业务流量往往存在着很大波动，具体如下。

产品业务量增长：在这个信息病毒式传播的时代，一些热点应用的业务量可能会在很短时间内大量增长。
周期性业务：客服服务、证券服务及春运购票等。这类活动往往都存在着很明显的周期性特征，会按照一定的周期（月、天、小时、分钟）进行波动。波峰和波谷的流量往往会有一个数量级以上的差异。
活动推广：一次成功的活动推广往往会带来数倍甚至数十倍的流量，需要业务可以快速扩展，在很短的时间内提供数十倍甚至上百倍的处理能力。
秒杀：秒杀活动是弹性伸缩压力最大的业务，会带来瞬时大量流量。 
为了应对这些场景，需要业务在一个很短的时间内提供强大的处理能力。而在业务低谷期，可以相应回收过剩的计算资源，减少消耗，达到系统性能和成本之间的平衡，提高产品的竞争力。
准备工作

产品对水平扩展的需求是一直存在的，但是受制于传统IT行业按天甚至按周计算的资源交付能力，弹性伸缩一直是一个美好的愿望。直到云计算这个基础设施完善之后，才使弹性伸缩的实现成为了可能。如果要实现弹性伸缩，需要以下几点的支持。

资源快速交付能力：业务可以根据需要，动态并快速地申请、释放资源。这也是云计算提供的基础能力，根据云计算平台的不同，一般都会提供从秒级到分钟级的资源交付能力，相对于传统IT管理按天计算的交付水平有了巨大的提升，这也是弹性伸缩的基础。在云环境下，绝大部分资源交付、扩容操作都可以在分钟级别完成，从而为弹性伸缩提供了基础支撑。
无状态服务设计：对于有状态服务来说，由于有着各种各样的状态信息，因此会使扩展的难度大大增加。因此，无状态话的服务设计，是弹性伸缩服务的前提。
业务性能监控：只有了解业务实际的负载情况，才有弹性伸缩的可能。只有对业务承载能力、运行负载有了全面的了解和实时监控，才能制定出相应的扩展指标。对于云服务厂商来说，基本上都提供了对基础资源，如CPU、内存、网络等的监控能力。而对应的PaaS服务，还提供了应用层数据的详细分析，为更细粒度、更加精确的扩展提供了可能。
统一的服务入口：只有提供了统一的服务入口，才可以在不影响用户的情况下实现后台服务的弹性伸缩。统一服务入口有两种实现机制，一种是在系统层面，通过负载均衡服务提供统一的流量入口，使用负载均衡服务统一进行管理。另一种是通过服务注册和发现机制，在服务层实现适配。对于外部访问，可以使用对外的负载均衡服务，对于内部服务，一般都会提供租户内部的负载均衡。业务方可以根据需要，使用对应的流量入口。
实现要点

前端系统一般都会采用无状态化服务设计，扩展相对简单。在实践中，有多种扩展方案，如通过DNS服务水平扩展、使用专有的apiserver、在SDK端分流及接入负载均衡等。其中负载均衡方案使用最广，综合效果也最好，可以满足绝大多数场景下的需要，下面就以负载均衡服务为例，介绍前端系统水平扩展的实现要点。

协议选择

负载均衡服务分为4层和7层服务，这两种并不是截然分开的，而是有兼容关系。4层负载均衡可以支持所有7层的流量转发，而且性能和效率一般也会更好。而7层负载均衡服务的优势在于解析到了应用层数据（HTTP层），因此可以理解应用层的协议内容，从而做到基于应用层的高级转发和更精细的流量控制。

对于HTTP服务，建议直接采用7层负载均衡，而其他所有类型的服务，如WebSocket、MySQL和Redis等，则可以直接使用TCP负载均衡。

无状态服务

前端系统可扩展性需要在系统设计层面进行保证，较为通用的做法是无状态化的服务设计。因为无状态，所以在系统扩展时只需要考虑外网设施的支持，而不需要改动服务代码。对于有状态的服务，则尽量服务改造把状态分离出去，将状态拆分到可以扩展的第三方服务中去。

高级流量转发

对于7层负载均衡来说，由于解析到了协议层，因此可以基于应用层的内容进行流量转发。除了最常用的粘性会话（Sticky Session）外，最常用的转发规则有基于域名和URL的流量转发两种。

基于域名的流量转发：外网的HTTP服务默认使用80端口提供，但经常会有多个不同域名的网站需要使用同样一个出口IP的情况。这时候就需要通过应用层解析，根据用户的访问域名把同一个端口的流量分发到不同的后端服务中去。域名流量转发是通过解析请求头的Host属性实现的，当浏览器通过域名访问时，会自动设置Host头。通过程序访问HTTP API接口时，一般的第三方库也会设置这个属性，但如果自己组装HTTP请求，则需要主动设置对应的Host头。
基于URL的流量转发：对一些大型网站，或者基于REST风格的API接口，单纯通过域名进行分流已经无法满足分流要求。此外，还存在着同一个域名的服务，根据URL分流到不同后端集群的情况，这种情况就可以通过请求中的URL路径信息，进行进一步分流。一般的URL都会支持模糊匹配。
后端系统扩展
后端系统，一般指用户接入端（Web系统、长连接服务器）和各种中间件之后的后台系统。在这一阶段，最重要的后端系统就是两种，缓存服务和数据库服务。下面，我们分别以Redis缓存服务和MySQL数据库为例，来介绍后端系统水平扩展的技术和核心技术点。

Redis水平扩展

Redis去年发布了3.0版本，官方支持了Redis cluster即集群模式。至此结束了Redis没有官方集群的时代，在官方集群方案以前应用最广泛的就属Twitter发布的Twemproxy（https://github.com/twitter/twemproxy），国内的有豌豆荚开发的Codis（https://github. com/wandoulabs/codis）。

下面我们介绍一下Twemproxy和Redis Cluster两种集群水平扩展。

Twemporxy+Sentinel方案

Twemproxy，也叫nutcraker，是Twitter开源的一个Redis和Memcache快速/轻量级代理服务器。

Twemproxy内部实现多种hash算法，自动分片到后端多个Redis实例上，Twemproxy支持失败节点自动删除，它会检测与每个节点的连接是否健康。为了避免单点故障，可以平行部署多个代理节点（一致性hash算法保证key分片正确），Client可以自动选择一个。

有了这些特性，再结合负载均衡和Sentinel就可以架构出Redis集群，如图5所示。

图片描述
图5 基于Twemporxy的Redis水平扩展
负载均衡：实现Twemproxy的负载均衡，提高proxy的可用性和可扩张能力，使Twemproxy的扩容对应用透明。
Twemproxy集群：多个Twemproxy平行部署（配置相同），同时接受客户端的请求并转发请求给后端的Redis。
Redis Master-Slave主从组：Redis Master存储实际的数据，并处理Twemproxy转发的数据读写请求。数据按照hash算法分布在多个Redis实例上。Redis Slave复制master的数据，作为数据备份。在Master失效的时候，由Sentinel把Slave提升为Master。
Sentinel集群：检测Master主从存活状态，当Redis Master失效的时候，把Slave提升为新Master。
水平扩展实现就可以将一对主从实例加入Sentinel中，并通知Twemporxy更新配置加入新节点，将部分key通过一致性hash算法分布到新节点上。

Twemproxy方案缺点如下。

加入新节点后，部分数据被动迁移，而Twemproxy并没有提供相应的数据迁移能力，这样会造成部分数据丢失。
LB（负载均衡）+ Twemproxy + Redis 3层架构，链路长，另外加上使用Sentinel集群保障高可用，整个集群很复杂，难以管理。
Redis Cluster方案

Redis Cluster是Redis官方推出的集群解决方案，其设计的重要目标就是方便水平扩展，在1000个节点的时候仍能表现良好，并且可线性扩展。

Redis Cluster和传统的集群方案不一样，在设计的时候，就考虑到了去中心化、去中间件，也就是说，集群中的每个节点都是平等的关系，每个节点都保存各自的数据和整个集群的状态。

数据的分配也没有使用传统的一致性哈希算法，取而代之的是一种叫做哈希槽（hash slot）的方式。Redis Cluster默认分配了16384个slot，当我们set一个key时，会用CRC16算法来取模得到所属的slot，然后将这个key分到哈希槽区间的节点上，具体算法是CRC16(key) % 16384。举个例子，假设当前集群有3个节点，那么：

节点r1包含0到5500号哈希槽。
节点r2包含5501到11000号哈希槽。
节点r3包含11001到16384号哈希槽。
集群拓扑结构如图4-3所示，此处不再重复给出。

Redis Cluster水平扩展很容易操作，新节点加入集群中，通过redis-trib管理工具将其他节点的slot迁移部分到新节点上面，迁移过程并不影响客户端使用，如图6所示。

图片描述
图6 Redis Cluster水平扩展
为了保证数据的高可用性，Redis Cluster加入了主从模式，一个主节点对应一个或多个从节点，主节点提供数据存取，从节点则是从主节点实时备份数据，当这个主节点瘫痪后，通过选举算法在从节点中选取新主节点，从而保证集群不会瘫痪。

Redis Cluster其他具体细节可以参考官方文档，这里不再详细介绍。Redis Cluster方案缺点如下。

客户端实现复杂，管理所有节点连接，节点失效或变化需要将请求转移到新节点。
没有中心管理节点，节点故障通过gossip协议传递，有一定时延。
数据库水平扩展

单机数据库的性能由于物理硬件的限制会达到瓶颈，随着业务数据量和请求访问量的不断增长，产品方除了需要不断购买成本难以控制的高规格服务器，还要面临不断迭代的在线数据迁移。在这种情况下，无论是海量的结构化数据还是快速成长的业务规模，都迫切需要一种水平扩展的方法将存储成本分摊到成本可控的商用服务器上。同时，也希望通过线性扩容降低全量数据迁移对线上服务带来的影响，分库分表方案便应运而生。

分库分表的原理是将数据按照一定的分区规则Sharding到不同的关系型数据库中，应用再通过中间件的方式访问各个Shard中的数据。分库分表的中间件，隐藏了数据Sharding和路由访问的各项细节，使应用在大多数场景下可以像单机数据库一样，使用分库分表后的分布式数据库。

分布式数据库

网易早在2006年就开始了分布式数据库（DDB）的研究工作，经过10年的发展和演变，DDB的产品形态已全面趋于成熟，功能和性能得到了众多产品的充分验证。

图7是DDB的完整架构，由cloudadmin、LVS、DDB Proxy、SysDB及数据节点组成。

cloudadmin：负责DDB的一键部署、备份管理、监控报警及版本管理等功能。
LVS：负责将用户请求均匀分布到多个DDB Proxy上。
DDB Proxy：对外提供MySQL协议访问，实现SQL语法解析、分布式执行计划生成、下发SQL语句到后端数据库节点，汇总合并数据库节点执行结果。
SysDB：DDB元数据存储数据库，也基于RDS实现高可用。
RDS：底层数据节点，一个RDS存储多个数据分片。
图片描述
图7 网易DDB架构
分布式执行计划

分布式执行计划定义了SQL在分库分表环境中各个数据库节点上执行的方法、顺序和合并规则，是DDB实现中最为复杂的一环。如SQL：select * from user order by id limit 10 offset 10。

这个SQL要查询ID排名在10～20之间的user信息，这里涉及全局ID排序和全局LIMIT OFFSET两个合并操作。对全局ID排序，DDB的做法是将ID排序下发给各个数据库节点，在DBI层再进行一层归并排序，这样可以充分利用数据库节点的计算资源，同时将中间件层的排序复杂度降到最低，例如一些需要用到临时文件的排序场景，如果在中间件做全排序会导致极大的开销。

对全局LIMIT OFFSET，DDB的做法是将OFFSET累加到LIMIT中下发，因为单个数据节点中的OFFSET没有意义，且会造成错误的数据偏移，只有在中间件层的全局OFFSET才能保证OFFSET的准确性。

所以最后下发给各个DBN的SQL变为：select * from user order by id limit 20。又如SQL：select avg(age) from UserTet group by name可以通过EXPLAIN语法得到SQL的执行计划，如图8所示。

图片描述
图8 分布式执行计划
上述SQL包含GROUP BY分组和AVG聚合两种合并操作，与全局ORDER BY类似，GROUP BY也可以下发给数据节点、中间件层做一个归并去重，但是前提要将GROUP BY的字段同时作为ORDER BY字段下发，因为归并的前提是排序。对AVG聚合，不能直接下发，因为得到所有数据节点各自的平均值，不能求出全局平均值，需要在DBI层把AVG转化为SUM和COUNT再下发，在结果集合并时再求平均。

DDB执行计划的代价取决于DBI中的排序、过滤和连接，在大部分场景下，排序可以将ORDER BY下发简化为一次性归并排序，这种情况下代价较小，但是对GROUP BY和ORDER BY同时存在的场景，需要优先下发GROUP BY字段的排序，以达到归并分组的目的，这种情况下，就需要将所有元素做一次全排序，除非GROUP BY和ORDER BY字段相同。

DDB的连接运算有两种实现，第一种是将连接直接下发，若连接的两张表数据分布完全相同，并且在分区字段上连接，则满足连接直接下发的条件，因为在不同数据节点的分区字段必然没有相同值，不会出现跨库连接的问题。第二种是在不满足连接下发条件时，会在DBI内部执行Nest Loop算法，驱动表的顺序与FROM表排列次序一致，此时若出现ORDER BY表次序与表排列次序不一致，则不满足ORDER BY下发条件，也需要在DBI内做一次全排序。

分库分表的执行计划代价相比单机数据库而言，更加难以掌控，即便是相同的SQL模式，在不同的数据分布和分区字段使用方式上，也存在很大的性能差距，DDB的使用要求开发者和DBA对执行计划的原理具有一定认识。

分库分表在分区字段的使用上很有讲究，一般建议应用中80%以上的SQL查询通过分区字段过滤，使SQL可以单库执行。对于那些没有走分区字段的查询，需要在所有数据节点中并行下发，这对线程和CPU资源是一种极大的消耗，伴随着数据节点的扩展，这种消耗会越来越剧烈。另外，基于分区字段跨库不重合的原理，在分区字段上的分组、聚合、DISTINCT、连接等操作，都可以直接下发，这样对中间件的代价往往最小。

分布式事务

分布式事务是个历久弥新的话题，分库分表、分布式事务的目的是保障分库数据一致性，而跨库事务会遇到各种不可控制的问题，如个别节点永久性宕机，像单机事务一样的ACID是无法奢望的。另外，业界著名的CAP理论也告诉我们，对分布式系统，需要将数据一致性和系统可用性、分区容忍性放在天平上一起考虑。

两阶段提交协议（简称2PC）是实现分布式事务较为经典的方案，适用于中间件这种数据节点无耦合的场景。2PC的核心原理是通过提交分阶段和记日志的方式，记录下事务提交所处的阶段状态，在组件宕机重启后，可通过日志恢复事务提交的阶段状态，并在这个状态节点重试，如Coordinator重启后，通过日志可以确定提交处于Prepare还是PrepareAll状态，若是前者，说明有节点可能没有Prepare成功，或所有节点Prepare成功但还没有下发Commit，状态恢复后给所有节点下发RollBack；若是PrepareAll状态，需要给所有节点下发Commit，数据库节点需要保证Commit幂等。与很多其他一致性协议相同，2PC保障的是最终一致性。

2PC整个过程如图9所示。

图片描述
图9 两阶段提交协议
在网易DDB中，DBI和Proxy组件都作为Coordinator存在，2PC实现时，记录Prepare和PrepareAll的日志必须sync，以保障重启后恢复状态正确，而Coordinator最后的Commit日志主要作用是回收之前日志，可异步执行。

由于2PC要求Coordinator记日志，事务吞吐率受到磁盘I/O性能的约束，为此DDB实现了GROUP I/O优化，可极大程度提升2PC的吞吐率。2PC本质上说是一种阻塞式协议，两阶段提交过程需要大量线程资源，因此CPU和磁盘都有额外消耗，与单机事务相比，2PC在响应时间和吞吐率上相差很多，从CAP角度出发，可以认为2PC在一定程度上成全了C，牺牲了A。

另外，目前MySQL最流行的5.5和5.6版本中，XA事务日志无法复制到从节点，这意味着主库一旦宕机，切换到从库后，XA的状态会丢失，可能造成数据不一致，MySQL 5.7版本在这方面已经有所改善。

虽然2PC有诸多不足，我们依然认为它在DDB中有实现价值，DDB作为中间件，其迭代周期要比数据库这种底层服务频繁，若没有2PC，一次更新或重启就可能造成应用数据不一致。从应用角度看，分布式事务的现实场景常常无法规避，在有能力给出其他解决方案前，2PC也是一个不错的选择。

对购物转账等电商和金融业务，中间件层的2PC最大问题在于业务不可见，一旦出现不可抗力或意想不到的一致性破坏，如数据节点永久性宕机，业务难以根据2PC的日志进行补偿。金融场景下，数据一致性是命根，业务需要对数据有百分之百的掌控力，建议使用TCC这类分布式事务模型，或基于消息队列的柔性事务框架，请参考第5章，这两种方案都在业务层实现，业务开发者具有足够掌控力，可以结合SOA框架来架构。原理上说，这两种方案都是大事务拆小事务，小事务变本地事务，最后通过幂等的Retry来保障最终一致性。

弹性扩容

分库分表数据库中，在线数据迁移也是核心需求，会用在以下两种场景中。

数据节点弹性扩容：随着应用规模不断增长，DDB现有的分库可能有一天不足以支撑更多数据，要求DDB的数据节点具有在线弹性扩容的能力，而新节点加入集群后，按照不同的Sharding策略，可能需要将原有一些数据迁入新节点，如HASH分区，也有可能不需要在线数据迁移，如一些场景下的Range分区。无论如何，具备在线数据迁移是DDB支持弹性扩容的前提。
数据重分布：开发者在使用DDB过程中，有时会陷入困局，比如一些表的分区字段一开始没考虑清楚，在业务初具规模后才明确应该选择其他字段。又如一些表一开始认为数据量很小，只要单节点分布即可，而随着业务变化，需要转变为多节点Sharding。这两种场景都体现了开发者对DDB在线数据迁移功能的潜在需求。
无论是弹性扩容，还是表重分布，都可当作DDB以表或库为单位的一次完整在线数据迁移。该过程分为全量迁移和增量迁移两个阶段，全量迁移是将原库或原表中需要迁移的数据DUMP出来，并使用工具按照分区策略导入到新库新表中。增量迁移是要将全量迁移过程中产生的增量数据更新按照分区策略应用到新库新表。

全量迁移的方案相对简单，使用DDB自带工具按照特定分区策略DUMP和Load即可。对增量迁移，DDB实现了一套独立的迁移工具Hamal来订阅各个数据节点的增量更新，Hamal内部又依赖DBI模块将增量更新应用到新库新表，如图10所示。

图片描述
图10 DDB增量迁移工具Hamal
Hamal作为独立服务，与Proxy一样由DDB统一配置和管理，每个Hamal进程负责一个数据节点的增量迁移，启动时模拟Slave向原库拉取Binlog存储本地，之后实时通过DBI模块应用到新库新表，除了基本的迁移功能外，Hamal具备以下两个特性。

并行复制：Hamal的并行复制组件，通过在增量事件之间建立有向无环图，实时判断哪些事件可以并行执行，Hamal的并行复制与MySQL的并行复制相比快10倍以上。
断点续传：Hamal的增量应用具有幂等性，在网络中断或进程重启之后可以断点续传。
全局表

考虑一种场景：City表记录了国内所有城市信息，应用中有很多业务表需要与City做联表查询，如按照城市分组统计一些业务信息。假设City的主键和分区键都是CityId，若连接操作发生在中间件层，代价较高，为了将连接操作下发数据节点，需要让连接的业务表同样按照CityId分区，而大多数业务表往往不能满足这个条件。

连接直接下发需要满足两个条件，数据分布相同和分区键上连接，除此之外，其实还有一种解法，可以把City表冗余到所有数据节点中，这样各个数据节点本地连接的集合便是所求结果。DDB将这种类型的表称之为全局表。

全局表的特点是更新极少，通过2PC保障各个节点冗余表的一致性。可以通过在建表语句添加相关Hint指定全局表类型，在应用使用DDB过程中，全局表的概念对应用不可见。

本文节选自《云原生应用架构实践》，网易云基础服务架构团队著。