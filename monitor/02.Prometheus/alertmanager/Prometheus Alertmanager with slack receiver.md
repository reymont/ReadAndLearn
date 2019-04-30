Prometheus Alertmanager with slack receiver 
http://www.songjiayang.com/technical/prometheus-alert-slack-receiver/


在过去一篇文章 Prometheus With Alertmanager 中， 已介绍了 prometheus 的告警模块，Alertmanager 用法；今天我们将一起学习，使用 slack 接收告警通知，让咱们的运维看上去高大上，我们想做：
1.	使用 slack 接受消息。
2.	消息能够带有 url， 自动跳转到 prometheus 对应 graph 查询页面。
3.	能自定义颜色。
4.	能够 @ 某人
________________________________________
假设你已注册了 slack 账号，并创建了一个 #test 频道。
一. 为 #test 频道创建一个 incomming webhooks 应用
1.	点击频道标题，选择 Add an app or integration
 2. 然后在 app store 中搜索 incomming webhooks，选择第一个
 创建成功以后，拷贝 app webhook 地址，以被后面使用。
二. 修改 prometheus rules，添加一些字段
ALERT InstanceStatus
 IF up {job="node"}== 0
 FOR 10s
 LABELS {
   instance = "",
 }
 ANNOTATIONS {
   summary = "服务器运行状态",
   description = "服务器  已当机超过 20s",
   link = "http://localhost:9090/graph#%5B%7B%22range_input%22%3A%221h%22%2C%22expr%22%3A%22up%7Bjob%3D%5C%22node%5C%22%7D%20%3D%3D%200%22%2C%22tab%22%3A1%7D%5D",
   color = "#ff0000",
   username = "@sjy"
 }
这里，我在 rule 的 ANNOTATIONS 中，添加了 link, color, username 三个字段， 它们分别表示消息外链地址，消息颜色和需要 @ 的人。
三. 修改 Alertmanager 配置
这里我们将使用到 slack_configs，配置大致为：
 说下配置大致意思： 
1. 按 alertname 分组。 
2. 相同组，如果事件没有恢复，每隔 10s 发送一次（主要为了测试）。 
3. slack_configs 配置中，使用了 template 语句，通过 CommonAnnotations 查找字段。 
4. 插入外链不仅可以使用 title_link, 还可以使用 slack link 标记语法 <htttpxxxxxx| Click here>。
更多 slack 配置，请参考 incoming-webhooks。
经过以上配置，我们收到的消息是这样：
 
消息一条一条的，瞬间清晰很多。有了那几个自定义字段，稍作扩展，你将想到一些有趣的事情，比如自动分配任务，标记不同警报级别。
最后点击 title 或者 Click here， 即可跳转到 Prometheus graph 页面：
 
真的太方便了，有没有，再也不用担心多个 Prometheus 节点，切换查询的烦恼了。
________________________________________
不得不说，slack 还是非常好用的。经过我测试下来，无论网站，桌面客户端，APP，都没有被墙，消息到达及时，只是网页版，启动较慢。要知道，slack 在 IM 工具里，算很靠谱的了，你不用担心突然关掉之类，我个人比较推荐使用它。
当然如果你还是觉得慢，那么再推荐下零信，号称国内 slack, 他们文档上说是兼容 slack 的。
