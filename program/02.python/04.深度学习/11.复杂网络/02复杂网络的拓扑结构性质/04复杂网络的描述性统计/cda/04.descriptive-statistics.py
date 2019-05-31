#%%
# descriptive statistics
# assortative coefficient
import matplotlib.pyplot as plt
import networkx as nx

G = nx.lollipop_graph(4, 6)
nx.draw(G, with_labels=True)
plt.show()

pathlengths = []

print("source vertex {target:length}")
for v in G.nodes():
    spl = nx.shortest_path_length(G, v)
    print('{} {} '.format(v, spl))
    for p in spl:
        pathlengths.append(spl[p])
# pathlengths


#%%
print("average shortest path length %s" % (sum(pathlengths) / len(pathlengths)))
# histogram of path lengths
dist = {}
for p in pathlengths:
    if p in dist:
        dist[p] += 1
    else:
        dist[p] = 1

print('')
print("length #paths")
verts = dist.keys()
for d in sorted(verts):
    # print('%s %d' % (d, dist[d]))
    print('{} {}'.format(d, dist[d]))

# print('{}'.format(nx.radius(G)))
print("eccentricity: %s" % nx.eccentricity(G))
print("radius: %d" % nx.radius(G))
print("diameter: %d" % nx.diameter(G))
print("center: %s" % nx.center(G))
print("periphery: %s" % nx.periphery(G))
print("density: %s" % nx.density(G))