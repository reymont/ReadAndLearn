

7 复杂网络中的社图结构


<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [7.1 引言](#71-引言)
* [7.4 分裂方法](#74-分裂方法)
	* [基本思想](#基本思想)
	* [GN算法的实现](#gn算法的实现)
		* [广度优先算法](#广度优先算法)
* [7.5 凝聚算法](#75-凝聚算法)
	* [7.5.1 Newman快速算法](#751-newman快速算法)

<!-- /code_chunk_output -->



# 7.1 引言

整个网络是由若干个“群（group）”或“团（cluster）”构成的。每个群内部的节点之间的链接相对非常紧密，但是各个群之间的链接相对来说去比较稀疏。

网络社团结构的研究与社会学中的分级聚类（hierarchical clustering）有着密切的关系。

分级聚类是寻找社会网络中社图结构的一类传统算法。它是基于各个节点之间连接的相似性或者强度，把网络自然的划分为各个子群。根据往网络中添加边还是从网络中移除边， 该类算法又可以分为两类：凝聚方法（agglomerative method）和分裂方法（divisive method）。

# 7.4 分裂方法

## 基本思想

前面已经提到，根据网络中添加边还是从网络中移除边，可以把社会学中分级聚类的一套方法分为两大类：凝聚方法和分裂方法。GN方法就是一种分裂方法。它的基本思想是不断地从网络中移除介数（Betweenness）最大的边。边介数定义为网络中经过每条边的最短路径的数目。

GN算法的基本流程如下：
1. 计算网络中所有边的介数；
2. 找到介数最高的边并将它从网络中移除；
3. 重复步骤2，直到每个节点就是一个退化的社团为止。

## GN算法的实现

假设一个图的节点数为n，边数为m。每进行一次广度优先搜索就可以得到一个节点与其他各节点间的所有的最短路径，且算法复杂度为O(m)。

![betweenness.png](img/betweenness.png)

首先，找到这颗树不被任何其他节点访问的叶节点，将于叶节点相连的边赋值为1。
然后，从离数的源节点距离最远的一条边开始，逐步上移，依次为每条边赋值，其值为紧接在该边下的所有邻边的值之和再加1。
对所有可能的源节点重复这个过程。



### 广度优先算法

kruskal

![kruskal.png](img/kruskal.png)

![wg_betweenness.png](img/wg_betweenness.png)

```R
library(igraph)
g <- graph.formula(0-5,5-4,4-3,3-2,2-1,1-6)
V(g)
E(g)
ecount(g)
is.weighted(g)
wg <- g
E(wg)$weight <- c(10,25,22,12,16,14)
E(wg)$weight
degree(wg)
neighbors(wg,5)
plot(wg,layout=layout.circle)

```

![wg_hclust.png](img/wg_hclust.png)

```R
> kc <- fastgreedy.community(wg)
> membership(kc)
0 5 4 3 2 1 6 
1 1 1 1 2 2 2 
> library(ape)
> dendPlot(kc, mode="hclust")
```


![wg_betweenness_communities.png](img/wg_betweenness_communities.png)

```r
> plot(wg,layout=layout.circle)
> betweenness(wg)
0 5 4 3 2 1 6 
0 5 8 9 8 5 0 
> E(wg)
+ 6/6 edges (vertex names):
[1] 0--5 5--4 4--3 3--2 2--1 1--6
> edge.betweenness(wg)
[1]  6 10 12 12 10  6
> ebc <- edge.betweenness.community(g)
> membership(ebc)
0 5 4 3 2 1 6 
1 1 1 2 2 3 3 
> dendPlot(ebc, mode="hclust")
```


* [r - edge betweenness community cut off point - Stack Overflow ](https://stackoverflow.com/questions/24715788/edge-betweenness-community-cut-off-point)

查看划分的步骤

```r
cut <- cutat(ebc,4)
colors <- rainbow(4)
plot(wg, vertex.color=colors[cut],layout=layout.circle)
```


# 7.5 凝聚算法

## 7.5.1 Newman快速算法


