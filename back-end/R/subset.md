
* [Quick-R: Subsetting Data ](http://www.statmethods.net/management/subset.html)
* [R语言subset和merge函数的使用（笔记） - 飞天的日志 - 网易博客 ](http://blog.163.com/jiaqiang_wang/blog/static/11889615320158300180642/)


1、merge函数对数据框的操作，从两个数据框中选择出条件相等的行组合成一个新的数据框
```r
df1=data.frame(name=c("aa","bb","cc"),age=c(20,29,30),sex=c("f","m","f"))
df2=data.frame(name=c("dd","bb","cc"),age=c(40,35,36),sex=c("f","m","f"))
mergedf=merge(df1,df2,by="name")
```

2、subset函数，从某一个数据框中选择出符合某条件的数据或是相关的列
（1）单条件查询
```r
> selectresult=subset(df1,name=="aa")
> selectresult
  name age sex
1   aa  20   f
> df1
  name age sex
1   aa  20   f
2   bb  29   m
3   cc  30   f
```

（2）指定显示列
```r
> selectresult=subset(df1,name=="aa",select=c(age,sex))
> selectresult
  age sex
1  20   f
```

（3）多条件查询
```r
> selectresult=subset(df1,name=="aa" & sex=="f",select=c(age,sex))
> selectresult
  age sex
1  20   f
> df1
  name age sex
1   aa  20   f
2   bb  29   m
3   cc  30   f
```

```r
> x<-c(6,1,2,3,NA,12)
> x[x>5]    #x[5]是未知的，因此其值是否大于5也是未知的
[1]  6 NA 12
> subset(x,x>5)  #subset直接会把NA移除
[1]  6 12
> subset(airquality, Temp > 80, select = c(Ozone, Temp))
    Ozone Temp
29     45   81
35     NA   84
36     NA   85
38     29   82
39     NA   87
40     71   90
...

> subset(airquality, Day == 1, select = -Temp)
    Ozone Solar.R Wind Month Day
1      41     190  7.4     5   1
32     NA     286  8.6     6   1
62    135     269  4.1     7   1
93     39      83  6.9     8   1
124    96     167  6.9     9   1
...

> subset(airquality, select = Ozone:Wind)
    Ozone Solar.R Wind
1      41     190  7.4
2      36     118  8.0
3      12     149 12.6
4      18     313 11.5
5      NA      NA 14.3
```