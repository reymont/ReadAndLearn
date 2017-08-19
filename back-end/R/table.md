

* [R语言学习笔记 —— table 函数的应用 - cleverbegin的专栏 - CSDN博客 ](http://blog.csdn.net/clebeg/article/details/23529709)

```r
ct <- data.frame(  
        Vote.for.X = factor(c("Yes", "Yes", "No", "Not Sure", "No"), levels = c("Yes", "No", "Not Sure")),  
        Vote.for.X.Last.Time =  factor(c("Yes", "No", "No", "Yes", "No"), levels = c("Yes", "No"))  
      )  
ct
#  Vote.for.X Vote.for.X.Last.Time  
#1        Yes                  Yes  
#2        Yes                   No  
#3         No                   No  
#4   Not Sure                  Yes  
#5         No                   No  
cttab <-table(ct)  
cttab
#Vote.for.X.Last.Time  
#Vote.for.X Yes No  
#  Yes        1  1  
#  No         0  2  
#  Not Sure   1  0  
mode(cttab) 
summary(cttab)  
attributes(cttab)
addmargins(cttab)
#查看水平 
dimnames(cttab)
#频率，输出结果转化为数据框
as.data.frame(cttab)  
```

首先我们创建了一个示例数据集合，其中我们指定我们的因子的水平，然后 table 函数则是统计所有因子对出现的情况的频数


# subtable

subtable 类比 subset
subtable（tbl，subnames） tbl 感兴趣的表，subnames 一个类表，列出自己各个维度感兴趣的水平, subtable 实现如下

```r
subtable <- function(tbl, subnames) {  
  #将 table 转换称 array 获得 table 里面的所有元素  
  tblarray <- unclass(tbl)  
    
  #将 tblarray 以及 subnames 组合到一个list中  
  dcargs <- list(tblarray)  
  ndims <- length(subnames)  
  for(i in 1:ndims) {  
    dcargs[[i+1]] <- subnames[[i]]  
  }  
    
  #等价与执行 dcargs[[1]][dcargs[[2]][i], dcargs[[3]][j]] i,j 取遍所有该属性的元素  
  subarray <- do.call("[", dcargs)  
   
  #对list中的每一个属性调用 length  
  dims <- lapply(subnames, length)  
  subtbl <- array(subarray, dims, dimnames = subnames)  
  class(subtbl) <- "table"  
  return(subtbl)  
}   
```