

* [R中利用apply、tapply、lapply、sapply、mapply、table等函数进行分组统计_菜鸟的成长_新浪博客 ](http://blog.sina.com.cn/s/blog_6caea8bf0100xkpg.html)


* [R apply Function Examples -- EndMemo ](http://www.endmemo.com/program/R/apply.php)

```r
#apply() function applies a function to margins of an array or matrix.
#apply(x,margin,func, ...)
#• x: array
#• margin: subscripts, for matrix, 1 for row, 2 for column
#• func: the function
... 
>BOD    #R built-in dataset, Biochemical Oxygen Demand
  Time demand
1    1    8.3
2    2   10.3
3    3   19.0
4    4   16.0
5    5   15.6
6    7   19.8
Sum up for each row:
> apply(BOD,1,sum)
#[1]  9.3 12.3 22.0 20.0 20.6 26.8
#Sum up for each column:
> apply(BOD,2,sum)
#  Time demand 
#    22     89 
#Multipy all values by 10:
> apply(BOD,1:2,function(x) 10 * x)
     Time demand
[1,]   10     83
[2,]   20    103
[3,]   30    190
[4,]   40    160
[5,]   50    156
[6,]   70    198

#Used for array, margin set to 1:
> x <- array(1:9)
> apply(x,1,function(x) x * 10)
[1] 10 20 30 40 50 60 70 80 90

Two dimension array, margin can be 1 or 2:
> x <- array(1:9,c(3,3))
> x
     [,1] [,2] [,3]
[1,]    1    4    7
[2,]    2    5    8
[3,]    3    6    9

> apply(x,1,function(x) x * 10) #or apply(x,2,function(x) x * 10)
[1] 10 20 30 40 50 60 70 80 90

lapply() function can handle data frame with similar results, return is a list:
> lapply(BOD,sum)
$Time
[1] 22

$demand
[1] 89

> lapply(BOD,mean)
$Time
[1] 3.666667

$demand
[1] 14.83333

sapply() has similar function, it defines "simplify=TRUE" by default, thus return a vector:
> sapply(BOD,sum)
  Time demand 
    22     89 
> sapply(BOD,sum,simplify=FALSE)
$Time
[1] 22

$demand
[1] 89
```

* [r语言常用函数apply及subset函数 - lijinxiu123的博客 - CSDN博客 ](http://blog.csdn.net/lijinxiu123/article/details/51378700)


因为我是一个程序员，所以在最初学习R的时候，当成“又一门编程语言”来学习，但是怎么学都觉得别扭。现在我的看法倾向于，R不是一种通用型的编程语言，而是一种统计领域的软件工具。因此，不能用通用型编程的思维来设计R代码。在Andrew Lim关于R和Python的对比回答中，`R是一种面向数组(array-oriented)的语法，它更像数学，方便科学家将数学公式转化为R代码`。而python是一种通用编程语言，更工程化。在使用R时，要尽量用array的方式思考，避免for循环。不用循环怎么实现迭代呢？这就需要用到apply函数族。它不是一个函数，而是一族功能类似的函数。

概述
apply系列函数的基本作用是对数组（array，可以是多维）或者列表（list）按照元素或元素构成的子集合进行迭代，并将当前元素或子集合作为参数调用某个指定函数。vector是一维的array，dataframe可以看作特殊的list。
这些函数间的关系
作用目标	在每个元素上应用	在子集合上应用
array	apply	tapply
list	lapply(...)	by
其中lapply(...)包括一族函数
```
lapply
   |
   |-> 简化版: sapply
   |             | -> 可设置返回值模板: vapply
   |             |-> 多变量版: mapply
   |
   |-> 递归版: rapply
```
另外vector比较奇怪，vector是一维的array，但是却不全是和array使用相同的函数。在按元素迭代的情况下，使用和list一样的lapply函数；而在按子集合迭代的情况下，tapply和by都能用，只是返回值形式不同。