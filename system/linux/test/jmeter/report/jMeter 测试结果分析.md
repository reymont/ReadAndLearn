jMeter 测试结果分析 - JonnyWei的专栏 - CSDN博客 http://blog.csdn.net/xiaojianpitt/article/details/4821554

当我们拿到了jmeter测试结果之后，我们应该如何去看待它们呢？它们又是怎么来的呢？
一、Listener的使用
用过LoadRunner的人应该都知道，LoadRunner会为我们提供一大堆图标和曲线。但是在Jmeter里，我们只能找到几个可怜的Listener来方便我们查看测试结果。但是，对于初学者来说，一些简单的结果分析工具可以使我们更容易理解性能测试结果的分析原理。所以，千万别小看这几个简单的Listener啊。
A.Aggregate Report 聚合报告
clip_image002
我们可以看到，通过这份报告我们就可以得到通常意义上性能测试所最关心的几个结果了。
Samples -- 本次场景中一共完成了多少个Transaction
Average -- 平均响应时间
Median -- 统计意义上面的响应时间的中值
90% Line -- 所有transaction中90%的transaction的响应时间都小于xx
Min -- 最小响应时间
Max -- 最大响应时间
PS: 以上时间的单位均为ms
Error -- 出错率
Troughput -- 吞吐量，单位：transaction/sec
KB/sec -- 以流量做衡量的吞吐量
B.View Results Tree 以树状列表查看结果
clip_image003
通过这个Listener，我们可以看到很详细的每个transaction它所返回的结果，其中红色是指出错的transaction，绿色则为通过的。
如果你测试的场景会有很多的transaction完成，建议在这个Listener中仅记录出错的transaction就可以了。要做到这样，你只需要将Log/Display:中的Errors勾中就可以了。
二、.jtl文件的分析
在性能测试过程中，我们往往需要将测试结果保存在一个文件当中，这样既可以保存测试结果，也可以为日后的性能测试报告提供更多的素材。
Jmeter中，结果都存放在.jtl文件。这个.jtl文件可以提供多种格式的编写，而一般我们都是将其以csv文件格式记录，这样做是因为csv文件格式看起来比较方便，更重要的是这样做可以为二次分析提供很多便利。
我这里所说的二次分析是指除了使用Listener之外，我们还可以对.jtl文件进行再次分析。
a.设置jtl文件格式
我们从jmeter官方网站中下载下来的Jmeter解压后是可以直接使用的。但是，使用默认配置生成的jtl文件内容并不能满足我们的需要。于是我们必须进行必要的设置。在2.2版本中，如果要修改jtl设置必须要到jmeter.properties文件中设置；但是在2.3版本中，我们只需要在界面上设置就可以了。你只需要选择某个Listener，点击页面中的configure按钮。此时，一个设置界面就会弹出来，建议多勾选如下项：Save Field Name，Save Assertion Failure Message。
b.jtl文件中的各项
经过了以上设置，此时保存下来的jtl文件会有如下项：
timeStamp,elapsed,label,responseCode,responseMessage,threadName,dataType,success,failureMessage,bytes,Latency
请求发出的绝对时间，响应时间，请求的标签，返回码，返回消息，请求所属的线程，数据类型，是否成功，失败信息，字节，响应时间
其中聚合报告中的，吞吐量=完成的transaction数/完成这些transaction数所需要的时间；平均响应时间=所有响应时间的总和/完成的transaction数；失败率=失败的个数/transaction数
温馨提示：在jmeter2.2和2.3版本中，都存在的一个问题是当我们重新打开jmeter，使用某个Listener来查看jtl文件时，jmeter是会报错的。因此当你使用命令行方式完成了一个场景的测试后，你得到的只是一堆保存在jtl文件中的原始数据。所以知道聚合报告中的各项的来源是可以方便大家摆脱测试工具来进行结果的分析。
总的来说，对于jmeter的结果分析，主要就是对jtl文件中原始数据的整理，我是使用一些小脚本进行相关的分析的，不知道你打算怎么做呢？
反正实践后，你总能找到一条属于自己的数据分析之路。
测试结果的分析说明
说明：
Label：每个 JMeter 的 element （例如 HTTP Request ）都有一个 Name 属性，这里显示的就是 Name 属性的值
#Samples：表示你这次测试中一共发出了多少个请求，我的测试计划模拟 10 个用户，每个用户迭代 10 次，因此这里显示 100
Average：平均响应时间 —— 默认情况下是单个 Request 的平均响应时间，当使用了 Transaction Controller 时，也可以以 Transaction 为单位显示平均响应时间
Median：中位数，也就是 50 ％用户的响应时间
90% Line： 90 ％用户的响应时间
Min： 最小响应时间
Max： 最大响应时间
Error%：本次测试中出现错误的请求的数量 / 请求的总数
[NextPage]
Throughput：吞吐量 —— 默认情况下表示每秒完成的请求数（ Request per Second ），当使用了 Transaction Controller 时，也可以表示类似 LoadRunner 的 Transaction per Second 数
KB/Sec：每秒从服务器端接收到的数据量，相当于 LoadRunner 中的 Throughput/Sec
我分别模拟10、25、50、75和100个用户并发访问该页面，根据报告所得测试结果作出如下统计。注：时间单位是ms
clip_image004
用户数 #Samples Average Median 90%Line Min Max Error% Throughput KB/Sec
10 642 672 688 125 125 719 00.0 14.8/sec 221.15
25 250 1620 1687 1750 250 1781 00.0 14.5/sec 217.14
50 500 3319 3438 3578 281 3657 00.0 14.2/sec 212.02
75 750 4887 5109 5584 328 7094 00.0 14.5/sec 216.67
100 1000 6244 6485 6672 250 6844 00.0 15.1/sec 225.43
一般情况下，当用户能够在2秒以内得到响应时，会感觉系统的响应很快；当用户在2-5秒之间得到响应时，会感觉系统的响应速度还可以；当用户在5-10秒以内得到响应时，会感觉系统的响应速度很慢，但是还可以接受；而当用户在超过10秒后仍然无法得到响应时，会感觉系统糟透了，或者认为系统已经失去响应，而选择离开这个Web站点，或者发起第二次请求。故该系统的用户信息查询信息页面的在10到25人并发访问时，系统响应速度很快，25人到50人并发访问时速度还可以，50人到100人并发访问就比较慢了。