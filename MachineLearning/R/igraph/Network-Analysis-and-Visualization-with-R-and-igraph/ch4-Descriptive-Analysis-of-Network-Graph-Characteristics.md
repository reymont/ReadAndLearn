

# 4.2.1 节点度

```R

# 度分布可能呈现各种形状。yeast是一个酵母菌蛋白质相互作用的网络
library(igraphdata)
library(sand)
data(yeast)
ecount(yeast)
vcount(yeast)
degree(yeast)#度
betweenness(yeast)#介数
```

```R
#尽管度值很低的节点占了多数，网络中还存在相当数量的、度值高了几个数量级的节点
d.yeast <- degree(yeast)
hist(d.yeast,col="blue",
   xlab="Degree", ylab="Frequency",
   main="Degree Distribution")
```

![yeast_degree_hist.png](img/yeast_degree_hist.png)

```R
table(get.vertex.attribute(yeast,"Class"))

```R
dd.yeast <- degree.distribution(yeast)
d <- 1:max(d.yeast)-1
ind <- (dd.yeast != 0)
plot(d[ind], dd.yeast[ind], log="xy", col="blue",
   xlab=c("Log-Degree"), ylab=c("Log-Intensity"),
   main="Log-Log Degree Distribution")
```

![yeast_log_degree_hist.png](img/yeast_log_degree_hist.png)

```R
library(igraphdata)
library(sand)
data(yeast)

#存在一个巨型组件
comps <- decompose.graph(yeast)
table(sapply(comps, vcount))
#   2    3    4    5    6    7 2375 
#  63   13    5    6    1    3    1 
#两个节点一共有个63个graph
#2375个节点一共有1个

#通常关注巨型组件
#Creates a separate graph for each component of a graph.
yeast.gc <- decompose.graph(yeast)[[1]]
average.path.length(yeast.gc)
diameter(yeast.gc)
transitivity(yeast.gc)
```

# 社团发现

## igraph支持的社团发现算法

[R: rename community structure detection functions · Issue #692 · igraph/igraph](https://github.com/igraph/igraph/issues/692) （列举了igraph实现的社团算法）

* community.le.to.membership will be removed I believe
* community.to.membership will be also removed AFAIR
* compare.communities → compare
* edge.betweenness.community cluster_edge_betweenness
* edge.betweenness.community.merges should be internal?
* fastgreedy.community → cluster_fast_greedy
* infomap.community → cluster_infomap
* label.propagation.community cluster_label_prop
* leading.eigenvector.community cluster_leading_eigen
* multilevel.community → cluster_multilevel and cluster_louvain or just the * latter
* optimal.community → cluster_optimal
* spinglass.community → cluster_spinglass
* walktrap.community → cluster_walktrap

## 社团发现算法的介绍

[r - What are the differences between community detection algorithms in igraph? - Stack Overflow](https://stackoverflow.com/questions/9471906/what-are-the-differences-between-community-detection-algorithms-in-igraph)
[Summary of community detection algorithms in igraph 0.6 | R-bloggers ](https://www.r-bloggers.com/summary-of-community-detection-algorithms-in-igraph-0-6/)

Here is a short summary about the community detection algorithms currently implemented in igraph:

edge.betweenness.community is a hierarchical decomposition process where edges are removed in the decreasing order of their edge betweenness scores (i.e. the number of shortest paths that pass through a given edge). This is motivated by the fact that edges connecting different groups are more likely to be contained in multiple shortest paths simply because in many cases they are the only option to go from one group to another. This method yields good results but is very slow because of the computational complexity of edge betweenness calculations and because the betweenness scores have to be re-calculated after every edge removal. Your graphs with ~700 vertices and ~3500 edges are around the upper size limit of graphs that are feasible to be analyzed with this approach. Another disadvantage is that edge.betweenness.community builds a full dendrogram and does not give you any guidance about where to cut the dendrogram to obtain the final groups, so you'll have to use some other measure to decide that (e.g., the modularity score of the partitions at each level of the dendrogram).
fastgreedy.community is another hierarchical approach, but it is bottom-up instead of top-down. It tries to optimize a quality function called modularity in a greedy manner. Initially, every vertex belongs to a separate community, and communities are merged iteratively such that each merge is locally optimal (i.e. yields the largest increase in the current value of modularity). The algorithm stops when it is not possible to increase the modularity any more, so it gives you a grouping as well as a dendrogram. The method is fast and it is the method that is usually tried as a first approximation because it has no parameters to tune. However, it is known to suffer from a resolution limit, i.e. communities below a given size threshold (depending on the number of nodes and edges if I remember correctly) will always be merged with neighboring communities.
walktrap.community is an approach based on random walks. The general idea is that if you perform random walks on the graph, then the walks are more likely to stay within the same community because there are only a few edges that lead outside a given community. Walktrap runs short random walks of 3-4-5 steps (depending on one of its parameters) and uses the results of these random walks to merge separate communities in a bottom-up manner like fastgreedy.community. Again, you can use the modularity score to select where to cut the dendrogram. It is a bit slower than the fast greedy approach but also a bit more accurate (according to the original publication).
spinglass.community is an approach from statistical physics, based on the so-called Potts model. In this model, each particle (i.e. vertex) can be in one of c spin states, and the interactions between the particles (i.e. the edges of the graph) specify which pairs of vertices would prefer to stay in the same spin state and which ones prefer to have different spin states. The model is then simulated for a given number of steps, and the spin states of the particles in the end define the communities. The consequences are as follows: 1) There will never be more than c communities in the end, although you can set c to as high as 200, which is likely to be enough for your purposes. 2) There may be less than c communities in the end as some of the spin states may become empty. 3) It is not guaranteed that nodes in completely remote (or disconencted) parts of the networks have different spin states. This is more likely to be a problem for disconnected graphs only, so I would not worry about that. The method is not particularly fast and not deterministic (because of the simulation itself), but has a tunable resolution parameter that determines the cluster sizes. A variant of the spinglass method can also take into account negative links (i.e. links whose endpoints prefer to be in different communities).
leading.eigenvector.community is a top-down hierarchical approach that optimizes the modularity function again. In each step, the graph is split into two parts in a way that the separation itself yields a significant increase in the modularity. The split is determined by evaluating the leading eigenvector of the so-called modularity matrix, and there is also a stopping condition which prevents tightly connected groups to be split further. Due to the eigenvector calculations involved, it might not work on degenerate graphs where the ARPACK eigenvector solver is unstable. On non-degenerate graphs, it is likely to yield a higher modularity score than the fast greedy method, although it is a bit slower.
label.propagation.community is a simple approach in which every node is assigned one of k labels. The method then proceeds iteratively and re-assigns labels to nodes in a way that each node takes the most frequent label of its neighbors in a synchronous manner. The method stops when the label of each node is one of the most frequent labels in its neighborhood. It is very fast but yields different results based on the initial configuration (which is decided randomly), therefore one should run the method a large number of times (say, 1000 times for a graph) and then build a consensus labeling, which could be tedious.
igraph 0.6 will also include the state-of-the-art Infomap community detection algorithm, which is based on information theoretic principles; it tries to build a grouping which provides the shortest description length for a random walk on the graph, where the description length is measured by the expected number of bits per vertex required to encode the path of a random walk.

Anyway, I would probably go with fastgreedy.community or walktrap.community as a first approximation and then evaluate other methods when it turns out that these two are not suitable for a particular problem for some reason.

## R包igraph探究

[R包igraph探究 - 紫巅草 - 博客园 ](http://www.cnblogs.com/zidiancao/p/3937120.html)

## 代码

```R
library(igraphdata)
library(sand)
data(yeast)
yeast.gc <- decompose.graph(yeast)[[1]]

#获取yeast.gc的Class属性，分类
func.class <- get.vertex.attribute(yeast.gc, "Class")
table(func.class)
#func.class
# A   B   C   D   E   F   G   M   O   P   R   T   U 
# 51  98 122 238  95 171  96 278 171 248  45 240 483 

yc <- fastgreedy.community(yeast.gc)
c.m <- membership(yc)
#一共切分了31个子图
table(c.m)
#c.m
#  1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21 
#182  98 255 733 148  82 186 363  55  25  30  22  34  24  15  15  11  15   6  10   8 
# 22  23  24  25  26  27  28  29  30  31 
#  9   4   5   6   7   8   7   5   4   3 
table(c.m, func.class, useNA=c("no"))

cyc <- cluster_walktrap(yeast.gc)
cy.m <- membership(cyc)
table(cy.m)
table(cy.m, func.class, useNA=c("no"))
```

## 标签传播





通过相邻点给自己打标签，相同的标签一个类。跟特征向量可以组合应用，适用于话题类

```R
system.time(lc <- label.propagation.community(g))
print(modularity(lc))
plot(lc , g,vertex.size=5,vertex.label=NA)
```

# 社群划分模型的区别

* [R语言︱SNA-社会关系网络—igraph包（社群划分、画图）（三） - 素质云笔记/Recorder... - CSDN博客 ]

|社群模型|概念|效果|
|-|-|-|
|点连接|某点与某社群有关系就是某社群的|最差，常常是某一大类超级多|
|随机游走|利用距离相似度，用合并层次聚类方法建立社群|运行时间短，但是效果不是特别好，也会出现某类巨多|
|自旋玻璃|关系网络看成是随机网络场，利用能量函数来进行层次聚类|耗时长，适用较为复杂的情况|
|中间中心度|找到中间中心度最弱的删除，并以此分裂至到划分不同的大群落|耗时长，参数设置很重要|
|标签传播|通过相邻点给自己打标签，相同的标签一个雷|跟特征向量可以组合应用，适用于话题类|


## 标签传播社群发现

[label.propagation.community function | R Documentation ](https://www.rdocumentation.org/packages/igraph/versions/0.7.1/topics/label.propagation.community)
[标签传播(LPA)算法及python基于igraph包的实现 - 郑少强 - CSDN博客 ](http://blog.csdn.net/qq_31878083/article/details/51861078)

```R
#社群发现方法五：标签传播社群发现  
member<-label.propagation.community(g.undir,weights=V(g.undir)$weight)  
V(g.undir)$member  
member<-label.propagation.community(g.undir,weights = E(g.undir)$weight,initial = c(1,1,-1,-1,2,-1,1))  
V(g.undir)$member  
member<-label.propagation.community(g.undir,weights = E(g.undir)$weight,  
                                    initial = c(1,1,-1,-1,2,-1,1),fixed=c(T,F,F,F,F,F,T))  
```

```R
g <- erdos.renyi.game(10, 5/10) %du% erdos.renyi.game(9, 5/9)
g <- add.edges(g, c(1, 12))
label.propagation.community(g)
```