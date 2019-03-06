
## 1. window.callStacks 数据初始化 

```js
// 1. 
scope.$on('distributedCallFlowDirective.initialize.' + scope.namespace, function (event, transactionDetail) {
    initialize(transactionDetail);
});

// 2.
initialize = function (t) {
    window.callStacks = parseData(t.callStackIndex, t.callStack);
    // initialize the model

// 3.
dataView.setItems(window.callStacks);
```

## 2. 数据请求

1. http://172.20.62.129:8079/applications.pinpoint
2. http://172.20.62.129:8079/transactionInfo.pinpoint?agentId=test06portal-account-se&spanId=-2046869430050847345&traceId=test06portal-account-se%5E1551337904753%5E155&focusTimestamp=1551751480431&_=1551862031666
3. http://172.20.62.129:8079/configuration.pinpoint


## 3. transactionmetadata.pinpoint 数据解析

curl 'http://172.20.62.129:8079/transactionmetadata.pinpoint' -H 'Origin: http://172.20.62.129:8079' -H 'Accept-Encoding: gzip, deflate' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: application/json, text/plain, */*' -H 'Referer: http://172.20.62.129:8079/' -H 'Cookie: jenkins-timestamper-offset=-28800000; _ga=GA1.1.266930125.1536654252; ACEGI_SECURITY_HASHED_REMEMBER_ME_COOKIE=Y21pOjE1NTIwMTY1NDUzMTg6MzNhMWFjNTk0OWZjNzc2YjZmZDRiMDk1ZTk0ZWUzYTNiYWM1NjVjNTNiYzQyMDc0ZTliNWFjYzA1NDUzNTQzYw==; _gid=GA1.1.873026750.1551856481' -H 'Connection: keep-alive' --data 'I0=test06portal-account-se^1551337904753^199&T0=1551840094367&R0=9&I1=test06portal-account-se^1551337904753^198&T1=1551840094137&R1=44&I2=test06portal-account-se^1551337904753^197&T2=1551840093239&R2=124&I3=test06portal-account-se^1551337904753^196&T3=1551840093113&R3=8&I4=test06portal-account-se^1551337904753^195&T4=1551840090408&R4=4&I5=test06portal-account-se^1551337904753^194&T5=1551840089705&R5=4&I6=test06portal-account-se^1551337904753^193&T6=1551840089377&R6=32&I7=test06portal-account-se^1551337904753^192&T7=1551839554491&R7=12&I8=test06portal-account-se^1551337904753^191&T8=1551839554268&R8=14&I9=test06portal-account-se^1551337904753^190&T9=1551839553479&R9=56&I10=test06portal-account-se^1551337904753^189&T10=1551839553421&R10=7&I11=test06portal-account-se^1551337904753^188&T11=1551839552270&R11=5&I12=test06portal-account-se^1551337904753^187&T12=1551839551636&R12=5&I13=test06portal-account-se^1551337904753^186&T13=1551839550630&R13=34&I14=test06portal-account-se^1551337904753^185&T14=1551838243788&R14=7&I15=test06portal-account-se^1551337904753^184&T15=1551838243594&R15=17&I16=test06portal-account-se^1551337904753^183&T16=1551838242701&R16=42&I17=test06portal-account-se^1551337904753^182&T17=1551838242657&R17=5&I18=test06portal-account-se^1551337904753^181&T18=1551838241387&R18=7&I19=test06portal-account-se^1551337904753^180&T19=1551838240277&R19=8&I20=test06portal-account-se^1551337904753^179&T20=1551838239943&R20=37&I21=test06portal-account-se^1551337904753^178&T21=1551836911112&R21=10&I22=test06portal-account-se^1551337904753^177&T22=1551836910862&R22=20&I23=test06portal-account-se^1551337904753^176&T23=1551836909944&R23=69&I24=test06portal-account-se^1551337904753^175&T24=1551836909872&R24=5&I25=test06portal-account-se^1551337904753^174&T25=1551836908541&R25=6&I26=test06portal-account-se^1551337904753^173&T26=1551836907839&R26=8&I27=test06portal-account-se^1551337904753^172&T27=1551836907567&R27=29&I28=test06portal-account-se^1551337904753^171&T28=1551836426450&R28=9&I29=test06portal-account-se^1551337904753^170&T29=1551836426239&R29=65&I30=test06portal-account-se^1551337904753^169&T30=1551836423896&R30=81&I31=test06portal-account-se^1551337904753^168&T31=1551836423812&R31=8&I32=test06portal-account-se^1551337904753^167&T32=1551836422379&R32=11&I33=test06portal-account-se^1551337904753^166&T33=1551836421559&R33=5&I34=test06portal-account-se^1551337904753^165&T34=1551836421145&R34=81&I35=test06portal-account-se^1551337904753^164&T35=1551752037630&R35=10&I36=test06portal-account-se^1551337904753^163&T36=1551752037350&R36=34&I37=test06portal-account-se^1551337904753^162&T37=1551752036155&R37=138&I38=test06portal-account-se^1551337904753^161&T38=1551752036014&R38=6&I39=test06portal-account-se^1551337904753^160&T39=1551752034619&R39=12&I40=test06portal-account-se^1551337904753^159&T40=1551752033737&R40=5&I41=test06portal-account-se^1551337904753^158&T41=1551752033314&R41=29&I42=test06portal-account-se^1551337904753^157&T42=1551751481999&R42=12&I43=test06portal-account-se^1551337904753^156&T43=1551751481701&R43=22&I44=test06portal-account-se^1551337904753^155&T44=1551751480431&R44=125&I45=test06portal-account-se^1551337904753^154&T45=1551751480304&R45=8&I46=test06portal-account-se^1551337904753^153&T46=1551751473624&R46=5&I47=test06portal-account-se^1551337904753^152&T47=1551751471595&R47=8&I48=test06portal-account-se^1551337904753^151&T48=1551751469654&R48=5&I49=test06portal-account-se^1551337904753^150&T49=1551751468635&R49=10&I50=test06portal-account-se^1551337904753^149&T50=1551751467651&R50=32&I51=test06portal-account-se^1551337904753^148&T51=1551750647659&R51=10&I52=test06portal-account-se^1551337904753^147&T52=1551750647453&R52=15&I53=test06portal-account-se^1551337904753^146&T53=1551750646428&R53=44&I54=test06portal-account-se^1551337904753^145&T54=1551750646381&R54=7&I55=test06portal-account-se^1551337904753^144&T55=1551750639945&R55=5&I56=test06portal-account-se^1551337904753^143&T56=1551750639152&R56=6&I57=test06portal-account-se^1551337904753^142&T57=1551750638538&R57=136' --compressed

1. http://172.20.62.129:8079/transactionmetadata.pinpoint
2. 列出应用，获取spanId，获取traceId
```json
{
	"metadata": [{
			"agentId": "test06portal-account-se",
			"collectorAcceptTime": 1551840094367,
			"elapsed": 9,
			"spanId": "-1233040673034219464",
			"traceId": "test06portal-account-se^1551337904753^199",
			"application": "Microservice:get***",
			"startTime": 1551840094356,
			"endpoint": "10.244.15.158:20068",
			"remoteAddr": "10.244.21.129:38714",
			"exception": 0
		}
```


## 4. transactionInfo.pinpoint 数据解析

1. http://172.20.62.129:8079/transactionInfo.pinpoint?agentId=test06portal-account-se&spanId=-2046869430050847345&traceId=test06portal-account-se%5E1551337904753%5E155&focusTimestamp=1551751480431&_=1551862031666

2. 获取详细信息
```json
"callStack": [["", 1551751480300, 1551751480425, false, "test06portal-account-se", 0, "1", "", true, true, "invoke(Invocation invocation)", "MicroService:add***", "02:04:40 300", "0", "125", "0", "8", "AbstractProxyInvoker", "0", "DUBBO_PROVIDER", "test06portal-account-se", true, false, true],
["", 0, 0, false, null, 2, "6", "5", false, false, "SQL", "select * from ls_portal_channel_user_account where *** ", "", "", "", "", "", "", "0", "", null, false, false, true],
```

## 5. transactionmetadata

1. pinpoint\web\src\main\java\com\navercorp\pinpoint\web\controller\ScatterChartController.java
```java
    /**
     * selected points from scatter chart data query
     *
     * @param requestParam
     * @return
     */
    @RequestMapping(value = "/transactionmetadata", method = RequestMethod.POST)
    @ResponseBody
    public TransactionMetaDataViewModel transactionmetadata(@RequestParam Map<String, String> requestParam) {
        TransactionMetaDataViewModel viewModel = new TransactionMetaDataViewModel();
        TransactionMetadataQuery query = parseSelectTransaction(requestParam);
        if (query.size() > 0) {
            List<SpanBo> metadata = scatter.selectTransactionMetadata(query);
            viewModel.setSpanBoList(metadata);
        }

        return viewModel;
    }

    private TransactionMetadataQuery parseSelectTransaction(Map<String, String> requestParam) {
        final TransactionMetadataQuery query = new TransactionMetadataQuery();
        int index = 0;
        while (true) {
            final String transactionId = requestParam.get(PREFIX_TRANSACTION_ID + index);
            final String time = requestParam.get(PREFIX_TIME + index);
            final String responseTime = requestParam.get(PREFIX_RESPONSE_TIME + index);

            if (transactionId == null || time == null || responseTime == null) {
                break;
            }

            query.addQueryCondition(transactionId, Long.parseLong(time), Integer.parseInt(responseTime));
            index++;
        }
        logger.debug("query:{}", query);
        return query;
    }
```
2. pinpoint\web\src\main\java\com\navercorp\pinpoint\web\vo\TransactionMetadataQuery.java

```java
    public void addQueryCondition(String transactionId, long collectorAcceptTime, int responseTime) {
        if (transactionId == null) {
            throw new NullPointerException("transactionId must not be null");
        }
        TransactionId traceId = TransactionIdUtils.parseTransactionId(transactionId);
        QueryCondition condition = new QueryCondition(traceId, collectorAcceptTime, responseTime);
        queryConditionList.add(condition);
    }
```
3. pinpoint\web\src\main\java\com\navercorp\pinpoint\web\service\ScatterChartServiceImpl.java

```java
    /**
     * Queries for details on dots selected from the scatter chart.
     */
    @Override
    public List<SpanBo> selectTransactionMetadata(final TransactionMetadataQuery query) {
        if (query == null) {
            throw new NullPointerException("query must not be null");
        }
        final List<TransactionId> transactionIdList = query.getTransactionIdList();
        final List<List<SpanBo>> selectedSpans = traceDao.selectSpans(transactionIdList);


        final List<SpanBo> result = new ArrayList<>(query.size());
        int index = 0;
        for (List<SpanBo> spans : selectedSpans) {
            if (spans.isEmpty()) {
                // span data does not exist in storage - skip
            } else if (spans.size() == 1) {
                // case with a single unique span data
                result.add(spans.get(0));
            } else {
                // for recursive calls, we need to identify which of the spans was selected.
                // pick only the spans with the same transactionId, collectorAcceptor, and responseTime
                for (SpanBo span : spans) {

                    // should find the filtering condition with the correct index
                    final TransactionMetadataQuery.QueryCondition filterQueryCondition = query.getQueryConditionByIndex(index);

                    final TransactionId transactionId = span.getTransactionId();
                    final TransactionMetadataQuery.QueryCondition queryConditionKey = new TransactionMetadataQuery.QueryCondition(transactionId, span.getCollectorAcceptTime(), span.getElapsed());
                    if (queryConditionKey.equals(filterQueryCondition)) {
                        result.add(span);
                    }
                }
            }
            index++;
        }

        return result;
    }
```

4. pinpoint\web\src\main\java\com\navercorp\pinpoint\web\dao\hbase\HbaseTraceDaoV2.java

```java
    List<List<SpanBo>> selectSpans(List<TransactionId> transactionIdList, int eachPartitionSize) {
        if (CollectionUtils.isEmpty(transactionIdList)) {
            return Collections.emptyList();
        }

        List<List<TransactionId>> splitTransactionIdList = partition(transactionIdList, eachPartitionSize);

        return partitionSelect(splitTransactionIdList, HBaseTables.TRACE_V2_CF_SPAN, spanFilter);
    }


    private List<List<SpanBo>> partitionSelect(List<List<TransactionId>> partitionTransactionIdList, byte[] columnFamily, Filter filter) {
        if (CollectionUtils.isEmpty(partitionTransactionIdList)) {
            return Collections.emptyList();
        }
        if (columnFamily == null) {
            throw new NullPointerException("columnFamily must not be null.");
        }

        List<List<SpanBo>> spanBoList = new ArrayList<>();
        for (List<TransactionId> transactionIdList : partitionTransactionIdList) {
            List<List<SpanBo>> partitionSpanList = select0(transactionIdList, columnFamily, filter);
            spanBoList.addAll(partitionSpanList);
        }
        return spanBoList;
    }

    private List<List<SpanBo>> select0(List<TransactionId> transactionIdList, byte[] columnFamily, Filter filter) {
        if (CollectionUtils.isEmpty(transactionIdList)) {
            return Collections.emptyList();
        }

        final List<Get> multiGet = new ArrayList<>(transactionIdList.size());
        for (TransactionId transactionId : transactionIdList) {
            final Get get = createGet(transactionId, columnFamily, filter);
            multiGet.add(get);
        }

        TableName traceTableName = tableNameProvider.getTableName(HBaseTables.TRACE_V2_STR);
        return template2.get(traceTableName, multiGet, spanMapperV2);
    }
```

## 6. HBASE


```sh
/opt/hbase/hbase-1.2.6/bin/hbase shell
scan 'TraceV2', {LIMIT=>5}
```


## 5. call tree - 显示的界面


web/src/main/webapp/features/distributedCallFlow/distributed-call-flow.directive.js
```js
var columns = [
    {id: "method", name: "Method", field: "method", width: 400, formatter: treeFormatter},
    {id: "argument", name: "Argument", field: "argument", width: 300, formatter: argumentFormatter},
    {id: "exec-time", name: "Start Time", field: "execTime", width: 90, formatter: execTimeFormatter},
    {id: "gap-ms", name: "Gap(ms)", field: "gapMs", width: 70, cssClass: "right-align"},
    {id: "time-ms", name: "Exec(ms)", field: "timeMs", width: 70, cssClass: "right-align"},
    {id: "time-per", name: "Exec(%)", field: "timePer", width: 100, formatter: progressBarFormatter},
    {id: "exec-milli", name: "Self(ms)", field: "execMilli", width: 75, cssClass: "right-align"},
    {id: "class", name: "Class", field: "class", width: 120},
    {id: "api-type", name: "API", field: "apiType", width: 90},
    {id: "agent", name: "Agent", field: "agent", width: 130},
    {id: "application-name", name: "Application", field: "applicationName", width: 150}
];
```

## 1. call tree - method

```html
<div class="dcf-popover" data-container=".grid-canvas" data-toggle="popover" data-trigger="manual" data-placement="right" data-content="invoke(Invocation invocation)">
    <div style="position:absolute;top:0;left:0;bottom:0;width:5px;background-color:#db8eac"></div>
    <span style="display:inline-block;height:1px;width:0px"></span>
    <span class="toggle collapse"></span>&nbsp;invoke(Invocation invocation)</div>
```

web/src/main/webapp/features/distributedCallFlow/distributed-call-flow.directive.js

```js
html.push('<div class="'+divClass+'" data-container=".grid-canvas" data-toggle="popover" data-trigger="manual" data-placement="right" data-content="'+ removeTag( value ) +'">');
html.push("<div style='position:absolute;top:0;left:0;bottom:0;width:5px;background-color:"+ leftBarColor +"'></div>");
html.push("<span style='display:inline-block;height:1px;width:" + (15 * dataContext["indent"]) + "px'></span>");

if (window.callStacks[idx + 1] && window.callStacks[idx + 1].indent > window.callStacks[idx].indent) {
    if (dataContext._collapsed) {
        html.push(" <span class='toggle expand'></span>&nbsp;");
    } else {
        html.push(" <span class='toggle collapse'></span>&nbsp;");
    }
} else {
    html.push(" <span class='toggle'></span>&nbsp;");
}
```


