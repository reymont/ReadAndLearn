


* [Creating a graph — NetworkX 1.11 documentation ](https://networkx.readthedocs.io/en/stable/tutorial/tutorial.html)

```py
import networkx as nx
G=nx.Graph()
G.add_edges_from([(1,2),(1,3)])
G.add_node("spam")       # adds node "spam"
nx.connected_components(G)
sorted(nx.degree(G).values())
nx.clustering(G)
nx.degree(G)
nx.degree(G,1)
G.degree(1)
G.degree([1,2])
sorted(G.degree([1,2]).values())
sorted(G.degree().values())
import matplotlib.pyplot as plt
nx.draw(G)
nx.draw_random(G)
nx.draw_circular(G)
nx.draw_spectral(G)
plt.show()
nx.draw(G)
plt.savefig("path.png")
```