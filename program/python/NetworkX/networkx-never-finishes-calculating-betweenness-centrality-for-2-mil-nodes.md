
* [python - Networkx never finishes calculating Betweenness centrality for 2 mil nodes - Stack Overflow ](https://stackoverflow.com/questions/32465503/networkx-never-finishes-calculating-betweenness-centrality-for-2-mil-nodes)

`摘要(TL/DR)Too Long; Didn't Read`：`中介中心性(Betweenness centrality)`是一个非常慢的算法，所以你可能希望使用近似的度量，比如考虑myk节点子集。myk是比网络中的节点数要小的数。这个数要足够大，以保证具有统计学意义。（networkx函数有个参数实现了这个功能：`betweenness_centrality(G, k=myk)`）。

---

I'm not at all surprised it's taking a long time. Betweenness centrality is a slow calculation. The algorithm used by networkx is O(VE) where V is the number of vertices and E the number of edges. In your case VE = 10^13. I expect importing the graph to take O(V+E) time, so if that is taking long enough that you can tell it's not instantaneous, then O(VE) is going to be painful.

If a reduced network with 1% of the nodes and 1% of the edges (so 20,000 nodes and 50,000 edges) would take time X, then your desired calculation would take take 10000X. If X is one second, then the new calculation is close to 3 hours, which I think is incredibly optimistic (see my test below). So before you decide there's something wrong with your code, run it on some smaller networks and get an estimate of what the run time should be for your network.

A good alternative is to use an approximate measure. The standard betweenness measure considers every single pair of nodes and the paths between them. Networkx offers an alternative which uses a random sample of just k nodes and then finds shortest paths between those k nodes and all other nodes in the network. I think this should give a speedup to run in O(kE) time

So what you would use is

betweenness_centrality(G, k=k)
If you want to have bounds on how accurate your result is, you could do several calls with a smallish value of k, make sure that they are relatively close and then take the average result.

---

Here's some of my quick testing of run time, with random graphs of (V,E)=(20,50); (200,500); and (2000,5000)



Here's some of my quick testing of run time, with random graphs of (V,E)=(20,50); (200,500); and (2000,5000)
```py
import time
for n in [20,200,2000]:
    G=nx.fast_gnp_random_graph(n, 5./n)
    current_time = time.time()
    a=nx.betweenness_centrality(G)
    print time.time()-current_time

>0.00247192382812
>0.133368968964
>15.5196769238
```
```py
import time
for n in [20,200,2000]:
    G=nx.fast_gnp_random_graph(n, 5./n)
    current_time = time.time()
    a=nx.betweenness_centrality(G,k=3)
    print time.time()-current_time

0.0019998550415
0.00299978256226
0.0260000228882
```
```py
import time
for n in [20,200,2000]:
    G=nx.fast_gnp_random_graph(n, 5./n)
    current_time = time.time()
    a=nx.betweenness_centrality(G,k=20)
    print time.time()-current_time

0.0019998550415
0.00299978256226
0.0260000228882
```

So on my computer it takes 15 seconds to handle a network that is 0.1% the size of yours. It would take about 15 million seconds to do a network the same size as yours. That's 1.5*10^7 seconds which is a little under half of pi*10^7 seconds. Since pi*10^7 seconds is an incredibly good approximation to the number of seconds in a year, this would take my computer about 6 months.

So you'll want to run with an approximate algorithm.