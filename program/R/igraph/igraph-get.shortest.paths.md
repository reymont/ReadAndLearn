* [Using igraph/R to get the top 10 shortest path - Stack Overflow ](https://stackoverflow.com/questions/32873689/using-igraph-r-to-get-the-top-10-shortest-path)


> get.shortest.paths(g,v,V(g), output='epath')

```r
set.seed(1)
require(igraph)
g <- erdos.renyi.game(100,.2)
Then extract all shortest paths and calculate their length:

plist <- do.call(c,
            lapply(V(g), function(v) get.shortest.paths(g,v,V(g), output='epath')$epath))
Now figure out which paths are the top ten:

psize <- data.frame(i = 1:length(plist), plength = sapply(plist,length))

top10 <- head(psize[order(-psize$plength),],10)
Now figure out which edges this involves:

elist <- unlist(plist[top10$i])
And finally, get the subgraph which contains these vertices:

finalg <- subgraph.edges(g, elist)
```