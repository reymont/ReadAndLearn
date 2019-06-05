#%%
# https://networkx.github.io/documentation/networkx-2.0/auto_examples/graph/plot_karate_club.html
import matplotlib.pyplot as plt
import networkx as nx

G = nx.karate_club_graph()
print("Node Degree")
for v in G:
    print('%s %s' % (v, G.degree(v)))

nx.draw_circular(G, with_labels=True)
plt.show()

#%%
import networkx as nx
import numpy as np
import community

G = nx.karate_club_graph()
partition = community.best_partition(G)
print(partition)
print("Louvain Modularity: ", community.modularity(partition, G))

#%%
preds = nx.jaccard_coefficient(G)
for u, v, p in preds:
    print('(%d, %d) -> %.8f' % (u, v, p))

#%%
list(nx.k_shell(G, k = 2))
#%%
