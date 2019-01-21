

* [jenkins定时任务 - 潘掌柜 - 博客园 ](http://www.cnblogs.com/panpan0301/p/7738249.html)

# 一、定时构建位置
进入到job中，在【配置】页面，下拉到【构建触发器】，这里面有两个可选项，分别是“build periodically”和"poll SCM"
Build periodically
无论SVN中数据有无变化，均执行定时化的构建任务
Poll SCM
定时轮询SVN，查看SVN中是否有数据变化，如果有变化，则执行构建任务

# 二、构建语法
`* * * * *	(5个*)`
第一个*表示分钟，取值0~59
第二个*表示小时，取值0~23
第三个*表示一个月的第几天，取值1~31
第四个*表示第几月，取值1~12
第五个*表示一周中的第几天，取值0~7，其中0和7代表的都是周日
MINUTE HOUR DOM MONTH DOW
MINUTE Minutes within the hour (0–59)
HOUR The hour of the day (0–23)
DOM The day of the month (1–31)
MONTH The month (1–12)
DOW The day of the week (0–7) where 0 and 7 are Sunday.
jenkins帮助中为：
`* specifies all valid values【指定所有的有效值】`
M-N specifies a range of values【M-N指定了值的范围】
M-N/X or */X steps by intervals of X through the specified range or whole valid range A,B,...,Z enumerates multiple values
【M-N / X或* / X步骤间隔X通过指定范围或整个有效范围A，B，…，Z列举了多个值】

To allow periodically scheduled tasks to produce even load on the system, the symbol H (for “hash”) should be used wherever possible. For example, using 0 0 * * * for a dozen daily jobs will cause a large spike at midnight. In contrast, using H H * * * would still execute each job once a day, but not all at the same time, better using limited resources.
【允许定时任务在系统上处理甚至加载，符号“H”（hash）应该在任何地方都可以使用。举个例子，使用0 0 * * *给12个日常jobs将会在午夜造成一个巨大的高峰。相反的，`使用H H * * *仍然会每天一次的执行每一个job，但是并不在同一时间，更好的利用了有限的资源`】

The H symbol can be used with a range. For example, H H(0-7) * * * means some time between 12:00 AM (midnight) to 7:59 AM. You can also use step intervals with H, with or without ranges.
【符号H可以在一个内范围来使用。举个例子，H H(0-7) * * * 意味着在凌晨12点到上午7：59的一个时间.你也可以使用到H的有范围的或者没范围的步数间隔】

The H symbol can be thought of as a random value over a range, but it actually is a hash of the job name, not a random function, so that the value remains stable for any given project.
【符号H可以被认为是一个范围内的随机值，但是它是job名称的一个散列，不是一个随机的函数，所以这个值意味着任何一个给定项目的稳定】因此任何给定项目的值都是稳定的。

Beware that for the day of month field, short cycles such as */3 or H/3 will not work consistently near the end of most months, due to variable month lengths. For example, */3 will run on the 1st, 4th, …31st days of a long month, then again the next day of the next month. Hashes are always chosen in the 1-28 range, so H/3 will produce a gap between runs of between 3 and 6 days at the end of a month. (Longer cycles will also have inconsistent lengths but the effect may be relatively less noticeable.)
【要注意的是在月中的某一天，短周期像是as */3或者H/3在接近大多数月的月末将不会持续的工作，由于每个月长度的可变。举个例子，*/3会在1号、4号...31号每个长月运行，然后在下个月的第二天又会开始。哈希总是在1-28的范围内被选择，所以H / 3将会在一个月结束的3到6天之间产生一个缺口（长周期也会有不一致的长度，但效果可能相对较不明显）】

Empty lines and lines that start with # will be ignored as comments.
【空行和行用#开头将会被当作注释忽略】

In addition, @yearly, @annually, @monthly, @weekly, @daily, @midnight, and @hourly are supported as convenient aliases. These use the hash system for automatic balancing. For example, @hourly is the same as H * * * * and could mean at any time during the hour. @midnight actually means some time between 12:00 AM and 2:59 AM.
【另外，@每年，@每月，@ 每周，@ 每天，@半夜，@每小时都是方便的别名。这些使用hash系统进行自动平衡。例如，@每小时与H * * * *相同，在任何时候都可以表示。@午夜实际上是指在凌晨12点到凌晨2点59分之间的一段时间。】

Examples:
```sh
# every fifteen minutes (perhaps at :07, :22, :37, :52)
【每个15分钟】
H/15 * * * *
# every ten minutes in the first half of every hour (three times, perhaps at :04, :14, :24)
【在每个小时的前半个小时内的每10分钟】
H(0-29)/10 * * * *
# once every two hours at 45 minutes past the hour starting at 9:45 AM and finishing at 3:45 PM every weekday.
【每两小时45分钟，从上午9:45开始，每天下午3:45结束。】
45 9-16/2 * * 1-5
# once in every two hours slot between 9 AM and 5 PM every weekday (perhaps at 10:38 AM, 12:38 PM, 2:38 PM, 4:38 PM)
【每两小时一次，每个工作日上午9点到下午5点(也许是上午10:38，下午12:38，下午2:38，下午4:38)】
H H(9-16)/2 * * 1-5
# once a day on the 1st and 15th of every month except December
```

# 三、举个例子
每隔5分钟构建一次
H/5 * * * *

每两小时构建一次
H H/2 * * *

每天中午下班前定时构建一次
0 12 * * *

每天下午下班前定时构建一次
0 18 * * *