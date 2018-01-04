

alarm

curl 127.0.0.1:6081/history/precise64/cpu.idle

set GOPATH="E:\workspace\open-falcon\test\src"

@配置集成openbridge系统的用户管理

    "api": {
        "portal": "http://openbridge.f3322.net:88/monitor",
        "uic": "http://openbridge.f3322.net:88/monitor",
        "links": "http://link.example.com"
    }

https://demo.dev.yihecloud.com/monitor/api/action/45
https://demo.dev.yihecloud.com/monitor/team/users?name=MySQL%E5%91%8A%E8%AD%A6%E7%BB%84

"api": {
        "portal": "https://demo.dev.yihecloud.com/monitor",
        "uic": "https://demo.dev.yihecloud.com/monitor",
        "links": "http://link.example.com"
    }


curl -v https://demo.dev.yihecloud.com/monitor/api/action/45
curl -v https://demo.dev.yihecloud.com/monitor/team/users?name=%E8%BF%90%E7%BB%B4%E7%BB%84
运维组



@发送邮件sender配置



    "api": {
        "portal": "http://openbridge.f3322.net:88/monitor",
        "uic": "http://openbridge.f3322.net:88/monitor",
        "links": "http://link.example.com"
    }


192.168.31.61:8080/monitor/


"api": {
        "sms": "http://11.11.11.11:8000/sms",
        "mail": "https://demo.dev.yihecloud.com/monitor/email"
    }




配置使用fe组件默认设置

    "api": {
        "portal": "http://127.0.0.1:5050",
        "uic": "http://127.0.0.1:1234",
        "links": "http://link.example.com"
    }

设置匿名访问(免密码)


security.setAnonymousPaths("/portal/**;/docs/**;/auth/**;/metainfo/**;/common/**;/assets/**;" +
      "/login.jsp*;/index.jsp*;/logout.jsp*;/login*;/mlogin*;/html/**;/teams/users*");


如何配置策略表达式expression


快速入门 | Open-Falcon http://book.open-falcon.org/zh/usage/getting-started.html

如何配置策略表达式
策略表达式，即expression，具体可以参考HostGroup与Tags设计理念，这里只是举个例子：
 

上例中的配置传达出的意思是：falcon-judge这个模块的所有实例，如果qps连续3次大于1000，就报警给falcon这个报警组。
expression无需绑定到HostGroup，enjoy it


触发sendEvent事件

http://openbridge.f3322.net:88/monitor/team/users?name=343
http://openbridge.f3322.net:88/monitor/api/action/3


测试例子
lpush event:p0 "{\"id\":\"s_1_6666cd76f96956469e7be39d750cc7d9\",\"strategy\":{\"id\":7,\"metric\":\"cpu.busy\",\"tags\":{},\"func\":\"all(#3)\",\"operator\":\"\\u003e=\",\"rightValue\":90,\"maxStep\":3,\"priority\":0,\"note\":\"\",\"tpl\":{\"id\":7,\"name\":\"cpu.test\",\"parentId\":0,\"actionId\":3,\"creator\":\"liyang\"}},\"expression\":null,\"status\":\"PROBLEM\",\"endpoint\":\"192.168.1.55\",\"leftValue\":1,\"currentStep\":0,\"eventTime\":0,\"pushedTags\":null}"

json
{"id":"s_1_6666cd76f96956469e7be39d750cc7d9","strategy":{"id":1,"metric":"cpu.idle","tags":{},"func":"all(#3)","operator":"\u003e=","rightValue":90,"maxStep":3,"priority":0,"note":"","tpl":{"id":0,"name":"","parentId":0,"actionId":0,"creator":""}},"expression":null,"status":"","endpoint":"","leftValue":1,"currentStep":0,"eventTime":0,"pushedTags":null}

Alarm控制台
<Endpoint:192.168.1.55, Status:PROBLEM, Strategy:<Id:7, Metric:cpu.busy, Tags:map[], all(#3)>=1 MaxStep:3, P0, , <Id:7, Name:cpu.test, ParentId:0, ActionId:2, Creator:liyang>>, Expression:<nil>, LeftValue:2, CurrentStep:3, PushedTags:map[], TS:2016-08-09 09:07:00>

Expression sendEvent事件
lpush event:p5
lpush event:p6 \
"{\"id\":\"e_380_308b63d6122900e0de1a3feefdd5862a\",\"strategy\":null,\"expression\":{\"id\":380,\"metric\":\"container.cpu.usage.busy\",\"tags\":{\"deploy_id\":\"71keg5bgmro1geziwaixek449ugf6yh\"},\"func\":\"avg(#3)\",\"operator\":\"\\u003e=\",\"rightValue\":0.01,\"maxStep\":1,\"priority\":6,\"note\":\"\",\"actionId\":339},\"status\":\"PROBLEM\",\"endpoint\":\"192.168.0.187\",\"leftValue\":0.062295168564480606,\"currentStep\":1,\"eventTime\":1477469100,\"pushedTags\":{\"deploy_id\":\"71keg5bgmro1geziwaixek449ugf6yh\",\"id\":\"d9b8e247ac564d3fd2df175ca175031d22cab62eadb0d20e0dca9c0031d0416a\"}}"


触发strategies邮件队列/mail

5) "/mail"
127.0.0.1:6379> lrange /mail 0 -1
1) "{\"tos\":\"reymont@sina.cn,\",\"subject\":\"[P3][PROBLEM][192.168.1.55][][ all(#3) cpu.busy  1\\u003e=90][O0 1970-01-01 08:00:00]\",\"content\":\"PROBLEM\\r\\nP3\\r\\nEndpoint:192.168.1.55\\r\\nMetric:cpu.busy\\r\\nTags:\\r\\nall(#3): 1\\u003e=90\\r\\nNote:\\r\\nMax:3, Current:0\\r\\nTimestamp:1970-01-01 08:00:00\\r\\nhttp://127.0.0.1:5050/template/view/7\\r\\n\"}"

lpush /mail "{\"tos\":\"1432816213@qq.com\",\"subject\":\"[P3][PROBLEM][192.168.1.55][][ all(#3) cpu.busy  1\\u003e=90][O0 1971-01-01 08:00:00]\",\"content\":\"PROBLEM\\r\\nP3\\r\\nEndpoint:192.168.1.55\\r\\nMetric:cpu.busy\\r\\nTags:\\r\\nall(#3): 1\\u003e=90\\r\\nNote:\\r\\nMax:3, Current:0\\r\\nTimestamp:1971-01-01 08:00:00\\r\\nhttp://127.0.0.1:5050/template/view/7\\r\\n\"}"


lpush /mail "{\"tos\":\"mzhao@yihecloud.com\",\"subject\":\"[P5][PROBLEM][192.168.1.137][][ avg(#3) container.mem.usage.percent id=6cad56b474c7dd07189ea242738e292224c6af83acb24d1abdca6ba690a6c938 75.77769\\u003e=1][O1 2016-08-26 17:20:00]\",\"content\":\"PROBLEM\\r\\nP5\\r\\nEndpoint:192.168.1.137\\r\\nMetric:container.mem.usage.percent\\r\\nTags:id=6cad56b474c7dd07189ea242738e292224c6af83acb24d1abdca6ba690a6c938\\r\\navg(#3): 75.77769\\u003e=1\\r\\nNote:\\r\\nMax:3, Current:1\\r\\nTimestamp:2016-08-26 17:20:00\\r\\nhttp://openbridge.f3322.net:88/monitor/template/view/83\\r\\n\"}"


触发content json邮件队列/mail


expression

lpush /mail "{\"tos\":\"demo@xx.com\",\"subject\":\"[P6][OK] 2 container.cpu.usage.busy\",\"content\":\"{\\\"id\\\":\\\"e_380_19c98cc1e86d15cff42b6d052e9c2596\\\",\\\"strategy\\\":null,\\\"expression\\\":{\\\"id\\\":380,\\\"metric\\\":\\\"container.cpu.usage.busy\\\",\\\"tags\\\":{\\\"deploy_id\\\":\\\"71keg5bgmro1geziwaixek449ugf6yh\\\"},\\\"func\\\":\\\"avg(#3)\\\",\\\"operator\\\":\\\"\\\\u003e=\\\",\\\"rightValue\\\":0.01,\\\"maxStep\\\":1,\\\"priority\\\":6,\\\"note\\\":\\\"\\\",\\\"actionId\\\":339},\\\"status\\\":\\\"OK\\\",\\\"endpoint\\\":\\\"192.168.0.188\\\",\\\"leftValue\\\":0,\\\"currentStep\\\":1,\\\"eventTime\\\":1477459800,\\\"pushedTags\\\":{\\\"deploy_id\\\":\\\"71keg5bgmro1geziwaixek449ugf6yh\\\",\\\"id\\\":\\\"2b1f9d880bb7f13d57bf75832ec6f757faf4d4d804ec3523b34f797eed3ad71c\\\"}}\\r\\n{\\\"id\\\":\\\"e_380_9ccaa27cfea2836d74bd561509bf350c\\\",\\\"strategy\\\":null,\\\"expression\\\":{\\\"id\\\":380,\\\"metric\\\":\\\"container.cpu.usage.busy\\\",\\\"tags\\\":{\\\"deploy_id\\\":\\\"71keg5bgmro1geziwaixek449ugf6yh\\\"},\\\"func\\\":\\\"avg(#3)\\\",\\\"operator\\\":\\\"\\\\u003e=\\\",\\\"rightValue\\\":0.01,\\\"maxStep\\\":1,\\\"priority\\\":6,\\\"note\\\":\\\"\\\",\\\"actionId\\\":339},\\\"status\\\":\\\"OK\\\",\\\"endpoint\\\":\\\"192.168.0.182\\\",\\\"leftValue\\\":0,\\\"currentStep\\\":1,\\\"eventTime\\\":1477459860,\\\"pushedTags\\\":{\\\"deploy_id\\\":\\\"71keg5bgmro1geziwaixek449ugf6yh\\\",\\\"id\\\":\\\"1b4101a40492b979f539c320fb5061221f1ac7ddfa5deb4f9e87fdae89cc9349\\\"}}\"}"

strategy

"{\"tos\":\"cavan.wang@xx.com,dengteng@qq.com\",\"subject\":\"[P6][OK][192.168.0.187][][ avg(#3) cpu.busy  2.84338\\u003e=10][O1 2016-10-26 18:17:00]\",\"content\":\"{\\\"id\\\":\\\"s_3190_9b016f9c05fc0f5f6cc38973b7484ad1\\\",\\\"strategy\\\":{\\\"id\\\":3190,\\\"metric\\\":\\\"cpu.busy\\\",\\\"tags\\\":{},\\\"func\\\":\\\"avg(#3)\\\",\\\"operator\\\":\\\"\\\\u003e=\\\",\\\"rightValue\\\":10,\\\"maxStep\\\":3,\\\"priority\\\":6,\\\"note\\\":\\\"\\\",\\\"tpl\\\":{\\\"id\\\":83,\\\"name\\\":\\\"\xe9\x83\xa8\xe7\xbd\xb2\xe7\xad\x96\xe7\x95\xa5\\\",\\\"parentId\\\":0,\\\"actionId\\\":47,\\\"creator\\\":\\\"181f1ab4e4a6baac5f9158b265767ebc\\\"}},\\\"expression\\\":null,\\\"status\\\":\\\"OK\\\",\\\"endpoint\\\":\\\"192.168.0.187\\\",\\\"leftValue\\\":2.843383584589622,\\\"currentStep\\\":1,\\\"eventTime\\\":1477477020,\\\"pushedTags\\\":{}}\"}"

触发短信队列/sms

127.0.0.1:6379> lrange /sms 0 -1
1) "{\"tos\":\"\",\"content\":\"[P1][PROBLEM][192.168.1.138][][ all(#3) cpu.busy  7.46269\\u003e=2][O1 2016-08-09 17:21:00]\"}"
2) "{\"tos\":\"\",\"content\":\"[P1][PROBLEM][192.168.1.55][][ all(#3) cpu.busy  2.01005\\u003e=2][O3 2016-08-09 17:18:00]\"}"
3) "{\"tos\":\"\",\"content\":\"[P1][OK][192.168.1.138][][ all(#3) cpu.busy  1.50754\\u003e=2][O1 2016-08-09 17:17:00]\"}"



触发邮件发送mail-provider

curl -X POST http://127.0.0.1:4000/sender/mail -d "content=test&tos=reymont@sina.cn&subject=test"

#查看详情
curl -v -X POST http://192.168.31.220:8180/monitor/email -d "content=test&tos=reymont@sina.cn&subject=test"

curl -v -X POST http://192.168.31.61:8080/monitor/email -d "content=test&tos=reymont@sina.cn&subject=test"



配置tag触发容器报警

container.cpu.usage.busy/id=26eaad2834ff0f593c4b26d54c18f977482d69bc2e3a3077808db5a4fb460b17

id	metric	tags	max_step	priority	func	op	right_value
21	container.cpu.usage.busy	id=26eaad2834ff0f593c4b26d54c18f977482d69bc2e3a3077808db5a4fb460b17	3	0	all(#3)	>=	0


容器监控项

container.mem.memused.percent 已全部替换为container.mem.usage.percent

 

邮件例子

PROBLEM
P1
Endpoint:192.168.1.55
Metric:cpu.busy
Tags:
all(#3): 2.01005>=2
Note:
Max:3, Current:1
Timestamp:2016-08-09 18:02:00
http://127.0.0.1:5050/template/view/7

4) "{\"tos\":\"liuliu@liuliu.com,liuliu@qq.com,asd@163.com\",\"subject\":\"[P0][PROBLEM][192.168.1.55][][ all(#3) cpu.busy  4.52261\\u003e=2][O1 2016-08-19 14:06:00]\",\"content\":\"PROBLEM\\r\\nP0\\r\\nEndpoint:192.168.1.55\\r\\nMetric:cpu.busy\\r\\nTags:\\r\\nall(#3): 4.52261\\u003e=2\\r\\nNote:\\r\\nMax:3, Current:1\\r\\nTimestamp:2016-08-19 14:06:00\\r\\nhttp://openbridge.f3322.net:88/monitor/template/view/2\\r\\n\"}"
5) "{\"tos\":\"luoan12@qq.com\",\"subject\":\"[P1][OK][192.168.1.55][][ all(#3) cpu.busy  1.50754\\u003e=2][O1 2016-08-19 14:03:00]\",\"content\":\"OK\\r\\nP1\\r\\nEndpoint:192.168.1.55\\r\\nMetric:cpu.busy\\r\\nTags:\\r\\nall(#3): 1.50754\\u003e=2\\r\\nNote:\\r\\nMax:3, Current:1\\r\\nTimestamp:2016-08-19 14:03:00\\r\\nhttp://openbridge.f3322.net:88/monitor/template/view/7\\r\\n\"}"
6) "{\"tos\":\"asd@163.com,liuliu@liuliu.com,liuliu@qq.com\",\"subject\":\"[P0][OK][192.168.1.55][][ all(#3) cpu.busy  1.50754\\u003e=2][O1 2016-08-19 14:03:00]\",\"content\":\"OK\\r\\nP0\\r\\nEndpoint:192.168.1.55\\r\\nMetric:cpu.busy\\r\\nTags:\\r\\nall(#3): 1.50754\\u003e=2\\r\\nNote:\\r\\nMax:3, Current:1\\r\\nTimestamp:2016-08-19 14:03:00\\r\\nhttp://openbridge.f3322.net:88/monitor/template/view/2\\r\\n\"}"
7) "{\"tos\":\"luoan12@qq.com\",\"subject\":\"[P1][PROBLEM][192.168.1.55][][ all(#3) cpu.busy  2.48756\\u003e=2][O1 2016-08-19 14:02:00]\",\"content\":\"PROBLEM\\r\\nP1\\r\\nEndpoint:192.168.1.55\\r\\nMetric:cpu.busy\\r\\nTags:\\r\\nall(#3): 2.48756\\u003e=2\\r\\nNote:\\r\\nMax:3, Current:1\\r\\nTimestamp:2016-08-19 14:02:00\\r\\nhttp://openbridge.f3322.net:88/monitor/template/view/7\\r\\n\"}"


@标记清除状态


function batch_solve() {
    var boxes = $("input[type=checkbox]");
    var ids = []
    for (var i = 0; i < boxes.length; i++) {
        if (boxes[i].checked) {
            ids.push($(boxes[i]).attr("alarm"))
        }
    }

    $.post("/event/solve", {"ids": ids.join(',,')}, function(msg){
        if (msg=="") {
            location.reload();
        } else {
            alert(msg);
        }
    });
}

function solve(id) {
    $.post("/event/solve", {"ids": id}, function(msg){
        if (msg=="") {
            location.reload();
        } else {
            alert(msg);
        }
    });
}


@Go/eventdto.go 状态为OK的将会删除event
E:\workspace\yh\OpenBridge-passos-proxy\open-faclon\src\github.com\open-falcon\alarm\g\eventdto.go

func (this *SafeEvents) Put(event *model.Event) {
    if event.Status == "OK" {
        this.Delete(event.Id)
        return
    }


http\controller.go Index实现sort.Sort


E:\workspace\yh\OpenBridge-passos-proxy\open-faclon\src\alarm\http\controller.go

// 按照持续时间排序
    beforeOrder := make([]*g.EventDto, count)
    i := 0
    for _, event := range events {
        beforeOrder[i] = event
        i++
    }

    sort.Sort(g.OrderedEvents(beforeOrder))

按时间顺序排列

func (this OrderedEvents) Less(i, j int) bool {
    return this[i].Timestamp < this[j].Timestamp
}



main程序入口

    go http.Start()

    go cron.ReadHighEvent()
    go cron.ReadLowEvent()
    go cron.CombineSms()
    go cron.CombineMail()



api包portal.go

http://192.168.1.55:5050/api/action/1



api包uic.go



// return phones, emails
ParseTeams -> GetUsers -> UsersOf -> CurlUic

CurlUic获取用户信息
uri := fmt.Sprintf("%s/team/users", g.Config().Api.Uic)

http://192.168.1.55:1234/team/users?name=test




cron包reader.go

//调用消费队列
ReadHighEvent
consume(event, true)



cron包consumer.go

// 高优先级的不做报警合并
if isHigh {
    consumeHighEvents(event, action)
} else {
    consumeLowEvents(event, action)
}

调用api获取user
phones, mails := api.ParseTeams(action.Uic)


cron包reader.go

2016/08/08 17:43:17 reader.go:73: <Endpoint:192.168.1.138, Status:PROBLEM, Strategy:<Id:7, Metric:cpu.busy, Tags:map[], all(#3)>=1 MaxStep:3, P0, , <Id:7, Name:cpu.test, ParentId:0, ActionId:2, Creator:liyang>>, Expression:<nil>, LeftValue:5.02513, CurrentStep:1, PushedTags:map[], TS:2016-08-08 17:43:00>
2016/08/08 17:43:18 reader.go:72: ======>>>>
2016/08/08 17:43:18 reader.go:73: <Endpoint:192.168.1.55, Status:PROBLEM, Strategy:<Id:7, Metric:cpu.busy, Tags:map[], all(#3)>=1 MaxStep:3, P0, , <Id:7, Name:cpu.test, ParentId:0, ActionId:2, Creator:liyang>>, Expression:<nil>, LeftValue:3.53535, CurrentStep:1, PushedTags:map[], TS:2016-08-08 17:43:00>


cron\builder.go生成json邮件格式

E:\workspace\yh\OpenBridge-passos-proxy\open-faclon\src\
github.com\open-falcon\alarm\cron\builder.go

BuildCommonMailContent






