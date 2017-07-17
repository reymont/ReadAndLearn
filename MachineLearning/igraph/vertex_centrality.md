#节点中心性

节点中心性度量有：节点度中心性、接近中心性、介数中心性以及特征向量中心性

##节点度中心性

在一个网络图G=(V,E)中，节点v的度 $d_v$指的是与v相连的E中边的数量。

##接近中心性（closeness centrality）
如果一个节点与许多其他节点都很”接近“，那么节点处于网络中心位置（central）。

某节点到其他所有节点距离之和的倒数：
$$C_{cl}(v)=\frac{1}{\sum_{k \varepsilon V}dist(v,u)}$$

##介数中心性（betweenness centrality）
度量试图概括的是某个节点在多大程度上“介于”（between）其他节点对之间。节点的“重要性”与其再网络路径中的位置有关。
$$C_{B}(v)=\sum_{s\ne t\ne v \varepsilon{V}} \frac{\sigma(s,t|v)}{\sigma(s,t)}$$
$\sigma(s,t|v)$是s与t之间通过v的最短路径数量，而$\sigma(s,t)$是s与t之间（无论是否通过v）的最短路径总数。

##特征向量中心性
基于节点的特征，例如“状态”、“声望”或者“排名”等，用线性代数中特征向量形式表示。

#参考

1. Kolaczyk E D. Statistical Analysis of Network Data[M]. Springer New York, 2009.
2. [Kolaczyk, E. D. & Csárdi, G. Statistical Analysis of Network Data with R (Springer, 2014)](https://link.springer.com/book/10.1007%2F978-1-4939-0983-4)