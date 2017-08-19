


* [igraph R manual pages ](http://igraph.org/r/doc/as_ids.html)


Convert a vertex or edge sequence to an ordinary vector
Description
Convert a vertex or edge sequence to an ordinary vector

Usage
```r
as_ids(seq)

## S3 method for class 'igraph.vs'
as_ids(seq)

## S3 method for class 'igraph.es'
as_ids(seq)
```
Arguments
seq	
The vertex or edge sequence.

Details
For graphs without names, a numeric vector is returned, containing the internal numeric vertex or edge ids.

For graphs with names, and vertex sequences, the vertex names are returned in a character vector.

For graphs with names and edge sequences, a character vector is returned, with the ‘bar’ notation: a|b means an edge from vertex a to vertex b.

Value
A character or numeric vector, see details below.

Examples
```r
g <- make_ring(10)
as_ids(V(g))
as_ids(E(g))

V(g)$name <- letters[1:10]
as_ids(V(g))
as_ids(E(g))
```