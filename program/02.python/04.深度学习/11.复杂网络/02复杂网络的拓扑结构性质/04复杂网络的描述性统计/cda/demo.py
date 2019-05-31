#%% Change working directory from the workspace root to the ipynb file location. Turn this addition off with the DataScience.changeDirOnImportExport setting
# ms-python.python added
import os
try:
	os.chdir(os.path.join(os.getcwd(), 'program\\02.python\04.深度学习\11.复杂网络\02复杂网络的拓扑结构性质'))
	print(os.getcwd())
except:
	pass

#%%
import numpy as np
import networkx as nx
a1 = np.array([0,2,5,4,0,0,0])
a2 = np.array([2,0,2,0,7,0,0])
a3 = np.array([5,2,0,1,4,3,0])
a4 = np.array([4,0,1,0,0,4,0]) 
a5 = np.array([0,7,4,0,0,1,5])
a6 = np.array([0,0,3,4,1,0,7])
a7 = np.array([0,0,0,0,5,7,0])
a = np.vstack((a1,a2,a3,a4,a5,a6,a7))
a


#%%
network1 = nx.from_numpy_matrix(a)
mst = nx.minimum_spanning_tree(network1)
nx.draw_networkx(mst)


#%%
b = nx.to_numpy_matrix(mst)
b


#%%
mst2 = nx.minimum_spanning_edges(network1)
mst3 = list(mst2)
mst3[0][2]['weight']


#%%
mst3


#%%
# shortest path
shortest1 = nx.shortest_path(network1, source=0, target=6)
shortest1


#%%
shortest2 = nx.shortest_path(network1, source=0, target=6, weight = 'weight')
shortest2


#%%
shortest3 = nx.shortest_path(network1, source=0, weight='weight')
shortest3


#%%
shortest3[6]


#%%
shortest4 = nx.shortest_path(network1, weight='weight')
shortest4


#%%
shortest4[0][6]


#%%
# max flow
import numpy as np
import networkx as nx
a1 = np.array([0,10,0,0,5,0,15,0])
a2 = np.array([0,0,9,0,4,15,0,0])
a3 = np.array([0,0,0,10,0,15,0,0])
a4 = np.array([0,0,0,0,0,0,0,0])
a5 = np.array([0,0,0,0,0,8,4,0])
a6 = np.array([0,0,0,10,0,0,0,15])
a7 = np.array([0,0,0,0,0,0,0,16])
a8 = np.array([0,0,0,10,6,0,0,0])
a = np.vstack((a1,a2,a3,a4,a5,a6,a7,a8))
network1 = nx.from_numpy_matrix(a)


#%%
network1.is_directed()


#%%
nx.to_numpy_matrix(network1)


#%%
network1 = nx.DiGraph(a)
flowcost, flow = nx.maximum_flow(network1, _s = 0, _t = 3, capacity='weight')
flowcost


#%%
flow


#%%
flow3 = nx.minimum_cut(network1, _s=0, _t=3, capacity='weight')
flow3


#%%
flow4 = nx.minimum_cut_value(network1, _s=0, _t=3, capacity='weight')
flow4


#%%
# minimum cost flow problem
import networkx as nx
G = nx.DiGraph()
G.add_node('vs', demand = -10)
G.add_node('vt', demand = 10)
G.add_edge('vs','v1',weight = 4, capacity = 10)
G.add_edge('vs','v2',weight = 1, capacity = 8)
G.add_edge('v2','v1',weight = 2, capacity = 5)
G.add_edge('v2','v3',weight = 3, capacity = 10)
G.add_edge('v1','v3',weight = 6, capacity = 2)
G.add_edge('v3','vt',weight = 2, capacity = 4)
G.add_edge('v1','vt',weight = 1, capacity = 7)
flowCost, flowDict = nx.capacity_scaling(G)
#flowCost
flowDict



#%%
# degree distribution
get_ipython().run_line_magic('run', 'plot_degree_distribution.py')


#%%
# clustering coefficient
import networkx as nx
G = nx.complete_graph(5)
# nx.clustering(G, nodes=list(G.nodes())[1])
nx.clustering(G)


#%%
# clustering coefficient
G = nx.grid_2d_graph(5, 5)
nx.draw(G, with_labels=True)
nx.clustering(G, nodes=list(G.nodes())[1])


#%%
get_ipython().run_line_magic('run', 'plot_degree_distribution.py')
# len(G.nodes())
sum(nx.clustering(G, nodes=list(G.nodes())).values())/len(G.nodes())


#%%
# ER network
import networkx as nx
nx.draw(nx.fast_gnp_random_graph(100,0.05))


#%%
# robustness
# create a graph with degrees following a power law distribution
import networkx as nx
import random
import numpy as np
import matplotlib.pyplot as plt

s = nx.utils.powerlaw_sequence(1000, 2) #1000 nodes, power-law exponent 2
G = nx.expected_degree_graph(s, selfloops=False)
ListOfNodes = G.nodes()
# NumberofNodes = G.number_of_nodes()

largest_cc = np.zeros(40)
index = 0
for iter in range(0,40):
    RandomSample = random.sample(ListOfNodes, 20)
    G.remove_nodes_from(RandomSample)
    tmp = max(nx.connected_components(G), key = len)
    largest_cc[index] = len(tmp)/1000
    ListOfNodes = G.nodes()
    # NumberofNodes = G.number_of_nodes()
    index +=1

G = nx.expected_degree_graph(s, selfloops=False)
tmp2 = nx.degree_centrality(G)
OrderNodes = np.argsort(-np.asarray(list(tmp2.values())))
largest_cc2 = np.zeros(40)
index2 = 0
for iter2 in range(0,800,20):
    G.remove_nodes_from(OrderNodes[0:iter2])
    tmp3 = max(nx.connected_components(G), key = len)
    largest_cc2[index2] = len(tmp3)/1000
    index2 +=1
    G = nx.expected_degree_graph(s, selfloops=False)
    
fig = plt.figure ()
ax = fig.add_subplot (121)
ax.scatter(np.array(range(len(largest_cc)))+1, largest_cc)
ax2 = fig.add_subplot (122)
ax2.scatter(np.array(range(len(largest_cc2)))+1, largest_cc2)


#%%
# assortative coefficient 
import networkx as nx
G = nx.fast_gnp_random_graph(100,0.05)
r = nx.degree_assortativity_coefficient(G)
print("%3.1f"%r)


#%%
# node centrality 
import networkx as nx
import numpy as np
import networkx as nx
a1 = np.array([0,0,1,0,0,0,0])
a2 = np.array([0,0,1,0,0,0,0])
a3 = np.array([1,1,0,1,0,0,0])
a4 = np.array([0,0,1,0,1,0,0]) 
a5 = np.array([0,0,0,1,0,1,1])
a6 = np.array([0,0,0,0,1,0,1])
a7 = np.array([0,0,0,0,1,1,0])
a = np.vstack((a1,a2,a3,a4,a5,a6,a7))
network1 = nx.from_numpy_matrix(a)
nx.draw_networkx(network1)


#%%
nx.degree_centrality(network1)


#%%
nx.closeness_centrality(network1)


#%%
nx.betweenness_centrality(network1)


#%%
nx.pagerank(network1)


#%%
list(nx.k_shell(network1, k = 1))


#%%
list(nx.k_shell(network1, k = 2))


#%%
list(nx.k_shell(network1, k = 3))


#%%
# community detection
# python setup.py install
# cmd: pip install -U python-louvain
import networkx as nx
import numpy as np
import community
N = 16
G = [[0] * N for _ in range(16)]

def addEdge(G, v1 ,v2):
  G[v1][v2] = G[v2][v1] = 1
  
  
addEdge(G, 0, 2)
addEdge(G, 0, 3)
addEdge(G, 0, 4)
addEdge(G, 0, 5)
addEdge(G, 1, 2)
addEdge(G, 1, 4)
addEdge(G, 1, 7)
addEdge(G, 2, 4)
addEdge(G, 2, 5)
addEdge(G, 2, 6)
addEdge(G, 3, 7)
addEdge(G, 4, 10)
addEdge(G, 5, 7)
addEdge(G, 5, 11)
addEdge(G, 6, 7)
addEdge(G, 6, 11)
addEdge(G, 8, 9)
addEdge(G, 8, 10)
addEdge(G, 8, 11)
addEdge(G, 8, 14)
addEdge(G, 8, 15)
addEdge(G, 9, 12)
addEdge(G, 9, 14)
addEdge(G, 10, 11)
addEdge(G, 10, 12)
addEdge(G, 10, 13)
addEdge(G, 10, 14)
addEdge(G, 11, 13)
G = np.asarray(G)
network1 = nx.from_numpy_matrix(G)
partition = community.best_partition(network1)
print(partition)
print("Louvain Modularity: ", community.modularity(partition, network1))


#%%
import numpy as np
import networkx as nx
from networkx.algorithms.community import k_clique_communities

N = 9
G = [[0] * N for _ in range(9)]

def addEdge(G, v1 ,v2):
  G[v1][v2] = G[v2][v1] = 1
  
addEdge(G, 0, 1)
addEdge(G, 0, 2)
addEdge(G, 0, 3)
addEdge(G, 1, 2)
addEdge(G, 2, 3)
addEdge(G, 3, 4)
addEdge(G, 3, 5)
addEdge(G, 4, 5)
addEdge(G, 4, 6)
addEdge(G, 4, 7)
addEdge(G, 5, 6)
addEdge(G, 5, 7)
addEdge(G, 6, 7)
addEdge(G, 6, 8)
G = np.asarray(G)
network1 = nx.from_numpy_matrix(G)
partition = k_clique_communities(network1,3)
partition = list(partition)
# list(partition[0])
list(partition[1])


#%%
# link prediction
import networkx as nx
G = nx.complete_graph(5)
preds = nx.jaccard_coefficient(G, [(0, 1), (2, 3)])
for u, v, p in preds:
    print('(%d, %d) -> %.8f' % (u, v, p))


#%%
G = nx.complete_graph(5)
preds = nx.resource_allocation_index(G, [(0, 1), (2, 3)])
for u, v, p in preds:
    print('(%d, %d) -> %.8f' % (u, v, p))


#%%
import networkx as nx
G = nx.path_graph(3)
nx.draw_networkx(G)
G.node[0]['community'] = 0
G.node[1]['community'] = 0
G.node[2]['community'] = 0
preds = nx.cn_soundarajan_hopcroft(G, [(0, 2)])
for u, v, p in preds:
    print('(%d, %d) -> %d' % (u, v, p))


#%%
import networkx as nx
G = nx.Graph()
G.add_edges_from([(0, 1), (0, 2), (1, 3), (2, 3)])
G.node[0]['community'] = 0
G.node[1]['community'] = 0
G.node[2]['community'] = 1
G.node[3]['community'] = 0
nx.draw_networkx(G)
preds = nx.ra_index_soundarajan_hopcroft(G, [(0, 3)])
for u, v, p in preds:
    print('(%d, %d) -> %.8f' % (u, v, p))


#%%
# ER network
import networkx as nx
nx.draw(nx.fast_gnp_random_graph(100,0.05))


#%%
# WS small world network
import networkx as nx
nx.draw_spring(nx.watts_strogatz_graph(10,4,0))


#%%
# newmann ws small world network
nx.draw_spring(nx.newman_watts_strogatz_graph(100,4, 0.5))


#%%
# BA network
import networkx as nx
nx.draw_spring(nx.barabasi_albert_graph(100,4))


#%%
from networkx.algorithms.community import LFR_benchmark_graph
import numpy as np
import networkx as nx
import matplotlib.pyplot as plt
from matplotlib.colors import rgb2hex
n = 250
tau1 = 3
tau2 = 1.5
mu = 0.05
G = LFR_benchmark_graph(n, tau1, tau2, mu, average_degree=5,
                        min_community=20, seed=10)
communities = {frozenset(G.nodes[v]['community']) for v in G}
communities = list(communities)
comm1 = dict.fromkeys(communities[0],1)
comm2 = dict.fromkeys(communities[1],2)
comm3 = dict.fromkeys(communities[2],3)
comm3
comm1.update(comm2)
comm1.update(comm3)
tmp = sorted(comm1.items(), key = lambda e:e[0])
labels = [item[1] for item in tmp] 

k = max(labels)
cmap = plt.cm.gist_rainbow
color = [cmap(np.sqrt(s/k))[:3] for s in labels]
color = [rgb2hex(s) for s in color]
plt.figure(figsize=(5,5))
layout = nx.spring_layout(G)
nx.draw_networkx(G, layout = layout, 
                 with_labels = False, 
                 node_size = 10,
                 alpha = 0.6,
                 width = 0.2,
                 node_color = color)
plt.show()


#%%
import networkx as nx
import ndlib.models.ModelConfig as mc
import ndlib.models.epidemics.SIModel as si

# Network topology
g = nx.erdos_renyi_graph(1000, 0.1)

# Model selection
model = si.SIModel(g)

# Model Configuration
cfg = mc.Configuration()
cfg.add_model_parameter('beta', 0.01)
cfg.add_model_parameter("percentage_infected", 0.05)
model.set_initial_status(cfg)

# Simulation execution
iterations = model.iteration_bunch(200)
trends = model.build_trends(iterations)
from bokeh.io import output_notebook, show
from ndlib.viz.bokeh.DiffusionTrend import DiffusionTrend
viz1 = DiffusionTrend(model, trends)
p = viz1.plot(width=400, height=400)
# show(p)
print(viz1)
from ndlib.viz.bokeh.DiffusionPrevalence import DiffusionPrevalence
viz2 = DiffusionPrevalence(model, trends)
p2 = viz2.plot(width=400, height=400)
from ndlib.viz.bokeh.MultiPlot import MultiPlot
vm1 = MultiPlot()
vm1.add_plot(p)
vm1.add_plot(p2)
m = None
m = vm1.plot()
show(m)


#%%
# pip install ndlib
import networkx as nx
import ndlib.models.epidemics.SIRModel as sir
# Network Definition
g = nx.erdos_renyi_graph(1000, 0.1)
# Model Selection
model = sir.SIRModel(g)
import ndlib.models.ModelConfig as mc
# Model Configuration
config = mc.Configuration()
config.add_model_parameter('beta', 0.001)
config.add_model_parameter('gamma', 0.01)
config.add_model_parameter("percentage_infected", 0.05)
model.set_initial_status(config)
# Simulation
iterations = model.iteration_bunch(200)
trends = model.build_trends(iterations)
from bokeh.io import output_notebook, show
from ndlib.viz.bokeh.DiffusionTrend import DiffusionTrend
viz = DiffusionTrend(model, trends)
p = viz.plot(width=400, height=400)
# show(p)
from ndlib.viz.bokeh.DiffusionPrevalence import DiffusionPrevalence
viz2 = DiffusionPrevalence(model, trends)
p2 = viz2.plot(width=400, height=400)
# show(p2)
from ndlib.viz.bokeh.MultiPlot import MultiPlot
vm = MultiPlot()
vm.add_plot(p)
vm.add_plot(p2)
m = vm.plot()
show(m)


