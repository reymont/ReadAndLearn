[elk]基于elk的业务日志格式设计 - CSDN博客 https://blog.csdn.net/df007df/article/details/54781305

背景

php项目，业务监控为0，需要搭建一套日志查看，阀值告警等功能的监控系统。撒都不用说，直接上ELK。

我们跳过搭建过程（网上太多了）。 
通过docker搭建好了elk那一套（明显单机版），我要监控测试和线上，所以是个多采集的环境，使用了官方推荐的最新的filebeat就行log聚合，格式化还是在master用logstash。

需求

业务需求并不是很多，因为是在初期，等团队使用熟练后，业务日志会接入更多（项目决定）。

现在能想到的需求：

php运行错误和异常
api和页面执行性能
mysql慢查
本人已尽对项目代码进行改造，运行时发生的所有异常和error都会通过json格式写入在本地日志目录中，关键就看怎么定义格式了满足上面的一些需求了

思路

直接讲结果吧：

php运行错误和异常 
异常信息，时间，具体内容
错误信息，时间，具体内容
api和页面执行性能 
访问的api地址，执行时间等
访问的page地址，执行时间等
mysql慢查 
当前执行慢的sql, 参数（去除敏感信息）
从上面大致需要的监控需求来说，会发现很多共同点或者说是共有信息字段，比如：访问的模块，访问的路由，访问的用户，访问的哪种类型，子类型等

考虑下上面的这些问题，大体上我们就能设计出满足这些需求的通用日志格式了：

格式说明：

字段	类型	es not_analyzed	备注
sid	string	ture	uuid
time	data	ture	log生成时间
level	string	ture	log等级
msg	string	ture	信息简要
app	string	ture	项目名称
group	string	ture	日志一级分类
object	string	ture	日志二级分类
host	string	ture	host
client	string	ture	client
status	number	ture	状态码
elapsed	number	ture	执行毫秒
error	string	ture	错误的完整信息
url	string	ture	
route	string	ture	
例子：

php错误

group: php_error 
msg: 错误标题 
error:错误完整的内容，大家可自行定义

php异常

group: exception 
msg: 异常标题 
error:异常完整的内容，大家可自行定义

api,page 访问性能

group: api 
elapsed: 100.123 （毫秒） 
url: 具体url 
route: 路由(聚合分类用)

mysql慢查询

group: data 
object: slow_query 
url: 具体url 
error: 慢差的完整信息，包括sql,params等

格式意见定义好了，满足了之前的设计需求。 
具体如何通过定义好的格式去在kibana上进行可视化，熟悉的朋友应该能有个思路了，具体就不在这展开了。

最后

日记接入成功后，接下来只要封装好调用的方法即可。 
后面项目上还需要接入

队列日志
异步事务日志
具体实现思路敬请期待后面的文章。