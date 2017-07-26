import networkx as nx
G=nx.Graph()
G.add_node(1)
G.add_nodes_from([2,3])
H=nx.path_graph(10)
G.add_nodes_from(H)
G.add_node(H)

G.add_edge(1,2)
e=(2,3)
G.add_edge(*e) # unpack edge tuple*
G.add_edges_from([(1,2),(1,3)])
G.add_edges_from(H.edges())

FG=nx.Graph()
FG.add_weighted_edges_from([(1,2,0.125),(1,3,0.75),(2,4,1.2),(3,4,0.375)])
for n,nbrs in FG.adjacency_iter():
    for nbr,eattr in nbrs.items():
        data=eattr['weight']
        if data<0.5: print('(%d, %d, %.3f)' % (n,nbr,data))

for (u,v,d) in FG.edges(data='weight'):
     if d<0.5: print('(%d, %d, %.3f)'%(n,nbr,d))

import matplotlib.pyplot as plt