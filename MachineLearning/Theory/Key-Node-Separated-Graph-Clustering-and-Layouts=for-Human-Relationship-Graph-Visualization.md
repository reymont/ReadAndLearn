#Cluster Layout
The presented technique then generates a cluster graph, consisting of vertices corresponding to the clusters of nodes, and bundles corresponding to sets of edges connecting two nodes belonging to two different clusters. Bundles are weighted according to the number of edges.
然后，所呈现的技术生成一个集群图，其中包含对应于节点集群的顶点，以及对应于连接两个不同集群的两个节点的边集。包根据边的数量来加权

We denote the cluster graph as

CG = {V, B}
V = {v1, ...}
B = {b1, ...}
vi = {ni1, ...}
bi = {ei1, ...} , (5)

CG是群集图，V是顶点的集合，B是b边的集合。一个顶点$v_{i}$包含属于与vi对应的集群的一组节点$n_{ij}$，而一个包$b_{i}$由一组边缘$e_{ij}$组成，它们连接了属于同一对集群的节点的节点对。