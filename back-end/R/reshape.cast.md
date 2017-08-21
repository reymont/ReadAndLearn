


# R语言数据可视化之数据塑形技术

* [第一篇：R语言数据可视化概述(基于ggplot2) - 穆晨 - 博客园 ](http://www.cnblogs.com/muchen/p/5279727.html)
* [第二篇：R语言数据可视化之数据塑形技术 - 穆晨 - 博客园 ](http://www.cnblogs.com/muchen/p/5332359.html)
* [第三篇：R语言数据可视化之条形图 - 穆晨 - 博客园 ](http://www.cnblogs.com/muchen/p/5336466.html)
* [第四篇：R语言数据可视化之折线图、堆积图、堆积面积图 - 穆晨 - 博客园 ](http://www.cnblogs.com/muchen/p/5386296.html)
* [第五篇：R语言数据可视化之散点图 - 穆晨 - 博客园 ](http://www.cnblogs.com/muchen/p/5412278.html)
* [第六篇：R语言数据可视化之数据分布图（直方图、密度曲线、箱线图、等高线、2D密度图） - 穆晨 - 博客园 ](http://www.cnblogs.com/muchen/p/5430536.html)

第二篇：R语言数据可视化之数据塑形技术
阅读目录

* 前言
* 数据框塑型
* 因子水平塑型
* 变量塑型
* 长/宽数据塑型
* 小结

# 前言

绘制统计图形时，半数以上的时间会花在调用绘图命令之前的数据塑型操作上。因为在把数据送进绘图函数前，还得将数据框转换为适当格式才行。       

本文将给出使用R语言进行数据塑型的一些基本的技巧，更多技术细节推荐参考《R语言核心手册》。

# 数据框塑型

1. 创建数据框 - data.frame()
```r
# 创建向量p
p = c("A", "B", "C")
# 创建向量q
q = 1:3
# 创建数据框：含p/q两列
dat = data.frame(p, q)
# 2. 查看数据框信息 - str()
# 展示数据集dat信息
str(dat)
# 3. 向数据框添加列
# 基本格式为：数据框$新列名 = 向量名。如下代码将在dat数据集中创建名为newcol的列，并将向量v赋值给它：
dat$newcol = v
# 如果向量长度小于数据框的行数，R会重复这个向量，直到所有行被填充。
#  4. 从数据框中删除列
# 可以将NULL赋值给某列即可。如下代码将删除数据集中的badcol列：
# dat$badcol = NULL
# 也可以使用subset函数(后面会具体讲)，并将一个减号至于待删除的列前：
dat = subset(data, select = -badcol)
# 5. 重命名数据框中的列名
# 可以将列名称向量赋值给names函数：
names(dat) = c("name1", "name2", "name3")
#  如果想通过列名重命名某一列可以这样：
# 将名为ctrl的列更名为Cntrol
names(anthoming)[names(anthoming) == "ctrl"] = c("Cntrol")
# 6. 重排序数据框的列
# 可以通过数值位置重排序：
# 通过列的数值位置重排序
dat = dat[c(1,3,2)]
也可以通过列的名称重排序：
# 通过列的名称重排序
dat = dat[c("col1", "col3", "col2")]
# 7. 从数据框提取子集 - subset()
# 如下R语言代码从climate数据框中，选定Source属性为"Berkeley"的记录的"Year"、"Anomaly10y"两列：
# subset函数：首参选定数据集, Source参数选定行，select参选定列
subset(climate, Source == "Berkeley", select = c(Year, Anomaly10y))
```
# 因子水平塑型
```r
# 1. 根据数据的值改变因子水平顺序 - reorder()
# 下面这个例子将根据count列对spray列中的因子水平进行重排序，汇总数据为mean：
# reorder函数：首参选定因子向量，次参选定排序依据的数据向量，FUN参数选定汇总函数
iss$spray = reorder(iss$spray, iss$count, FUN = mean)
#2. 改变因子水平的名称 - revalue() / mapvalues() in plyr包
#如下两行R语言代码均可将水平因子f中名为"small"，"medium"，"large"的因子分别更名为"S"，"M", "L"：
# 方法一
f = revalue(f, c(small = "S", medium = "M", large = "L"))
# 方法二
f = mapvalues(f, c("small", "medium", "large"), c("S", "M", "L"))
#3. 去掉因子中不再使用的水平 - droplevels()
#如下R语言代码将剔除掉因子f中多余的水平：
droplevels(f)
```
# 变量塑型
```r
# 1. 变量替换 - match()
#要将某些值替换为其他特定值，可使用match函数。如下R语言代码将数据框pg的group列的oldvals中的"ctr1"，"trt1"，"trt2"的值分别替换为"No"，"Yes"，"Yes"：
# 旧值
oldvals = c("ctrl1", "trt1", "trt2")
# 新值
newvals = factor(c("No", "Yes", "Yes"))
# 替换
pg$treatment = newvals[match(pg$group, oldvals)]
#2. 分组转换数据 - ddply() in plyr包
#通过使用ddply()函数的transform参数功能，能够对不同分组内的数据进行转换。如下R语代码能够将cabbages数据框按照Cult列因子进行分组，并在数据框中创建一个新的名为DevWt的列，该新列值由原某列值减分组均值得到：
# ddply函数：首参选定数据框，次参选定分组变量，叁参选定处理方式，肆参输出新列
cb = ddply(cabbages, "Cult", transform, DevWt = HeadWt - mean(HeadWt))
# 3. 分组汇总数据 - ddply() in plyr包
#通过使用ddply()函数的transform参数功能，能够对不同分组内的数据进行汇总。汇总和上面介绍的转换的区别在于汇总结果的记录数等于分组的个数，而转换操作后记录数是不变的，只是对原列进行改动转换。如下R语言代码将cabbages数据框按照Cult和Date列因子进行分组，并在数据框中创建一个新的名为DevWt的列，该新列值由对每个分组进行均值统计得到：
# ddply函数：首参选定数据框，次参选定分组变量，叁参选定处理方式，肆参输出新列
cb = ddply(cabbages, c("Cult", "date"), summarise, Weight = mean(HeadWt))
```


# 长/宽数据塑型

```r
# 1. 宽数据 -> 长数据 - melt() in reshape2包
#anthoming数据集如下所示：
#其中expt和ctrl两列可以合并为一列。合并后的数据框相对合并前的叫长数据，而合并前的数据框相对合并后的数据叫宽数据，是不是很贴切呢？
#如下R语言代码使用melt函数将上述数据集"拉长"：
# melt函数：首参选定数据框，次参选定记录标识列，variable.name选定拉长后的属性名列，value.name选定拉长后的属性值列
melt(anthoming, id.vars = "angle", variable.name = "condition", value.name = "count")
#2. 长数据 -> 宽数据 - dcast() in reshape2包
#plum数据集如下所示：
#该数据框中length列和time列作为标识列， 如下R语言代码可将该数据框压扁：
# dcast函数：首参选定数据框，次参选定记录标识列和新的属性名列，value.var选定被拉长的属性值列
dcast(plum, length + time ~ survival, value.var = "count")
```

# 小结

在调用任何图像绘制函数之前，都要`按照绘图函数的要求摆放好数据`，这个过程也被称为`数据塑型`。本文的部分功能可能读者会疑惑有啥用，别着急，先进入到有趣的绘制章节部分吧。随着绘图次数增多，慢慢就会懂了。

分类: 【08】数据可视化_R语言实践
标签: 数据可视化, R语言, ggplot2, ggplot, 数据塑型



* [R语言进阶之4：数据整形（reshape） - 51CTO.COM ](http://developer.51cto.com/art/201305/396615.htm)

四、reshape/reshape2 包

Hadley Wickham，牛人，很牛X的一个人，写了很多R语言包，著名的有ggplot2, plyr, reshape/reshape2等。reshape2包是reshape包的重写版，用reshape2就行，都在CRAN源中，用install.packages函数就可以安装。reshape/reshape2的函数很少，一般用户直接使用的是melt, acast 和 dcast 函数。

melt是溶解/分解的意思，即拆分数据。reshape/reshape2的melt函数是个S3通用函数，它会根据数据类型（数据框，数组或列表）选择melt.data.frame, melt.array 或 melt.list函数进行实际操作。

如果是数组（array）类型，melt的用法就很简单，它依次对各维度的名称进行组合将数据进行线性/向量化。如果数组有n维，那么得到的结果共有n+1列，前n列记录数组的位置信息，最后一列才是观测值：
```r
> datax <- array(1:8, dim=c(2,2,2)) 
> melt(datax) 
  Var1 Var2 Var3 value 
1    1    1    1     1 
2    2    1    1     2 
3    1    2    1     3 
4    2    2    1     4 
5    1    1    2     5 
6    2    1    2     6 
7    1    2    2     7 
8    2    2    2     8 
 
> melt(datax, varnames=LETTERS[24:26],value.name="Val") 
  X Y Z Val 
1 1 1 1   1 
2 2 1 1   2 
3 1 2 1   3 
4 2 2 1   4 
5 1 1 2   5 
6 2 1 2   6 
7 1 2 2   7 
8 2 2 2   8 
```

## 列表数据

* 如果是列表数据，melt 函数将列表中的数据拉成两列，一列记录列表元素的值，另一列记录列表元素的名称；
* 如果列表中的元素是列表，则增加列变量存储元素名称。元素值排列在前，名称在后，越是顶级的列表元素名称越靠后：

```r
> datax <- list(agi="AT1G10000", GO=c("GO:1010","GO:2020"), KEGG=c("0100", "0200", "0300")) 
> melt(datax) 
      value   L1 
1 AT1G10000  agi 
2   GO:1010   GO 
3   GO:2020   GO 
4      0100 KEGG 
5      0200 KEGG 
6      0300 KEGG 
> melt(list(at_0100=datax)) 
      value   L2      L1 
1 AT1G10000  agi at_0100 
2   GO:1010   GO at_0100 
3   GO:2020   GO at_0100 
4      0100 KEGG at_0100 
5      0200 KEGG at_0100 
6      0300 KEGG at_0100 
```
如果数据是数据框类型，melt的参数就稍微复杂些：
```r
melt(data, id.vars, measure.vars, 
    variable.name = "variable", ..., na.rm = FALSE, 
    value.name = "value") 
```
其中 id.vars 是被当做维度的列变量，每个变量在结果中占一列；measure.vars 是被当成观测值的列变量，它们的列变量名称和值分别组成 variable 和 value两列，列变量名称用variable.name 和 value.name来指定。我们用airquality数据来看看：
```r
> str(airquality) 
'data.frame':   153 obs. of  6 variables: 
 $ Ozone  : int  41 36 12 18 NA 28 23 19 8 NA ... 
 $ Solar.R: int  190 118 149 313 NA NA 299 99 19 194 ... 
 $ Wind   : num  7.4 8 12.6 11.5 14.3 14.9 8.6 13.8 20.1 8.6 ... 
 $ Temp   : int  67 72 74 62 56 66 65 59 61 69 ... 
 $ Month  : int  5 5 5 5 5 5 5 5 5 5 ... 
 $ Day    : int  1 2 3 4 5 6 7 8 9 10 ... 
```
如果打算按月份分析臭氧和太阳辐射、风速、温度三者（列2:4）的关系，我们把它转成长格式数据框：
```r
> aq <- melt(airquality, var.ids=c("Ozone", "Month", "Day"),  
+ measure.vars=c(2:4), variable.name="V.type", value.name="value") 
> str(aq) 
'data.frame':   459 obs. of  5 variables: 
 $ Ozone : int  41 36 12 18 NA 28 23 19 8 NA ... 
 $ Month : int  5 5 5 5 5 5 5 5 5 5 ... 
 $ Day   : int  1 2 3 4 5 6 7 8 9 10 ... 
 $ V.type: Factor w/ 3 levels "Solar.R","Wind",..: 1 1 1 1 1 1 1 1 1 1 ... 
 $ value : num  190 118 149 313 NA NA 299 99 19 194 ...
``` 
var.ids 可以写成id，measure.vars可以写成measure。id（即var.ids）和 观测值（即measure.vars）这两个参数可以只指定其中一个，剩余的列被当成另外一个参数的值；如果两个都省略，数值型的列被看成观测值，其他的被当成id。如果想省略参数或者去掉部分数据，参数名最好用 id/measure，否则得到的结果很可能不是你要的：
```r
> str(melt(airquality, var.ids=c(1,5,6), measure.vars=c(2:4))) 
'data.frame':   459 obs. of  5 variables: 
 $ Ozone   : int  41 36 12 18 NA 28 23 19 8 NA ... 
 $ Month   : int  5 5 5 5 5 5 5 5 5 5 ... 
 $ Day     : int  1 2 3 4 5 6 7 8 9 10 ... 
 $ variable: Factor w/ 3 levels "Solar.R","Wind",..: 1 1 1 1 1 1 1 1 1 1 ... 
 $ value   : num  190 118 149 313 NA NA 299 99 19 194 ... 
> str(melt(airquality, var.ids=1, measure.vars=c(2:4)))   #看这里，虽然id只引用了一列，但结果却不是这样 
'data.frame':   459 obs. of  5 variables: 
 $ Ozone   : int  41 36 12 18 NA 28 23 19 8 NA ... 
 $ Month   : int  5 5 5 5 5 5 5 5 5 5 ... 
 $ Day     : int  1 2 3 4 5 6 7 8 9 10 ... 
 $ variable: Factor w/ 3 levels "Solar.R","Wind",..: 1 1 1 1 1 1 1 1 1 1 ... 
 $ value   : num  190 118 149 313 NA NA 299 99 19 194 ... 
> str(melt(airquality, var.ids=1))  #这样用更惨，结果不是我们要的吧？ 
 
Using  as id variables 
'data.frame':   918 obs. of  2 variables: 
 $ variable: Factor w/ 6 levels "Ozone","Solar.R",..: 1 1 1 1 1 1 1 1 1 1 ... 
 $ value   : num  41 36 12 18 NA 28 23 19 8 NA ... 
> str(melt(airquality, id=1))  #这样才行 
'data.frame':   765 obs. of  3 variables: 
 $ Ozone   : int  41 36 12 18 NA 28 23 19 8 NA ... 
 $ variable: Factor w/ 5 levels "Solar.R","Wind",..: 1 1 1 1 1 1 1 1 1 1 ... 
 $ value   : num  190 118 149 313 NA NA 299 99 19 194 ... 
```
数据整容有什么用？当然有。别忘了reshape2和ggplot2都是Hadley Wickham的作品，melt 以后的数据（称为molten数据）用ggplot2做统计图就很方便了，可以快速做出我们需要的图形：
```
library(ggplot2) 
 
aq$Month <- factor(aq$Month) 
p <- ggplot(data=aq, aes(x=Ozone, y=value, color=Month)) + theme_bw() 
p + geom_point(shape=20, size=4) + geom_smooth(aes(group=1), fill="gray80") + facet_wrap(~V.type, scales="free_y") 
```
R语言进阶之四：数据整形（reshape） - xxx - xxx的博客

## acast, dcast

melt获得的数据（molten data）可以用 acast 或 dcast 还原。acast获得数组，dcast获得数据框。和unstack函数一样，cast函数使用公式参数。公式的左边每个变量都会作为结果中的一列，而右边的变量被当成因子类型，每个水平都会在结果中产生一列。
```r
> head(dcast(aq, Ozone+Month+Day~V.type)) 
  Ozone Month Day Solar.R Wind Temp 
1     1     5  21       8  9.7   59 
2     4     5  23      25  9.7   61 
3     6     5  18      78 18.4   57 
4     7     5  11      NA  6.9   74 
5     7     7  15      48 14.3   80 
6     7     9  24      49 10.3   69 
```

## cast

cast函数的作用不只是还原数据，还可以使用函数对数据进行汇总（aggregate）。事实上，melt函数是为cast服务的，目的是使用cast函数对数据进行aggregate：
```r
> dcast(aq, Month~V.type, fun.aggregate=mean, na.rm=TRUE) 
  Month  Solar.R      Wind     Temp 
1     5 181.2963 11.622581 65.54839 
2     6 190.1667 10.266667 79.10000 
3     7 216.4839  8.941935 83.90323 
4     8 171.8571  8.793548 83.96774 
5     9 167.4333 10.180000 76.90000 
```

# R之data.table -melt/dcast(数据拆分和合并)

* [R之data.table -melt/dcast(数据合并和拆分) - Little_Rookie - 博客园 ](http://www.cnblogs.com/nxld/p/6067137.html)

写在前面：数据整形的过程确实和揉面团有些类似，先将数据通过melt()函数将数据揉开，然后再通过dcast()函数将数据重塑成想要的形状
## reshape2包：
* melt-把宽格式数据转化成长格式。
* cast-把长格式数据转化成宽格式。（dcast-输出时返回一个数据框。acast-输出时返回一个向量/矩阵/数组。）
注：melt是数据融合的意思，它做的工作其实就是把数据由“宽”转“长”。
* cast 函数的作用除了还原数据外，还可以对数据进行整合。
* dcast 输出数据框。公式的左边每个变量都会作为结果中的一列，而右边的变量被当成因子类型，每个水平都会在结果中产生一列。

## tidyr包：
gather-把宽度较大的数据转换成一个更长的形式，它类比于从reshape2包中融合函数的功能
spread-把长的数据转换成一个更宽的形式，它类比于从reshape2包中铸造函数的功能。

## data.table包：
data.table的函数melt 和dcast 是增强包reshape2里同名函数的扩展

```r
library(data.table)
ID <- c(NA,1,2,2)
Time <- c(1,2,NA,1)
X1 <- c(5,3,NA,2)
X2 <- c(NA,5,1,4)
mydata <- data.table(ID,Time,X1,X2) 
mydata
##    ID Time X1 X2
## 1: NA    1  5 NA
## 2:  1    2  3  5
## 3:  2   NA NA  1
## 4:  2    1  2  4
md <- melt(mydata, id=c("ID","Time")) #or md <- melt(mydata, id=1:2)
#melt以使每一行都是一个唯一的标识符-变量组合
md     #将第一列作为id列，其他列全部融合就可以了
##    ID Time variable value
## 1: NA    1       X1     5
## 2:  1    2       X1     3
## 3:  2   NA       X1    NA
## 4:  2    1       X1     2
## 5: NA    1       X2    NA
## 6:  1    2       X2     5
## 7:  2   NA       X2     1
## 8:  2    1       X2     4
```

将变量"variable",和"value"揉合在一起，结果产生了新的两列，一列是变量variable，指代是哪个揉合变量，另外一列是取值value，即变量对应的值。我们也称这样逐行排列的方式称为长数据格式

 

melt:数据集的融合是将它重构为这样一种格式：每个测量变量独占一行，行中带有要唯一确定这个测量所需的标识符变量。
```r
str(mydata)
## Classes 'data.table' and 'data.frame':   4 obs. of  4 variables:
##  $ ID  : num  NA 1 2 2
##  $ Time: num  1 2 NA 1
##  $ X1  : num  5 3 NA 2
##  $ X2  : num  NA 5 1 4
##  - attr(*, ".internal.selfref")=<externalptr>
str(md)
## Classes 'data.table' and 'data.frame':   8 obs. of  4 variables:
##  $ ID      : num  NA 1 2 2 NA 1 2 2
##  $ Time    : num  1 2 NA 1 1 2 NA 1
##  $ variable: Factor w/ 2 levels "X1","X2": 1 1 1 1 2 2 2 2
##  $ value   : num  5 3 NA 2 NA 5 1 4
##  - attr(*, ".internal.selfref")=<externalptr>
setcolorder(md,c("ID","variable","Time","value")) ##setcolorder()可以用来修改列的顺序。
md
##    ID variable Time value
## 1: NA       X1    1     5
## 2:  1       X1    2     3
## 3:  2       X1   NA    NA
## 4:  2       X1    1     2
## 5: NA       X2    1    NA
## 6:  1       X2    2     5
## 7:  2       X2   NA     1
## 8:  2       X2    1     4
mdr <- melt(mydata, id=c("ID","Time"),variable.name="Xzl",value.name="Vzl",na.rm = TRUE) #variable.name定义变量名
mdr
##    ID Time Xzl Vzl
## 1: NA    1  X1   5
## 2:  1    2  X1   3
## 3:  2    1  X1   2
## 4:  1    2  X2   5
## 5:  2   NA  X2   1
## 6:  2    1  X2   4
mdr1 <- melt(mydata, id=c("ID","Time"),variable.name="Xzl",value.name="Vzl",measure.vars=c("X1"),na.rm = TRUE) #measure.vars筛选
mdr1
##    ID Time Xzl Vzl
## 1: NA    1  X1   5
## 2:  1    2  X1   3
## 3:  2    1  X1   2
md[Time==1]
##    ID variable Time value
## 1: NA       X1    1     5
## 2:  2       X1    1     2
## 3: NA       X2    1    NA
## 4:  2       X2    1     4
md[Time==2]
##    ID variable Time value
## 1:  1       X1    2     3
## 2:  1       X2    2     5
#执行整合
# rowvar1 + rowvar2 + ... ~ colvar1 + colvar2 + ...
# 在这个公式中，rowvar1 + rowvar2 + ... 定义了要划掉的变量集合，以确定各行的内容，而colvar1 + colvar2 + ... 则定义了要划掉的、确定各列内容的变量集合。
newmd<- dcast(md, ID~variable, mean)
newmd
##    ID X1  X2
## 1:  1  3 5.0
## 2:  2 NA 2.5
## 3: NA  5  NA
newmd2<- dcast(md, ID+variable~Time)
newmd2  
##    ID variable  1  2 NA
## 1:  1       X1 NA  3 NA
## 2:  1       X2 NA  5 NA
## 3:  2       X1  2 NA NA
## 4:  2       X2  4 NA  1
## 5: NA       X1  5 NA NA
## 6: NA       X2 NA NA NA
#ID+variable~Time  使用Time对(ID，variable)分组 Time:1,2,NA   类似excel的数据透析 
newmd3<- dcast(md, ID~variable+Time)
newmd3 #variable:X1,X2     Time:1,2,NA   类似excel的数据透析
##    ID X1_1 X1_2 X1_NA X2_1 X2_2 X2_NA
## 1:  1   NA    3    NA   NA    5    NA
## 2:  2    2   NA    NA    4   NA     1
## 3: NA    5   NA    NA   NA   NA    NA
```
#即使只是凡世中一颗小小的尘埃，命运也要由自己主宰，像向日葵般，迎向阳光、勇敢盛开