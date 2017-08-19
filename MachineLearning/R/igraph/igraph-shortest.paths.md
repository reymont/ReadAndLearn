
* [R: Shortest (directed or undirected) paths between vertices ](http://cneurocvs.rmki.kfki.hu/igraph/doc/R/shortest.paths.html)

```r
shortest.paths(graph, v=V(graph), mode = c("all", "out", "in"),
      weights = NULL)
get.shortest.paths(graph, from, to=V(graph), mode = c("all", "out",
      "in"), weights = NULL)
get.all.shortest.paths(graph, from, to = V(graph), mode = c("all", "out", "in")) 
average.path.length(graph, directed=TRUE, unconnected=TRUE)
path.length.hist (graph, directed = TRUE, verbose = igraph.par("verbose")) 
```


* [graph - Find All Shortest Paths using igraph/R - Stack Overflow ](https://stackoverflow.com/questions/19996444/find-all-shortest-paths-using-igraph-r)

You could use shortest.paths that returns the matrix of the distances between each node:

distMatrix <- shortest.paths(g, v=V(g), to=V(g))
Result:

      cdc42 ste20 mkk2 bul1 mth1 vma6 vma2  ... 
cdc42     0     1  Inf  Inf    4    3    2  
ste20     1     0  Inf  Inf    3    2    1  
mkk2    Inf   Inf    0    1  Inf  Inf  Inf  
bul1    Inf   Inf    1    0  Inf  Inf  Inf  
mth1      4     3  Inf  Inf    0    1    2  
vma6      3     2  Inf  Inf    1    0    1
vma2      2     1  Inf  Inf    2    1    0  
...      
And it's very easy to access it:

# e.g. shortest path length between the second node and the fifth
distMatrix[2,5]
>
[1] 3

# or using node names:
distMatrix["ste20", "mth1"]
>
[1] 3
