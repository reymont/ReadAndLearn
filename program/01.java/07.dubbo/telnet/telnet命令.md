分布式系列 - dubbo服务telnet命令 - 秦鹏飞 - 博客园 https://www.cnblogs.com/feiqihang/p/4387330.html

分布式系列 - dubbo服务telnet命令
dubbo服务发布之后，我们可以利用telnet命令进行调试、管理。
Dubbo2.0.5以上版本服务提供端口支持telnet命令，下面我以通过实例抛砖引玉一下：
1.连接服务
    测试对应IP和端口下的dubbo服务是否连通，cmd命令如下

telnet localhost 20880

    正常情况下，进入telnet窗口，键入回车进入dubbo命令模式。

    

2.查看服务列表
查看服务
dubbo>ls

com.test.DemoService


查看服务中的接口
dubbo>ls com.test.DemoService

queryDemoPageList

insertDemolist

uploadDemoList

deleteDemolist

ls
(list services and methods)

ls

显示服务列表。

ls -l

显示服务详细信息列表。

ls XxxService

显示服务的方法列表。

ls -l XxxService

显示服务的方法详细信息列表。



3.调用服务接口
调用接口时，以JSON格式传入参数（这点很方便 :-D），然后打印返回值和所用时间。
dubbo>invoke com.test.DemoService.queryDemoPageList({"id":"100"}, 1, 2)

{"totalCount":1,"data":[{date":"2011-03-23 14:10:32","name":"张三","keyword":null}]}

elapsed: 10 ms.

invoke
invoke XxxService.xxxMethod({"prop": "value"})

调用服务的方法。

invoke xxxMethod({"prop": "value"})

调用服务的方法(自动查找包含此方法的服务)。


4.查看服务状态
查看服务调用次数，不过比较奇怪的是，我刚才已经调用过一次queryDemoPageList了，而这里显示的为0（貌似不太准，有待进一步了解）
dubbo>count  com.test.DemoService

dubbo>

+-------------------------+-------+--------+--------+---------+-----+

| method                  | total | failed | active | average | max |

+-------------------------+-------+--------+--------+---------+-----+

| queryDemoPageList | 0     | 0      | 0      | 0ms     | 0ms |

| insertDemolist    | 0     | 0      | 0      | 0ms     | 0ms |

| uploadDemoList    | 0     | 0      | 0      | 0ms     | 0ms |

| deleteDemolist    | 0     | 0      | 0      | 0ms     | 0ms |

+-------------------------+-------+--------+--------+---------+-----+

count
count XxxService

统计1次服务任意方法的调用情况。

count XxxService 10

统计10次服务任意方法的调用情况。

count XxxService xxxMethod

统计1次服务方法的调用情况。

count XxxService xxxMethod 10

统计10次服务方法的调用情况。

status
status

显示汇总状态，该状态将汇总所有资源的状态，当全部OK时则显示OK，只要有一个ERROR则显示ERROR，只要有一个WARN则显示WARN。

status -l

显示状态列表。



参考资料：
Telnet命令参考手册：http://alibaba.github.io/dubbo-doc-static/Telnet+Command+Reference-zh-showComments=true&showCommentArea=true.htm