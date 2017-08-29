

# R(6): 数据处理包dplyr

* [R(6): 数据处理包dplyr - 天戈朱 - 博客园 ](http://www.cnblogs.com/tgzhu/p/6769410.html)

 dplyr包是Hadley Wickham的新作，主要用于数据清洗和整理，该包专注dataframe数据格式，从而大幅提高了数据处理速度，并且提供了与其它数据库的接口，本节学习dplyr包函数基本用法。dplyr()可使用%>%（链式操作），其功能是用于实现将一个函数的输出传递给下一个函数的第一个参数。注意，传递给下一个函数的第一个参数，那么下一个函数的第一个参数就不用写。

# 目录：

筛选: filter()
排列: arrange()
选择: select()
变形: mutate()
汇总: summarise()
分组: group_by()
数据关连
bind
## 筛选: filter()

 dplyr包安装及载入，使用datasets包中的mtcars数据集做演示，首先将过长的数据整理成友好的tbl_df数据：
install.packages("dplyr")
library(dplyr)
mtcars_df = tbl_df(mtcars)
按给定的逻辑判断筛选出符合要求的子数据集
注意：只能将指定条件的观测筛选出来，为了弥补这个缺陷，可以使用select()函数筛选指定的变量，而且比subset()函数更灵活，而且选择变量的同时也可以重新命名变量。如果剔除某些变量的话，只需在变量前加上负号“-”。之所以说他比subset()函数灵活，是因为可以在select()函数传递如下参数：
starts_with(x, ignor.case = TRUE)#选择以字符x开头的变量
ends_with(x, ignor.case = TRUE)#选择以字符x结尾的变量
contains(x, ignor.case = TRUE)#选择所有包含x的变量
matches(x, ignor.case = TRUE)#选择匹配正则表达式的变量
num_range('x', 1:5, width = 2)#选择x01到x05的变量
one_of('x','y','z')#选择包含在声明变量中的
everything()#选择所有变量，一般调整数据集中变量顺序时使用
```r
> filter(mtcars_df, hp<110 & vs == 1)
# A tibble: 10 × 11
     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
1   22.8     4 108.0    93  3.85 2.320 18.61     1     1     4     1
2   18.1     6 225.0   105  2.76 3.460 20.22     1     0     3     1
3   24.4     4 146.7    62  3.69 3.190 20.00     1     0     4     2
4   22.8     4 140.8    95  3.92 3.150 22.90     1     0     4     2
```
## 排列: arrange()

按给定的列名依次对行进行排序：
```r
> a <- head(mtcars_df,2)
> a
# A tibble: 2 × 11
    mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
1    21     6   160   110   3.9 2.620 16.46     0     1     4     4
2    21     6   160   110   3.9 2.875 17.02     0     1     4     4
> arrange(a,desc(wt,qsec))
# A tibble: 2 × 11
    mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
1    21     6   160   110   3.9 2.875 17.02     0     1     4     4
2    21     6   160   110   3.9 2.620 16.46     0     1     4     4
> arrange(a,wt,qsec)
# A tibble: 2 × 11
    mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
1    21     6   160   110   3.9 2.620 16.46     0     1     4     4
2    21     6   160   110   3.9 2.875 17.02     0     1     4     4
```
## 选择: select()

用列名作参数来选择子数据集:

```r
> mtcars_df %>% select(mpg,wt,qsec)
# A tibble: 32 × 3
     mpg    wt  qsec
*  <dbl> <dbl> <dbl>
1   21.0 2.620 16.46
2   21.0 2.875 17.02
```

## 变形: mutate()

对已有列进行数据运算并添加为新列:
```r
> mutate(mtcars_df, NO = 1:dim(mtcars_df)[1])
# A tibble: 32 × 12
     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb    NO
   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <int>
1   21.0     6 160.0   110  3.90 2.620 16.46     0     1     4     4     1
2   21.0     6 160.0   110  3.90 2.875 17.02     0     1     4     4     2
3   22.8     4 108.0    93  3.85 2.320 18.61     1     1     4     1     3
4   21.4     6 258.0   110  3.08 3.215 19.44     1     0     3     1     4
5   18.7     8 360.0   175  3.15 3.440 17.02     0     0     3     2     5
6   18.1     6 225.0   105  2.76 3.460 20.22     1     0     3     1     6
```
## 汇总: summarise()

对数据框调用其它函数进行汇总操作, 返回一维的结果:
```r
> summarise(mtcars, mean(disp))
  mean(disp)
1   230.7219
> summarise(group_by(mtcars, cyl), mean(disp))
# A tibble: 3 × 2
    cyl `mean(disp)`
  <dbl>        <dbl>
1     4     105.1364
2     6     183.3143
3     8     353.1000
```
可以用来聚合的函数有：  
min()：返回最小值
max()：返回最大值
mean()：返回均值
sum()：返回总和
sd()：返回标准差
median()：返回中位数
IQR()：返回四分位极差
n()：返回观测个数
n_distinct()：返回不同的观测个数
first()：返回第一个观测
last()：返回最后一个观测
nth()：返回n个观测
# 分组: group_by()

当对数据集通过group_by()添加了分组信息后，mutate()，arrange() 和 summarise() 函数会自动对这些 tbl 类数据执行分组操作。
```r
> cars <- group_by(mtcars_df, cyl)
> summarise(cars, count = n()) # count = n()用来计算次数
# A tibble: 3 × 2
    cyl count
  <dbl> <int>
1     4    11
2     6     7
3     8    14
```
## 数据关连

数据库中经常需要将多个表进行连接操作，如左连接、右连接、内连接等，这里dplyr包也提供了数据集的连接操作，具体如下
left_join(a, b, by="x1")
right_join(a, b, by="x1")
inner_join(a, b, by="x1")
outer_join(a, b, by="x1")
semi_join(a, b, by="x1") # 数据集a中能与数据集b匹配的记录
anti_join(a, b, by="x1") # 数据集a中雨数据集b不匹配的记录
intersect(x, y): x 和 y 的交集（按行）
union(x, y): x 和 y 的并集（按行）
setdiff(x, y): x 和 y 的补集 （在x中不在y中）

## bind

在R基础包里有cbind()函数和rbind()函数实现按列的方向进行数据合并和按行的方向进行数据合并，而在dplyr包中也添加了类似功能的函数，它们是bind_cols()函数和bind_rows()函数
bind_rows()函数需要两个数据框或tbl对象有相同的列数，而bind_cols()函数则需要两个数据框或tbl对象有相同的行数。
mydf1 <- data.frame(x = c(1,2,3,4), y = c(10,20,30,40))
mydf2 <- data.frame(x = c(5,6), y = c(50,60))
mydf3 <- data.frame(z = c(100,200,300,400))
bind_rows(mydf1, mydf2)
bind_cols(mydf1, mydf3)