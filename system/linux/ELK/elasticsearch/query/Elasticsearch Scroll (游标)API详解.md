

Elasticsearch Scroll (游标)API详解 - Terry 的博客 - 博客频道 - CSDN.NET 
http://blog.csdn.net/u012450329/article/details/52692628

分类：全文索引
（423） （0） 举报 收藏
http://www.16php.com/archives/380
今天我们来探讨一下Elasticsearch Scroll API，在这之前我们先回顾一下数据库的知识。
1. 相关数据库知识（帮助理解）
传统数据库游标：游标（cursor）是系统为用户开设的一个数据缓冲区，存放SQL语句的执行结果。每个游标区都有一个名字,用户可以用SQL语句逐一从游标中获取记录，并赋给主变量，交由主语言进一步处理。就本质而言，游标实际上是一种能从包括多条数据记录的结果集中每次提取一条记录的机制。
游标是一段私有的SQL工作区,也就是一段内存区域,用于暂时存放受SQL语句影响到的数据。通俗理解就是将受影响的数据暂时放到了一个内存区域的虚表中，而这个虚表就是游标。
2. 为什么使用Elasticsearch Scroll
当Elasticsearch响应请求时，它必须确定docs的顺序，排列响应结果。如果请求的页数较少（假设每页20个docs）, Elasticsearch不会有什么问题，但是如果页数较大时，比如请求第20页，Elasticsearch不得不取出第1页到第20页的所有docs，再去除第1页到第19页的docs，得到第20页的docs。
解决的方法就是使用Scroll。因为Elasticsearch要做一些操作（确定之前页数的docs）为每一次请求，所以，我们可以让Elasticsearch储存这些信息为之后的查询请求。这样做的缺点是，我们不能永远的储存这些信息，因为存储资源是有限的。所以Elasticsearch中可以设定我们需要存储这些信息的时长。
3. 如何使用 Elasticsearch Scroll
我们只需在普通的query后加上scroll的参数例如： curl -XGET localhost:9200/bank/account/_search?pretty&scroll=2m -d {“query”:{“match_all”:{}}} 其中“2m” 代表2分钟，是需要保存的时长（数字+单位，具体单位表示见表1）。
Table 1. 时间单位对照表
Time	Units
y	Year
M	Month
w	Week
d	Day
h	Hour
m	Minute
s	Second
上面的查询语句返回如下结果:
{
  "_scroll_id": : " cXVlcnlUaGVuRmV0Y2g7NTs5MTM6aDEySHRHNVpScVNiN2VUZVV6QV9xdzs5MTQ6aDEySHRHNVpScVNiN2VUZVV6QV9xdzs5MTU6aDEySHRHNVpScVNiN2VUZVV6QV9xdzs5MTc6aDEySHRHNVpScVNiN2VUZVV6QV9xdzs5MTY6aDEySHRHNVpScVNiN2VUZVV6QV9xdzswOw==",
  "took" : 3,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
    }…
观察返回结果可以发现，新增加了“_scroll_id”部分。这是一个在稍后查询中需要用到的句柄。之后的查询语句如下：
curl –XGET 'localhost:9200/_search/scroll?
scroll=2m&pretty&scroll_id=cXVlcnlUaGVuRmV0Y2g7NTs5MTM6aDEySHRHNVpScVNiN2VUZVV6QV9xdzs5MTQ6aDEySHRHNVpScVNiN2VUZVV6QV9xdzs5MTU6aDEySHRHNVpScVNiN2VUZVV6QV9xdzs5MTc6aDEySHRHNVpScVNiN2VUZVV6QV9xdzs5MTY6aDEySHRHNVpScVNiN2VUZVV6QV9xdzswOw=='
在上面语句的返回结果中，又会包含“_scroll_id”部分，在每次的查询中都会返回一个新的 “_scroll_id”（只有最新返回的“_scroll_id”是有效的），再次的查询只能使用最新的“_scroll_id”。注：如果查询中包含聚合，只有最初的查询结果是聚合结果。
3.1. Scanning Scroll API
如果只对查询结果感兴趣而不关心结果的顺序，可以使用更高效的scanning scroll。使用方法非常简单，只需在查询语句后加上“search_type=scan”即可。
curl -XGET 'localhost:9200/bank/account/_search?pretty&scroll=2m&search_type=scan' -d '{"size":3,"query":{"match_all":{}}}'
curl –XGET 'localhost:9200/_search/scroll?scroll=2m&pretty&scroll_id=c2Nhbjs1OzkzMzpoMTJIdEc1WlJxU2I3ZVRlVXpBX3F3OzkzNzpoMTJIdEc1WlJxU2I3ZVRlVXpBX3F3OzkzNDpoMTJIdEc1WlJxU2I3ZVRlVXpBX3F3OzkzNjpoMTJIdEc1WlJxU2I3ZVRlVXpBX3F3OzkzNTpoMTJIdEc1WlJxU2I3ZVRlVXpBX3F3OzE7dG90YWxfaGl0czoxMDAwOw==
A scanning scroll 查询与 a standard scroll 查询有几点不同：
•  1. A scanning scroll 查询结果没有排序，结果的顺序是doc入库时的顺序；
•  2. A scanning scroll 查询不支持聚合
•  3. A scanning scroll最初的查询结果的“hits”列表中不会包含结果
•  4. A scanning scroll 最初的查询中如果设定了“size”，如下：
curl -XGET 'localhost:9200/bank/account/_search?pretty&scroll=2m&search_type=scan' -d '{"size":3,"query":{"match_all":{}}}'
•	这个“size”是设定每个分片（shard）的数量，也就是说如果设定size=3，而有5个shard，每次返回结果的最大值就是3*5=15。
3.2. 清除Scroll API
1. 在scroll search过程中保存的信息在超时后会自动删除，但是我们也可以通过clear scroll API来手动删除。如下：
curl –XDELETE 'localhost:9200/_search/scroll -d 'c2Nhbjs2OzM0NDg1ODpzRlBLc0FXNlNyNm5JWUc1'
2. 如果要删除多个，可以用逗号隔开，也可以通过下面语句全部删除
curl –XDELETE 'localhost:9200/_search/scroll/_all'
4. Elasticsearch 客户端TransportClient
TestTransportClient.Java（使用TransportClient代码示例）
// 实例化ES配置信息 
Settings settings = ImmutableSettings.settingsBuilder()
  .put("client.transport.sniff", true)
  .put("cluster.name", "hansight_cluster")
  .put("node.name","node1").build();
// 实例化ES客户端 
Client client = new TransportClient(settings)
  .addTransportAddress(new InetSocketTransportAddress("XXX.XXX.XXX.XXX", 9300));
// 设置Scroll参数,执行查询并返回结果 
SearchResponse scrollResp = client.prepareSearch("bank")
  .setTypes("account")
  .setSearchType(SearchType.SCAN)
  .setScroll(new TimeValue(20000))
  .setSize(3).execute().actionGet();
4.1. TransportClient#execute() 过程
下面先介绍一下execute()的过程，整个过程分两大步骤：
第一步：send request
•  在设置完各种search request属性后，返回的是一个ActionRequestBuilder的对象（本例中是SearchRequestBuilder对象），该类位于：org.elasticsearch.action包下（SearchRequestBuilder位于：org.elasticsearch.action.search下）
•  在execute(…)方法中，创建了一个ActionListener（PlainListenableActionFuture是ActionListener的实现类）。那么这个ActionListener的作用是什么呢？我们从源码中找到关于ActionListener的说明：“A listener for action responses or failures”,是用来监听action的执行结果（响应或者失败）的。创建源码如下：
public ListenableActionFutureexecute() {
  PlainListenableActionFuturefuture = new PlainListenableActionFuture<>(request.listenerThreaded(), threadPool);
  execute(future);
  return future;
}
•  listener已经创建好了，但是我们还没有对应要监听的action，于是开始构建相应的action，在org.elasticsearch.client.support. AbstractClient的search方法中我们找到了构建过程：
@Override
public void search(final SearchRequest request, final ActionListenerlistener) {
  execute(SearchAction.INSTANCE, request, listener);
}
•  在源码的SearchAction.INSTANCE这一步构建了我们本次search所需的action。 那么action是干嘛的呢？action在源码中的说明为“Base action. Supports building the Request through a RequestBuilder”，可见它是用来创建请求的，本例中我们就是创建了一个search的请求，并用listener来监听它的执行结果。
•  然后再通过action的proxy来调用执行org.elasticsearch.transport. TransportService的sendRequest方法将请求发送到server端。
第二步：service response
•  service端收到request后经过什么操作我们暂且不管（在service端中会详细说明）。Service处理完成后把结果返回到客户端。首先介绍一个非常重要的类：org.elasticsearch.transport.netty包下的MessageChannelHandler。 服务端的response返回后首先到了MessageChannelHandler的messageReceived(…)方法：
public void messageReceived(ChannelHandlerContext ctx, MessageEvent e) throws Exception {
   …
  if (TransportStatus.isRequest(status)) {…}
  else {
    TransportResponseHandler handler = transportServiceAdapter.remove(requestId);
    // ignore if its null, the adapter logs it 
    if (handler != null) {
      if (TransportStatus.isError(status)) {
        handlerResponseError(wrappedStream, handler);
        } else {
          handleResponse(ctx.getChannel(), wrappedStream, handler);
        }
        } else {
          // if its null, skip those bytes 
          buffer.readerIndex(markedReaderIndex + size);
        }
         …
      }
•  然后从缓存中又取得了这个这次请求的handler。 通过调用handler.handleResponse(response)这一步从而把response返回到了future对象中 （注：future=this.client.prepareSearch(“bank”).setTypes(“account”).setScroll(new TimeValue(20000)).setSize(3).execute()）。 至此execute()操作完成。
4.2. actionGet()操作
根据execute()操作返回的future对象直接调用actionGet()就获得结果。 
SearchResponse scrollResp = future. actionGet();
5. Elasticsearch Scroll 服务端
Elasticsearch scroll 首次查询和之后的查询流程有所不同，设置了scan属性的查询和没设置该属性的查询流程也不同，client设置的request的属性不同，决定了Service端的处理流程。
•  首先MessageChannelHandlerd的messageReceived方法接受到请求， 在handleRequest方法中获得请求相应的handler。这里需要注意的是，根据请求的不同，获取到的handler也是不一样的，例如第一次scroll search的handler是org.elasticsearch.action.search.TransportSearchAction .TransportHandler，而之后的scroll query的handler就变成org.elasticsearch.action.search.TransportSearchScrollAction.TransportHandler。
•  之后再调用handler的messageReceived的方法，下面我们看一下这个方法：
public void messageReceived(SearchRequest request, final TransportChannel channel) throws Exception {
  // no need for a threaded listener 
  request.listenerThreaded(false);
  execute(request, new ActionListener() {
    @Override
    public void onResponse(SearchResponse result) {
      try {
        channel.sendResponse(result);
        } catch (Throwable e) {
          onFailure(e);
        }
      }
 
      @Override
      public void onFailure(Throwable e) {
        try {
          channel.sendResponse(e);
          } catch (Exception e1) {
            logger.warn("Failed to send response for search", e1);
          }
        }
        });
      }
•  这个方法包含两个参数request和channel，request顾名思义，它包含了我们请求的信息，channel意思是通道，而它的作用也确实类似于通道，它可以把操作结果（成功返回请求结果，失败则返回失败信息）返回给客户端。
•  下面我们再研究一下具体的操作类org.elasticsearch.action.search.type.TransportSearchQueryThenFetchAction（我们以first scroll search为例说明）。它的业务逻辑主要靠其内部类AsyncAction来完成。通过调用performFirstPhase方法（其实是父类BaseAsyncAction的方法）来进行first scroll search，这个过程分三步：
•	第一步：query（sendExecuteFirstPhase这个方法）；
•	第二步：fetch（onFirstPhaseResult这个方法）;
•	第三步：最后将获得的结果通过回调listener.onResponse(response)将结果返回给客户端。
6. 关于scroll_id的几点补充
scroll_id是在Elasticsearch server端产生的。
6.1. 在哪一步产生的?
•  在fetch刚刚结束的时候，即TransportAction的各种子类，在本文例子中就是TransportSearchQueryThenFetchAction，在调用TransportSearchQueryThenFetchAction.AsyncAction. innerFinishHim()方法中：
void innerFinishHim() throws Exception {
  InternalSearchResponse internalResponse = searchPhaseController.merge(sortedShardList, firstResults, fetchResults);
  String scrollId = null;
  if (request.scroll() != null) {
    scrollId = TransportSearchHelper.buildScrollId(request.searchType(), firstResults, null);
  }
  listener.onResponse(new SearchResponse(internalResponse, scrollId, expectedSuccessfulOps, successfulOps.get(), buildTookInMillis(), buildShardFailures()));
}
调用了TransportSearchHelper的buildScrollId方法，来创建了scroll_id
6.2. scroll_id的含义
•  先让我们来看一下TransportSearchHelper的buildScrollId方法：
public static String buildScrollId(SearchType searchType, AtomicArray searchPhaseResults, @Nullable Map attributes) throws IOException {
  if (searchType == SearchType.DFS_QUERY_THEN_FETCH || searchType == SearchType.QUERY_THEN_FETCH) {
    return buildScrollId(ParsedScrollId.QUERY_THEN_FETCH_TYPE, searchPhaseResults, attributes);
    }
  }
  ...
  public static String buildScrollId(String type, AtomicArray searchPhaseResults, @Nullable Map attributes) throws IOException {
    ...
    return Base64.encodeBytes(bytesRef.bytes, bytesRef.offset, bytesRef.length, Base64.URL_SAFE);
  }
•  可以看到buildScrollId包含三个参数：
•	Type：String，查询的类型，ParsedScrollId.QUERY_THEN_FETCH_TYPE=queryThenFetch；
•	searchPhaseResults：结果信息
•	attributes：查询条件参数
•  可见生成的scroll_id中包含了这一次查询的查询方式以及一些结果信息，由于每次查询的结果不同，所以生成的scroll_id也不同，这也是Elasticsearch API要求每次scroll查询要用最新 scroll_id的原因。
•  下面我们解码一个scroll_id来看看它的内容：
String scrollId = "cXVlcnlUaGVuRmV0Y2g7NTsxMTU0OmgxMkh0RzVaUnFTYjdlVGVVekFfcXc7MTE1MzpoMTJIdEc1WlJxU2I3ZVRlVXpBX3F3OzExNTY6aDEySHRHNVpScVNiN2VUZVV6QV9xdzsxMTU1OmgxMkh0RzVaUnFTYjdlVGVVekFfcXc7MTE1NzpoMTJIdEc1WlJxU2I3ZVRlVXpBX3F3OzA7";
  BytesRef scroll_id_bytes = new BytesRef();
  scroll_id_bytes.bytes = Base64.decode(scrollId);
  CharsRef chars = new CharsRef();
  UnicodeUtil.UTF8toUTF16(scroll_id_bytes.bytes, 0, scroll_id_bytes.bytes.length, chars);
  System.out.println("================");
  StringBuffer sb = new StringBuffer();
  for (char c : chars.chars) {
    sb.append(c);
  }
  System.out.println(sb);
  System.out.println("================");
运行结果如下：
 ================
  queryThenFetch;5;1154:h12HtG5ZRqSb7eTeUzA_qw;1153:h12HtG5ZRqSb7eTeUzA_qw;1156:h12HtG5ZRqSb7eTeUzA_qw;1155:h12HtG5ZRqSb7eTeUzA_qw;1157:h12HtG5ZRqSb7eTeUzA_qw;0;
  ================

