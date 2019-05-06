

* [simplify | igraph R manual pages ](http://igraph.org/r/doc/simplify.html)

# Simple graphs
## Description
Simple graphs are graphs which do not contain loop and multiple edges.

## Usage
```r
simplify(graph, remove.multiple = TRUE, remove.loops = TRUE,
  edge.attr.comb = igraph_opt("edge.attr.comb"))

is_simple(graph)
```

## Arguments

|Name|Remark|
|-|-|
|graph|	The graph to work on.|
|remove.multiple|	Logical, whether the multiple edges are to be removed.|
|remove.loops	|Logical, whether the loop edges are to be removed.|
|edge.attr.comb	|Specifies what to do with edge attributes, if remove.multiple=TRUE. In this case many edges might be mapped to a single one in the new graph, and their attributes are combined. Please see attribute.combination for details on this.|

## Details
A loop edge is an edge for which the two endpoints are the same vertex. Two edges are multiple edges if they have exactly the same two endpoints (for directed graphs order does matter). A graph is simple is it does not contain loop edges and multiple edges.

is_simple checks whether a graph is simple.

simplify removes the loop and/or multiple edges from a graph. If both remove.loops and remove.multiple are TRUE the function returns a simple graph.

## Value
A new graph object with the edges deleted.

## Author(s)
Gabor Csardi csardi.gabor@gmail.com

## See Also
which_loop, which_multiple and count_multiple, delete_edges, delete_vertices

## Examples

```r
g <- graph( c(1,2,1,2,3,3) )
is_simple(g)
is_simple(simplify(g, remove.loops=FALSE))
is_simple(simplify(g, remove.multiple=FALSE))
is_simple(simplify(g))
```