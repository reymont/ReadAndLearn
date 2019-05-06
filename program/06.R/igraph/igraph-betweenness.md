

* [igraph R manual pages ](http://igraph.org/r/doc/betweenness.html)

Vertex and edge betweenness centrality
Description
The vertex and edge betweenness are (roughly) defined by the number of geodesics (shortest paths) going through a vertex or an edge.

Usage
estimate_betweenness(graph, vids = V(graph), directed = TRUE, cutoff,
  weights = NULL, nobigint = TRUE)

betweenness(graph, v = V(graph), directed = TRUE, weights = NULL,
  nobigint = TRUE, normalized = FALSE)

edge_betweenness(graph, e = E(graph), directed = TRUE, weights = NULL)
Arguments
graph	
The graph to analyze.

vids	
The vertices for which the vertex betweenness estimation will be calculated.

directed	
Logical, whether directed paths should be considered while determining the shortest paths.

cutoff	
The maximum path length to consider when calculating the betweenness. If zero or negative then there is no such limit.

weights	
Optional positive weight vector for calculating weighted betweenness. If the graph has a weight edge attribute, then this is used by default.

nobigint	
Logical scalar, whether to use big integers during the calculation. This is only required for lattice-like graphs that have very many shortest paths between a pair of vertices. If TRUE (the default), then big integers are not used.

v	
The vertices for which the vertex betweenness will be calculated.

normalized	
Logical scalar, whether to normalize the betweenness scores. If TRUE, then the results are normalized according to

Bnorm=2*B/(n*n-3*n+2)

, where Bnorm is the normalized, B the raw betweenness, and n is the number of vertices in the graph.

e	
The edges for which the edge betweenness will be calculated.

Details
The vertex betweenness of vertex \code{v} is defined by

sum( g_ivj / g_ij, i!=j,i!=v,j!=v)

The edge betweenness of edge \code{e} is defined by

sum( g_iej / g_ij, i!=j).

betweenness calculates vertex betweenness, edge_betweenness calculates edge betweenness.

estimate_betweenness only considers paths of length cutoff or smaller, this can be run for larger graphs, as the running time is not quadratic (if cutoff is small). If cutoff is zero or negative then the function calculates the exact betweenness scores.

estimate_edge_betweenness is similar, but for edges.

For calculating the betweenness a similar algorithm to the one proposed by Brandes (see References) is used.

Value
A numeric vector with the betweenness score for each vertex in v for betweenness.

A numeric vector with the edge betweenness score for each edge in e for edge_betweenness.

estimate_betweenness returns the estimated betweenness scores for vertices in vids, estimate_edge_betweenness the estimated edge betweenness score for all edges; both in a numeric vector.

Note
edge_betweenness might give false values for graphs with multiple edges.

Author(s)
Gabor Csardi csardi.gabor@gmail.com

References
Freeman, L.C. (1979). Centrality in Social Networks I: Conceptual Clarification. Social Networks, 1, 215-239.

Ulrik Brandes, A Faster Algorithm for Betweenness Centrality. Journal of Mathematical Sociology 25(2):163-177, 2001.

See Also
closeness, degree

Examples
g <- sample_gnp(10, 3/10)
betweenness(g)
edge_betweenness(g)