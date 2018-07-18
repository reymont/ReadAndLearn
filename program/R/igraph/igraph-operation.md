

* [R包—iGraph_燕子神经窝_新浪博客 ](http://blog.sina.com.cn/s/blog_60034d4a0101e12h.html)

这几天收到师兄的任务，熟悉iGRaph包的使用，通过查资料，外加自己的实践，在此做个简单的学习笔记。
以下例子均是在R 3.0.1版本下测试的。
# 1.用igraph创建图表
```r
g<- graph(c(1,2, 1,3, 1,4, 2,4, 3,4), directed=T)
> g
IGRAPH D--- 4 5 -- 
> plot(g, layout=layout.fruchterman.reingold)R包—iGraph
```

# 2.创建多种图形的图表

```r
> g1 <- graph.full(4)
> g1
IGRAPH U--- 4 6 -- Full graph
+ attr: name (g/c), loops (g/x)
> g2 <- graph.ring(3)
> g2
IGRAPH U--- 3 3 -- Ring graph
+ attr: name (g/c), mutual (g/x), circular (g/x)
> g3 = graph.lattice(c(3,4,2))#create a lattice
> g3
IGRAPH U--- 24 46 -- Lattice graph
+ attr: name (g/c), dimvector (g/n), nei (g/n), mutual (g/x),
  circular (g/x)
> g4 = graph.tree(50, children=2)#create a tree
> g4
IGRAPH D--- 50 49 -- Tree
+ attr: name (g/c), children (g/n), mode (g/c)
>plot(g4,layout=layout.fruchterman.reingold,vertex.label.dist=0.3,edge.arrow.size=0.5,vertex.color="red")
```

# 3.随机图表和优先连接的生成

```r
> g <- erdos.renyi.game(20, 0.2)#create a random graph and fix probability 
> g
IGRAPH U--- 20 43 -- Erdos renyi (gnp) graph
+ attr: name (g/c), type (g/c), loops (g/x), p (g/n)
> plot(g, layout=layout.fruchterman.reingold, vertex.label=NA, vertex.size=5,vertex.color="green")
> g <- erdos.renyi.game(20, 15, type='gnm')# Generate random graph, fixed number of arcs
> g
IGRAPH U--- 20 15 -- Erdos renyi (gnm) graph
+ attr: name (g/c), type (g/c), loops (g/x), m (g/n)
> plot(g, layout=layout.reingold.tilford, vertex.label=NA, vertex.size=5,vertex.color="green")
```



# 4.简单图表的算法

```r
g <- erdos.renyi.game(12, 0.35)
> g
IGRAPH U--- 12 21 -- Erdos renyi (gnp) graph
+ attr: name (g/c), type (g/c), loops (g/x), p (g/n)
> E(g)$weight <- round(runif(length(E(g))),2) * 50#Create the graph and assign random edge weights
> mst <- minimum.spanning.tree(g)#Compute the minimum spanning tree
> mst
IGRAPH U-W- 12 11 -- Erdos renyi (gnp) graph
+ attr: name (g/c), type (g/c), loops (g/x), p (g/n), weight
  (e/n)
```

# 5 最短路径算法：

```r
> pa <- get.shortest.paths(g, 5, 9)[[1]]
> pa
[1] 5 3 9
> V(g)[pa]$color <- 'green'
> E(g)$color <- 'grey'
> E(g, path=pa)$color <- 'red'
> E(g, path=pa)$width <- 3
> plot(g, layout=layout.fruchterman.reingold)
> plot(mst, layout=layout.reingold.tilford,  edge.label=E(mst)$weight)
> plot(g, layout=layout.fruchterman.reingold, edge.label=E(g)$weight)
```