#%%
import networkx as nx
G = nx.barbell_graph(10,5)
nx.draw_spring(G)

#%%
nx.shortest_path(G, source=0, target=24)

#%%
