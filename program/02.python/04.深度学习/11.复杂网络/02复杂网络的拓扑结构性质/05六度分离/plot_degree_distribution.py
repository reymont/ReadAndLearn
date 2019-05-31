import networkx as nx
def plot_degree_distribution (graph):
  degs = {}
  for n in graph.nodes ():
    deg = graph.degree(n)
    if deg not in degs:
      degs [deg] = 0
    degs [deg] += 1
  # items = sorted(degs.items())
  items = degs.items()
  # print(degs)
  fig = plt.figure ()
  ax = fig.add_subplot (111)
  ax.scatter([k for (k, v) in items] , [v for (k,
  v) in items])
  ax.set_xscale ('log')
  ax.set_yscale ('log')
  ax.set_xlim(1e0, 1e2)
  ax.set_ylim(1e0, 1e4)
  plt.title ("Degree Distribution")
  fig.savefig ("degree_distribution.png")
  
import networkx as nx
import matplotlib.pyplot as plt

#create a graph with degrees following a power law distribution
s = nx.utils.powerlaw_sequence(1000, 2.5) #10000 nodes, power-law exponent 2
G = nx.expected_degree_graph(s, selfloops=False)

# print(G.nodes())
# print(G.edges())

#draw and show graph
# pos = nx.spring_layout(G)
# nx.draw_networkx(G, pos)
# plt.show()

plot_degree_distribution (G)



