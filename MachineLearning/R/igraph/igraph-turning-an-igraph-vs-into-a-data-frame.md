

First, a couple of clarifying points. The object created by all_shortest_paths is a list with two elements: 1) res and 2) nrgeo. The res object is also a list--but a list of igraph.vs objects. The igraph.vs object is an igraph specific object known as a vertex sequence. Base R functions won't know what to do with it. So we use the as_id function to convert an igraph.vs object to a vector of ids.

Since PathsE$res is a list of igraph.vs objects, you need to iterate over the list and collapse it into a data frame. There are several ways to do this. Here is one:

```r
set.seed(6857)
g <- sample_smallworld(1, 100, 5, 0.05) #Building a random graph
sp <- all_shortest_paths(g, 5, 70)
mat <- sapply(sp$res, as_ids) 
#sapply iterates the function as_ids over all elements in the list sp$res and collapses it into a matrix
#This produces a matrix, but notice that it is the transpose of what you want:
> mat
     [,1] [,2] [,3] [,4]
[1,]    5    5    5    5
[2,]  100    4  100    1
[3,]   95   65   65   75
[4,]   70   70   70   70

#So, transpose it and convert to a data frame:

> df <- as.data.frame(t(mat))
  V1  V2 V3 V4
1  5 100 95 70
2  5   4 65 70
3  5 100 65 70
4  5   1 75 70
#Which we can do in a single line of code:

set.seed(6857)
g <- sample_smallworld(1, 100, 5, 0.05)
sp <- all_shortest_paths(g, 5, 70)
df <- as.dataframe(t(sapply(sp$res, as_ids)))
```