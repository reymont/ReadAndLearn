#%%
# http://snap.stanford.edu/data/facebook_combined.txt.gz


import numpy as np
import networkx as nx
from matplotlib.colors import rgb2hex
G = nx.Graph()
cwd = r"program\\02.python\\04.深度学习\\11.复杂网络\\02复杂网络的拓扑结构性质\\06聚类系数\\"
for s in open(cwd+'facebook_combined.txt').readlines():
    s = s.strip()
    s = s.split()
    G.add_edge(int(s[0]),int(s[1]))

#%%
# nx.clustering(G)
# 求该网络点的聚类系数的平均值
sum(nx.clustering(G, nodes=list(G.nodes())).values())/len(G.nodes())
#%%
# help(nx.Graph().degree())
print (len(G.nodes))
# print ("degree", G.degree())
# 统计所有的度
print ("all_degree", sum(span for n, span in G.degree()))
print ("avg_degree", sum(span for n, span in G.degree())/len(G.nodes()))
# 从1加到4039
# print ("degree", sum(n for n in range(1,len(G.nodes))))
# print (dir(G.degree()))
# 连边的数量
print ("size", G.size())
# 定理1 无向图中所有顶点的度之和等于边数的2倍，
# 有向图中所有顶点的入度之和等于所有顶点的出度之和。
print (176468/2 ==  G.size())
# n个端点的完全图有n个端点以及n(n − 1) / 2条边
print (len(G.nodes) * (len(G.nodes)-1)/2)
print (G.size()/(len(G.nodes) * (len(G.nodes)-1)/2))
#%%
help(nx.fast_gnp_random_graph)
#%%
# ER network
import networkx as nx
# nx.draw(nx.fast_gnp_random_graph(100,0.05))
ERG = nx.fast_gnp_random_graph(len(G.nodes),0.010819963503439287)
# 求该网络点的聚类系数的平均值
print (sum(nx.clustering(ERG, nodes=list(ERG.nodes())).values())/len(ERG.nodes()))
#%%
# clustering coefficient
G = nx.complete_graph(5)
# nx.clustering(G, nodes=list(G.nodes())[1])
nx.clustering(G)

#%%
# clustering coefficient
G = nx.grid_2d_graph(5, 5)
nx.draw(G, with_labels=True)
nx.clustering(G, nodes=list(G.nodes())[1])

#%%
# robustness
# create a graph with degrees following a power law distribution
import networkx as nx
import random
import numpy as np
import matplotlib.pyplot as plt

s = nx.utils.powerlaw_sequence(1000, 2) #1000 nodes, power-law exponent 2
G = nx.expected_degree_graph(s, selfloops=False)
# NumberofNodes = G.number_of_nodes()

#%%

G = nx.Graph()
cwd = r"program\\02.python\\04.深度学习\\11.复杂网络\\02复杂网络的拓扑结构性质\\06聚类系数\\"
for s in open(cwd+'facebook_combined.txt').readlines():
    s = s.strip()
    s = s.split()
    G.add_edge(int(s[0]),int(s[1]))

ListOfNodes = G.nodes()
largest_cc = np.zeros(202)
index = 0
for iter in range(0,int(4020/20)):
    # print (len(G.nodes()))
    RandomSample = random.sample(ListOfNodes, 20)
    G.remove_nodes_from(RandomSample)
    tmp = max(nx.connected_components(G), key = len)
    largest_cc[index] = len(tmp)/1000
    ListOfNodes = G.nodes()
    # NumberofNodes = G.number_of_nodes()
    index +=1

# G = nx.expected_degree_graph(s, selfloops=False)
G = nx.Graph()
cwd = r"program\\02.python\\04.深度学习\\11.复杂网络\\02复杂网络的拓扑结构性质\\06聚类系数\\"
for s in open(cwd+'facebook_combined.txt').readlines():
    s = s.strip()
    s = s.split()
    G.add_edge(int(s[0]),int(s[1]))
tmp2 = nx.degree_centrality(G)
OrderNodes = np.argsort(-np.asarray(list(tmp2.values())))
largest_cc2 = np.zeros(40)
index2 = 0
for iter2 in range(0,4020,20):
    G.remove_nodes_from(OrderNodes[0:iter2])
    tmp3 = max(nx.connected_components(G), key = len)
    largest_cc2[index2] = len(tmp3)/1000
    index2 +=1
    # G = nx.expected_degree_graph(s, selfloops=False)

fig = plt.figure ()
ax = fig.add_subplot (121)
ax.scatter(np.array(range(len(largest_cc)))+1, largest_cc)
ax2 = fig.add_subplot (122)
ax2.scatter(np.array(range(len(largest_cc2)))+1, largest_cc2)

#%%
