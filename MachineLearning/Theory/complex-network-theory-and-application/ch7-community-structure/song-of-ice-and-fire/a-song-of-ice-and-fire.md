


<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [R语言的igraph画社交关系图示例](#r语言的igraph画社交关系图示例)
	* [3.根据联系人的多少决定节点的大小和色彩，连线设成弧线](#3根据联系人的多少决定节点的大小和色彩连线设成弧线)
* [igraph](#igraph)
* [attribute](#attribute)
	* [betweenness](#betweenness)

<!-- /code_chunk_output -->


* [mathbeveridge/asoiaf: Character Interaction Networks for George R. R. Martin's "A Song of Ice and Fire" saga ](https://github.com/mathbeveridge/asoiaf)
* [Network of Thrones | A Song of Math and Westeros ](https://networkofthrones.wordpress.com/)
* [Network of Thrones ](https://www.macalester.edu/~abeverid/thrones.html)
* [基于社区发现算法和图分析Neo4j解读《权力的游戏》 | 神机喵算 ](https://bigdata-ny.github.io/2016/08/12/graph-of-thrones-neo4j-social-network-analysis/)
* [igraph基本使用方法示例 - NodYoung - CSDN博客 ](http://blog.csdn.net/NNNNNNNNNNNNY/article/details/53701277)




* [07. Plotting Networks: Weighted Edges - Shizuka Lab ](http://www.shizukalab.com/toolkits/sna/weighted-edges)


* [A Storm of Swords](https://www.macalester.edu/~abeverid/data/stormofswords.csv)数据

# R语言的igraph画社交关系图示例

* [R语言的igraph画社交关系图示例 ](http://mp.weixin.qq.com/s/7aMmX6ExK_4_jGzCNR-wnw)
* [R语言的igraph画社交关系图示例 - 大数据文摘微信公众账号 ](http://www.weixinnu.com/tag/article/3886340582)

## 3.根据联系人的多少决定节点的大小和色彩，连线设成弧线

```r
source("http://michael.hahsler.net/SMU/ScientificCompR/code/map.R")
E(g)$curved <- 0.2 #将连线设成弧线，数值越大弧线越弯
jpeg(filename='dolphins_curve1.jpg',width=800,height=800,units='px')
layout=layout.fruchterman.reingold
plot(g, layout=layout, vertex.size=map(degree(g),c(1,20)), vertex.color=map(degree(g),c(1,20)))
dev.off()
```


# igraph


* [直方图的一天--周的如何和有字符串标签 - 广瓜网 ](http://www.guanggua.com/question/6923223-how-to-histogram-day-of-week-and-have-string-labels.html)


```r
dat <- as.Date( c("2010-04-02", "2010-04-06", "2010-04-09", "2010-04-10", "2010-04-14", 
       "2010-04-15", "2010-04-19",   "2010-04-21", "2010-04-22", "2010-04-23","2010-04-24", 
        "2010-04-25", "2010-04-26", "2010-04-28", "2010-04-29", "2010-04-30"))
 dwka <- format(dat , "%a")
 dwka
# [1] "Fri" "Tue" "Fri" "Sat" "Wed" "Thu" "Mon"
#  [8] "Wed" "Thu" "Fri" "Sat" "Sun" "Mon" "Wed"
# [15] "Thu" "Fri"
dwkn <- as.numeric( format(dat , "%w") ) # numeric version
hist( dwkn , breaks= -.5+0:7, labels= unique(dwka[order(dwkn)]))
```

# attribute

```r
#数组
length(attr(d,"names"))
#一个值
attributes(d)
```


* [Attribute Plots ](https://cran.r-project.org/web/packages/UpSetR/vignettes/attribute.plots.html)

```r
library(UpSetR)
library(ggplot2)
library(grid)
library(plyr)
movies <- read.csv(system.file("extdata", "movies.csv", package = "UpSetR"), 
    header = T, sep = ";")
```

## betweenness

* [betweenness | igraph R manual pages ](http://igraph.org/r/doc/betweenness.html)


```R
g <- sample_gnp(10, 3/10)
betweenness(g)
edge_betweenness(g)
```