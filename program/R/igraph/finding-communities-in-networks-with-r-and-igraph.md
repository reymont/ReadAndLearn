

* [Finding communities in networks with R and igraph ](https://www.sixhat.net/finding-communities-in-networks-with-r-and-igraph.html)

Finding communities in networks with R and igraph

Finding communities in networks

Finding communities in networks is a common task under the paradigm of complex systems. Doing it in R is easy. There are several ways to do community partitioning of graphs using very different packages. I’m going to use igraph to illustrate how communities can be extracted from given networks.

igraph is a lovely library to work with graphs. 95% of what you’ll ever need is available in igraph. It has the advantage that the libraries are written in C and are fast as hell.

algorithms for community detection in networks

walktrap.community

This algorithm finds densely connected subgraphs by performing random walks. The idea is that random walks will tend to stay inside communities instead of jumping to other communities.

Pascal Pons, Matthieu Latapy: Computing communities in large networks using random walks, http://arxiv.org/abs/physics/0512106

edge.betweenness.community

This algorithm is the Girvan-Newman algorithm. It is a divisive algorithm where at each step the edge with the highest betweenness is removed from the graph. For each division you can compute the modularity of the graph. At the end, choose to cut the dendrogram where the process gives you the highest value of modularity.

M Newman and M Girvan: Finding and evaluating community structure in networks, Physical Review E 69, 026113 (2004)

fastgreedy.community

This algorithm is the Clauset-Newman-Moore algorithm. In this case the algorithm is agglomerative. At each step two groups merge. The merging is decided by optimising modularity. This is a fast algorithm, but has the disadvantage of being a greedy algorithm. Thus, is might not produce the best overall community partitioning, although I find it useful and accurate.

A Clauset, MEJ Newman, C Moore: Finding community structure in very large networks, http://www.arxiv.org/abs/cond-mat/0408187

spinglass.community

This algorithm uses as spin-glass model and simulated annealing to find the communities inside a network.

J. Reichardt and S. Bornholdt: Statistical Mechanics of Community Detection, Phys. Rev. E, 74, 016110 (2006), http://arxiv.org/abs/cond-mat/0603718

M. E. J. Newman and M. Girvan: Finding and evaluating community structure in networks, Phys. Rev. E 69, 026113 (2004)

An example:
```R
# First we load the ipgrah package
library(igraph)
 
# let's generate two networks and merge them into one graph.
g2 <- barabasi.game(50, p=2, directed=F)
g1 <- watts.strogatz.game(1, size=100, nei=5, p=0.05)
g <- graph.union(g1,g2)
 
# let's remove multi-edges and loops
g <- simplify(g)
 
# let's see if we have communities here using the 
# Grivan-Newman algorithm
# 1st we calculate the edge betweenness, merges, etc...
ebc <- edge.betweenness.community(g, directed=F)
 
# Now we have the merges/splits and we need to calculate the modularity
# for each merge for this we'll use a function that for each edge
# removed will create a second graph, check for its membership and use
# that membership to calculate the modularity
mods <- sapply(0:ecount(g), function(i){
  g2 <- delete.edges(g, ebc$removed.edges[seq(length=i)])
  cl <- clusters(g2)$membership
# March 13, 2014 - compute modularity on the original graph g 
# (Thank you to Augustin Luna for detecting this typo) and not on the induced one g2. 
  modularity(g,cl)
})
 
# we can now plot all modularities
plot(mods, pch=20)
 
# Now, let's color the nodes according to their membership
g2<-delete.edges(g, ebc$removed.edges[seq(length=which.max(mods)-1)])
V(g)$color=clusters(g2)$membership
 
# Let's choose a layout for the graph
g$layout <- layout.fruchterman.reingold
 
# plot it
plot(g, vertex.label=NA)
 
# if we wanted to use the fastgreedy.community agorithm we would do
fc <- fastgreedy.community(g)
com<-community.to.membership(g, fc$merges, steps= which.max(fc$modularity)-1)
V(g)$color <- com$membership+1
g$layout <- layout.fruchterman.reingold
plot(g, vertex.label=NA)
```
try it!