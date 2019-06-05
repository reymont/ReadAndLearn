#%%
# BA network
import networkx as nx
G = nx.barabasi_albert_graph(100,4)
nx.draw_spring(G)

#%%
# 平均聚类系数
sum(nx.clustering(G, nodes=list(G.nodes())).values())/len(G.nodes())
#%%
# 平均最短路
sum(nx.shortest_path(G))/len(G.nodes())
#%%
