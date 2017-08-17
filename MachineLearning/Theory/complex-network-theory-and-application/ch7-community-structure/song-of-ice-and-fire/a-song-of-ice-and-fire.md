

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
