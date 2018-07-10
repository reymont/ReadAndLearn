MySQL DATE_SUB() 函数 http://www.w3school.com.cn/sql/func_date_sub.asp

定义和用法
DATE_SUB() 函数从日期减去指定的时间间隔。
语法
DATE_SUB(date,INTERVAL expr type)
date 参数是合法的日期表达式。expr 参数是您希望添加的时间间隔。
type 参数可以是下列值：
Type 值
MICROSECOND
SECOND
MINUTE
HOUR
DAY
WEEK
MONTH
QUARTER
YEAR
SECOND_MICROSECOND
MINUTE_MICROSECOND
MINUTE_SECOND
HOUR_MICROSECOND
HOUR_SECOND
HOUR_MINUTE
DAY_MICROSECOND
DAY_SECOND
DAY_MINUTE
DAY_HOUR
YEAR_MONTH
实例
假设我们有如下的表：
OrderId	ProductName	OrderDate
1	'Computer'	2008-12-29 16:25:46.635
现在，我们希望从 "OrderDate" 减去 2 天。
我们使用下面的 SELECT 语句：
SELECT OrderId,DATE_SUB(OrderDate,INTERVAL 2 DAY) AS OrderPayDate
FROM Orders
结果：
OrderId	OrderPayDate
1	2008-12-27 16:25:46.635